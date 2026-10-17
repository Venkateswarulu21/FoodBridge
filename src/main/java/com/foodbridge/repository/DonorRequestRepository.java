package com.foodbridge.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import com.foodbridge.model.DonorRequest;

import jakarta.persistence.LockModeType;

public interface DonorRequestRepository extends JpaRepository<DonorRequest, Integer> {

    List<DonorRequest> findAllByOrderByCreatedAtDesc();

    List<DonorRequest> findByStatusOrderByCreatedAtDesc(String status);

    List<DonorRequest> findByDonorUserIdOrderByCreatedAtDesc(int donorId);

    long countByStatus(String status);

    long countByDonorUserIdAndStatus(int donorId, String status);

    /** Row lock: two admins can't approve or assign the same donation at the same time. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select d from DonorRequest d where d.requestId = ?1")
    Optional<DonorRequest> lockById(int id);
}
