package com.foodbridge.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.User;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByEmail(String email);

    List<User> findAllByOrderByCreatedAtDesc();

    List<User> findByRoleAndStatusOrderByName(String role, String status);

    long countByRole(String role);

    @Query("select u.userId from User u where u.role = ?1 and u.status = 'active'")
    List<Integer> findActiveIdsByRole(String role);

    @Transactional @Modifying
    @Query("update User u set u.emailVerified = true, "
         + "u.status = case when u.status = 'pending' then 'active' else u.status end where u.email = ?1")
    void markEmailVerified(String email);

    @Transactional @Modifying
    @Query("update User u set u.password = ?2 where u.email = ?1")
    void updatePassword(String email, String passwordHash);
}
