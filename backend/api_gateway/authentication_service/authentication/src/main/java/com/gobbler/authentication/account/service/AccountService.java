package com.gobbler.authentication.account.service;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Optional;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import javax.persistence.EntityNotFoundException;

// import com.gobbler.authentication.account.dto.ProfileDTO;
import com.gobbler.authentication.account.exception.UnauthorizedException;
import com.gobbler.authentication.account.model.UserAccount;
import com.gobbler.authentication.account.model.UserAccountRepository;
import com.gobbler.authentication.account.model.UserCreateRequest;

@Component
public class AccountService implements UserOps {

    private final UserAccountRepository userAccountRepository;

    private final BCryptPasswordEncoder bCryptPasswordEncoder = new BCryptPasswordEncoder();

    public AccountService(UserAccountRepository userAccountRepository) {
        this.userAccountRepository = userAccountRepository;
    }

    public UserAccount readUserByEmail (String email) {
        return userAccountRepository.findByEmail(email).orElseThrow(EntityNotFoundException::new);
    }

    public UserAccount createUser(UserCreateRequest userCreateRequest) {
        Optional<UserAccount> existingUser = userAccountRepository.findByEmail(userCreateRequest.getEmail());
        if (existingUser.isPresent()) {
            throw new IllegalArgumentException("User already exists");
        }
        UserAccount user = new UserAccount(userCreateRequest.getEmail(), userCreateRequest.getPassword());
        userAccountRepository.save(user);
        return user;
    }

    // @Override
    // public ProfileDTO userLogin(String email, String password) {

    //     if(email.equalsIgnoreCase("testex")) {
    //         throw new UnauthorizedException("userlogin");
    //     }

    //     return new ProfileDTO("test", "test", "123456", Arrays.asList("Administrator"));
    // }
}
