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
public class ResonatorReadout extends QReadout {
    float r_amp;
    float r_fc;
    float r_fr;
    float r_freq;
    float[] r_iq2prob_center0;
    float[] r_iq2prob_center1;
    float[] r_iq2prob_center2;
    float[] r_iq2prob_fidelity;
    boolean r_iq2prob_intrinsic;

    int r_jpa; // id of the readout jpa
    float r_jpa_biasAmp;
    int r_jpa_delay;
    int r_jpa_longer;
    float r_jpa_pumpAmp;
    float r_jpa_pumpFreq;
    float r_jpa_pumpPower;
    int r_ln;
    int[] r_truncatePts;
    float r_uSrcPower;
    HashMap<String, Float> r_wvSettings = new HashMap<>();
    String r_wvTyp;
}
