package com.foodbridge.web;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Set;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.foodbridge.model.DonorRequest;
import com.foodbridge.model.User;
import com.foodbridge.repository.DonorRequestRepository;
import com.foodbridge.service.NotificationService;
import com.foodbridge.service.UploadService;

@Controller
@RequestMapping("/donor")
public class DonorController {

    private static final Set<String> FOOD_TYPES  = Set.of("veg", "non-veg", "both");
    private static final Set<String> EVENT_TYPES = Set.of("home", "wedding", "party", "restaurant", "corporate", "other");
    private static final Set<String> UNITS       = Set.of("kg", "plates", "litres", "packets", "boxes", "pieces");

    private final DonorRequestRepository donors;
    private final NotificationService notifications;
    private final UploadService uploads;
    private final CurrentUserResolver current;

    public DonorController(DonorRequestRepository donors, NotificationService notifications,
                           UploadService uploads, CurrentUserResolver current) {
        this.donors = donors;
        this.notifications = notifications;
        this.uploads = uploads;
        this.current = current;
    }

    @GetMapping("/dashboard")
    public String dashboard(Authentication auth, Model model) {
        User me = current.require(auth);
        model.addAttribute("requests",       donors.findByDonorUserIdOrderByCreatedAtDesc(me.getUserId()));
        model.addAttribute("pendingCount",   donors.countByDonorUserIdAndStatus(me.getUserId(), "pending"));
        model.addAttribute("collectedCount", donors.countByDonorUserIdAndStatus(me.getUserId(), "collected"));
        current.addNotifications(model, me);
        return "donor/donordashboard";
    }

    @GetMapping("/request")
    public String requestForm(Authentication auth, Model model) {
        current.addNotifications(model, current.require(auth));
        return "donor/new_request";
    }

    @PostMapping("/request")
    public String submit(Authentication auth, Model model,
                         @RequestParam(name = "food_name", required = false) String foodName,
                         @RequestParam(name = "food_type", required = false) String foodType,
                         @RequestParam(required = false) String quantity,
                         @RequestParam(required = false) String unit,
                         @RequestParam(required = false) String location,
                         @RequestParam(name = "event_type", required = false) String eventType,
                         @RequestParam(required = false) String description,
                         @RequestParam(name = "pickup_deadline", required = false) String deadline,
                         @RequestParam(name = "photo", required = false) MultipartFile photo) {
        User me = current.require(auth);
        current.addNotifications(model, me);
        try {
            DonorRequest dr = new DonorRequest();
            dr.setDonor(me);
            dr.setFoodName(required(foodName, "Food name", 200));
            dr.setFoodType(oneOf(foodType, FOOD_TYPES, "Please choose a food type."));
            BigDecimal qty = new BigDecimal(required(quantity, "Quantity", 20));
            if (qty.signum() <= 0 || qty.compareTo(new BigDecimal("100000")) > 0) {
                throw new IllegalArgumentException("Quantity must be greater than 0.");
            }
            dr.setQuantity(qty);
            dr.setUnit(UNITS.contains(unit) ? unit : "kg");
            dr.setLocation(required(location, "Pickup location", 1000));
            dr.setEventType(EVENT_TYPES.contains(eventType) ? eventType : "other");
            dr.setDescription(description == null ? null : description.trim());
            LocalDateTime when = LocalDateTime.parse(required(deadline, "Pickup deadline", 30));
            if (!when.isAfter(LocalDateTime.now())) {
                throw new IllegalArgumentException("The pickup deadline must be in the future.");
            }
            dr.setPickupDeadline(Timestamp.valueOf(when));
            uploads.saveImage(photo).ifPresent(dr::setPhotoPath);

            donors.save(dr);
            notifications.notifyAdmins("New donation from " + me.getName() + ": " + dr.getFoodName(), "info");
            notifications.notifyUser(me.getUserId(), "Your donation '" + dr.getFoodName() + "' was submitted.", "success");
            return "redirect:/donor/dashboard?msg=Donation+submitted+successfully!";
        } catch (NumberFormatException e) {
            model.addAttribute("error", "Quantity must be a number.");
        } catch (DateTimeParseException e) {
            model.addAttribute("error", "Please choose a valid pickup date and time.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            model.addAttribute("error", e.getMessage());
        } catch (IOException e) {
            model.addAttribute("error", "The photo could not be saved. Please try again.");
        }
        return "donor/new_request";
    }

    private static String required(String v, String label, int max) {
        String t = v == null ? "" : v.trim();
        if (t.isEmpty()) throw new IllegalArgumentException(label + " is required.");
        if (t.length() > max) throw new IllegalArgumentException(label + " is too long.");
        return t;
    }

    private static String oneOf(String v, Set<String> allowed, String message) {
        if (v == null || !allowed.contains(v)) throw new IllegalArgumentException(message);
        return v;
    }
}
