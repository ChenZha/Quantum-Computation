package com.qos.waveform;

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
public class XfrFuncFlat extends XfrFunc {
    private final float bandWidth;
    public XfrFuncFlat(float bandWidth){
        if (bandWidth <=0 ) {
            throw new IllegalArgumentException("non positive bandWidth value.");
        }
        this.bandWidth = bandWidth;
    }
    class CacheKey extends XfrFunc.CacheKey {
        private float bandWidth(){return bandWidth;}

        CacheKey(int length){
            super(length);
        }
        public int hashCode(){
            int code = super.hashCode();
            return code*31 + (int)(1e5*bandWidth);
        }
        public boolean equals(Object other){
            if (!super.equals(other)) {
                return false;
            }
            CacheKey o = (CacheKey) other;
            return bandWidth == o.bandWidth();
        }
    }
    @Override
    float[] samples(final float[] f) {
        CacheKey cacheKey = new CacheKey(f.length);
        float[] v = cache.get(cacheKey);
        if (v != null) return v.clone();
        v = new float[2*f.length];
        for (int i = 0; i < 2*bandWidth; i += 2){
            v[i] = 1F;
        }
        cache.put(cacheKey,v.clone());
        return v;
    }
    @Override
    public float[] samples_t(final float[] f) {
        float[] v = new float[2*f.length];
        for (int i = 0; i < 2*bandWidth; i += 2){
            v[i] = 1F;
        }
        return v;
    }
}
