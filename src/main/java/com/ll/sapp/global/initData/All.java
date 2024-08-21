package com.ll.sapp.global.initData;

import com.ll.sapp.domain.surl.service.SurlService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class All {
    private final SurlService surlService;

    @Bean
    public ApplicationRunner initDataAll() {
        return args -> {
            if ( surlService.count() > 0 ) return;

            surlService.add("https://www.google.com", "구글");
            surlService.add("https://www.naver.com", "네이버");
            surlService.add("https://www.daum.net", "다음");
        };
    }
}
