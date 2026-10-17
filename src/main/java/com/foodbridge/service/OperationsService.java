package com.foodbridge.service;

import java.sql.Timestamp;
import java.util.Set;
import java.util.function.Supplier;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.DonorRequest;
import com.foodbridge.model.FoodAssignment;
import com.foodbridge.repository.AssignmentRepository;
import com.foodbridge.repository.DonorRequestRepository;
import com.foodbridge.repository.ReceiverRequestRepository;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.repository.VolunteerRepository;

/** Multi-step operations that must succeed or fail as one unit. Changes to loaded entities are saved on commit. */
@Service
@Transactional
public class OperationsService {

    public static final Set<String> ASSIGNMENT_STATUSES = Set.of("assigned", "on_the_way", "picked_up", "delivered", "failed");
    public static final Set<String> RECEIVER_STATUSES   = Set.of("pending", "partially_fulfilled", "fulfilled", "cancelled");
    public static final Set<String> USER_STATUSES       = Set.of("active", "inactive");

    private final DonorRequestRepository donors;
    private final ReceiverRequestRepository receivers;
    private final AssignmentRepository assignments;
    private final VolunteerRepository volunteers;
    private final UserRepository users;
    private final NotificationService notifications;

    public OperationsService(DonorRequestRepository donors, ReceiverRequestRepository receivers,
                             AssignmentRepository assignments, VolunteerRepository volunteers,
                             UserRepository users, NotificationService notifications) {
        this.donors = donors;
        this.receivers = receivers;
        this.assignments = assignments;
        this.volunteers = volunteers;
        this.users = users;
        this.notifications = notifications;
    }

    public void decideDonation(int requestId, boolean approve) {
        DonorRequest r = lockDonation(requestId, "pending", "Only pending donations can be reviewed.");
        r.setStatus(approve ? "approved" : "rejected");
        notifications.notifyUser(r.getDonorId(), approve
            ? "Your food donation '" + r.getFoodName() + "' has been approved! A volunteer will be assigned soon."
            : "Your donation request '" + r.getFoodName() + "' was reviewed and not approved. Thank you for offering!",
            approve ? "success" : "warning");
    }

    public void assign(int donorRequestId, Integer volunteerUserId, Integer receiverRequestId) {
        DonorRequest donation = lockDonation(donorRequestId, "approved",
            "Only approved donations that are not yet assigned can be assigned.");
        FoodAssignment fa = new FoodAssignment();
        fa.setDonorRequest(donation);
        if (volunteerUserId != null) {
            fa.setVolunteer(volunteers.findByUserUserId(volunteerUserId)
                .orElseThrow(() -> new IllegalArgumentException("The selected volunteer was not found.")));
        }
        if (receiverRequestId != null) {
            fa.setReceiverRequest(receivers.findById(receiverRequestId)
                .orElseThrow(() -> new IllegalArgumentException("The selected receiver request was not found.")));
        }
        donation.setStatus("assigned");
        assignments.save(fa);
        if (volunteerUserId != null) {
            notifications.notifyUser(volunteerUserId, "You have been assigned a food pickup task. Check your dashboard.", "info");
        }
    }

    /** volunteerId == null means "admin" (any assignment); otherwise only that volunteer's own assignment. */
    public void updateAssignmentStatus(int assignmentId, String status, Integer volunteerId) {
        if (!ASSIGNMENT_STATUSES.contains(status)) throw new IllegalArgumentException("Invalid status.");
        FoodAssignment fa = assignments.findById(assignmentId)
            .filter(a -> volunteerId == null || volunteerId == a.getVolunteerId())
            .orElseThrow(() -> new IllegalArgumentException("Assignment not found."));
        fa.setStatus(status);
        if ("picked_up".equals(status)) fa.setPickedUpAt(new Timestamp(System.currentTimeMillis()));
        if ("delivered".equals(status)) fa.setDeliveredAt(new Timestamp(System.currentTimeMillis()));
        if ("picked_up".equals(status) || "delivered".equals(status)) fa.getDonorRequest().setStatus("collected");
    }

    public void updateReceiverStatus(int requestId, String status) {
        if (!RECEIVER_STATUSES.contains(status)) throw new IllegalArgumentException("Invalid status.");
        receivers.findById(requestId).orElseThrow(notFound("Request not found.")).setStatus(status);
    }

    public void updateUserStatus(int actingAdminId, int userId, String status) {
        if (!USER_STATUSES.contains(status)) throw new IllegalArgumentException("Invalid status.");
        if (actingAdminId == userId) throw new IllegalArgumentException("You can't change your own status.");
        users.findById(userId).orElseThrow(notFound("User not found.")).setStatus(status);
    }

    /** Loads a donation under a row lock and checks it is in the expected status. */
    private DonorRequest lockDonation(int id, String expectedStatus, String wrongStatusMessage) {
        DonorRequest r = donors.lockById(id).orElseThrow(notFound("Donation not found."));
        if (!expectedStatus.equals(r.getStatus())) throw new IllegalStateException(wrongStatusMessage);
        return r;
    }

    private static Supplier<IllegalArgumentException> notFound(String message) {
        return () -> new IllegalArgumentException(message);
    }
}
