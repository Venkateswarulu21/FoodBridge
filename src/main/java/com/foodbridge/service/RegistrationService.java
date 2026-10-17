package com.foodbridge.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.User;
import com.foodbridge.model.Volunteer;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.repository.VolunteerRepository;

@Service
public class RegistrationService {

    private final UserRepository users;
    private final VolunteerRepository volunteers;
    private final PasswordEncoder encoder;

    public RegistrationService(UserRepository users, VolunteerRepository volunteers, PasswordEncoder encoder) {
        this.users = users;
        this.volunteers = volunteers;
        this.encoder = encoder;
    }

    /**
     * Creates the account in 'pending' state; it becomes 'active' once the emailed OTP is verified
     * (AuthController sends the code). An email that registered earlier but never verified can register
     * again: its details are replaced.
     */
    @Transactional
    public void register(User u, String plainPassword) {
        User target = users.findByEmail(u.getEmail()).orElse(u);
        if (target != u) {
            if (target.isEmailVerified() || !"pending".equalsIgnoreCase(target.getStatus())) {
                throw new IllegalStateException("Email already registered. Please sign in.");
            }
            target.setName(u.getName());
            target.setPhone(u.getPhone());
            target.setRole(u.getRole());
            target.setAddress(u.getAddress());
            target.setOrgName(u.getOrgName());
        }
        target.setPassword(encoder.encode(plainPassword));
        users.save(target);
        if ("volunteer".equals(target.getRole()) && volunteers.findByUserUserId(target.getUserId()).isEmpty()) {
            volunteers.save(new Volunteer(target));
        }
    }
}
