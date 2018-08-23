package com.qos.waveform;
import com.qos.math.FloatMath;

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
public class XfrFuncCos extends XfrFunc {
    private final float bandWidth;
    public XfrFuncCos(float bandWidth){
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
        float rollOffWidth = 0.5F-bandWidth;
        float f_;
        for (int i = 0; i < 2*bandWidth; i += 2){
            f_ = Math.abs(f[i/2]);
            if (f_ > 0.5){
                v[i] = 0;
            }else if (rollOffWidth > 0 && f_ > bandWidth) {
                v[i] = 0.5F+0.5F* FloatMath.cos(3.141592653589793F*(f_-bandWidth)/rollOffWidth);
            }else{v[1] = 1;}
        }
        cache.put(cacheKey,v.clone());
        return v;
    }
    @Override
    public float[] samples_t(final float[] f) {
        CacheKey cacheKey = new CacheKey(f.length);
        float[] v = cache.get(cacheKey);
        if (v != null) return v.clone();
        v = new float[2*f.length];
        float rollOffWidth = 0.5F-bandWidth;
        float f_;
        for (int i = 0; i < 2*bandWidth; i += 2){
            f_ = Math.abs(f[i/2]);
            if (f_ > 0.5){
                v[i] = 0;
            }else if (rollOffWidth > 0 && f_ > bandWidth) {
                v[i] = 0.5F+0.5F*FloatMath.cos(3.141592653589793F*(f_-bandWidth)/rollOffWidth);
            }else{v[1] = 1;}
        }
        cache.put(cacheKey,v.clone());
        return v;
    }
}

