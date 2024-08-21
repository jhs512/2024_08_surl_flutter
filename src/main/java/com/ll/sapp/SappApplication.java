package com.ll.sapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class SappApplication {

    public static void main(String[] args) {
        SpringApplication.run(SappApplication.class, args);
    }

}
