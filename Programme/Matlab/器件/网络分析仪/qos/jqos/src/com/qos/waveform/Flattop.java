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

import com.qos.math.DoubleMath;
import com.qos.math.FloatMath;

/** Trapezoid: rectangular pulse with gaussian rising and falling edges,
* it is a rectangular pulse convolved with an gaussian filter.
  */

public class Flattop extends Waveform {
    private final float amplitude;
    private final float edgeWidth;

    static class CacheKey extends Waveform.CacheKey {
        private final float amplitude;
        private final float edgeWidth;

        CacheKey(int length, float carrierFrequency,
                 float amplitude, float edgeWidth){
            super(length, carrierFrequency);
            this.amplitude = amplitude;
            this.edgeWidth = edgeWidth;
        }
        @Override
        public int hashCode(){
            int code = 31*super.hashCode() + (int)(1e4*amplitude);
            code = 31*code + (int)(1e4*edgeWidth);
            return code;
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return amplitude == o.amplitude && edgeWidth == o.edgeWidth;
        }
    }

    public Flattop(int length, float amplitude, float edgeWidth){
        super(length);
        if (edgeWidth < 1){
            throw new IllegalArgumentException(String.format("edgeWidth %.4f less than 1",edgeWidth));
        }
        if (length-1 < 2*edgeWidth){
            throw new IllegalArgumentException(
                    String.format("length %d shorter than 2*edgeWidth+1, edgeWidth %.4f", length, edgeWidth));
        }
        this.edgeWidth = edgeWidth;
        this.amplitude = amplitude;
    }

    public Flattop copy(){
        Flattop newWaveform =  new Flattop(length, amplitude, edgeWidth);
        newWaveform._copy(this);
        return newWaveform;
    }

    CacheKey getCacheKey(){
        return new CacheKey(length, carrierFrequency,amplitude, edgeWidth);
    }

    float[] _freqSamples() {
        float[] f = shiftedSampleFrequencies();
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        float tempVar4;
        float topLength = length - (edgeWidth)-1;
        float tempVar1 = 2* FloatMath.sqr(0.749562486F/(edgeWidth-1));

        for (int i = 0; i < 2*f.length; i += 2){
            tempVar2 = amplitude*topLength*(float) DoubleMath.sinc(f[i/2]*topLength);
            tempVar3 = -6.283185307179586F*f[i/2]*t0;

            tempVar4 = FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
            v[i] = tempVar2* FloatMath.cos(tempVar3)*tempVar4;
            v[i+1] = tempVar2*FloatMath.sin(tempVar3)*tempVar4;
        }
        return v;
    }

    public float[] freqSamples(float[] f) {
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        float tempVar4;
        float topLength = length - (edgeWidth)-1;
        float tempVar1 = 2* FloatMath.sqr(0.749562486F/(edgeWidth-1));

        for (int i = 0; i < 2*f.length; i += 2){
            tempVar2 = amplitude*topLength*(float) DoubleMath.sinc(f[i/2]*topLength);
            tempVar3 = -6.283185307179586F*f[i/2]*t0;

            tempVar4 = FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
            v[i] = tempVar2* FloatMath.cos(tempVar3)*tempVar4*scaleFactor;
            v[i+1] = tempVar2*FloatMath.sin(tempVar3)*tempVar4*scaleFactor;
        }
        return v;
    }
}

