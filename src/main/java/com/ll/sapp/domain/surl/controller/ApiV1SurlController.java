package com.ll.sapp.domain.surl.controller;

import com.ll.sapp.domain.surl.dto.SurlDto;
import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.service.SurlService;
import com.ll.sapp.global.rsData.RsData;
import com.ll.sapp.standard.dto.Empty;
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
    public RsData<SurlDto> add(
            @Valid @RequestBody SurlAddReqBody reqBody
    ) {
        Surl surl = surlService.add(reqBody.url(), reqBody.subject());

        return new RsData<>("200-1", "%d번 URL이 생성되었습니다.".formatted(surl.getId()), new SurlDto(surl));
    }


    public record SurlModifyReqBody(
            @NotBlank String url,
            @NotBlank String subject
    ) {
    }

    @PutMapping("/{id}")
    @Transactional
    public RsData<SurlDto> modify(
            @PathVariable long id,
            @Valid @RequestBody SurlModifyReqBody reqBody
    ) {
        Surl surl = surlService.findById(id).get();
        surlService.modify(surl, reqBody.url(), reqBody.subject());

        return new RsData<>("200-1", "%d번 URL이 수정되었습니다.".formatted(surl.getId()), new SurlDto(surl));
    }


    @DeleteMapping("/{id}")
    @Transactional
    public RsData<Empty> delete(
            @PathVariable long id
    ) {
        Surl surl = surlService.findById(id).get();
        surlService.delete(surl);

        return new RsData<>("200-1", "삭제되었습니다.");
    }
}
