package com.qos.exception;

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
public class IllegalUsage extends QException {
    /*
     * throwed at some special cases when a class method should not be called in a special subclass.
     * for example, in Waveform the freqSamples() method is defined abstract because each subclass should has
     * its specific implementation, the freqSamples() method is needed for most Waveform class but for very special
     * subclasses the freqSamples() method is not necessary or even not implementable, DC, Spacer, WaveformSum
     * for example, as subclasses of Waveform, the must implement the freqSamples() method yet this method should
     * never be called,
     */
    public IllegalUsage(String message, Throwable cause){
        super(message, cause);
    }
    public IllegalUsage(String message){
        super(message);
    }
}
