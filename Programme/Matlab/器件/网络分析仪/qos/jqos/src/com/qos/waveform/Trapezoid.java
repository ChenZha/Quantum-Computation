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
public class Trapezoid extends Waveform {
    private final Rect internalWv1;
    private final Rect internalWv2;
    private final float amplitude;
    private final int edgeWidth;
    private final int plateauWidth;

    static class CacheKey extends Waveform.CacheKey {
        private final float amplitude;
        private final float edgeWidth;
        private final float plateauWidth;

        CacheKey(int length, float carrierFrequency,
                 float amplitude, float edgeWidth, float plateauWidth){
            super(length, carrierFrequency);
            this.amplitude = amplitude;
            this.edgeWidth = edgeWidth;
            this.plateauWidth = plateauWidth;
        }
        @Override
        public int hashCode(){
            int code = 31*super.hashCode() + (int)(1e4*amplitude);
            code = 31*code + (int)(1e4*edgeWidth);
            code = 31*code + (int)(1e4*plateauWidth);
            return code;
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return amplitude == o.amplitude && edgeWidth == o.edgeWidth
                    && plateauWidth == o.plateauWidth;
        }
    }

    public Trapezoid(float amplitude, int edgeWidth, int plateauWidth){
        super(plateauWidth+2*edgeWidth-2);
        if (edgeWidth < 1){
            throw new IllegalArgumentException(
                    String.format("edgeWidth %.4f less than 1",edgeWidth));
        }
        if (plateauWidth < 1){
            throw new IllegalArgumentException(
                    String.format("plateauWidth %.4f less than 1",edgeWidth));
        }
        internalWv1 = new Rect(edgeWidth,1);
        internalWv2 = new Rect(edgeWidth+plateauWidth-1,amplitude);
        this.amplitude = amplitude;
        this.edgeWidth = edgeWidth;
        this.plateauWidth = plateauWidth;
    }

    public Trapezoid copy(){
        Trapezoid newWaveform =  new Trapezoid(amplitude, edgeWidth, plateauWidth);
        newWaveform._copy(this);
        return newWaveform;
    }

    CacheKey getCacheKey(){
        return new CacheKey(length, carrierFrequency, amplitude, edgeWidth, plateauWidth);
    }

    float[] _freqSamples() {
        float[] f = shiftedSampleFrequencies();
        float[] v1 = internalWv1.freqSamples(f);
        float[] v2 = internalWv2.freqSamples(f);
        float[] v = new float[v1.length];
        for (int i = 0; i < v1.length; i += 2) {
            v[i] = (v1[i] * v2[i] - v1[i+1] * v2[i + 1])/edgeWidth;
            v[i + 1] = (v1[i] * v2[i + 1] + v1[i+1]* v2[i])/edgeWidth;
        }
        return v;
    }

    public float[] freqSamples(float[] f) {
        float[] v1 = internalWv1.freqSamples(f);
        float[] v2 = internalWv2.freqSamples(f);
        float[] v = new float[v1.length];
        for (int i = 0; i < v1.length; i += 2) {
            v[i] = (v1[i] * v2[i] - v1[i+1] * v2[i + 1])*scaleFactor/edgeWidth;
            v[i + 1] = (v1[i] * v2[i + 1] + v1[i+1]* v2[i])*scaleFactor/edgeWidth;
        }
        return v;
    }
}

