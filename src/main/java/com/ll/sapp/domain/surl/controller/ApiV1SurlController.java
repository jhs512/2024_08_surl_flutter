package com.ll.sapp.domain.surl.controller;

import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.service.SurlService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/surls")
@RequiredArgsConstructor
public class ApiV1SurlController {
    private final SurlService surlService;

    @GetMapping("")
    public List<Surl> getSurls() {
        return surlService.findAll();
    }
}
