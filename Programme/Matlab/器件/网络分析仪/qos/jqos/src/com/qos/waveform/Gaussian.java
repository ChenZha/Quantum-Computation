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
public final class Gaussian extends Waveform {
    private final float amplitude;
    private final float sigma;

    private static class CacheKey extends Waveform.CacheKey {
        private final float amplitude;
        private final float sigma;

        private CacheKey(int length, float carrierFrequency,
                         float amplitude, float sigma){
            super(length, carrierFrequency);
            this.amplitude = amplitude;
            this.sigma = sigma;
        }

        @Override
        public int hashCode(){
            int code = 31*super.hashCode() + (int)(1e4*amplitude);
            code = 31*code + (int)(1e4*sigma);
            return code;
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return amplitude == o.amplitude && sigma == o.sigma;
        }
    }

    public Gaussian(int length, float amplitude) throws IllegalArgumentException{
        super(length);
        if (length < 2) {
            throw new IllegalArgumentException("minimum length of Gaussian Envelop is 2, " +length + " given.");
        }
        this.amplitude = amplitude;
        this.sigma = 0.21230F*length;
    }

    // rSigma: sigma/length, default: 0.212330, waveform length is 2*FWHM
    public Gaussian(int length, float amplitude, float rSigma){
        super(length);
        if (rSigma <= 0){
            throw(new IllegalArgumentException("zero or negative sigma."));
        }
        this.amplitude = amplitude;
        this.sigma = rSigma*length;
    }

    public Gaussian copy(){
        Gaussian newWaveform =  new Gaussian(length, amplitude, sigma/length);
        newWaveform._copy(this);
        return newWaveform;
    }

    CacheKey getCacheKey(){
        return new CacheKey(length, carrierFrequency,amplitude,sigma);
    }

    float[] _freqSamples(){
        float[] f = shiftedSampleFrequencies();
        float ampF = 2.506628274631000F*amplitude*sigma;
        float tempVar1 = 2* FloatMath.sqr(1/(6.283185307179586F*sigma));
        float [] v = new float[2*f.length];
        // float t0 = tStart + ((float)length-1F)/2;
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        for (int i = 0; i < 2*f.length; i += 2){
            tempVar2 = ampF*FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
            tempVar3 = -6.283185307179586F*f[i/2]*t0;
            v[i] = tempVar2*FloatMath.cos(tempVar3);
            v[i+1] = tempVar2*FloatMath.sin(tempVar3);
        }
        return v;
    }

    public float[] freqSamples(float[] f){
        float ampF = 2.506628274631000F*amplitude*sigma;
        float tempVar1 = 2*FloatMath.sqr(1/(6.283185307179586F*sigma));
        float [] v = new float[2*f.length];
        float t0 = ((float)length-1F)/2;
        float tempVar2;
        float tempVar3;
        for (int i = 0; i < 2*f.length; i += 2){
            tempVar2 = ampF*FloatMath.exp(-FloatMath.sqr(f[i/2])/tempVar1);
            tempVar3 = -6.283185307179586F*f[i/2]*t0;
            v[i] = tempVar2*FloatMath.cos(tempVar3)*scaleFactor;
            v[i+1] = tempVar2*FloatMath.sin(tempVar3)*scaleFactor;
        }
        return v;
    }
}
