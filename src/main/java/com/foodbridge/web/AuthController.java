package com.foodbridge.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestParam;

import com.foodbridge.model.User;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.security.LoginSuccessHandler;
import com.foodbridge.service.OtpException;
import com.foodbridge.service.OtpPurpose;
import com.foodbridge.service.OtpService;
import com.foodbridge.service.RegistrationService;

import jakarta.servlet.http.HttpSession;

/** Registration with email OTP, OTP verification, and password reset by OTP. */
@Controller
public class AuthController {

    private static final Logger log = LoggerFactory.getLogger(AuthController.class);
    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE = Pattern.compile("^[0-9+\\-\\s]{7,15}$");
    private static final Set<String> SELF_SERVICE_ROLES = Set.of("donor", "receiver", "volunteer");

    private final UserRepository users;
    private final RegistrationService registration;
    private final OtpService otp;
    private final PasswordEncoder encoder;

    public AuthController(UserRepository users, RegistrationService registration, OtpService otp, PasswordEncoder encoder) {
        this.users = users;
        this.registration = registration;
        this.otp = otp;
        this.encoder = encoder;
    }

    // The HttpSession parameter makes sure a session exists before the JSP renders its CSRF token.

    @GetMapping("/login")
    public String loginPage(Authentication auth, HttpSession session) {
        if (isSignedIn(auth)) return "redirect:" + LoginSuccessHandler.homeFor(roleOf(auth));
        return "login";
    }

    // ---------- registration ----------

    @GetMapping("/register")
    public String registerPage(Authentication auth, HttpSession session) {
        if (isSignedIn(auth)) return "redirect:" + LoginSuccessHandler.homeFor(roleOf(auth));
        return "register";
    }

    @PostMapping("/register")
    public String register(@RequestParam(required = false) String name,
                           @RequestParam(required = false) String email,
                           @RequestParam(required = false) String password,
                           @RequestParam(required = false) String phone,
                           @RequestParam(required = false) String role,
                           @RequestParam(required = false) String address,
                           @RequestParam(name = "org_name", required = false) String orgName,
                           Model model) {
        String n = trim(name), e = norm(email), r = trim(role).toLowerCase();
        String error = null;
        if (n.length() < 2 || n.length() > 100) error = "Please enter your name (2 to 100 characters).";
        else if (!EMAIL.matcher(e).matches() || e.length() > 150) error = "Please enter a valid email address.";
        else if (!SELF_SERVICE_ROLES.contains(r)) error = "Please choose a role.";
        else if (!trim(phone).isEmpty() && !PHONE.matcher(trim(phone)).matches()) error = "Please enter a valid phone number.";
        else if (trim(address).length() > 500 || trim(orgName).length() > 200) error = "Address or organisation name is too long.";
        else error = passwordProblem(password);
        if (error != null) {
            model.addAttribute("error", error);
            return "register";
        }

        User u = new User();
        u.setName(n);
        u.setEmail(e);
        u.setPhone(trim(phone));
        u.setRole(r);
        u.setAddress(trim(address));
        u.setOrgName(trim(orgName));
        try {
            registration.register(u, password);
        } catch (IllegalStateException ex) {
            model.addAttribute("error", ex.getMessage());
            return "register";
        }
        try {
            otp.send(e, OtpPurpose.REGISTER);
            return redirectTo("/verify-otp", e, "msg", "Account created. We emailed a 6-digit code to " + e + ".");
        } catch (OtpException ex) {
            return redirectTo("/verify-otp", e, "err", "Account created, but " + lowerFirst(ex.getMessage()) + " Use \"Resend code\" to try again.");
        }
    }

    // ---------- email verification ----------

    @GetMapping("/verify-otp")
    public String verifyPage(@RequestParam(required = false) String email, Model model, HttpSession session) {
        String e = norm(email);
        model.addAttribute("email", e);
        model.addAttribute("expiresIn", otp.secondsUntilExpiry(e, OtpPurpose.REGISTER));
        model.addAttribute("resendIn", otp.secondsUntilResend(e, OtpPurpose.REGISTER));
        return "verify-otp";
    }

    @PostMapping("/verify-otp")
    public String verify(@RequestParam(required = false) String email,
                         @RequestParam(required = false) String otpCode, Model model) {
        String e = norm(email);
        try {
            otp.verify(e, OtpPurpose.REGISTER, trim(otpCode));
        } catch (OtpException ex) {
            model.addAttribute("email", e);
            model.addAttribute("error", ex.getMessage());
            return "verify-otp";
        }
        users.markEmailVerified(e);
        return "redirect:/login?msg=" + enc("Email verified. You can sign in now.");
    }

    @PostMapping("/resend-otp")
    public String resend(@RequestParam(required = false) String email,
                         @RequestParam(defaultValue = "REGISTER") String purpose) {
        String e = norm(email);
        OtpPurpose p = "RESET_PASSWORD".equals(purpose) ? OtpPurpose.RESET_PASSWORD : OtpPurpose.REGISTER;
        String page = p == OtpPurpose.REGISTER ? "/verify-otp" : "/reset-password";
        Optional<User> u = users.findByEmail(e);
        boolean eligible = u.isPresent() && (p == OtpPurpose.REGISTER
            ? !u.get().isEmailVerified() && "pending".equalsIgnoreCase(u.get().getStatus())
            : "active".equalsIgnoreCase(u.get().getStatus()));
        if (eligible) {
            try {
                otp.send(e, p);
            } catch (OtpException ex) {
                return redirectTo(page, e, "err", ex.getMessage());
            }
        }
        return redirectTo(page, e, "msg", "If that email can receive a code, a new one is on its way.");
    }

    // ---------- live (no page reload) OTP endpoints used by verify-otp.jsp ----------

    @PostMapping("/api/otp/verify")
    @ResponseBody
    public Map<String, Object> verifyLive(@RequestParam(required = false) String email,
                                          @RequestParam(required = false) String otpCode) {
        String e = norm(email);
        try {
            otp.verify(e, OtpPurpose.REGISTER, trim(otpCode));
        } catch (OtpException ex) {
            return Map.of("ok", false, "message", ex.getMessage());
        }
        users.markEmailVerified(e);
        return Map.of("ok", true, "message", "Email verified! Taking you to sign in...",
                      "redirect", "/login?msg=" + enc("Email verified. You can sign in now."));
    }

    @PostMapping("/api/otp/resend")
    @ResponseBody
    public Map<String, Object> resendLive(@RequestParam(required = false) String email) {
        String e = norm(email);
        Optional<User> u = users.findByEmail(e);
        boolean eligible = u.isPresent() && !u.get().isEmailVerified() && "pending".equalsIgnoreCase(u.get().getStatus());
        if (eligible) {
            try {
                otp.send(e, OtpPurpose.REGISTER);
            } catch (OtpException ex) {
                return Map.of("ok", false, "message", ex.getMessage(),
                              "resendIn", otp.secondsUntilResend(e, OtpPurpose.REGISTER));
            }
        }
        return Map.of("ok", true, "message", "A new code is on its way. Check your inbox.",
                      "expiresIn", otp.secondsUntilExpiry(e, OtpPurpose.REGISTER),
                      "resendIn", otp.secondsUntilResend(e, OtpPurpose.REGISTER));
    }

    // ---------- forgot / reset password ----------

    @GetMapping("/forgot-password")
    public String forgotPage(HttpSession session) {
        return "forgot-password";
    }

    @PostMapping("/forgot-password")
    public String forgot(@RequestParam(required = false) String email, Model model) {
        String e = norm(email);
        if (!EMAIL.matcher(e).matches()) {
            model.addAttribute("error", "Please enter a valid email address.");
            return "forgot-password";
        }
        Optional<User> u = users.findByEmail(e);
        if (u.isPresent() && "active".equalsIgnoreCase(u.get().getStatus())) {
            try {
                otp.send(e, OtpPurpose.RESET_PASSWORD);
            } catch (OtpException ex) {
                log.warn("Password-reset code not sent to {}: {}", e, ex.getMessage());
            }
        }
        // Same answer whether or not the account exists, so this page can't be used to discover registered emails.
        return redirectTo("/reset-password", e, "msg", "If an account exists for that email, we've sent it a 6-digit code.");
    }

    @GetMapping("/reset-password")
    public String resetPage(@RequestParam(required = false) String email, Model model, HttpSession session) {
        model.addAttribute("email", norm(email));
        return "reset-password";
    }

    @PostMapping("/reset-password")
    public String reset(@RequestParam(required = false) String email,
                        @RequestParam(required = false) String otpCode,
                        @RequestParam(required = false) String password,
                        @RequestParam(required = false) String confirm, Model model) {
        String e = norm(email);
        model.addAttribute("email", e);
        String problem = passwordProblem(password);
        if (problem == null && !password.equals(confirm)) problem = "The two passwords don't match.";
        if (problem != null) {
            model.addAttribute("error", problem);
            return "reset-password";
        }
        try {
            otp.verify(e, OtpPurpose.RESET_PASSWORD, trim(otpCode));
        } catch (OtpException ex) {
            model.addAttribute("error", ex.getMessage());
            return "reset-password";
        }
        users.updatePassword(e, encoder.encode(password));
        return "redirect:/login?msg=" + enc("Password changed. Please sign in with your new password.");
    }

    // ---------- helpers ----------

    private static String passwordProblem(String p) {
        if (p == null || p.length() < 8) return "Password must be at least 8 characters.";
        if (p.length() > 64) return "Password must be 64 characters or fewer.";
        if (!p.matches(".*[A-Za-z].*") || !p.matches(".*\\d.*")) return "Password must contain at least one letter and one number.";
        return null;
    }

    private static boolean isSignedIn(Authentication a) {
        return a != null && a.isAuthenticated() && !(a instanceof AnonymousAuthenticationToken);
    }

    private static String roleOf(Authentication a) {
        for (GrantedAuthority g : a.getAuthorities()) {
            if (g.getAuthority().startsWith("ROLE_")) return g.getAuthority().substring(5).toLowerCase();
        }
        return "";
    }

    private static String redirectTo(String path, String email, String key, String message) {
        return "redirect:" + path + "?email=" + enc(email) + "&" + key + "=" + enc(message);
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static String norm(String s) {
        return trim(s).toLowerCase();
    }

    private static String lowerFirst(String s) {
        return s == null || s.isEmpty() ? "" : Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }
}
