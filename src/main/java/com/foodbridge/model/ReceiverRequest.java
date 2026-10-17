package com.foodbridge.model;

import java.sql.Timestamp;
import java.time.LocalDate;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

@Entity
@Table(name = "receiver_requests")
public class ReceiverRequest {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer requestId;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "receiver_id")
    private User receiver;
    @Column(nullable = false) private int peopleCount;
    @Column(length = 20) private String foodPreference = "both";
    @Column(nullable = false) private LocalDate requiredDate;
    @Column(nullable = false, columnDefinition = "TEXT") private String location;
    @Column(columnDefinition = "TEXT") private String description;
    @Column(length = 30) private String status = "pending";
    @CreationTimestamp @Column(updatable = false) private Timestamp createdAt;

    // read-only values the JSP views use
    public int getReceiverId()          { return receiver.getUserId(); }
    public String getReceiverName()     { return receiver.getName(); }
    public String getReceiverOrg()      { return receiver.getOrgName(); }
    public String getReceiverPhone()    { return receiver.getPhone(); }

    public Integer getRequestId()       { return requestId; }
    public User getReceiver()           { return receiver; }
    public void setReceiver(User v)     { receiver = v; }
    public int getPeopleCount()         { return peopleCount; }
    public void setPeopleCount(int v)   { peopleCount = v; }
    public String getFoodPreference()   { return foodPreference; }
    public void setFoodPreference(String v) { foodPreference = v; }
    public LocalDate getRequiredDate()  { return requiredDate; }
    public void setRequiredDate(LocalDate v) { requiredDate = v; }
    public String getLocation()         { return location; }
    public void setLocation(String v)   { location = v; }
    public String getDescription()      { return description; }
    public void setDescription(String v) { description = v; }
    public String getStatus()           { return status; }
    public void setStatus(String v)     { status = v; }
    public Timestamp getCreatedAt()     { return createdAt; }
}
