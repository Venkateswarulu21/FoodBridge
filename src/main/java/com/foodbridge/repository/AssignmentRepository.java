package com.foodbridge.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.foodbridge.model.FoodAssignment;

public interface AssignmentRepository extends JpaRepository<FoodAssignment, Integer> {

    List<FoodAssignment> findAllByOrderByAssignedAtDesc();

    List<FoodAssignment> findByVolunteerVolunteerIdOrderByAssignedAtDesc(int volunteerId);

    /** Assignments that deliver to one of this receiver's requests. */
    List<FoodAssignment> findByReceiverRequestReceiverUserIdOrderByAssignedAtDesc(int receiverUserId);

    long countByStatus(String status);

    long countByStatusAndReceiverRequestReceiverUserId(String status, int receiverUserId);
}
