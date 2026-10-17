package com.foodbridge.security;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.foodbridge.model.User;
import com.foodbridge.repository.UserRepository;

@Service
public class AppUserDetailsService implements UserDetailsService {

    private final UserRepository users;

    public AppUserDetailsService(UserRepository users) {
        this.users = users;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User u = users.findByEmail(email == null ? "" : email.trim().toLowerCase())
            .orElseThrow(() -> new UsernameNotFoundException("No such user"));
        boolean active = "active".equalsIgnoreCase(u.getStatus()) && u.isEmailVerified();
        return org.springframework.security.core.userdetails.User.withUsername(u.getEmail())
            .password(u.getPassword())
            .roles(u.getRole().toUpperCase())     // admin -> ROLE_ADMIN, donor -> ROLE_DONOR, ...
            .disabled(!active)
            .build();
    }
}
