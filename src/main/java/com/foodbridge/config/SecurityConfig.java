package com.foodbridge.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import com.foodbridge.security.LoginFailureHandler;
import com.foodbridge.security.LoginSuccessHandler;

import jakarta.servlet.DispatcherType;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http,
                                           LoginSuccessHandler success,
                                           LoginFailureHandler failure) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                // internal forwards to JSP views and error pages
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()
                // public pages
                .requestMatchers("/", "/login", "/register", "/verify-otp", "/resend-otp",
                                 "/forgot-password", "/reset-password", "/api/otp/**", "/login-otp", "/api/login-otp/**",
                                 "/error", "/error/**", "/css/**", "/js/**", "/images/**", "/favicon.ico").permitAll()
                // role-based areas
                .requestMatchers("/admin/**").hasRole("ADMIN")
                .requestMatchers("/donor/**").hasRole("DONOR")
                .requestMatchers("/receiver/**").hasRole("RECEIVER")
                .requestMatchers("/volunteer/**").hasRole("VOLUNTEER")
                .anyRequest().authenticated())
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .usernameParameter("email")
                .passwordParameter("password")
                .successHandler(success)
                .failureHandler(failure)
                .permitAll())
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout"))   // the sidebar uses a plain link
                .logoutSuccessUrl("/login?msg=You+have+been+logged+out.")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID"))
            .exceptionHandling(ex -> ex.accessDeniedPage("/error/403"));
        return http.build();
    }
}
