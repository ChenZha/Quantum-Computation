package com.qos.sqc.qObject;

import java.util.HashMap;

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
public class Xmon extends Qubit {

    // float f01;
    float f02;
    float[][] T1;
    float[][] T2;

    int g_I_ln;
    float g_XY12_amp;
    int g_XY12_ln;
    float g_XY2_amp;
    int g_XY2_ln;
    float g_XY4_amp;
    int g_XY4_ln;
    float g_XY_amp;
    int g_XY_ln;
    float g_XY_phaseOffset;
    int g_Z2_z_ln;

    String g_Z_typ;
    float g_Z2m_z_amp;
    float g_Z2p_z_amp;
    float g_Z_amp;
    int g_Z_z_ln;

    HashMap<String, Float> g_detune_wvSettings = new HashMap<>();
    String g_detune_wvTyp;

    float g_XY_dragAlpha;
    boolean g_xy_dragPulse;
    float g_XY_fc;
    float g_XY_uSrcPower;
    HashMap<String, Float> g_XY_wvSettings = new HashMap<>();
    String g_XY_wvTyp;

    float[] g_Z_amp2f01;
    float[] g_Z_amp2f02;
    HashMap<String, Float> qr_Z_wvSettings = new HashMap<>();
    String qr_Z_wvTyp;

    int spc_biasRise;
    float spc_driveAmp;
    int spc_driveLn;
    int spc_driveRise;
    float spc_sbFreq;
    int spc_zLonger;

    int[] syncDelay_r;
    int[] syncDelay_xy;
    int syncDelay_z;
    float t_rrDipFWHM_est;
    float t_spcFWHM_est;
    float t_zAmp2freqFreqSrchRng;
    float t_zAmp2freqFreqStep;

    int[] xTalk_z_qubits;
    float[] xTalk_z_dcCoef;
    float[] xTalk_z_pulseCoef;


    float[] zdc_amp2f01;
    float[] zdc_amp2f02;
    float zdc_amp2fFreqRng;
    float zdc_amp;
    float zdc_ampCorrection;
    float zdc_settlingTime;
    float[] zpls_amp2f01Df;
    float[] zpls_amp2f02Df;
    float zpls_amp2fFreqRng;

    public Xmon(int id){super(id);}
}
