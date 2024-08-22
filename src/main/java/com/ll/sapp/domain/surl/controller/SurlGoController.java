package com.ll.sapp.domain.surl.controller;

import com.ll.sapp.domain.surl.dto.SurlDto;
import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.service.SurlService;
import com.ll.sapp.global.rsData.RsData;
import com.ll.sapp.standard.dto.Empty;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class SurlGoController {
    private final SurlService surlService;

    @GetMapping("/go/{id}")
    public String go(
            @PathVariable long id
    ) {
        Surl surl = surlService.findById(id).get();

        return "redirect:" + surl.getUrl();
    }
}
