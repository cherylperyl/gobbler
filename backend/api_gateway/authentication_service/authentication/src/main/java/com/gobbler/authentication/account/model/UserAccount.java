package com.gobbler.authentication.account.model;

import com.sun.istack.NotNull;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public class UserAccount {

    @Id
    private String userId;

    /* intended to be replicate of email for org.springframework.security.core.Authentication
    which relies on the attribute `username` to be present */
    private String username;

    private String email;

    private String password;

    private String role;

    public UserAccount() {
    }

    public UserAccount(String email, String password) {
        this.userId = UUID.randomUUID().toString();
        this.email = email;
        this.username = email;
        BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder();
        this.password = bCryptPasswordEncoder.encode(password);
        this.role = "ROLE_USER";
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
        this.username = email;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public ArrayList<String> getRoles() {
        ArrayList<String> roles = new ArrayList<String>();
        roles.add(this.role);
        return roles;
    }

}
