package com.qos.waveform;

import com.qos.math.FloatMath;
import com.qos.math.Interpolation;
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

// adiabatic cz gate waveform
// reference: J. M. Martinis and M. R. Geller, Phys. Rev. A 90, 022307(2014)
// acz waveform can not be frequency mixed, the carrierFrequency property is not used
public final class ACZ extends Waveform{
    private final float amplitude; // = 1F;
    private final float thf; // = 0.863937979737193F;
    private final float thi; // = 0.05F;
    private final float lam2; // = -0.18F;
    private final float lam3; // = 0.04F;

    public ACZ(int length, float amplitude, float thf, float thi, float lam2, float lam3) {
        super(length);
        this.amplitude = amplitude;
        this.thf = thf;
        this.thi = thi;
        this.lam2 = lam2;
        this.lam3 = lam3;
    }

    public ACZ copy(){
        ACZ newWaveform =  new ACZ(length, amplitude, thf, thi, lam2, lam3);
        newWaveform._copy(this);
        return newWaveform;
    }

    private class CacheKey extends Waveform.CacheKey {
        private final float amplitude;
        private final float thf;
        private final float thi;
        private final float lam2;
        private final float lam3;

        private CacheKey(int length, float carrierFrequency,
                         float amplitude, float thf, float thi, float lam2, float lam3){
            super(length, carrierFrequency);
            this.amplitude = amplitude;
            this.thf = thf;
            this.thi = thi;
            this.lam2 = lam2;
            this.lam3 = lam3;
        }

        @Override
        public int hashCode(){
            int code = 31*super.hashCode() + (int)(1e4*amplitude);
            code = 31*code + (int)(1e4*thf);
            code = 31*code + (int)(1e4*thi);
            code = 31*code + (int)(1e4*lam2);
            code = 31*code + (int)(1e4*lam3);
            return code;
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return super.equals(o) &&
                    amplitude == o.amplitude && thf == o.thf && thi == o.thi
                    && lam2 == o.lam2 && lam3 == o.lam3;
        }
    }

    CacheKey getCacheKey(){
        return new CacheKey(length, carrierFrequency,
            amplitude, thf, thi, lam2, lam3);
    }

    float[] _freqSamples() {
        float[] ti = FloatMath.linSpace(0,1,length);
        float[] han2 = new float[length];
        for (int i=0; i<length; i++ ){
            han2[i] = (1-lam3)*(1-FloatMath.cos(6.283185307179586F*ti[i]))
                    +lam2*(1-FloatMath.cos(12.566370614359172F*ti[i]))
                    +lam3*(1-FloatMath.cos(18.849555921538759F*ti[i]));
        }
        float maxH = han2[0];
        for (int i=1; i<length; i++ ){
            maxH = Math.max(maxH,han2[i]);
        }

        float[] thsl = new float[length];
        for (int i=0; i<length; i++ ){
            thsl[i]= thi+(thf-thi)*han2[i]/maxH;
        }
        float[] tlu = new float[length];
        for (int i=1; i<length; i++ ){
            tlu[i] = FloatMath.sin(thsl[i])*ti[1]+tlu[i-1];
        }

        ti=FloatMath.linSpace(0, tlu[tlu.length-1], length);

        float[] th = Interpolation.ascendLinear1d(tlu, thsl, ti,thsl[thsl.length-1]);

        /*
        SimplePlot plt0 = new SimplePlot("time", "amplitude",
                "QOS | Tester | Waveform", "ACZ___");
        plt0.addDataSet(tlu, thsl,"1");
        plt0.addDataSet(ti, th,"samples by freqFunc and iFFT, real part");
        plt0.plot();
        */

        float th0 = 1/FloatMath.tan(th[0]);
        for (int i=0; i<length; i++ ){
            th[i] = 1/FloatMath.tan(th[i]);
            th[i] -= th0;
        }

        float minT = th[0];
        for (int i=1; i<length; i++ ){
            minT = Math.min(minT,th[i]);
        }
        for (int i=0; i<length; i++ ) {
            th[i] = amplitude*th[i] / minT;
        }

        float[] samples = new float[2*numSamples];
        for (int i=0; i<th.length; i++){
            samples[2*i] = th[i];
        }

        // TODO: use real fft
        FloatFFT.fft(samples);
        return samples;
    }

    // a user demand to inspect the frequency samples, as far as QOS is considered, this method is never used.
    public float[] freqSamples(float[] f) {
        float[] ti = FloatMath.linSpace(0,1,length);
        float[] han2 = new float[length];
        for (int i=0; i<length; i++ ){
            han2[i] = (1-lam3)*(1-FloatMath.cos(6.283185307179586F*ti[i]))
                    +lam2*(1-FloatMath.cos(12.566370614359172F*ti[i]))
                    +lam3*(1-FloatMath.cos(18.849555921538759F*ti[i]));
        }
        float maxH = han2[0];
        for (int i=1; i<length; i++ ){
            maxH = Math.max(maxH,han2[i]);
        }

        float[] thsl = new float[length];
        for (int i=0; i<length; i++ ){
            thsl[i]= thi+(thf-thi)*han2[i]/maxH;
        }
        float[] tlu = new float[length];
        for (int i=1; i<length; i++ ){
            tlu[i] = FloatMath.sin(thsl[i])*ti[1]+tlu[i-1];
        }

        ti=FloatMath.linSpace(0, tlu[tlu.length-1], length);

        float[] th = Interpolation.ascendLinear1d(tlu, thsl, ti,thsl[thsl.length-1]);

        /*
        SimplePlot plt0 = new SimplePlot("time", "amplitude",
                "QOS | Tester | Waveform", "ACZ___");
        plt0.addDataSet(tlu, thsl,"1");
        plt0.addDataSet(ti, th,"samples by freqFunc and iFFT, real part");
        plt0.plot();
        */

        float th0 = 1/FloatMath.tan(th[0]);
        for (int i=0; i<length; i++ ){
            th[i] = 1/FloatMath.tan(th[i]);
            th[i] -= th0;
        }

        float minT = th[0];
        for (int i=1; i<length; i++ ){
            minT = Math.min(minT,th[i]);
        }
        for (int i=0; i<length; i++ ) {
            th[i] = amplitude*th[i] / minT;
        }

        float[] samples = new float[2*numSamples];
        for (int i=0; i<th.length; i++){
            samples[2*i] = th[i];
        }

        // TODO: use real fft
        FloatFFT.fft(samples);

        float[] samplesRe = new float[samples.length/2];
        float[] samplesIm = new float[samples.length/2];
        for (int i=0; i<samplesRe.length; i++){
            samplesRe[i] = samples[2*i];
            samplesIm[i] = samples[2*i+1];
        }
        carrierFrequency = 0; // acz can not be frequency mixed
        float[] frequency = shiftedSampleFrequencies();
        float[] vRe = Interpolation.eqDistCubic1d(frequency, samplesRe,f);
        float[] vIm = Interpolation.eqDistCubic1d(frequency, samplesIm,f);
        float[] v = new float[2*f.length];
        for (int i=0; i<f.length; i+=2){
            v[i] = vRe[i/2];
            v[i+1] = vIm[i/2];
        }
        return v;
    }

}

