package com.ll.sapp.domain.surl.controller;

import com.ll.sapp.domain.surl.dto.SurlDto;
import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.service.SurlService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/surls")
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ApiV1SurlController {
    private final SurlService surlService;

    @GetMapping("/{id}")
    public SurlDto getSurl(
            @PathVariable long id
    ) {
        return surlService
                .findById(id)
                .map(SurlDto::new)
                .get();
    }


    @GetMapping("")
    public List<SurlDto> getSurls() {
        return surlService
                .findAll()
                .stream()
                .map(SurlDto::new)
                .toList();
    }


    public record SurlAddReqBody(
            @NotBlank String url,
            @NotBlank String subject
    ) {
    }

    @PostMapping("")
    @Transactional
    public String add(
            @Valid @RequestBody SurlAddReqBody reqBody
    ) {
        Surl surl = surlService.add(reqBody.url(), reqBody.subject());
        String msg = surl.getId() + "번 단축URL이 생성되었습니다.";
        return "200-1/" + msg;
    }
}
