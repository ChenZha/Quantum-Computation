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
* 单比特门保真度，NULL 表示没有数据，页面显示
 */
public class OneQGateFidelities {
    // 门作用的比特编号
    private int qubit;

    // X 门保真度
    private Float x;
    // X/2 门保真度
    private Float x2p;
    // -X/2 门保真度
    private Float x2m;
    // Y 门保真度
    private Float y;
    // Y/2 门保真度
    private Float y2p;
    // -Y/2 门保真度
    private Float y2m;
    // Z 门保真度
    private Float z;
    // Z/2 门保真度
    private Float z2p;
    // -Z/2 门保真度
    private Float z2m;
    // H 门保真度
    private Float h;

    public OneQGateFidelities(){}

    public float getX() {
        return x;
    }

    public void setX(Float x) {
        this.x = x;
    }

    public float getX2p() {
        return x2p;
    }

    public void setX2p(Float x2p) {
        this.x2p = x2p;
    }

    public float getX2m() {
        return x2m;
    }

    public void setX2m(Float x2m) {
        this.x2m = x2m;
    }

    public float getY() {
        return y;
    }

    public void setY(Float y) {
        this.y = y;
    }

    public float getY2p() {
        return y2p;
    }

    public void setY2p(Float y2p) {
        this.y2p = y2p;
    }

    public float getY2m() {
        return y2m;
    }

    public void setY2m(Float y2m) {
        this.y2m = y2m;
    }

    public float getZ() {
        return z;
    }

    public void setZ(Float z) {
        this.z = z;
    }

    public float getZ2p() {
        return z2p;
    }

    public void setZ2p(Float z2p) {
        this.z2p = z2p;
    }

    public float getZ2m() {
        return z2m;
    }

    public void setZ2m(Float z2m) {
        this.z2m = z2m;
    }

    public float getH() {
        return h;
    }

    public void setH(Float h) {
        this.h = h;
    }


}
