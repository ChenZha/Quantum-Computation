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
// Resonator QReadout pulse with Ringing
public class RRRing extends Waveform{
    private Waveform internalWv;

    public RRRing(int length, float amplitude, float edgeWidth,
                  float ringAmplitude, int ringWidth){
        super(length);
        Flattop flattopWv = new Flattop(length, amplitude, edgeWidth);
        Gaussian gaussian = new Gaussian(2*ringWidth, ringAmplitude);
        internalWv = flattopWv.add(gaussian);
    }

    private RRRing(int length){
        super(length);
    }

    public RRRing copy(){
        RRRing newWaveform =  new RRRing(length);
        newWaveform.internalWv = internalWv.copy();
        newWaveform._copy(this);
        return newWaveform;
    }

    CacheKey getCacheKey(){return null;}
    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache){
        internalWv.carrierFrequency = carrierFrequency;
        internalWv.phase = phase;

        float scaleFactor = getScaleFactor();
        float[] v = internalWv.samples(tStart, padLength, xfrFunc, cache);
        for (int i=0; i<v.length; i++){
            v[i] = scaleFactor*v[i];
        }
        return v;
    }

    float[] _freqSamples() {
        // should never be called
        return null;
    }
    public float[] freqSamples(float[] f){
        float[] v = internalWv.freqSamples(f);
        for (int i=0; i<v.length; i++){
            v[i] *= scaleFactor;
        }
        return v;
    }
}
