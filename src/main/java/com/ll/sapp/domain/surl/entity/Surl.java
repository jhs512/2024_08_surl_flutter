package com.ll.sapp.domain.surl.entity;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Surl {
    private Long id;
    private String url;
    private String title;

    public Surl(String url, String title) {
        this.url = url;
        this.title = title;
    }
}
