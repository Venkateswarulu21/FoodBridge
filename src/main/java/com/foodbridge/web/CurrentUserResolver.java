package com.foodbridge.web;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.ui.Model;

import com.foodbridge.model.User;
import com.foodbridge.repository.NotificationRepository;
import com.foodbridge.repository.UserRepository;

/** Looks up the signed-in user from the database and fills the notification bell used by every dashboard. */
@Component
public class CurrentUserResolver {

    private final UserRepository users;
    private final NotificationRepository notifications;

    public CurrentUserResolver(UserRepository users, NotificationRepository notifications) {
        this.users = users;
        this.notifications = notifications;
    }

    public User require(Authentication auth) {
        return users.findByEmail(auth.getName())
            .orElseThrow(() -> new IllegalStateException("Signed-in user no longer exists"));
    }

    public void addNotifications(Model model, User user) {
        model.addAttribute("notifications", notifications.findTop20ByUserUserIdOrderByCreatedAtDesc(user.getUserId()));
        model.addAttribute("unreadCount", notifications.countByUserUserIdAndReadFalse(user.getUserId()));
    }
}
