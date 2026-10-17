package com.foodbridge.web;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.foodbridge.model.User;

/** "My profile" page, opened from the profile card at the bottom of the sidebar. Any signed-in role can use it. */
@Controller
public class ProfileController {

    private final CurrentUserResolver current;

    public ProfileController(CurrentUserResolver current) {
        this.current = current;
    }

    @GetMapping("/profile")
    public String profile(Authentication auth, Model model) {
        User me = current.require(auth);   // fresh from the database
        model.addAttribute("profile", me.withoutPassword());   // never expose the hash to a view
        current.addNotifications(model, me);
        return "profile";
    }
}
