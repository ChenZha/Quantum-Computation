package com.qos.waveform;

import com.qos.math.Interpolation;
import com.qos.math.DoubleMath;
import com.qos.math.FloatMath;
import com.qos.math.IntMath;
import com.qos.math.FloatFFT;

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
public final class XfrFuncNumeric extends XfrFunc {
    private final float[] frequency;
    private final float[] amplitudeRe;
    private final float[] amplitudeIm;
    private int hashCode;

    public XfrFuncNumeric(float[] frequency, float[] freqAmplitudeRe, float[] freqAmplitudeIm) throws IllegalArgumentException {
        if (freqAmplitudeRe.length != frequency.length || freqAmplitudeRe.length != freqAmplitudeIm.length){
            throw(new IllegalArgumentException("length of frequency, ferqAmplitudeRe and freqAmplitudeIm mismatch."));
        }
        if (freqAmplitudeRe.length < 2){
            throw(new IllegalArgumentException("length of frequency, length frequency less than 2."));
        }
        this.frequency = frequency;
        this.amplitudeRe = freqAmplitudeRe;
        this.amplitudeIm = freqAmplitudeIm;

        float[] s0 = samples(new float[]{0});
        float a0 = FloatMath.sqrt(s0[0]*s0[0]+s0[1]*s0[1]);
        int i=0;
        while (i<amplitudeRe.length){
            amplitudeRe[i] /= a0;
            amplitudeIm[i] /= a0;
            i++;
        }
    }


    public XfrFuncNumeric(float[] timeSamples, float fs){
        this(timeSamples, fs, 0,false);
    }

    public XfrFuncNumeric(float[] timeSamples, float fs, float tShift){
        this(timeSamples, fs, tShift,false);
    }

    public XfrFuncNumeric(float[] timeSamples, float fs, float tShift,boolean correctImpulse){
        // fs: timeSamples sampling frequency in unit of DA sampling frequency
        int numSamples = IntMath.nextPow2(timeSamples.length);
        float[] samples = new float[2*numSamples];
        for (int i=0; i< timeSamples.length; i++){
            samples[2*i] = timeSamples[i];
        }
        FloatFFT.fft(samples);

        frequency = new float[numSamples];
        amplitudeRe = new float[numSamples];
        amplitudeIm = new float[numSamples];

        int cInd = numSamples/2;
        int ind;
        int i=0;
        float df = fs/numSamples;
        while (i<cInd){
            ind = i+cInd;
            frequency[ind] = df*i;
            amplitudeRe[ind] = samples[2*i];
            amplitudeIm[ind] = samples[2*i+1];
            i++;
        }
        while (i<numSamples){
            ind = i-cInd;
            frequency[ind] = df*(i-numSamples);
            amplitudeRe[ind] = samples[2*i];
            amplitudeIm[ind] = samples[2*i+1];
            i++;
        }

        if (tShift !=0) {
            float phi;
            for (i = 0; i < frequency.length; i++) {
                phi = 6.283185307179586F * tShift * frequency[i];
                amplitudeRe[i] = amplitudeRe[i] * FloatMath.cos(phi);
                amplitudeIm[i] = amplitudeIm[i] * FloatMath.sin(phi);
            }
        }

        if (correctImpulse){
            float tempVar;
            for (i = 0; i < frequency.length; i++) {
                tempVar = (float) DoubleMath.sinc(frequency[i]);
                amplitudeRe[i] = amplitudeRe[i]/tempVar;
                amplitudeIm[i] = amplitudeIm[i]/tempVar;
            }
        }

        float[] s0 = samples(new float[]{0});
        float a0 = FloatMath.sqrt(s0[0]*s0[0]+s0[1]*s0[1]);
        i=0;
        while (i<numSamples){
            amplitudeRe[i] /= a0;
            amplitudeIm[i] /= a0;
            i++;
        }
    }

    float[] samples(final float[] f){
        // f must be equidistant, starts from -0.5 and ends at 0.5: to be fast,
        // this condition is NOT checked, the caller has to guarantee that!
        // XfrFuncs are only intended to be used for Envelopes, which only calls
        // with equidistant f starts from -0.5 and ends at 0.5

        CacheKey cacheKey = new CacheKey(f.length);
        float[] v = cache.get(cacheKey);
        if (v != null) return v.clone();
        v =  new float[2*f.length];

        // cubbic interpolation works fine for smooth functions,
        // it is probematic for functions with pikes or sharp turning points,
        // int results in asymmetric peaks for sharp symmetric peaks.
        //float[] vRe = Interpolation.eqDistCubic1d(frequency, amplitudeRe,f);
        // float[] vIm = Interpolation.eqDistCubic1d(frequency, amplitudeIm,f);

        float[] vRe = Interpolation.eqDistLinear1d(frequency, amplitudeRe,f,0);
        float[] vIm = Interpolation.eqDistLinear1d(frequency, amplitudeIm,f,0);

        //float tempVar1;
        int j;
        for (int i=0; i<f.length; i++){
            j = 2*i;
            v[j] = vRe[i];
            v[j+1] = vIm[i];
        }
        cache.put(cacheKey,v.clone());
        return v;
    }

    public float[] samples_t(final float[] f){
        // f must be equidistant, starts from -0.5 and ends at 0.5: to be fast,
        // this condition is NOT checked, the caller has to guarantee that!
        // XfrFuncs are only intended to be used for Envelopes, which only calls
        // with equidistant f starts from -0.5 and ends at 0.5

        float[] v =  new float[2*f.length];

        // cubic interpolation works fine for smooth functions,
        // it is probematic for functions with pikes or sharp turning points,
        // int results in asymmetric peaks for sharp symmetric peaks.
        // float[] vRe = Interpolation.eqDistCubic1d(frequency, amplitudeRe,f);
        // float[] vIm = Interpolation.eqDistCubic1d(frequency, amplitudeIm,f);

        float[] vRe = Interpolation.eqDistLinear1d(frequency, amplitudeRe, f,0);
        float[] vIm = Interpolation.eqDistLinear1d(frequency, amplitudeIm, f,0);

        //float tempVar1;
        int j;
        for (int i=0; i<f.length; i++){
            j = 2*i;
            v[j] = vRe[i];
            v[j+1] = vIm[i];
        }
        return v;
    }

    @Override
    public int hashCode(){
        if (hashCode != 0) return hashCode;
        int numSamples = frequency.length;
        float s1 = frequency[0];
        float s2 = frequency[numSamples-1];
        float s3 = 0;
        float s4 = 0;
        float s5 = 0;
        float s6 = 0;
        for (int i=0; i<numSamples; i++){
            s3 += amplitudeRe[i];
            s4 += amplitudeIm[i];
            s5 += amplitudeRe[i]*amplitudeIm[i];
            s6 += amplitudeRe[i]*amplitudeIm[numSamples-i-1];
        }
        int code = numSamples;
        code = code*31 + (int)(s1*1e2);
        code = code*31 + (int)(s2*1e2);
        code = code*31 + (int)(s3*1e3);
        code = code*31 + (int)(s4*1e3);
        code = code*31 + (int)(s5*1e3);
        code = code*31 + (int)(s6*1e3);
        hashCode = code; // cache hashCode
        return code;
    }

    class CacheKey extends XfrFunc.CacheKey{
        private float[] frequency(){return frequency;}
        private float[] amplitudeRe(){return amplitudeRe;}
        private float[] amplitudeIm(){return amplitudeIm;}

        CacheKey(int length){
            super(length);
        }
        @Override
        public int hashCode(){
            int code = super.hashCode();
            return code*31 + hashCode;
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            if (frequency.length != o.frequency().length) return false;
            float[] o_frequency = o.frequency();
            float[] o_amplitudeRe = o.amplitudeRe();
            float[] o_amplitudeIm = o.amplitudeIm();
            for (int i= 0; i< frequency().length; i++){
                if (frequency[i] != o_frequency[i] ||
                        amplitudeRe[i] != o_amplitudeRe[i] ||
                        amplitudeIm[i] != o_amplitudeIm[i]){ return false;}
            }
            return true;
        }
    }
}
