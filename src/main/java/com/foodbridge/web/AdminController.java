package com.foodbridge.web;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.foodbridge.model.User;
import com.foodbridge.repository.AssignmentRepository;
import com.foodbridge.repository.DonorRequestRepository;
import com.foodbridge.repository.ReceiverRequestRepository;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.service.MailService;
import com.foodbridge.service.OperationsService;

/** Everything under /admin/** is restricted to ROLE_ADMIN in SecurityConfig. */
@Controller
@RequestMapping("/admin")
public class AdminController {

    private final DonorRequestRepository donors;
    private final ReceiverRequestRepository receivers;
    private final AssignmentRepository assignments;
    private final UserRepository users;
    private final OperationsService operations;
    private final CurrentUserResolver current;
    private final MailService mail;

    public AdminController(DonorRequestRepository donors, ReceiverRequestRepository receivers,
                           AssignmentRepository assignments, UserRepository users,
                           OperationsService operations, CurrentUserResolver current,
                           MailService mail) {
        this.donors = donors;
        this.receivers = receivers;
        this.assignments = assignments;
        this.users = users;
        this.operations = operations;
        this.current = current;
        this.mail = mail;
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication auth, Model model) {
        User me = current.require(auth);
        model.addAttribute("totalDonations",   donors.count());
        model.addAttribute("pendingDonations", donors.countByStatus("pending"));
        model.addAttribute("totalReceivers",   receivers.count());
        model.addAttribute("deliveredCount",   assignments.countByStatus("delivered"));
        model.addAttribute("totalDonors",      users.countByRole("donor"));
        model.addAttribute("totalVolunteers",  users.countByRole("volunteer"));
        model.addAttribute("recentDonations",  donors.findByStatusOrderByCreatedAtDesc("pending"));
        model.addAttribute("recentRequests",   receivers.findPending());
        model.addAttribute("assignments",      assignments.findAllByOrderByAssignedAtDesc());
        current.addNotifications(model, me);
        return "admin/admin-dashboard";
    }

    /** Sends a test email to the signed-in admin and shows the real result, so mail settings can be checked quickly. */
    @GetMapping(value = "/email-test", produces = "text/plain;charset=UTF-8")
    @ResponseBody
    public String emailTest(Authentication auth) {
        User me = current.require(auth);
        String problem = mail.sendTest(me.getEmail());
        return problem == null
            ? "OK: a test email was sent to " + me.getEmail() + ". Check the inbox (and the Spam folder)."
            : "FAILED: " + problem;
    }

    @GetMapping("/donors")
    public String donorList(Model model) {
        model.addAttribute("requests", donors.findAllByOrderByCreatedAtDesc());
        return "admin/donors";
    }

    @PostMapping("/donors")
    public String decideDonation(@RequestParam String action,
                                 @RequestParam("request_id") int requestId) {
        try {
            operations.decideDonation(requestId, "approve".equals(action));
            return "redirect:/admin/donors";
        } catch (IllegalArgumentException | IllegalStateException e) {
            return "redirect:/admin/donors?err=" + enc(e.getMessage());
        }
    }

    @GetMapping("/receivers")
    public String receiverList(Model model) {
        model.addAttribute("requests", receivers.findAllByOrderByCreatedAtDesc());
        return "admin/receivers";
    }

    @PostMapping("/receivers")
    public String updateReceiver(@RequestParam("request_id") int requestId, @RequestParam String status) {
        try {
            operations.updateReceiverStatus(requestId, status);
            return "redirect:/admin/receivers";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/receivers?err=" + enc(e.getMessage());
        }
    }

    @GetMapping("/users")
    public String userList(Model model) {
        model.addAttribute("users", users.findAllByOrderByCreatedAtDesc());
        return "admin/users";
    }

    @PostMapping("/users")
    public String updateUser(Authentication auth, @RequestParam("user_id") int userId, @RequestParam String status) {
        try {
            operations.updateUserStatus(current.require(auth).getUserId(), userId, status);
            return "redirect:/admin/users";
        } catch (IllegalArgumentException e) {
            return "redirect:/admin/users?err=" + enc(e.getMessage());
        }
    }

    @GetMapping("/assign")
    public String assignPage(Model model) {
        model.addAttribute("approvedDonations", donors.findByStatusOrderByCreatedAtDesc("approved"));
        model.addAttribute("pendingReceivers",  receivers.findPending());
        model.addAttribute("volunteers",        users.findByRoleAndStatusOrderByName("volunteer", "active"));
        model.addAttribute("assignments",       assignments.findAllByOrderByAssignedAtDesc());
        return "admin/assign";
    }

    @PostMapping("/assign")
    public String assignAction(@RequestParam String action,
                               @RequestParam(name = "donor_request_id", required = false) Integer donorRequestId,
                               @RequestParam(name = "volunteer_id", required = false) Integer volunteerUserId,
                               @RequestParam(name = "receiver_request_id", required = false) Integer receiverRequestId,
                               @RequestParam(name = "assignment_id", required = false) Integer assignmentId,
                               @RequestParam(required = false) String status) {
        try {
            if ("assign".equals(action) && donorRequestId != null) {
                operations.assign(donorRequestId, volunteerUserId, receiverRequestId);
            } else if ("update_status".equals(action) && assignmentId != null && status != null) {
                operations.updateAssignmentStatus(assignmentId, status, null);
            }
            return "redirect:/admin/assign";
        } catch (IllegalArgumentException | IllegalStateException e) {
            return "redirect:/admin/assign?err=" + enc(e.getMessage());
        }
    }

    private static String enc(String s) {
        return URLEncoder.encode(s == null ? "Something went wrong." : s, StandardCharsets.UTF_8);
    }
}
