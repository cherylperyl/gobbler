package com.gobbler.authentication.account.service;

// import com.gobbler.authentication.account.dto.ProfileDTO;
import com.gobbler.authentication.account.model.UserAccount;
import com.gobbler.authentication.account.model.UserCreateRequest;

public interface UserOps {
    // ProfileDTO userLogin(String email, String password);

    UserAccount createUser(UserCreateRequest userCreateRequest);
    
    UserAccount readUserByEmail(String email);
}
