package domain;

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
/*
* 运行结果
 */
public class QuantumResult {
    private long taskId;
    // 实际运行的线路
    // 用户提供的线路可能因为物理系统的限制不能运行，这种情况下会转换成一个可运行的等价线路运行
    private String[][] finalCircuit;
    // 任务运行结果，长度：2^比特数, null 表示线路无法运行或运行错误
    private float[] result;
	// fidelity[0][j-1] :  第j个读取比特|0>态读取保真度
	// fidelity[1][j-1] :  第j个读取比特|1>态读取保真度
	private float[][] readoutFidelity;
	// 单次event结果， 比特数 x 重复次数（QuantumTask 中 stats 属性定义）
	private boolean[][] singleShotEvents;
	// 说明： 可能会有对实验过程、方法、结果的一个说明（中文）
	private String noteCN;
    // 说明： 可能会有对实验过程、方法、结果的一个说明（中文）
	private String noteEN;
	
    /* 返回实际输出的控制波形作为额外数据，null 表示没有这个数据
        * 3x比特数 行：
        * waveforms[0]: 第一个比特 xy I 波形
        * waveforms[0]: 第一个比特 xy Q 波形
        * waveforms[0]: 第一个比特 xy Z 波形
        * waveforms[0]: 第二个比特 xy I 波形
        * ...
        */
    private float[][] waveforms;

    public QuantumResult(){}

    public long getTaskId() {
        return taskId;
    }

    public void setTaskId(long taskId) {
        this.taskId = taskId;
    }

    public String[][] getFinalCircuit() {
        return finalCircuit;
    }

    public void setFinalCircuit(String[][] finalCircuit) {
        this.finalCircuit = finalCircuit.clone();
    }

    public float[] getResult() {
        return result;
    }

    public void setResult(float[] result) {
        this.result = result.clone();
    }
	
	public float [][] getReadoutFidelities() {
        return readoutFidelity.clone();
    }
	
	public void setReadoutFidelities(float[][] readoutFidelity) {
        this.readoutFidelity = readoutFidelity.clone();
    }
	
	public boolean[][] getSingleShotEvents() {
        return singleShotEvents.clone();
    }
	
	public void setSingleShotEvents(boolean[][] singleShotEvents) {
        this.singleShotEvents = singleShotEvents.clone();
    }

    public float[][] getWaveforms() {
        return waveforms.clone();
    }

    public void setWaveforms(float[][] waveforms) {
        this.waveforms = waveforms.clone();
    }

    public String getNoteCN() {
        return noteCN;
    }
	
	public void setNoteCN(String note) {
        this.noteCN = note;
    }
	
	public String getNoteEN() {
        return noteEN;
    }
	
	public void setNoteEN(String note) {
        this.noteCN = note;
    }

    public float[][] getReadoutFidelity() {
        return readoutFidelity;
    }

    public void setReadoutFidelity(float[][] readoutFidelity) {
        this.readoutFidelity = readoutFidelity;
    }
}
