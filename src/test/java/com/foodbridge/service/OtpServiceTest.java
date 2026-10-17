package com.foodbridge.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import com.foodbridge.model.EmailOtp;
import com.foodbridge.repository.OtpRepository;

class OtpServiceTest {

    private static final String EMAIL = "someone@example.com";

    private final OtpRepository repo = mock(OtpRepository.class);
    private final MailService mail = mock(MailService.class);
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(4);
    private final OtpService service = new OtpService(repo, mail, encoder, 10, 5, 60, 5);

    private EmailOtp activeCode(String code, int attempts) {
        EmailOtp otp = new EmailOtp(EMAIL, "REGISTER", encoder.encode(code), LocalDateTime.now().plusMinutes(10));
        otp.setAttempts(attempts);
        when(repo.findActive(EMAIL, "REGISTER")).thenReturn(Optional.of(otp));
        return otp;
    }

    @Test
    void correctCodeIsAcceptedAndUsedUp() {
        EmailOtp otp = activeCode("123456", 0);
        service.verify(EMAIL, OtpPurpose.REGISTER, "123456");
        assertTrue(otp.isConsumed());
    }

    @Test
    void wrongCodeCountsAsAnAttemptAndKeepsTheCodeAlive() {
        EmailOtp otp = activeCode("123456", 0);
        OtpException ex = assertThrows(OtpException.class, () -> service.verify(EMAIL, OtpPurpose.REGISTER, "000000"));
        assertTrue(ex.getMessage().contains("4 attempts left"));
        assertEquals(1, otp.getAttempts());
        assertFalse(otp.isConsumed());
    }

    @Test
    void fifthWrongGuessBurnsTheCode() {
        EmailOtp otp = activeCode("123456", 4);
        assertThrows(OtpException.class, () -> service.verify(EMAIL, OtpPurpose.REGISTER, "000000"));
        assertTrue(otp.isConsumed());
    }

    @Test
    void missingOrExpiredCodeIsRejected() {
        when(repo.findActive(EMAIL, "REGISTER")).thenReturn(Optional.empty());
        assertThrows(OtpException.class, () -> service.verify(EMAIL, OtpPurpose.REGISTER, "123456"));
    }

    @Test
    void nonNumericInputIsRejectedAndCounted() {
        EmailOtp otp = activeCode("123456", 0);
        assertThrows(OtpException.class, () -> service.verify(EMAIL, OtpPurpose.REGISTER, "12ab56"));
        assertEquals(1, otp.getAttempts());
    }

    @Test
    void resendIsBlockedDuringCooldown() {
        when(repo.secondsSinceLast(EMAIL, "REGISTER")).thenReturn(Optional.of(10));
        assertThrows(OtpException.class, () -> service.send(EMAIL, OtpPurpose.REGISTER));
        verify(mail, never()).sendOtp(anyString(), anyString(), eq(OtpPurpose.REGISTER), eq(10));
    }

    @Test
    void sendStoresOnlyAHashAndEmailsTheCode() {
        when(repo.secondsSinceLast(EMAIL, "REGISTER")).thenReturn(Optional.empty());
        service.send(EMAIL, OtpPurpose.REGISTER);
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        ArgumentCaptor<EmailOtp> saved = ArgumentCaptor.forClass(EmailOtp.class);
        verify(mail).sendOtp(eq(EMAIL), code.capture(), eq(OtpPurpose.REGISTER), eq(10));
        verify(repo).save(saved.capture());
        assertEquals(6, code.getValue().length());
        assertTrue(encoder.matches(code.getValue(), saved.getValue().getOtpHash()));
    }
}
