package com.qos.waveform;

import com.github.benmanes.caffeine.cache.Cache;
import com.qos.math.DoubleMath;
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
// rectangular pulse directly evaluated by time funciton, not frequency mixing allowed
public class RectT extends Waveform {
    private final float amplitude;
    public RectT(int length, float amplitude){
        super(length);
        this.amplitude = amplitude;
    }

    public RectT copy(){
        return new RectT(length, amplitude);
    }

    // should never be used
    CacheKey getCacheKey(){return null;}

    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache) { // RectT is rarely used(mostly pulse calibration), thus not cached
        float[] v =  new float[2*numSamples];
        for (int i=2*padLength; i< 2*(padLength+length); i+=2){
            v[i] = amplitude;
        }
        return v;
    }

    float[] _freqSamples() {
        // should never be called
        return null;
    }
    public float[] freqSamples(float[] f){
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        for (int i = 0; i < 2*f.length; i += 2){
            tempVar2 = amplitude*length*(float) DoubleMath.sinc(f[i/2]*length);
            tempVar3 = -6.283185307179586F*f[i/2]*t0;
            v[i] = tempVar2* FloatMath.cos(tempVar3)*scaleFactor;
            v[i+1] = tempVar2*FloatMath.sin(tempVar3)*scaleFactor;
        }
        return v;
    }

}

