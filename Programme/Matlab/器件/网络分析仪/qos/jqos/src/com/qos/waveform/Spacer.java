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
public final class Spacer extends Waveform {
    private static int CACHE_SIZE = (int)2e3; // Spacer are typically very short, 2e3 is sufficient
    // despite its simplicity, spacer is the most frequently used waveform,
    // we make a dedicated cache: samples for all possible Spacer waveforms.
    private static float[][] wvDataCache = new float[CACHE_SIZE][];
    static {
        for (int i = 0; i < CACHE_SIZE; i++) {
            wvDataCache[i] = new float[2*(i + 1)]; // the spacer waveform is treated differently from regular waveforms for performance.
        }
    }

    public Spacer(int length){
        super(length);
    }

    public Spacer copy(){
        return new Spacer(length);
    }

    CacheKey getCacheKey(){return null;}
    @Override
    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache){
        if (length <= CACHE_SIZE) {
            return wvDataCache[length-1];
        } else{
            // return new float[2*length+4*getPadLength()];
            return new float[2*length]; // the spacer waveform is treated differently from regular waveforms for performance.
        }
    }

    float[] _freqSamples() {
        // should never be called
        return null;
    }
    public float[] freqSamples(final float[] f) {
        float[] v = new float[2*f.length];
        v[0] = 0;
        return v;
    }
}


