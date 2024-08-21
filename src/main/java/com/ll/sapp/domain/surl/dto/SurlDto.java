package com.ll.sapp.domain.surl.dto;

import com.ll.sapp.domain.surl.entity.Surl;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class SurlDto {
    private long id;
    private LocalDateTime createDate;
    private LocalDateTime modifyDate;
    private String url;
    private String subject;

    public SurlDto(Surl surl) {
        this.id = surl.getId();
        this.createDate = surl.getCreateDate();
        this.modifyDate = surl.getModifyDate();
        this.url = surl.getUrl();
        this.subject = surl.getTitle();
    }
}
