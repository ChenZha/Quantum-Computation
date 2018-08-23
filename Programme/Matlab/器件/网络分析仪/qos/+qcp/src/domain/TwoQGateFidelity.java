package domain;

/**
 * Copyright (c) 2017 onward, Yulin Wu. All rights reserved.
 * <p>
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * This software is provided on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND.
 * <p>
 * mail4ywu@gmail.com/mail4ywu@icloud.com
 * University of Science and Technology of China.
 */
/*
* 两比特门保真度，NULL 表示没有数据，页面显示
 */
public class TwoQGateFidelity {
    // 门作用的第一个比特编号
    private int q1;
    // 门作用的第二个比特编号
    private int q2;
    // CZ 门保真度
    private Float cz;

    public TwoQGateFidelity(){}

    public int getQ1() {
        return q1;
    }

    public void setQ1(int q1) {
        this.q1 = q1;
    }

    public int getQ2() {
        return q2;
    }

    public void setQ2(int q2) {
        this.q2 = q2;
    }

    public float getCz() {
        return cz;
    }

    public void setCz(Float cz) {
        this.cz = cz;
    }
}
