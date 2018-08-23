package com.qos.exception.io;

import com.qos.exception.QException;

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

public class updateQubitDatabaseError  extends QException{
    public updateQubitDatabaseError(){
        super("update qubit data base failed.", null);
    }
    public updateQubitDatabaseError(String message){
        super(message, null);
    }
    public updateQubitDatabaseError(String message, Throwable cause){
        super(message, cause);
    }
}