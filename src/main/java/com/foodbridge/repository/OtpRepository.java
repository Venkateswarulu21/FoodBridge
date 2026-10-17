package com.foodbridge.repository;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.EmailOtp;

import jakarta.persistence.LockModeType;

public interface OtpRepository extends JpaRepository<EmailOtp, Long> {

    @Transactional @Modifying
    @Query("update EmailOtp o set o.consumed = true where o.email = ?1 and o.purpose = ?2 and o.consumed = false")
    void invalidateActive(String email, String purpose);

    /** Row is locked, so concurrent guesses are counted correctly. Call inside a transaction. */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<EmailOtp> findFirstByEmailAndPurposeAndConsumedFalseAndExpiresAtAfterOrderByIdDesc(
        String email, String purpose, LocalDateTime now);

    Optional<EmailOtp> findFirstByEmailAndPurposeOrderByCreatedAtDesc(String email, String purpose);

    long countByEmailAndCreatedAtAfter(String email, LocalDateTime since);

    @Transactional @Modifying
    @Query("delete from EmailOtp o where o.createdAt < ?1")
    int deleteOlderThan(LocalDateTime cutoff);

    default Optional<EmailOtp> findActive(String email, String purpose) {
        return findFirstByEmailAndPurposeAndConsumedFalseAndExpiresAtAfterOrderByIdDesc(
            email, purpose, LocalDateTime.now());
    }

    /** Seconds since the newest code for this email and purpose was created, or empty if none. */
    default Optional<Integer> secondsSinceLast(String email, String purpose) {
        return findFirstByEmailAndPurposeOrderByCreatedAtDesc(email, purpose)
            .map(o -> (int) Duration.between(o.getCreatedAt(), LocalDateTime.now()).toSeconds());
    }

    default long countLastHour(String email) {
        return countByEmailAndCreatedAtAfter(email, LocalDateTime.now().minusHours(1));
    }
}
