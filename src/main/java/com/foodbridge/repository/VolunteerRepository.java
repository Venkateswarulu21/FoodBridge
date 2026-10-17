package com.foodbridge.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.foodbridge.model.Volunteer;

public interface VolunteerRepository extends JpaRepository<Volunteer, Integer> {

    Optional<Volunteer> findByUserUserId(int userId);

    /** The volunteer id for a user account, or -1 if that user has no volunteer record. */
    default int idOf(int userId) {
        return findByUserUserId(userId).map(Volunteer::getVolunteerId).orElse(-1);
    }
}
