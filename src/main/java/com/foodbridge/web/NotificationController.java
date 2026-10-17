package com.foodbridge.web;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foodbridge.model.User;
import com.foodbridge.repository.NotificationRepository;

@RestController
@RequestMapping("/notifications")
public class NotificationController {

    private final NotificationRepository notifications;
    private final CurrentUserResolver current;

    public NotificationController(NotificationRepository notifications, CurrentUserResolver current) {
        this.notifications = notifications;
        this.current = current;
    }

    @GetMapping
    public Map<String, Object> list(Authentication auth) {
        User me = current.require(auth);
        return Map.of("notifications", notifications.findTop20ByUserUserIdOrderByCreatedAtDesc(me.getUserId()),
                      "unreadCount", notifications.countByUserUserIdAndReadFalse(me.getUserId()));
    }

    @PostMapping
    public ResponseEntity<Void> markAllRead(Authentication auth) {
        notifications.markAllRead(current.require(auth).getUserId());
        return ResponseEntity.ok().build();
    }
}
