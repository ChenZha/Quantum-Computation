package com.qos.waveform;

import com.qos.math.FloatFFT;
import com.qos.math.FloatMath;
import com.qos.math.IntMath;
import com.qos.exception.io.FilePathNotExistError;
//import org.jetbrains.annotations.Contract;

import java.nio.file.Files;
import java.nio.file.Path;
// import java.util.concurrent.ConcurrentHashMap;
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
public abstract class Waveform {
    // all properties defined in subclasses should be private, in this way all Waveform object
    // has only two public property: phase and carrierFrequency, all other parameters are passed in by the constructor.

    /*
    private static final int MIN_PAD_LENGTH = 16;
    // the padLength, if not set, will be set to MIN_PAD_LENGTH at the the first waveform creation
    // and can not be changed afterwards, thus it is strongly recommended to explicitly
    // set this global final property before any waveform creations, typically during the initialization
    // process.

    private static volatile int padLength;
    private static volatile int prePadLength;
    //@Contract(pure = true)
    // public static int getPadLength(){return padLength/2;}
    //@Contract(pure = true)
    // public static int getPrePadLength(){return prePadLength;}
    public synchronized static void setPadLength(int padLength_) throws SetFinalPropertyError {
        if (padLengthSet) {throw new SetFinalPropertyError("trying to set the final property padLength.");}
        if (padLength_<prePadLength){
            throw new IllegalArgumentException("padLength value less than minimum: "+prePadLength);
        }

        if (padLength_<MIN_PAD_LENGTH){
            throw new IllegalArgumentException("padLength value less than minimum: "+MIN_PAD_LENGTH);
        }

        padLength = padLength_*2;
        prePadLength = Math.max(MIN_PAD_LENGTH,padLength_/20);
        padLengthSet = true;
        loadCache();
    }

    private static volatile boolean padLengthSet = false;
    */

    public static final int prePadLength = 16;

	/*
    private static volatile Path cachePath;
    public synchronized static void setCachePath(Path path) throws FilePathNotExistError {
        if (!Files.exists(path)){
            throw new FilePathNotExistError("the given cache path: "+ path + " dose not exist.");}
        cachePath = path;
    }
	*/


    // carrierFrequency, phase are the only public properties
    public float carrierFrequency;
    public float phase; // only needed for IQ waveforms

    // scaleFactor is only used in sample evaluation and copy methods
    protected float scaleFactor = 1F; // protected because we need to set this property in copy methods of subclasses
    float getScaleFactor(){return scaleFactor;}
    final Waveform scale(float scaleFactor){
        Waveform newWaveform = this.copy();
        newWaveform.scaleFactor = this.scaleFactor*scaleFactor;
        return newWaveform;
    }

    public final int length;
    protected int numSamples; // numeric waveforms has to use this property, thus can not be private

    private float[] _sampleFrequencies;

    private float[] sampleFrequencies(){
        if (_sampleFrequencies != null) return _sampleFrequencies;
        _sampleFrequencies = new float[numSamples];
        int np  = IntMath.log2(numSamples);
        if (np <= SAMPLE_FREQ_TABLE_SIZE){
            for (int i=0; i<numSamples; i++){
                _sampleFrequencies[i] = sampleFreqTable[np-1][i];
            }
        } else {
            float df = 1F / numSamples;
            _sampleFrequencies[numSamples-1] = -df;
            for (int j = 1; j < numSamples/2; j++){
                _sampleFrequencies[j] = _sampleFrequencies[j-1] + df;
                _sampleFrequencies[numSamples-1-j] = _sampleFrequencies[numSamples-j] - df;
            }
        }
        return _sampleFrequencies;
    }
    protected final float[] shiftedSampleFrequencies(){
        float[] v0 = sampleFrequencies();
        float[] v = new float[v0.length];
        for (int i=0; i<v0.length; i++){
            v[i] = v0[i]-carrierFrequency;
        }
        return v;
    }

    private static final int SAMPLE_FREQ_TABLE_SIZE = 16;
    private static final float[][] sampleFreqTable = new float[SAMPLE_FREQ_TABLE_SIZE][];
    static{ // this saves 2/3 to 3/4 of the sampleFrequencies calculation time
        for (int i=0; i<SAMPLE_FREQ_TABLE_SIZE; i++){
            int numSamples = IntMath.pow(2,i+1);
            float df = 1F / numSamples;
            sampleFreqTable[i] = new float[numSamples];
            sampleFreqTable[i][numSamples-1] = -df;
            for (int j = 1; j < numSamples/2; j++){
                sampleFreqTable[i][j] = sampleFreqTable[i][j-1] + df;
                sampleFreqTable[i][numSamples-1-j] = sampleFreqTable[i][numSamples-j] - df;
            }
        }
    }

    static class CacheKey {
        private final int length;
        private final float carrierFrequency;

        CacheKey(int length,float carrierFrequency){
            this.length = length;
            this.carrierFrequency = carrierFrequency;
        }

        @Override
        public int hashCode(){
            int code = 23;
            code = code*31 + length;
            code = code*31 + (int) (1e5*carrierFrequency);
            return code;
        }
        @Override
        public boolean equals(Object other){
            if((other == null) || (this.getClass() != other.getClass())){
                return false;
            }
            CacheKey o = (CacheKey) other;
            return length == o.length &&
                    carrierFrequency == o.carrierFrequency;
        }
    }
    abstract CacheKey getCacheKey();

    Waveform(int length) {
        if (length <= 0 ) {
            throw new IllegalArgumentException("Zero or negative Waveform length.");
        } else{
            this.length = length;
        }
        // numSamples = IntMath.nextPow2(length+2*padLength);
    }

    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache){
        numSamples = IntMath.nextPow2(length+2*padLength);
        float[] v = (cache.get(getCacheKey(), key -> {
            float[] samples_ = _freqSamples();
            if (xfrFunc != null) {
                float[] xfrFuncSamples = xfrFunc.samples(sampleFrequencies());
                float tempVar;
                for (int i = 0; i < 2 * numSamples; i += 2) {
                    tempVar = samples_[i] * xfrFuncSamples[i] - samples_[i + 1] * xfrFuncSamples[i + 1];
                    samples_[i + 1] = samples_[i + 1] * xfrFuncSamples[i] + samples_[i] * xfrFuncSamples[i + 1];
                    samples_[i] = tempVar;
                }
            }
            // TODO: use real ifft
            FloatFFT.ifft(samples_);
            return samples_;
        })).clone();

        if (carrierFrequency !=0 ) {
            float phi = -phase + 6.283185307179586F * tStart * carrierFrequency;
            float re = FloatMath.cos(phi);
            float im = FloatMath.sin(phi);
            float tempVar;
            for (int i = 0; i < v.length; i += 2) {
                tempVar = (re * v[i] - im * v[i + 1]) * scaleFactor;
                v[i + 1] = (re * v[i + 1] + im * v[i]) * scaleFactor;
                v[i] = tempVar;
            }
        } else if(scaleFactor!=1F) {
            for (int i = 0; i < v.length; i += 2) {
                v[i] = v[i]* scaleFactor;
                v[i + 1] = v[i + 1]*scaleFactor;
            }
        }
        return v;
    }

    // envelop only
    // for better caching, _freqSamples need to calculate the samples without the scale factor,
    // while the pubic method freqSamples has to calculate with the scale factor, thus _freqSamples
    // is not implemented by calling freqSamples, it is implemented independently for performance.
    abstract float[] _freqSamples();
    public abstract float[] freqSamples(final float[] f);

    // except in DC and Spacer, the implemented copy method must call the _copy method
    public abstract Waveform copy();
    protected void _copy(Waveform source){
        phase = source.phase;
        carrierFrequency = source.carrierFrequency;
        scaleFactor = source.scaleFactor;
    }

    public final Waveform add(Waveform other){
        return new WaveformSum(this, other);
    }
    public final Waveform deriv(){
        // derivative is only applied on the envelop, frequency mixing is not included
        return new WaveformDeriv(this);
    }
    public final Waveform dragify(float alpha){
        return new WaveformDrag(this, alpha);
    }
}

final class WaveformSum extends Waveform {
    private final Waveform waveform1;
    private final Waveform waveform2;
    private float[] _samples;

    WaveformSum(Waveform waveform1, Waveform waveform2){
        super(Math.max(waveform1.length, waveform1.length));
        this.waveform1 = waveform1.copy();
        this.waveform2 = waveform2.copy();
    }

    public WaveformSum copy() {
        WaveformSum newWaveform =  new WaveformSum(waveform1,waveform2);
        newWaveform._copy(this);
        return newWaveform;
    }

    // WaveformSum dose not use cache, getCacheKey is never used
    CacheKey getCacheKey(){return null;}

    @Override
    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache) {
        if (_samples != null){return _samples;} // a WaveformSum can not be evaluated more than once
        // the phase must be kept! if not, the DRAG waveform will wrong
        waveform1.phase = waveform1.phase + phase;
        // the carrierFrequency is overwritten
        waveform1.carrierFrequency = carrierFrequency;
        waveform2.phase = waveform2.phase + phase;
        waveform2.carrierFrequency = carrierFrequency;

        float[] s1 = waveform1.samples(tStart, padLength, xfrFunc, cache);
        float[] s2 = waveform2.samples(tStart, padLength, xfrFunc, cache);
        float[] v;
        if (s1.length < s2.length) {
            for (int i = 0; i < s1.length; i++) {
                s2[i] = s1[i] + s2[i];
            }
            v = s2;
        } else {
            for (int i = 0; i < s2.length; i++) {
                s1[i] = s1[i] + s2[i];
            }
            v = s1;
        }

        if (scaleFactor !=1F) {
            for (int i = 0; i < v.length; i++) {
                v[i] = scaleFactor * v[i];
            }
        }
        // no copy for performance, to those who evaluate a WaveformSum more than once
        // do modifications to the returned sample array directly: don't do it! it a implicit
        // rule that a waveform should only be evaluated once.
        _samples = v;
        return v;
    }

    float[] _freqSamples(){
        return null;
        // throw new IllegalUsage("The _freqSamples method of a WaveformSum instance should never be called.");
    }

    // freqSamples is just to answer a demand to be able to inspect the frequency sample easily,
    // as for as qos is considered, this method is never used.
    public float[] freqSamples(final float[] f){
        // to tell you a secret: the result of this method is not exactly correct,
        // as qos never uses this method, I don't care about it.
        float[] v1 = waveform1.freqSamples(f);
        float[] v2 = waveform2.freqSamples(f);
        for (int i=0; i<v1.length; i++){
            v1[i] += v2[i];
            v1[i] *= scaleFactor;
        }
        return v1;
    }
}

// derivation is done on the envelope, frequency fixing, phase of the original is ignored.
final class WaveformDeriv extends Waveform {
    private final Waveform baseWaveform;

    WaveformDeriv(Waveform baseWaveform){
        super(baseWaveform.length);
        this.baseWaveform = baseWaveform.copy();
        this.baseWaveform.phase = 0;
        this.baseWaveform.carrierFrequency = 0; // must set to zero
    }

    public WaveformDeriv copy(){
        WaveformDeriv newWaveform =  new WaveformDeriv(baseWaveform);
        newWaveform._copy(this);
        return newWaveform;
    }

    private static class CacheKey extends Waveform.CacheKey {
        private Waveform.CacheKey baseWaveformCacheKey;
        private CacheKey(int length, float carrierFrequency,
                         Waveform.CacheKey baseWaveformCacheKey){
            super(length, carrierFrequency);
            this.baseWaveformCacheKey = baseWaveformCacheKey;
        }
        @Override
        public int hashCode(){
            return 31*super.hashCode() + baseWaveformCacheKey.hashCode();
        }
        @Override
        public boolean equals(Object other){
            if (!super.equals(other)) return false;
            CacheKey o = (CacheKey) other;
            return baseWaveformCacheKey.equals(o.baseWaveformCacheKey);
        }
    }

    CacheKey getCacheKey(){return new CacheKey(length, carrierFrequency,
            baseWaveform.getCacheKey());}

    float[] _freqSamples(){
        baseWaveform.numSamples = numSamples;
        baseWaveform.carrierFrequency = carrierFrequency;
        float[] v = baseWaveform._freqSamples();
        float[] f = shiftedSampleFrequencies();
        float tempVar1;
        float tempVar2;
        for (int i=0; i<v.length; i+=2){
            tempVar1 = v[i];
            tempVar2 = 6.283185307179586F*f[i/2];
            v[i] = -v[i+1]*tempVar2;
            v[i+1] = tempVar1*tempVar2;
        }
        return v;
    }
    public float[] freqSamples(final float[] f){
        float[] v = baseWaveform.freqSamples(f);
        float tempVar1;
        float tempVar2;
        for (int i=0; i<v.length; i+=2){
            tempVar1 = v[i];
            tempVar2 = 6.283185307179586F*f[i/2];
            v[i] = -v[i+1]*tempVar2*scaleFactor;
            v[i+1] = tempVar1*tempVar2*scaleFactor;
        }
        return v;
    }
}

final class WaveformDrag extends Waveform {
    private final Waveform baseWaveform;
    private final Waveform _baseWaveform;
    private final float alpha;

    WaveformDrag(Waveform baseWaveform, float alpha){
        // alpha typical value is 0.5 for negative ah
        super(baseWaveform.length);
        Waveform drivWv = baseWaveform.deriv().scale(alpha);
        drivWv.phase = 1.5707963267949F;
        this.baseWaveform = baseWaveform.add(drivWv);
        this._baseWaveform = baseWaveform;
        this.alpha = alpha;
    }

    public WaveformDrag copy(){
        WaveformDrag newWaveform =  new WaveformDrag(_baseWaveform, alpha);
        newWaveform._copy(this);
        return newWaveform;
    }

    // WaveformDrag dose not use cache, getCacheKey is never used
    CacheKey getCacheKey(){return null;}

    @Override
    float[] samples(int tStart, int padLength, XfrFunc xfrFunc, Cache<CacheKey, float[]> cache) {
        baseWaveform.phase = phase;
        baseWaveform.carrierFrequency = carrierFrequency;
        float[] v = baseWaveform.samples(tStart, padLength, xfrFunc, cache);
        if (scaleFactor !=1F) {
            for (int i = 0; i < v.length; i++) {
                v[i] = scaleFactor * v[i];
            }
        }
        return v;
    }

    float[] _freqSamples(){
        return null;
        // throw new IllegalUsage("The _freqSamples method of a WaveformDrag instance should never be called.");
    }
    public float[] freqSamples(final float[] f){
        float[] v = baseWaveform.freqSamples(f);
        if (scaleFactor !=1F) {
            for (int i = 0; i < v.length; i++) {
                v[i] = scaleFactor * v[i];
            }
        }
        return v;
    }
}
