package com.ll.sapp.domain.surl.service;

import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.repository.SurlRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SurlService {
    private final SurlRepository surlRepository;

    public void add(String url, String title) {
        Surl surl = new Surl(url, title);
        surlRepository.save(surl);
    }

    public List<Surl> findAll() {
        return surlRepository.findAll();
    }
}
