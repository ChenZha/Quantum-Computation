package com.qos.waveform;

import com.github.benmanes.caffeine.cache.Cache;

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
public final class DC extends Waveform {
    private final float level;
    public DC(int length, float lvl){
        super(length);
        level = lvl;
    }

    public DC copy(){
        return new DC(length,level);
    }

    CacheKey getCacheKey(){return null;}

    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache) { // DC is rarely used, thus not cached
        float[] v =  new float[2*length];
        for (int i=0; i< v.length; i++){
            v[i] = level;
        }
        return v;
    }

    float[] _freqSamples() {
        // should never be called
        return null;
    }
    public float[] freqSamples(float[] f) {
        float[] v = new float[2*f.length];
        for (int i = 0; i<v.length; i += 2){
            if (f[i/2]==0) {
                v[i] = f.length;
            }
        }
        return v;
    }

}
