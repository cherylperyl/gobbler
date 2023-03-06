package com.gobbler.authentication.account.model;

import lombok.Data;

@Data
public class UserCreateRequest {
    private String email;
    private String password;

    public UserCreateRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public UserCreateRequest() {
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
