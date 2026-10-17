
package com.foodbridge.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
public class MailService {

    private static final Logger log =
            LoggerFactory.getLogger(MailService.class);

    private final String apiKey;
    private final String from;
    private final ObjectMapper objectMapper;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public MailService(
            @Value("${BREVO_API_KEY:}") String apiKey,
            @Value("${MAIL_FROM:foodbridge2124@gmail.com}") String from,
            ObjectMapper objectMapper) {

        this.apiKey = apiKey;
        this.from = from;
        this.objectMapper = objectMapper;
    }

    public void sendOtp(
            String to,
            String code,
            OtpPurpose purpose,
            int ttlMinutes) {

        String action = switch (purpose) {
            case REGISTER -> "verify your email address";
            case RESET_PASSWORD -> "reset your password";
            case LOGIN -> "sign in to FoodBridge";
        };

        String text = "Your FoodBridge verification code is "
                + code + ".\n\n"
                + "Use it to " + action + ".\n"
                + "It expires in " + ttlMinutes + " minutes.\n"
                + "If you did not request this code, ignore this email.";

        String html = "<div style=\"font-family:Arial,sans-serif;"
                + "max-width:480px;margin:auto;padding:24px;"
                + "border:1px solid #eee;border-radius:12px\">"
                + "<h2 style=\"color:#E8821A\">FoodBridge</h2>"
                + "<p>Use this code to " + action + ":</p>"
                + "<p style=\"font-size:34px;font-weight:bold;"
                + "letter-spacing:8px;color:#1A1A2E\">"
                + code + "</p>"
                + "<p>It expires in " + ttlMinutes
                + " minutes. If you did not request it, "
                + "ignore this email.</p></div>";

        try {
            sendEmail(
                    to,
                    "FoodBridge: " + purpose.subject(),
                    text,
                    html
            );
        } catch (Exception e) {
            log.error("Could not send OTP email to {}: {}",
                    to, e.getMessage());

            throw new OtpException(
                    "We couldn't send the email right now. "
                    + "Please try again in a minute."
            );
        }
    }

    private void sendEmail(
            String to,
            String subject,
            String text,
            String html) throws Exception {

        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException(
                    "BREVO_API_KEY is not configured.");
        }

        if (from == null || from.isBlank()) {
            throw new IllegalStateException(
                    "MAIL_FROM is not configured.");
        }

        Map<String, Object> payload = Map.of(
                "sender", Map.of(
                        "name", "FoodBridge",
                        "email", from
                ),
                "to", List.of(Map.of("email", to)),
                "subject", subject,
                "textContent", text,
                "htmlContent", html
        );

        String json = objectMapper.writeValueAsString(payload);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(
                        "https://api.brevo.com/v3/smtp/email"))
                .timeout(Duration.ofSeconds(20))
                .header("api-key", apiKey)
                .header("accept", "application/json")
                .header("content-type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();

        HttpResponse<String> response = httpClient.send(
                request,
                HttpResponse.BodyHandlers.ofString()
        );

        if (response.statusCode() < 200
                || response.statusCode() >= 300) {

            log.error("Brevo API returned HTTP {}: {}",
                    response.statusCode(), response.body());

            throw new IllegalStateException(
                    "Brevo rejected the email request. HTTP "
                    + response.statusCode());
        }

        log.info("Brevo accepted email for recipient {}", to);
    }

    public String sendTest(String to) {
        try {
            sendEmail(
                    to,
                    "FoodBridge test email",
                    "If you can read this, FoodBridge can send email.",
                    "<p>If you can read this, FoodBridge can send email.</p>"
            );

            return null;
        } catch (Exception e) {
            log.error("Test email failed: {}", e.getMessage());
            return e.getMessage();
        }
    }
}
