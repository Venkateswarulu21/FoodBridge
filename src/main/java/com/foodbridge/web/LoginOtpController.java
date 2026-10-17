package com.foodbridge.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Optional;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.foodbridge.model.User;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.security.AppUserDetailsService;
import com.foodbridge.security.LoginSuccessHandler;
import com.foodbridge.service.OtpException;
import com.foodbridge.service.OtpPurpose;
import com.foodbridge.service.OtpService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Second step of sign-in. The email comes from the server-side session (set after the password was accepted),
 * never from the browser, so nobody can pick someone else's mailbox.
 */
@Controller
public class LoginOtpController {

    private static final long PENDING_MAX_MS = 15 * 60 * 1000L;

    private final UserRepository users;
    private final OtpService otp;
    private final AppUserDetailsService userDetails;
    private final SecurityContextRepository contextRepository = new HttpSessionSecurityContextRepository();

    public LoginOtpController(UserRepository users, OtpService otp, AppUserDetailsService userDetails) {
        this.users = users;
        this.otp = otp;
        this.userDetails = userDetails;
    }

    @GetMapping("/login-otp")
    public String page(HttpServletRequest req, Model model) {
        String email = pendingEmail(req.getSession(false));
        if (email == null) return "redirect:/login?msg=" + enc("Please sign in first.");
        fill(model, email);
        return "login-otp";
    }

    /** Plain form post (used only when JavaScript is off). */
    @PostMapping("/login-otp")
    public String submit(HttpServletRequest req, HttpServletResponse res,
                         @RequestParam(required = false) String otpCode, Model model) {
        String email = pendingEmail(req.getSession(false));
        if (email == null) return "redirect:/login?msg=" + enc("Your sign-in expired. Please sign in again.");
        try {
            otp.verify(email, OtpPurpose.LOGIN, otpCode == null ? "" : otpCode.trim());
        } catch (OtpException e) {
            fill(model, email);
            model.addAttribute("error", e.getMessage());
            return "login-otp";
        }
        String home = finishLogin(req, res, email);
        if (home == null) return "redirect:/login?error=inactive";
        return "redirect:" + home;
    }

    @PostMapping("/api/login-otp/verify")
    @ResponseBody
    public Map<String, Object> verifyLive(HttpServletRequest req, HttpServletResponse res,
                                          @RequestParam(required = false) String otpCode) {
        String email = pendingEmail(req.getSession(false));
        if (email == null) {
            return Map.of("ok", false, "restart", true, "message", "Your sign-in expired. Please sign in again.");
        }
        try {
            otp.verify(email, OtpPurpose.LOGIN, otpCode == null ? "" : otpCode.trim());
        } catch (OtpException e) {
            return Map.of("ok", false, "message", e.getMessage());
        }
        String home = finishLogin(req, res, email);
        if (home == null) {
            return Map.of("ok", false, "restart", true, "message", "This account isn't active. Please contact the administrator.");
        }
        return Map.of("ok", true, "message", "Signed in! Taking you to your dashboard...", "redirect", home);
    }

    @PostMapping("/api/login-otp/resend")
    @ResponseBody
    public Map<String, Object> resendLive(HttpServletRequest req) {
        String email = pendingEmail(req.getSession(false));
        if (email == null) {
            return Map.of("ok", false, "restart", true, "message", "Your sign-in expired. Please sign in again.");
        }
        try {
            otp.send(email, OtpPurpose.LOGIN);
        } catch (OtpException e) {
            return Map.of("ok", false, "message", e.getMessage(), "resendIn", otp.secondsUntilResend(email, OtpPurpose.LOGIN));
        }
        return Map.of("ok", true, "message", "A new code is on its way. Check your inbox.",
                      "expiresIn", otp.secondsUntilExpiry(email, OtpPurpose.LOGIN),
                      "resendIn", otp.secondsUntilResend(email, OtpPurpose.LOGIN));
    }

    // ---------------------------------------------------------------------------------------------

    /** Completes the sign-in after a correct code. Returns the dashboard path, or null if the account can't sign in. */
    private String finishLogin(HttpServletRequest req, HttpServletResponse res, String email) {
        Optional<User> found = users.findByEmail(email);
        if (found.isEmpty()) return null;
        User u = found.get();
        if (!"active".equalsIgnoreCase(u.getStatus()) || !u.isEmailVerified()) return null;

        UserDetails details = userDetails.loadUserByUsername(email);
        UsernamePasswordAuthenticationToken token =
            UsernamePasswordAuthenticationToken.authenticated(details, null, details.getAuthorities());

        req.changeSessionId();                               // new session id once the user is really signed in
        HttpSession session = req.getSession();
        session.removeAttribute(LoginSuccessHandler.PENDING_EMAIL);
        session.removeAttribute(LoginSuccessHandler.PENDING_AT);

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(token);
        SecurityContextHolder.setContext(context);
        contextRepository.saveContext(context, req, res);

        LoginSuccessHandler.storeCurrentUser(req, u);
        return LoginSuccessHandler.homeFor(u.getRole());
    }

    private static String pendingEmail(HttpSession session) {
        if (session == null) return null;
        Object email = session.getAttribute(LoginSuccessHandler.PENDING_EMAIL);
        Object at = session.getAttribute(LoginSuccessHandler.PENDING_AT);
        if (!(email instanceof String) || !(at instanceof Long)) return null;
        if (System.currentTimeMillis() - (Long) at > PENDING_MAX_MS) return null;
        return (String) email;
    }

    private void fill(Model model, String email) {
        model.addAttribute("maskedEmail", mask(email));
        model.addAttribute("expiresIn", otp.secondsUntilExpiry(email, OtpPurpose.LOGIN));
        model.addAttribute("resendIn", otp.secondsUntilResend(email, OtpPurpose.LOGIN));
    }

    private static String mask(String email) {
        int at = email.indexOf('@');
        return at <= 1 ? email : email.charAt(0) + "***" + email.substring(at);
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
