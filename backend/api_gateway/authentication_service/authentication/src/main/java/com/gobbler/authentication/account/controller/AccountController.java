package com.gobbler.authentication.account.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.gobbler.authentication.account.model.UserAccount;
import com.gobbler.authentication.account.model.UserCreateRequest;
import com.gobbler.authentication.account.service.AccountService;
import com.gobbler.authentication.account.service.UserOps;

@RestController
@RequestMapping("/account")
public class AccountController {
    private final UserOps userOps;

    public AccountController(AccountService accountService) {
        userOps = accountService;
    }

    @GetMapping("/ping")
    public ResponseEntity ping() {
        Map<String, String> response = new HashMap<>();
        response.put("ping", "pong!");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/create")
    public ResponseEntity createUser (@RequestBody UserCreateRequest userCreateRequest) {
        UserAccount user = userOps.createUser(userCreateRequest);
        System.out.println("User created: " + user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public UserAccount getAuthenticatedUserProfile() {
        String email = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        System.out.println("Authenticated user email: " + email);
        return userOps.readUserByEmail(email);
    }
}
