package com.foodbridge.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.MailAuthenticationException;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class MailService {

    private static final Logger log = LoggerFactory.getLogger(MailService.class);

    private final JavaMailSender sender;
    private final String from;
    private final String smtpUser;

    public MailService(JavaMailSender sender,
                       @Value("${app.mail.from:}") String from,
                       @Value("${spring.mail.username:}") String smtpUser) {
        this.sender = sender;
        this.from = from;
        this.smtpUser = smtpUser;
    }

    /** Sends a real email through the configured SMTP server. */
    public void sendOtp(String to, String code, OtpPurpose purpose, int ttlMinutes) {
        if (smtpUser == null || smtpUser.isBlank()) {
            log.error("SMTP is not configured. Set MAIL_USERNAME and MAIL_PASSWORD.");
            throw new OtpException("Email sending is not set up on this server yet. Please contact the administrator.");
        }
        String action = switch (purpose) {
            case REGISTER       -> "verify your email address";
            case RESET_PASSWORD -> "reset your password";
            case LOGIN          -> "sign in to FoodBridge";
        };
        String text = "Your FoodBridge code is " + code + ".\n\n"
            + "Use it to " + action + ". It expires in " + ttlMinutes + " minutes.\n"
            + "If you didn't ask for this, you can ignore this email.";
        String html = "<div style=\"font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:24px;"
            + "border:1px solid #eee;border-radius:12px\">"
            + "<h2 style=\"color:#E8821A;margin:0 0 12px\">FoodBridge</h2>"
            + "<p>Use this code to " + action + ":</p>"
            + "<p style=\"font-size:34px;font-weight:700;letter-spacing:8px;margin:18px 0;color:#1A1A2E\">" + code + "</p>"
            + "<p style=\"color:#666\">It expires in " + ttlMinutes + " minutes. "
            + "If you didn't ask for this, you can ignore this email.</p></div>";
        try {
            MimeMessage msg = sender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, true, "UTF-8");
            helper.setFrom(from == null || from.isBlank() ? smtpUser : from, "FoodBridge");
            helper.setTo(to);
            helper.setSubject("FoodBridge: " + purpose.subject());
            helper.setText(text, html);
            sender.send(msg);
        } catch (MessagingException | MailException | java.io.UnsupportedEncodingException e) {
            if (e instanceof MailAuthenticationException) {
                log.error("The mail server rejected the login. Check spring.mail.username (for Brevo: the SMTP login, "
                    + "e.g. xxxx@smtp-brevo.com) and spring.mail.password (the SMTP key). Environment variables "
                    + "MAIL_USERNAME / MAIL_PASSWORD override application.yml. Current username: {}", smtpUser);
            }
            log.error("Could not send OTP email to {}: {}", to, e.getMessage());
            throw new OtpException("We couldn't send the email right now. Please try again in a minute.");
        }
    }

    /** Admin diagnostic: returns null when the test mail was handed to the SMTP server, otherwise the real error. */
    public String sendTest(String to) {
        if (smtpUser == null || smtpUser.isBlank()) {
            return "No SMTP username is configured (spring.mail.username is empty).";
        }
        try {
            MimeMessage msg = sender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, false, "UTF-8");
            helper.setFrom(from == null || from.isBlank() ? smtpUser : from, "FoodBridge");
            helper.setTo(to);
            helper.setSubject("FoodBridge test email");
            helper.setText("If you can read this, FoodBridge can send email.");
            sender.send(msg);
            return null;
        } catch (Exception e) {
            Throwable cause = e.getCause();
            return e.getClass().getSimpleName() + ": " + e.getMessage()
                + (cause != null ? " | cause: " + cause.getMessage() : "");
        }
    }
}
