package com.foodbridge.model;

import java.time.LocalDateTime;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

/** One emailed one-time code. Only the BCrypt hash is stored, never the code itself. */
@Entity
@Table(name = "email_otps", indexes = {
    @Index(name = "idx_otp_lookup", columnList = "email, purpose, consumed, expiresAt"),
    @Index(name = "idx_otp_created", columnList = "email, createdAt")})
public class EmailOtp {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, length = 150) private String email;
    @Column(nullable = false, length = 30) private String purpose;      // REGISTER, RESET_PASSWORD or LOGIN
    @Column(nullable = false, length = 100) private String otpHash;
    private int attempts;
    private boolean consumed;
    @CreationTimestamp @Column(nullable = false, updatable = false) private LocalDateTime createdAt;
    @Column(nullable = false) private LocalDateTime expiresAt;

    protected EmailOtp() {}
    public EmailOtp(String email, String purpose, String otpHash, LocalDateTime expiresAt) {
        this.email = email; this.purpose = purpose; this.otpHash = otpHash; this.expiresAt = expiresAt;
    }

    public Long getId()                 { return id; }
    public String getOtpHash()          { return otpHash; }
    public int getAttempts()            { return attempts; }
    public void setAttempts(int v)      { attempts = v; }
    public boolean isConsumed()         { return consumed; }
    public void setConsumed(boolean v)  { consumed = v; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
