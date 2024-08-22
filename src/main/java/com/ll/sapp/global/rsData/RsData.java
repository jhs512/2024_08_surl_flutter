package com.ll.sapp.global.rsData;

import lombok.Getter;

@Getter
public class RsData<T> {
    private String resultCode;
    private String msg;
    private T body;

    public RsData(String resultCode, String msg) {
        this(resultCode, msg, null);
    }

    public RsData(String resultCode, String msg, T body) {
        this.resultCode = resultCode;
        this.msg = msg;
        this.body = body;
    }
}
