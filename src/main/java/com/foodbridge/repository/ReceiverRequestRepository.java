package com.foodbridge.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.foodbridge.model.ReceiverRequest;

public interface ReceiverRequestRepository extends JpaRepository<ReceiverRequest, Integer> {

    List<ReceiverRequest> findAllByOrderByCreatedAtDesc();

    List<ReceiverRequest> findByReceiverUserIdOrderByCreatedAtDesc(int receiverId);

    List<ReceiverRequest> findByStatusOrderByRequiredDateAsc(String status);

    default List<ReceiverRequest> findPending() {
        return findByStatusOrderByRequiredDateAsc("pending");
    }
}
