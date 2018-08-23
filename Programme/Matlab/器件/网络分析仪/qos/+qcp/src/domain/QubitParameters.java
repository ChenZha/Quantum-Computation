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
* 比特参数，页面显示，注释显示格式是 latex, 可复制到http://latex.codecogs.com/eqneditor/editor.php查看
 */
public class QubitParameters {
    // 比特编号
    private int qubit;
    // 页面显示名称 f01
    private float f01;
    // 页面显示名称 f02
    private float f12;
    // 页面显示名称 T1
    private float T1;
    // 页面显示名称 T2^{*}
    private float T2star;
    // 页面显示名称 F_{readout}
    private float readoutFidelity;

    public QubitParameters(){}

    public float getF01() {
        return f01;
    }

    public void setF01(float f01) {
        this.f01 = f01;
    }

    public float getF12() {
        return f12;
    }

    public void setF12(float f12) {
        this.f12 = f12;
    }

    public float getT1() {
        return T1;
    }

    public void setT1(float t1) {
        T1 = t1;
    }

    public float getT2star() {
        return T2star;
    }

    public void setT2star(float t2star) {
        T2star = t2star;
    }

    public float getReadoutFidelity() {
        return readoutFidelity;
    }

    public void setReadoutFidelity(float readoutFidelity) {
        this.readoutFidelity = readoutFidelity;
    }

}
