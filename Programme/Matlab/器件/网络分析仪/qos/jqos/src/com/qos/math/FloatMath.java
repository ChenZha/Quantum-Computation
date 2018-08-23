package com.qos.math;

import com.sun.javaws.exceptions.InvalidArgumentException;

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
public final class FloatMath {
    public static float PI = 3.141592653589793F;
    public static float PI2 = 6.283185307179586F;
    private static float PRECISION = 1e-7F;  // 1e-7 is more than enough for QOS

    public static int floor2int(float x){
        // TODO
        return (int) Math.floor((double) x);
    }
    public static float sqrt(float x){
        // TODO
        return (float) Math.sqrt((double) x);
    }

    public static float pow(float x, float n){
        // TODO
        return (float) Math.pow((double) x, (double) n);
    }

    public static float sqr(float x){
        return x*x;
    }

    public static float exp(float x){
        // TODO
        return (float) Math.exp((double) x);
    }
    public static float cos(float x){
        // TODO
        return (float) Math.cos((double) x);
    }
    public static float sin(float x){
        return (float) Math.sin((double) x);
    }

    public static float tan(float x){
        return (float) Math.tan((double) x);
    }

    public static float log(float x){
        return (float) Math.log((double) x);
    }

    public static float[] linSpace(float x0, float x1, int n){
        if (n<2) throw new IllegalArgumentException(String.format("minimum number of points is 2, %d given.",n));
        float d = (x1-x0)/(n-1);
        float[] v = new float[n];
        v[0] = x0;
        for (int i=1; i<n; i++) v[i] = v[i-1]+d;
        return v;
    }

}
