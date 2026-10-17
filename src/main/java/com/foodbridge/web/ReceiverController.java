package com.foodbridge.web;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Set;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.foodbridge.model.ReceiverRequest;
import com.foodbridge.model.User;
import com.foodbridge.repository.AssignmentRepository;
import com.foodbridge.repository.ReceiverRequestRepository;
import com.foodbridge.service.NotificationService;

@Controller
@RequestMapping("/receiver")
public class ReceiverController {

    private static final Set<String> PREFERENCES = Set.of("veg", "non-veg", "both");

    private final ReceiverRequestRepository receivers;
    private final AssignmentRepository assignments;
    private final NotificationService notifications;
    private final CurrentUserResolver current;

    public ReceiverController(ReceiverRequestRepository receivers, AssignmentRepository assignments,
                              NotificationService notifications, CurrentUserResolver current) {
        this.receivers = receivers;
        this.assignments = assignments;
        this.notifications = notifications;
        this.current = current;
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication auth, Model model) {
        User me = current.require(auth);
        model.addAttribute("requests",       receivers.findByReceiverUserIdOrderByCreatedAtDesc(me.getUserId()));
        model.addAttribute("assignments",    assignments.findByReceiverRequestReceiverUserIdOrderByAssignedAtDesc(me.getUserId()));   // only this receiver's deliveries
        model.addAttribute("deliveredCount", assignments.countByStatusAndReceiverRequestReceiverUserId("delivered", me.getUserId()));
        current.addNotifications(model, me);
        return "receiver/dashboard";
    }

    @GetMapping("/request")
    public String requestForm(Authentication auth, Model model) {
        current.addNotifications(model, current.require(auth));
        model.addAttribute("today", LocalDate.now().toString());
        return "receiver/new_request";
    }

    @PostMapping("/request")
    public String submit(Authentication auth, Model model,
                         @RequestParam(name = "people_count", required = false) String peopleCount,
                         @RequestParam(name = "food_preference", required = false) String preference,
                         @RequestParam(name = "required_date", required = false) String requiredDate,
                         @RequestParam(required = false) String location,
                         @RequestParam(required = false) String description) {
        User me = current.require(auth);
        current.addNotifications(model, me);
        try {
            ReceiverRequest rr = new ReceiverRequest();
            rr.setReceiver(me);
            int people = Integer.parseInt(peopleCount == null ? "" : peopleCount.trim());
            if (people < 1 || people > 100000) throw new IllegalArgumentException("Number of people must be between 1 and 100000.");
            rr.setPeopleCount(people);
            if (preference == null || !PREFERENCES.contains(preference)) throw new IllegalArgumentException("Please choose a food preference.");
            rr.setFoodPreference(preference);
            LocalDate date = LocalDate.parse(requiredDate == null ? "" : requiredDate.trim());
            if (date.isBefore(LocalDate.now())) throw new IllegalArgumentException("The required date can't be in the past.");
            rr.setRequiredDate(date);
            if (location == null || location.isBlank() || location.length() > 1000) throw new IllegalArgumentException("Please enter a delivery location.");
            rr.setLocation(location.trim());
            rr.setDescription(description == null ? null : description.trim());

            receivers.save(rr);
            notifications.notifyAdmins("Food requirement from " + me.getName() + " for " + people + " people", "info");
            notifications.notifyUser(me.getUserId(), "Your food requirement was submitted. The admin will process it soon.", "success");
            return "redirect:/receiver/dashboard?msg=Request+submitted!";
        } catch (NumberFormatException e) {
            model.addAttribute("error", "Number of people must be a whole number.");
        } catch (DateTimeParseException e) {
            model.addAttribute("error", "Please choose a valid date.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            model.addAttribute("error", e.getMessage());
        }
        return "receiver/new_request";
    }
}
