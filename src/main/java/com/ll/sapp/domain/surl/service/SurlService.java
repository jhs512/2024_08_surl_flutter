package com.ll.sapp.domain.surl.service;

import com.ll.sapp.domain.surl.entity.Surl;
import com.ll.sapp.domain.surl.repository.SurlRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SurlService {
    private final SurlRepository surlRepository;

    @Transactional
    public Surl add(String url, String title) {
        Surl surl = new Surl(url, title);
        return surlRepository.save(surl);
    }

    public List<Surl> findAll() {
        return surlRepository.findAll();
    }

    public long count() {
        return surlRepository.count();
    }

    public Optional<Surl> findById(long id) {
        return surlRepository.findById(id);
    }
}
