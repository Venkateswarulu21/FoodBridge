package com.foodbridge.service;

/** A problem with an OTP that is safe to show to the user. */
public class OtpException extends RuntimeException {
    public OtpException(String message) {
        super(message);
    }
}
