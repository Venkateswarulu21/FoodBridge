package com.foodbridge.service;

public enum OtpPurpose {
    REGISTER("Registration OTP"),
    RESET_PASSWORD("Password Reset OTP"),
    LOGIN("Login OTP");

    private final String subject;

    OtpPurpose(String subject) {
        this.subject = subject;
    }

    public String subject() {
        return subject;
    }
}