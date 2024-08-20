package com.ll.sapp.global.initData;

import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class All {
    @Bean
    public ApplicationRunner initDataAll() {
        return args -> {
            System.out.println("이 부분은 스프링부트가 시작되면 자동으로 실행됩니다.");
            System.out.println("이 부분에 초기화 작업을 넣어주세요.");
        };
    }
}
