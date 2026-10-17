package com.foodbridge.model;

import jakarta.persistence.*;

@Entity
@Table(name = "volunteers")
public class Volunteer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer volunteerId;
    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;
    @Column(length = 50) private String vehicleType;
    @Column(length = 20) private String availability = "available";
    private int totalDeliveries;

    protected Volunteer() {}
    public Volunteer(User user) { this.user = user; }

    public Integer getVolunteerId() { return volunteerId; }
    public User getUser()           { return user; }
    public String getVehicleType()  { return vehicleType; }
    public String getAvailability() { return availability; }
    public int getTotalDeliveries() { return totalDeliveries; }
}
