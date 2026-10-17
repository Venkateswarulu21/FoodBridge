# FoodBridge (Spring Boot)

Leftover-food gathering and redistribution. Donors post surplus food, an admin approves it and assigns a
volunteer, volunteers deliver it, receivers (NGOs) request food and track deliveries.

Java 17+, Spring Boot 3.5, Spring Security, Spring Data JPA (Hibernate) + MySQL 8, JSP views, real email OTP.

## Run it
1. **Database**: create an empty schema once: `CREATE DATABASE food_bridge CHARACTER SET utf8mb4;`
   Hibernate creates and extends the tables from the entities (`spring.jpa.hibernate.ddl-auto: update`), and
   `DataInitializer` adds the demo accounts when the users table is empty (`app.seed-demo-data`).
   An existing `food_bridge` database keeps working as it is: missing columns/tables are added on startup.
2. **Settings**: copy `config/application.yml.example` to `config/application.yml` and fill in your MySQL password
   and mail login. That file is git-ignored and overrides `src/main/resources/application.yml`.
3. `mvn spring-boot:run` and open http://localhost:8080
4. Check email: sign in as admin and open http://localhost:8080/admin/email-test. It sends a test mail and prints
   the real error if it fails. The startup log also prints which mail username is in use.
5. Tests: `mvn test`

Demo logins (already verified): `admin@foodbridge.com` / `Admin@123`; `donor@`, `receiver@`, `volunteer@foodbridge.com` / `Test@123`.
These addresses are fake. Change the admin's email to one you own before turning on login OTP.

## Roles (enforced in `config/SecurityConfig.java`)
`/admin/**` ADMIN, `/donor/**` DONOR, `/receiver/**` RECEIVER, `/volunteer/**` VOLUNTEER. `/profile` is for any signed-in user.
Anyone can self-register as donor, receiver or volunteer. Admin accounts can't be created from the website.

## Email OTP
- **Register**: account is `pending` -> 6-digit code emailed -> live verify page -> account becomes `active`.
- **Forgot password**: code emailed -> new password.
- **Login (optional)**: after the password is accepted a code is emailed and the sign-in only completes once it is entered.
  Turn on with `app.login-otp.enabled: true` (or env `LOGIN_OTP_ENABLED=true`) after `/admin/email-test` says OK.
- Codes: SecureRandom, stored only as a BCrypt hash, valid 10 min, 5 wrong tries per code,
  60 s resend wait, max 10 codes per email per hour (`app.otp` in `application.yml`).

## Layout
```
config/      SecurityConfig, WebConfig, DataInitializer (demo accounts)
security/    UserDetailsService, login success/failure handlers
web/         Auth, LoginOtp, Admin, Donor, Receiver, Volunteer, Profile, Notification controllers
service/     OtpService, MailService, RegistrationService, OperationsService, UploadService
model/       JPA entities (User, Volunteer, DonorRequest, ReceiverRequest, FoodAssignment, Notification, EmailOtp)
repository/  Spring Data JPA interfaces
webapp/WEB-INF/views/   JSP pages        resources/static/   css, js, images
```

## Verified so far
The main sources compile against the project's Spring jars with the JPA annotations stubbed. The Hibernate mapping,
the derived query names and the JSP rendering were not run in the build environment, so the first
`mvn spring-boot:run` on your machine is the final check.
