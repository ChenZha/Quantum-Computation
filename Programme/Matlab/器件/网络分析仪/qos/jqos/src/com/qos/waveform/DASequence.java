package com.qos.waveform;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.qos.exception.changeFinalPropertyError;
import com.qos.exception.waveform.padLengthNotSetError;

import java.util.ArrayList;


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
public final class DASequence {
    public static int MAX_CHANNEL_NUM = 2000;

    private static ArrayList<Cache<Waveform.CacheKey, float[]>> cache = new ArrayList<>();
    private static ArrayList<Integer> padLength = new ArrayList<>();

    public int getLength(){return sequence.getLength();}
    // 0 to MAX_CHANNEL_NUM - 1
    private final int channel;
    private int[] outputDelay = new int[]{0,0};
    public int[] getOutputDelay(){return outputDelay;}
    public void setOutputDelay(int[] outputDelay) throws IllegalArgumentException {
        if ((outputDelay[0] < -Waveform.prePadLength) || (outputDelay[1] < -Waveform.prePadLength)){
            throw new IllegalArgumentException(
                    "at least one of outputDelay [" + outputDelay[0] + ","+outputDelay[1]+
                            "] less than minimum "+ -Waveform.prePadLength);
        }
        this.outputDelay = outputDelay;
    }
    public boolean outputDelayByHardware = false;
    private XfrFunc xfrFunc;
    // in this way cache is not effective
    public void setXfrFunc(XfrFunc xfrFunc){
        this.xfrFunc = xfrFunc;
        cache.get(channel).invalidateAll();
    }
    public XfrFunc getXfrFunc(){
        return xfrFunc;
    }

    public int getPadLength() {
        return padLength.get(channel);
    }
    public void setPadLength(int padLength) throws changeFinalPropertyError {
        if (padLength < Waveform.prePadLength){
            throw(new IllegalArgumentException("padLength "+padLength +
                    " less than minimum(waveform prePadLength) "+ Waveform.prePadLength));
        } else if(DASequence.padLength.get(channel) != null) {
            if (DASequence.padLength.get(channel) != padLength) {
                throw new changeFinalPropertyError();
            } else {return;}
        }
        DASequence.padLength.set(channel,padLength);
    }
    // private int padLength = Waveform.prePadLength; // default: waveform prePadLength

    private final Sequence sequence;
    private float[] samples;

    public DASequence(int channel, Sequence sequence){
        if (channel < 0){throw new IllegalArgumentException("channel not a non negative integer");}
        if (channel+1 > MAX_CHANNEL_NUM){throw new IllegalArgumentException("channel "+channel+" exceeds maximum "+(MAX_CHANNEL_NUM-1));}
        sequence.setSealed();
        if (channel > cache.size()-1){
            int numExistingChannels = cache == null? 0:cache.size();
            for (int i=0; i<channel + 1 - numExistingChannels; i++){
                cache.add(Caffeine.newBuilder()
                        .maximumSize(50)
                        .build());
                padLength.add(null);
            }
        }
        this.sequence = sequence;
        this.channel = channel;
    }

    public float[] samples(){
        if (samples != null){return samples;}
        int _padLength;
        if (padLength.get(channel) == null){
            padLength.set(channel,Waveform.prePadLength);
            _padLength = Waveform.prePadLength;
        }else{
            _padLength = padLength.get(channel);
        }
        // if (_padLength == 0){throw new padLengthNotSetError();}

        samples = sequence.samples(_padLength, xfrFunc, cache.get(channel));
        return samples;
    }

}
