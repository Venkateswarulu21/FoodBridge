package com.foodbridge.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findTop20ByUserUserIdOrderByCreatedAtDesc(int userId);

    long countByUserUserIdAndReadFalse(int userId);

    @Transactional @Modifying
    @Query("update Notification n set n.read = true where n.user.userId = ?1")
    void markAllRead(int userId);
}
