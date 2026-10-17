package com.foodbridge.service;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.EmailOtp;
import com.foodbridge.repository.OtpRepository;

/**
 * Email OTP: 6 digits from SecureRandom, stored only as a BCrypt hash, expires after a few
 * minutes, limited wrong guesses per code, resend cooldown and an hourly cap per email.
 */
@Service
public class OtpService {

    private final SecureRandom random = new SecureRandom();
    private final OtpRepository repo;
    private final MailService mail;
    private final PasswordEncoder encoder;
    private final int ttlMinutes;
    private final int maxAttempts;
    private final int cooldownSeconds;
    private final int maxPerHour;

    public OtpService(OtpRepository repo, MailService mail, PasswordEncoder encoder,
                      @Value("${app.otp.ttl-minutes:10}") int ttlMinutes,
                      @Value("${app.otp.max-attempts:5}") int maxAttempts,
                      @Value("${app.otp.resend-cooldown-seconds:60}") int cooldownSeconds,
                      @Value("${app.otp.max-per-hour:5}") int maxPerHour) {
        this.repo = repo;
        this.mail = mail;
        this.encoder = encoder;
        this.ttlMinutes = ttlMinutes;
        this.maxAttempts = maxAttempts;
        this.cooldownSeconds = cooldownSeconds;
        this.maxPerHour = maxPerHour;
    }

    /** Generates a code and emails it. If the email cannot be sent nothing is stored. */
    @Transactional
    public void send(String email, OtpPurpose purpose) {
        Optional<Integer> since = repo.secondsSinceLast(email, purpose.name());
        if (since.isPresent() && since.get() < cooldownSeconds) {
            throw new OtpException("Please wait " + (cooldownSeconds - since.get()) + " seconds before asking for another code.");
        }
        if (repo.countLastHour(email) >= maxPerHour) {
            throw new OtpException("Too many codes requested for this email. Please try again in an hour.");
        }
        String code = String.format("%06d", random.nextInt(1_000_000));
        repo.invalidateActive(email, purpose.name());
        repo.save(new EmailOtp(email, purpose.name(), encoder.encode(code), LocalDateTime.now().plusMinutes(ttlMinutes)));
        mail.sendOtp(email, code, purpose, ttlMinutes);   // throws OtpException -> the insert is rolled back
    }

    /** Succeeds silently or throws OtpException with a message that can be shown to the user. */
    @Transactional(noRollbackFor = OtpException.class)   // wrong guesses must still be counted
    public void verify(String email, OtpPurpose purpose, String code) {
        EmailOtp otp = repo.findActive(email, purpose.name())
            .orElseThrow(() -> new OtpException("That code has expired or was never requested. Please ask for a new one."));
        if (otp.getAttempts() >= maxAttempts) {
            otp.setConsumed(true);
            throw new OtpException("Too many wrong attempts. Please ask for a new code.");
        }
        boolean ok = code != null && code.matches("\\d{6}") && encoder.matches(code, otp.getOtpHash());
        if (!ok) {
            otp.setAttempts(otp.getAttempts() + 1);
            int left = maxAttempts - otp.getAttempts();
            if (left <= 0) {
                otp.setConsumed(true);
                throw new OtpException("Too many wrong attempts. Please ask for a new code.");
            }
            throw new OtpException("Incorrect code. " + left + (left == 1 ? " attempt" : " attempts") + " left.");
        }
        otp.setConsumed(true);
    }

    /** Seconds left before the newest code for this email expires (0 if none). */
    public int secondsUntilExpiry(String email, OtpPurpose purpose) {
        return repo.secondsSinceLast(email, purpose.name()).map(s -> Math.max(0, ttlMinutes * 60 - s)).orElse(0);
    }

    /** Seconds until another code may be requested (0 = now). */
    public int secondsUntilResend(String email, OtpPurpose purpose) {
        return repo.secondsSinceLast(email, purpose.name()).map(s -> Math.max(0, cooldownSeconds - s)).orElse(0);
    }

    @Scheduled(cron = "0 30 3 * * *")
    public void purgeOldCodes() {
        repo.deleteOlderThan(LocalDateTime.now().minusDays(2));
    }
}