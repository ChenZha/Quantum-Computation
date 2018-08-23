package com.qos.waveform;

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
public final class Cos extends Waveform {
    private final float amplitude;

    private static class CacheKey extends Waveform.CacheKey {
        private final float amplitude;

        private CacheKey(int length, float carrierFrequency,
                         float amplitude){
            super(length, carrierFrequency);
            this.amplitude = amplitude;
        }

        @Override
        public int hashCode(){
            return 31*super.hashCode() + (int)(1e4*amplitude);
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return amplitude == o.amplitude;
        }
    }

    public Cos(int length, float amplitude) throws IllegalArgumentException{
        super(length);
        if (length < 2) {
            throw new IllegalArgumentException("minimum length of Cos Envelop is 2, " +length + " given.");
        }
        this.amplitude = amplitude;
    }

    public Cos copy(){
        Cos newWaveform =  new Cos(length, amplitude);
        newWaveform._copy(this);
        return newWaveform;
    }

    CacheKey getCacheKey(){
        return new CacheKey(length, carrierFrequency,amplitude);
    }

    float[] _freqSamples(){
        float[] f = shiftedSampleFrequencies();
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        for (int i = 0; i < 2*f.length; i += 2) {
            tempVar2 = amplitude/2.0F*(length/2.0F*((float) DoubleMath.sinc(1-length*f[i/2]))+
                    length/2.0F*((float) DoubleMath.sinc(-1-length*f[i/2]))+
                    length*((float) DoubleMath.sinc(length*f[i/2])));
            tempVar3 = -6.283185307179586F*f[i/2]*t0;
            v[i] = tempVar2*FloatMath.cos(tempVar3);
            v[i+1] = tempVar2*FloatMath.sin(tempVar3);
        }
        return v;
    }

    public float[] freqSamples(float[] f){
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        for (int i = 0; i < 2*f.length; i += 2) {
            tempVar2 = amplitude/2.0F*(length/2.0F*((float) DoubleMath.sinc(1-length*f[i/2]))+
                    length/2.0F*((float) DoubleMath.sinc(-1-length*f[i/2]))+
                    length*((float) DoubleMath.sinc(length*f[i/2])));
            tempVar3 = -6.283185307179586F*f[i/2]*t0;
            v[i] = tempVar2*FloatMath.cos(tempVar3);
            v[i+1] = tempVar2*FloatMath.sin(tempVar3);
        }
        return v;
    }
}