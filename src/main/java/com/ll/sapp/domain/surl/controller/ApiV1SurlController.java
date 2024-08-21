package com.ll.sapp.domain.surl.controller;

import com.ll.sapp.domain.surl.dto.SurlDto;
import com.ll.sapp.domain.surl.service.SurlService;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/surls")
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ApiV1SurlController {
    private final SurlService surlService;

    @GetMapping("")
    public List<SurlDto> getSurls() {
        return surlService
                .findAll()
                .stream()
                .map(SurlDto::new)
                .toList();
    }
}
