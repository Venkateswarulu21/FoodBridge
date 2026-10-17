package com.foodbridge.model;

import java.sql.Timestamp;

import org.hibernate.annotations.CreationTimestamp;

import jakarta.persistence.*;

/** Serialised to JSON by /notifications, so the owning user is deliberately not exposed. */
@Entity
@Table(name = "notifications")
public class Notification {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer notifId;
    @ManyToOne(fetch = FetchType.LAZY, optional = false) @JoinColumn(name = "user_id")
    private User user;
    @Column(nullable = false, columnDefinition = "TEXT") private String message;
    @Column(length = 20) private String type = "info";
    @Column(name = "is_read", nullable = false) private boolean read;
    @CreationTimestamp @Column(updatable = false) private Timestamp createdAt;

    protected Notification() {}
    public Notification(User user, String message, String type) {
        this.user = user; this.message = message; this.type = type;
    }

    public Integer getNotifId()     { return notifId; }
    public String getMessage()      { return message; }
    public String getType()         { return type; }
    public boolean isRead()         { return read; }
    public Timestamp getCreatedAt() { return createdAt; }
}
