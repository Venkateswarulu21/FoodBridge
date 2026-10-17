package com.foodbridge.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import jakarta.servlet.http.HttpServletRequest;

@ControllerAdvice
public class GlobalExceptionHandler {

    /** A photo bigger than the limit in application.yml used to end in a bare 500 page. */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public String photoTooLarge(HttpServletRequest req) {
        String back = req.getRequestURI().contains("/donor") ? "/donor/request" : "/";
        return "redirect:" + back + "?err="
            + URLEncoder.encode("That photo is too large. Please choose one smaller than 5 MB.", StandardCharsets.UTF_8);
    }
}
