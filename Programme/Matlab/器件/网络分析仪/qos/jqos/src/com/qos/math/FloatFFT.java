package com.qos.math;
import java.util.HashMap;
import edu.emory.mathcs.jtransforms.fft.FloatFFT_1D;

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
// wrapper of jtransforms.fft
public final class FloatFFT {
    private static HashMap<Integer,FloatFFT_1D> cache = new HashMap<>();
    public static void fft(float[] v){
        // length of v must be a power of 2, to be fast, this condition is not checked, the caller has to grantee that
        int n = v.length/2;
        FloatFFT_1D fft = cache.get(n);
        if (fft == null){
            fft = new FloatFFT_1D(n);
            cache.put(n, fft);
        }
        fft.complexForward(v);
    }
    public static void rfft(float[] v){
        // length of v must be a power of 2, to be fast, this condition is not checked, the caller has to grantee that
        int n = v.length/2;
        FloatFFT_1D fft = cache.get(n);
        if (fft == null){
            fft = new FloatFFT_1D(n);
            cache.put(n, fft);
        }
        fft.realForward(v);
    }
    public static void ifft(float[] v){
        // length of v must be a power of 2, to be fast, this condition is not checked, the caller has to grantee that
        int n = v.length/2;
        FloatFFT_1D fft = cache.get(n);
        if (fft == null){
            fft = new FloatFFT_1D(n);
            cache.put(n, fft);
        }
        fft.complexInverse(v, true);
    }
    public static void rifft(float[] v){
        // length of v must be a power of 2, to be fast, this condition is not checked, the caller has to grantee that
        int n = v.length/2;
        FloatFFT_1D fft = cache.get(n);
        if (fft == null){
            fft = new FloatFFT_1D(n);
            cache.put(n, fft);
        }
        fft.realInverse(v, true);
    }
}
