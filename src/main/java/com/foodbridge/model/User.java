package com.foodbridge.model;

import java.sql.Timestamp;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

/** Every account (admin, donor, receiver, volunteer). Starts as 'pending' until the emailed OTP is confirmed. */
@Entity
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userId;
    @Column(nullable = false, length = 100) private String name;
    @Column(nullable = false, unique = true, length = 150) private String email;
    @Column(nullable = false) private String password;           // BCrypt hash
    @Column(length = 20) private String phone;
    @Column(nullable = false, length = 20) private String role = "donor";
    @Column(nullable = false, length = 20) private String status = "pending";
    @Column(length = 200) private String orgName;
    @Column(columnDefinition = "TEXT") private String address;
    private boolean emailVerified;
    @CreationTimestamp @Column(updatable = false) private Timestamp createdAt;

    /** Detached copy without the password hash, safe for the session and the JSP views. */
    public User withoutPassword() {
        User c = new User();
        c.userId = userId; c.name = name; c.email = email; c.phone = phone; c.role = role; c.status = status;
        c.orgName = orgName; c.address = address; c.emailVerified = emailVerified; c.createdAt = createdAt;
        return c;
    }

    public Integer getUserId()          { return userId; }
    public String getName()             { return name; }
    public void setName(String v)       { name = v; }
    public String getEmail()            { return email; }
    public void setEmail(String v)      { email = v; }
    public String getPassword()         { return password; }
    public void setPassword(String v)   { password = v; }
    public String getPhone()            { return phone; }
    public void setPhone(String v)      { phone = v; }
    public String getRole()             { return role; }
    public void setRole(String v)       { role = v; }
    public String getStatus()           { return status; }
    public void setStatus(String v)     { status = v; }
    public String getOrgName()          { return orgName; }
    public void setOrgName(String v)    { orgName = v; }
    public String getAddress()          { return address; }
    public void setAddress(String v)    { address = v; }
    public boolean isEmailVerified()    { return emailVerified; }
    public void setEmailVerified(boolean v) { emailVerified = v; }
    public Timestamp getCreatedAt()     { return createdAt; }
}
