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

import com.foodbridge.model.User;
import com.foodbridge.repository.AssignmentRepository;
import com.foodbridge.repository.VolunteerRepository;
import com.foodbridge.service.OperationsService;

@Controller
@RequestMapping("/volunteer")
public class VolunteerController {

    private final AssignmentRepository assignments;
    private final VolunteerRepository volunteers;
    private final OperationsService operations;
    private final CurrentUserResolver current;

    public VolunteerController(AssignmentRepository assignments, VolunteerRepository volunteers,
                               OperationsService operations, CurrentUserResolver current) {
        this.assignments = assignments;
        this.volunteers = volunteers;
        this.operations = operations;
        this.current = current;
    }

    @GetMapping({"/dashboard", "/tasks"})
    public String dashboard(Authentication auth, Model model) {
        User me = current.require(auth);
        int volunteerId = volunteers.idOf(me.getUserId());
        model.addAttribute("volunteerId", volunteerId);
        model.addAttribute("assignments", assignments.findByVolunteerVolunteerIdOrderByAssignedAtDesc(volunteerId));
        current.addNotifications(model, me);
        return "volunteer/dashboard";
    }

    @PostMapping("/update")
    public String update(Authentication auth,
                         @RequestParam("assignment_id") int assignmentId,
                         @RequestParam String status) {
        User me = current.require(auth);
        int volunteerId = volunteers.idOf(me.getUserId());
        try {
            // Only this volunteer's own assignments can be changed; the donor request is looked up on the server.
            operations.updateAssignmentStatus(assignmentId, status, volunteerId);
            return "redirect:/volunteer/dashboard?msg=Status+updated!";
        } catch (IllegalArgumentException e) {
            return "redirect:/volunteer/dashboard?err=" + URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8);
        }
    }
}
