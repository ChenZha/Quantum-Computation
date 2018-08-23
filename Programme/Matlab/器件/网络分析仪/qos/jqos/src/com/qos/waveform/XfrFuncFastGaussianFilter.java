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
// a gaussian shaped filter that rolls off fast to zero around half sampling frequency.
public class XfrFuncFastGaussianFilter extends XfrFuncGaussianFilter{
    public XfrFuncFastGaussianFilter(float bandWidth, float attenuation){
        super(bandWidth,attenuation);
    }
    public XfrFuncFastGaussianFilter(float bandWidth){
        // by default, attenuation = 3dB
        super(bandWidth,3F);
    }
    class CacheKey extends XfrFuncGaussianFilter.CacheKey {
        CacheKey(int length){
            super(length);
        }

        public int hashCode(){
            return super.hashCode() + 1;
        }
    }
    @Override
    float[] samples(final float[] f) {
        CacheKey cacheKey = new CacheKey(f.length);
        float[] v = cache.get(cacheKey);
        if (v != null) return v.clone();
        v = new float[2*f.length];

        float tempVar1 = 2* FloatMath.sqr(sigmaf);
        for (int i = 0; i < 2*f.length; i += 2){
            v[i] = FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
        }
        float a0 = FloatMath.exp(-0.25F/tempVar1);
        float denominator = 1 - a0;
        for (int i = 0; i < 2*f.length; i += 2){
            v[i] = (v[i] - a0)/denominator;
        }
        cache.put(cacheKey,v.clone());
        return v;
    }
    @Override
    public float[] samples_t(final float[] f) {
        float[] v = new float[2*f.length];

        float tempVar1 = 2* FloatMath.sqr(sigmaf);
        for (int i = 0; i < 2*f.length; i += 2){
            v[i] = FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
        }
        float a0 = FloatMath.exp(-0.25F/tempVar1);
        float denominator = 1 - a0;
        for (int i = 0; i < 2*f.length; i += 2){
            v[i] = (v[i] - a0)/denominator;
        }
        return v;
    }
}
