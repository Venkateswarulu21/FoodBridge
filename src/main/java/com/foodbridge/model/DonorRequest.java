package com.foodbridge.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

@Entity
@Table(name = "donor_requests")
public class DonorRequest {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer requestId;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "donor_id")
    private User donor;
    @Column(nullable = false, length = 200) private String foodName;
    @Column(nullable = false, length = 20) private String foodType = "veg";
    @Column(nullable = false, precision = 10, scale = 2) private BigDecimal quantity;
    @Column(length = 30) private String unit = "kg";
    @Column(nullable = false, columnDefinition = "TEXT") private String location;
    @Column(nullable = false) private Timestamp pickupDeadline;
    @Column(length = 20) private String eventType = "home";
    @Column(columnDefinition = "TEXT") private String description;
    @Column(length = 500) private String photoPath;
    @Column(length = 20) private String status = "pending";
    @CreationTimestamp @Column(updatable = false) private Timestamp createdAt;

    // read-only values the JSP views use
    public int getDonorId()             { return donor.getUserId(); }
    public String getDonorName()        { return donor.getName(); }
    public String getDonorPhone()       { return donor.getPhone(); }

    public Integer getRequestId()       { return requestId; }
    public User getDonor()              { return donor; }
    public void setDonor(User v)        { donor = v; }
    public String getFoodName()         { return foodName; }
    public void setFoodName(String v)   { foodName = v; }
    public String getFoodType()         { return foodType; }
    public void setFoodType(String v)   { foodType = v; }
    public BigDecimal getQuantity()     { return quantity; }
    public void setQuantity(BigDecimal v) { quantity = v; }
    public String getUnit()             { return unit; }
    public void setUnit(String v)       { unit = v; }
    public String getLocation()         { return location; }
    public void setLocation(String v)   { location = v; }
    public Timestamp getPickupDeadline() { return pickupDeadline; }
    public void setPickupDeadline(Timestamp v) { pickupDeadline = v; }
    public String getEventType()        { return eventType; }
    public void setEventType(String v)  { eventType = v; }
    public String getDescription()      { return description; }
    public void setDescription(String v) { description = v; }
    public String getPhotoPath()        { return photoPath; }
    public void setPhotoPath(String v)  { photoPath = v; }
    public String getStatus()           { return status; }
    public void setStatus(String v)     { status = v; }
    public Timestamp getCreatedAt()     { return createdAt; }
}
