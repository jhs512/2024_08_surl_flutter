package com.ll.sapp.domain.surl.repository;

import com.ll.sapp.domain.surl.entity.Surl;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class SurlRepository {
    private long lastId = 0;
    private List<Surl> surls = new ArrayList<>();

    public void save(Surl surl) {
        if (surl.getId() == null) {
            surl.setId(++lastId);
        }

        surls.add(surl);
    }

    public List<Surl> findAll() {
        return surls;
    }
}
