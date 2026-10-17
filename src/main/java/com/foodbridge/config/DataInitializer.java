package com.foodbridge.config;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.foodbridge.model.User;
import com.foodbridge.model.Volunteer;
import com.foodbridge.repository.UserRepository;
import com.foodbridge.repository.VolunteerRepository;

/**
 * Hibernate creates and updates the tables (spring.jpa.hibernate.ddl-auto), so this only adds the demo accounts
 * to an empty database. Turn it off with app.seed-demo-data=false (env SEED_DEMO_DATA) and change the passwords
 * before going live.
 */
@Component
@ConditionalOnProperty(name = "app.seed-demo-data", havingValue = "true", matchIfMissing = true)
public class DataInitializer implements ApplicationRunner {

    private final UserRepository users;
    private final VolunteerRepository volunteers;
    private final PasswordEncoder encoder;

    public DataInitializer(UserRepository users, VolunteerRepository volunteers, PasswordEncoder encoder) {
        this.users = users;
        this.volunteers = volunteers;
        this.encoder = encoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (users.count() > 0) return;
        seed("Super Admin",  "admin@foodbridge.com",     "Admin@123", "9999999999", "admin",     null,                       null);
        seed("Rajesh Kumar", "donor@foodbridge.com",     "Test@123",  "9876543210", "donor",     "Connaught Place, New Delhi", null);
        seed("Priya Sharma", "receiver@foodbridge.com",  "Test@123",  "9123456789", "receiver",  "Karol Bagh, New Delhi",    "Seva Trust NGO");
        volunteers.save(new Volunteer(
            seed("Amit Singh", "volunteer@foodbridge.com", "Test@123", "9012345678", "volunteer", "Lajpat Nagar, New Delhi", null)));
    }

    private User seed(String name, String email, String password, String phone, String role, String address, String org) {
        User u = new User();
        u.setName(name); u.setEmail(email); u.setPassword(encoder.encode(password)); u.setPhone(phone);
        u.setRole(role); u.setAddress(address); u.setOrgName(org);
        u.setStatus("active"); u.setEmailVerified(true);
        return users.save(u);
    }
}
