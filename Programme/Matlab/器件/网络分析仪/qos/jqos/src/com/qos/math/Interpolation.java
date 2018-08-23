package com.qos.math;

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
public class Interpolation {
    public static float[] ascendLinear1d(float[] x, float[] y, float[] xi, float fillValue) {
        // x must be ascending and has no duplicates, to be fast, this condition is NOT checked, the caller has to guarantee it!
        // xi is also assumed to be ascending
        float[] yi = new float[xi.length];
        int ind = 0;
        int tempVar = x.length-2;
        boolean outOfLowerBound = true;
        boolean outOfUpperBound = false;
        float xUb = x[x.length-1];
        for (int i = 0; i < xi.length; i++) {
            if (outOfLowerBound && xi[i] >= x[ind]){
                outOfLowerBound = false;
            }
            if (!outOfUpperBound && xi[i] > xUb){
                outOfUpperBound = true;
            }
            if (outOfLowerBound || outOfUpperBound){
                yi[i] = fillValue;
            }else{
                while (ind < tempVar && xi[i]>=x[ind+1]){
                    ind += 1;
                }
                yi[i] = (y[ind+1] - y[ind])*(xi[i]-x[ind])/(x[ind+1]-x[ind]) + y[ind];
            }

        }
        return yi;
    }
    public static float[] eqDistLinear1d(float[] x, float[] y, float[] xi, float fillValue) {
        // x must be equidistant: to be fast, this condition is NOT checked, the caller has to guarantee it!
        int xyLength = x.length;
        float dx = x[1] - x[0]; // assume x is equidistant
        float[] yi = new float[xi.length];
        float xi2;
        for (int i = 0; i < xi.length; i++) {
            xi2 = (xi[i] - x[0]) / dx;
            if (xi2 < 0 || xi2 > xyLength-1) {
                yi[i] = fillValue;
            } else {
                int index = FloatMath.floor2int(xi2);
                yi[i] = (y[index+1] - y[index])*(xi2-index) + y[index];
            }
        }
        return yi;
    }
    public static float[] eqDistCubic1d(float[] x, float[] y, float[] xi){
        return eqDistCubic1d(x, y, xi, 0);
    }
    public static float[] eqDistCubic1d(float[] x, float[] y, float[] xi, float fillValue) {
        // x must be equidistant: to be fast, this condition is NOT checked, the caller has to guarantee it!
        int xyLength = x.length;
        float dx = x[1] - x[0]; // assume x is equidistant
        float[] yi = new float[xi.length];
        float xi2;
        for (int i = 0; i < xi.length; i++) {
            xi2 = (xi[i] - x[0]) / dx;
            if (xi2 < 0 || xi2 > xyLength-1) {
                yi[i] = fillValue;
            } else if (xi2 >= 0 && xi2 < 1) {
                yi[i] = (y[1] - y[0])*xi2 + y[0];
            } else if (xi2 >= xyLength - 2 && xi2 <= xyLength - 1) {
                yi[i] = (y[xyLength - 1] - y[xyLength - 2])*(xi2-xyLength+2) + y[xyLength - 2];
            } else {
                int index = FloatMath.floor2int(xi2);
                float hp2 = y[index + 2];
                float hp1 = y[index + 1];
                float hp0 = y[index];
                float hm1 = y[index - 1];
                float c = (hp1 - hm1)/2;
                float b = (-hp2 + 4*hp1 - 5*hp0 + 2*hm1)/2;
                float a = (hp2 - 3*hp1 + 3*hp0 - hm1)/2;
                float xr = (xi2 - index);
                yi[i] = ((a*xr + b)*xr + c)*xr + hp0;
            }
        }
        return yi;
    }

}
