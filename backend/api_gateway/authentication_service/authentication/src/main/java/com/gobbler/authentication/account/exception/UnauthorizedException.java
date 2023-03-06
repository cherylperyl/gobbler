package com.gobbler.authentication.account.exception;

public class UnauthorizedException extends RuntimeException{

    public UnauthorizedException(String apiUrl) {
        super("No authorization granted to access " + apiUrl);
    }

}
