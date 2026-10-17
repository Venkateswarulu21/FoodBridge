package com.foodbridge.model;

import java.sql.Timestamp;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

/** Links a donation to a receiver request and a volunteer. The last two are optional until the admin picks them. */
@Entity
@Table(name = "food_assignments")
public class FoodAssignment {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer assignmentId;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "donor_request_id")
    private DonorRequest donorRequest;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "receiver_request_id")
    private ReceiverRequest receiverRequest;
    @ManyToOne(fetch = FetchType.LAZY) @JoinColumn(name = "volunteer_id")
    private Volunteer volunteer;
    @CreationTimestamp @Column(updatable = false) private Timestamp assignedAt;
    private Timestamp pickedUpAt;
    private Timestamp deliveredAt;
    @Column(length = 20) private String status = "assigned";
    @Column(columnDefinition = "TEXT") private String notes;

    // read-only values the JSP views use (null-safe: receiver and volunteer may not be chosen yet)
    public int getDonorRequestId()      { return donorRequest.getRequestId(); }
    public String getDonorFoodName()    { return donorRequest.getFoodName(); }
    public String getDonorLocation()    { return donorRequest.getLocation(); }
    public int getReceiverRequestId()   { return receiverRequest == null ? 0 : receiverRequest.getRequestId(); }
    public String getReceiverLocation() { return receiverRequest == null ? null : receiverRequest.getLocation(); }
    public String getReceiverOrgName() {
        if (receiverRequest == null) return null;
        String org = receiverRequest.getReceiverOrg();
        return org == null || org.isBlank() ? receiverRequest.getReceiverName() : org;
    }
    public int getVolunteerId()         { return volunteer == null ? 0 : volunteer.getVolunteerId(); }
    public String getVolunteerName()    { return volunteer == null ? null : volunteer.getUser().getName(); }
    public String getVolunteerPhone()   { return volunteer == null ? null : volunteer.getUser().getPhone(); }

    public Integer getAssignmentId()    { return assignmentId; }
    public DonorRequest getDonorRequest() { return donorRequest; }
    public void setDonorRequest(DonorRequest v) { donorRequest = v; }
    public ReceiverRequest getReceiverRequest() { return receiverRequest; }
    public void setReceiverRequest(ReceiverRequest v) { receiverRequest = v; }
    public Volunteer getVolunteer()     { return volunteer; }
    public void setVolunteer(Volunteer v) { volunteer = v; }
    public Timestamp getAssignedAt()    { return assignedAt; }
    public Timestamp getPickedUpAt()    { return pickedUpAt; }
    public void setPickedUpAt(Timestamp v) { pickedUpAt = v; }
    public Timestamp getDeliveredAt()   { return deliveredAt; }
    public void setDeliveredAt(Timestamp v) { deliveredAt = v; }
    public String getStatus()           { return status; }
    public void setStatus(String v)     { status = v; }
    public String getNotes()            { return notes; }
}
