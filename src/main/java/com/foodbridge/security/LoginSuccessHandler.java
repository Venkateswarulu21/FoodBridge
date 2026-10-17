package com.foodbridge.security;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Component;

import com.foodbridge.model.User;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.service.OtpException;
import com.foodbridge.service.OtpPurpose;
import com.foodbridge.service.OtpService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Runs after the password was accepted. With login OTP on (app.login-otp.enabled) the user is NOT signed in yet:
 * a 6-digit code is emailed and the sign-in is finished by LoginOtpController once the code is entered.
 */
@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    private static final Logger log = LoggerFactory.getLogger(LoginSuccessHandler.class);

    public static final String PENDING_EMAIL = "pendingLoginEmail";
    public static final String PENDING_AT = "pendingLoginAt";

    private final UserRepository users;
    private final OtpService otp;
    private final boolean otpEnabled;
    private final SecurityContextLogoutHandler logoutHandler = new SecurityContextLogoutHandler();

    public LoginSuccessHandler(UserRepository users, OtpService otp,
                               @Value("${app.login-otp.enabled:false}") boolean otpEnabled) {
        this.users = users;
        this.otp = otp;
        this.otpEnabled = otpEnabled;
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest req, HttpServletResponse res, Authentication auth)
            throws IOException {
        User u = users.findByEmail(auth.getName()).orElseThrow();
        String ctx = req.getContextPath();

        if (!otpEnabled) {                                   // plain password login
            storeCurrentUser(req, u);
            res.sendRedirect(ctx + homeFor(u.getRole()));
            return;
        }

        // Password was right, but the sign-in is not complete: drop it and wait for the emailed code.
        logoutHandler.logout(req, res, auth);
        HttpSession session = req.getSession(true);
        session.setAttribute(PENDING_EMAIL, u.getEmail());
        session.setAttribute(PENDING_AT, System.currentTimeMillis());
        try {
            otp.send(u.getEmail(), OtpPurpose.LOGIN);
            res.sendRedirect(ctx + "/login-otp?msg=" + enc("We emailed you a 6-digit code."));
        } catch (OtpException e) {
            res.sendRedirect(ctx + "/login-otp?err=" + enc(e.getMessage()));
        } catch (RuntimeException e) {                       // e.g. database problem: log it, show a clear message
            log.error("Could not create the sign-in code for {}", u.getEmail(), e);
            session.removeAttribute(PENDING_EMAIL);
            session.removeAttribute(PENDING_AT);
            res.sendRedirect(ctx + "/login?err=" + enc("We couldn't send your sign-in code right now. Please try again in a minute."));
        }
    }

    public static void storeCurrentUser(HttpServletRequest req, User u) {
        // a copy without the hash: the JSP views read ${sessionScope.currentUser}
        req.getSession().setAttribute("currentUser", u.withoutPassword());
    }

    public static String homeFor(String role) {
        return switch (role == null ? "" : role.toLowerCase()) {
            case "admin"     -> "/admin/dashboard";
            case "donor"     -> "/donor/dashboard";
            case "receiver"  -> "/receiver/dashboard";
            case "volunteer" -> "/volunteer/dashboard";
            default          -> "/login";
        };
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
