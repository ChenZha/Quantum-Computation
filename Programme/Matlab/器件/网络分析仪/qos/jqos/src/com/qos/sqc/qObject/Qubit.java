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
public abstract class Qubit {
    private static volatile HashMap<Integer, Qubit> allQubits = new HashMap<>();
    private static synchronized void addQubit(int id, Qubit qubit){
        allQubits.put(id,qubit);
    }

    private final int id;  // id is loaded from the qubit database, the database guarantees its uniqueness
    public int getId(){return id;}
    public float f01;

    @Override
    public boolean equals(Object other) {
        return !((other == null) || (this.getClass() != other.getClass())) && this.id == ((Qubit) other).id;
    }

    public Qubit(int id){
        this.id = id;
        addQubit(id,this);
    }

}
