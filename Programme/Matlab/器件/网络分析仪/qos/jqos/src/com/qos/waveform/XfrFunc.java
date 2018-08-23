package com.qos.waveform;

import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

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
public abstract class XfrFunc {
    abstract float[] samples(float[] f);
    // f must be equidistant, starts from -0.5 and ends at 0.5: to be fast, these condition is NOT checked, the caller has to guarantee that!
    // XfrFuncs are only intended to be used for Envelopes, which only calls with equidistant f starts from -0.5 and ends at 0.5.
    // this is also why this method is package private

    // for inspection in tests, as for as QOS considered this method is never used.
    public abstract float[] samples_t(float[] f);

    protected static final ConcurrentHashMap<CacheKey,float[]> cache = new ConcurrentHashMap<>();

    public static int getCacheSize(){return cache.size();}
    static final int MAX_CACHE_NUM = (int) 5e5;

    public XfrFunc add(XfrFunc xfrFunc){
        if (xfrFunc == null){ return this;}
        return new XfrFuncSum(this, xfrFunc);
    }

    public XfrFunc inv(){
        return new XfrFuncInv(this);
    }

    class CacheKey {
        private int length;

        CacheKey(int length){
            this.length = length;
        }

        @Override
        public int hashCode(){
            int code = 23;
            return code*31 + this.length;
        }
        @Override
        public boolean equals(Object other){
            if((other == null) || (this.getClass() != other.getClass())){
                return false;
            }
            CacheKey o = (CacheKey) other;
            return length == o.length;
        }

    }
}

final class XfrFuncSum extends XfrFunc {
    private ArrayList<XfrFunc> xfrFuncLst = new ArrayList<>();
    ArrayList<XfrFunc> getXfrFuncLst(){return xfrFuncLst;}
    XfrFuncSum(XfrFunc xfrFunc1, XfrFunc xfrFunc2){
        if (xfrFunc1 instanceof XfrFuncSum){
            xfrFuncLst.addAll(((XfrFuncSum) xfrFunc1).getXfrFuncLst());
            if (xfrFunc2 instanceof XfrFuncSum){
                xfrFuncLst.addAll(((XfrFuncSum) xfrFunc2).getXfrFuncLst());
            } else {
                xfrFuncLst.add(xfrFunc2);
            }
        } else if (xfrFunc2 instanceof XfrFuncSum){
            xfrFuncLst.add(xfrFunc1);
            xfrFuncLst.addAll(((XfrFuncSum) xfrFunc2).getXfrFuncLst());
        } else {
            xfrFuncLst.add(xfrFunc1);
            xfrFuncLst.add(xfrFunc2);
        }
    }

    @Override
    float[] samples(float[] f) {
        float[] v = new float[2*f.length];
        float[] vi;
        int i = 0;
        for (XfrFunc xfrFunc:xfrFuncLst){
            vi = xfrFunc.samples(f);
            if (i>0) {
                float tempVar;
                for (int j = 0; j < 2 * f.length; j += 2) {
                    tempVar = v[j] * vi[j] - v[j + 1] * vi[j + 1];
                    v[j + 1] = v[j] * vi[j + 1] + v[j + 1] * vi[j];
                    v[j] = tempVar;
                }
            }else{
                v = vi;
            }
            i += 1;
        }
        return v;
    }

    @Override
    public float[] samples_t(float[] f) {
        float[] v = new float[2*f.length];
        float[] vi;
        int i = 0;
        for (XfrFunc xfrFunc:xfrFuncLst){
            vi = xfrFunc.samples_t(f);
            if (i>0) {
                float tempVar;
                for (int j = 0; j < 2 * f.length; j += 2) {
                    tempVar = v[j] * vi[j] - v[j + 1] * vi[j + 1];
                    v[j + 1] = v[j] * vi[j + 1] + v[j + 1] * vi[j];
                    v[j] = tempVar;
                }
            }else{
                v = vi;
            }
            i += 1;
        }
        return v;
    }

    @Override
    public int hashCode() {
        int code = 21;
        for (XfrFunc xfrFunc:xfrFuncLst){
            code = 31*code + xfrFunc.hashCode();
        }
        return code;
    }
}

final class XfrFuncInv extends XfrFunc {
    private XfrFunc internalXfrFunc;
    XfrFuncInv(XfrFunc xfrFunc){
        internalXfrFunc = xfrFunc;
    }

    @Override
    float[] samples(float[] f) {
        float[] v = internalXfrFunc.samples(f);
        float tempVar1;
        for (int j=0; j < 2*f.length; j += 2){
            tempVar1 = v[j]*v[j] + v[j+1]*v[j+1];
            v[j] =  v[j]/tempVar1;
            v[j+1] =  -v[j+1]/tempVar1;
        }
        return v;
    }

    @Override
    public float[] samples_t(float[] f) {
        float[] v = internalXfrFunc.samples_t(f);
        float tempVar1;
        for (int j=0; j < 2*f.length; j += 2){
            tempVar1 = v[j]*v[j] + v[j+1]*v[j+1];
            v[j] =  v[j]/tempVar1;
            v[j+1] =  -v[j+1]/tempVar1;
        }
        return v;
    }

    @Override
    public int hashCode() {
        return internalXfrFunc.hashCode()+1;
    }
}
