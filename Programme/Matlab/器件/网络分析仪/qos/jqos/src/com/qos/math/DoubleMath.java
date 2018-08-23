package com.qos.math;
import org.apache.commons.math3.util.FastMath;

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
public class DoubleMath {
    public static double sinc(double x){
        x = FastMath.PI*x;
        if (FastMath.abs(x) <= 1e-6) {
            x = x*x;
            return ((x - 20)*x + 120)/120;
        } else {
            return FastMath.sin(x)/x;
        }
    }
}
