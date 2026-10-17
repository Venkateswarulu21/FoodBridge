package com.foodbridge.service;

import org.springframework.stereotype.Service;

import com.foodbridge.model.Notification;
import com.foodbridge.repository.NotificationRepository;
import com.foodbridge.repository.UserRepository;

@Service
public class NotificationService {

    private final NotificationRepository notifications;
    private final UserRepository users;

    public NotificationService(NotificationRepository notifications, UserRepository users) {
        this.notifications = notifications;
        this.users = users;
    }

    public void notifyUser(int userId, String message, String type) {
        notifications.save(new Notification(users.getReferenceById(userId), message, type));
    }

    public void notifyAdmins(String message, String type) {
        users.findActiveIdsByRole("admin").forEach(id -> notifyUser(id, message, type));
    }
}
