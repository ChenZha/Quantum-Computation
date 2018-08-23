package com.qos.waveform;

import com.github.benmanes.caffeine.cache.Cache;
import com.qos.exception.waveform.ChangeSealedSequenceError;

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
/**
 * in consideration of performance, the Sequence class is not designed to be safe, the user has to
 * abide to the following rule rule: a sequence, once added to another sequence, should
 * never be modified afterwards
 */
public final class Sequence{
    private int length;
    public int getLength(){return length;}

    private boolean sealed = false;
    // setSealed should only be called by DASequence, a sealed sequence is ready for launch, it can not be changed
    // any more, including added to other sequence or having other sequences added.
    void setSealed(){
        sealed = true;
    }

    private ArrayList<Waveform> envLst = new ArrayList<>();
    private Sequence sequence2add;
    public Sequence scale(float scaleFactor){
        Sequence newSequence = this.copy();
        if (sequence2add != null){
            newSequence.sequence2add = sequence2add.scale(scaleFactor);
        }
        for(int i=0; i<newSequence.envLst.size(); i++){
            Waveform wv = newSequence.envLst.get(i);
            wv = wv.scale(scaleFactor);
            newSequence.envLst.set(i,wv);
        }
        return newSequence;
    }

    public void shiftPhase(float phase){
        if (sequence2add != null){
            sequence2add.shiftPhase(phase);
        }
        for (Waveform wv:envLst){
            wv.phase += phase;
        }
    }

    public Sequence(Waveform waveform){
        envLst.add(waveform);
        length = waveform.length;
    }

    public Sequence(Sequence sequence){
        for (Waveform wv:sequence.envLst){
            envLst.add(wv.copy());
        }
        length = sequence.length;
    }

    public void add(Sequence sequence) throws ChangeSealedSequenceError {
        // in add, a copy of the sequence to add is made
        if (sealed){throw new ChangeSealedSequenceError();}
        int dLength = length - sequence.length;
        if (dLength<0) {
            envLst.add(new Spacer(-dLength));
            length = length - dLength;
        } else if(dLength>0) sequence.concat(new Spacer(dLength));
        if (sequence2add == null){
            sequence2add = sequence.copy();
        }else{
            sequence2add.add(sequence);
        }
    }

    public Sequence copy(){
        return new Sequence(this);
    }

    // copy is not done here for performance, the caller has to do it if necessay.
    public void concat(Waveform waveform) throws ChangeSealedSequenceError {
        if (sealed){throw new ChangeSealedSequenceError();}
        envLst.add(waveform);
        length += waveform.length;
        if (sequence2add != null){
            sequence2add.concat(new Spacer(waveform.length));
        }
    }
    // copy is not done here for performance, the caller has to do it if necessay.
    public void concat(Waveform[] waveforms) throws ChangeSealedSequenceError {
        if (sealed){throw new ChangeSealedSequenceError();}
        int seqLn = 0;
        for (Waveform wv:waveforms){
            envLst.add(wv);
            length += wv.length;
            seqLn += wv.length;
        }
        if (sequence2add != null){
            sequence2add.concat(new Spacer(seqLn));
        }
    }
    // copy is not done here for performance, the caller has to do it if necessary.
    public void concat(Sequence sequence) throws ChangeSealedSequenceError {
        if (sealed){throw new ChangeSealedSequenceError();}
        envLst.addAll(sequence.envLst);
        int seqLn = sequence.length;
        if (sequence2add != null){
            if (sequence.sequence2add == null) {
                sequence2add.concat(new Spacer(seqLn));
            } else{
                sequence2add.concat(sequence.sequence2add);
            }
        }else if(sequence.sequence2add != null){
            sequence2add = new Sequence(new Spacer(length));
            sequence2add.concat(sequence.sequence2add);
        }
        length += seqLn;
    }

    // should only be called in DASequence
    float[] samples(int padLength, XfrFunc xfrFunc, Cache<Waveform.CacheKey, float[]> cache){
        float[] va = null;
        if (sequence2add != null){
            int dLength = length - sequence2add.length;
            if (dLength > 0) try {
                sequence2add.concat(new Spacer(dLength));
            } catch (ChangeSealedSequenceError e) {
                // this is OK
            }
            va = sequence2add.samples(padLength, xfrFunc, cache);
        }

        /////////////////////////////////
        // float[] v = new float[2*length+2*padLength]; // in case of pad one side
        // float[] v = new float[2*length+4*padLength]; // in case of pad both sides

        // in case of pad both sides but with different padding length
        int prePadLength = Waveform.prePadLength;
        float[] v = new float[2*length+2*prePadLength+2*padLength];
        /////////////////////////////////

        int tStart = 0;

        /////////////////////////////////
        // int ind1 = 0; // pad only one side
        // int ind1 = 2*padLength; // in case of pad both sides
        int ind1 = 2*prePadLength;  // in case of pad both sides but with different padding length
        /////////////////////////////////

        int ind2;
        int wvLn;
        float[] wvData;
        int wvDataLn;
        boolean notSpacer;
        // int wvCount = 0;
        for (Waveform wv:envLst){
            wvData = wv.samples(tStart,padLength, xfrFunc, cache);

            wvDataLn = wvData.length;
            wvLn = wv.length;
            notSpacer = !(wv instanceof Spacer || wv instanceof DC);
            ///* pad both sides, if not, remove the following lines
            if (notSpacer) {
                for (int i = 2 * prePadLength; i > 0; i--) { // in case of pad both sides but with different padding length
                // for (int i = 2 * padLength; i > 0; i--) { // in case of pad both sides with the same padding length
                    v[ind1 - i] += wvData[wvDataLn - i];
                }
            }
            //*/
            for (int i = 0; i < 2*wvLn; i++) {
                v[ind1] += wvData[i];
                ind1 += 1;
            }
            ind2 = ind1;
            if (notSpacer) {
                for (int i = 0; i < 2 * padLength; i++) {
                    v[ind2 + i] += wvData[2 * wvLn + i];
                }
            }
            tStart += wvLn;
            // wvCount += 1;
        }

        if (va != null){
            for (int i = 0; i < v.length; i++) {
                v[i] += va[i];
            }
        }

        return v;

    }

    // freqSamples is added to satisfy a user demand: be able to check the frequency samples,
    // not necessary as far as the QOS system is concerned
    public float[][] freqSamples(float[] f){
        float[][] v = new float[envLst.size()][2*f.length];
        int i = 0;
        for (Waveform wv:envLst){
            v[i] = wv.freqSamples(f);
        }
        return v;
    }
}
