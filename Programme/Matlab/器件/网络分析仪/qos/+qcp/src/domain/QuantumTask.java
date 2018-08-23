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
* 任务，原 QuantumTaskDO
 */
public class QuantumTask {
    private long taskId;
    private long slot;
    private long seed;
    /*
    * circuit 是原 QuantumTaskDO 中的 data 属性
    * 数据格式： N行，M 列， M： 比特数目，目前是12
    * {{"Y2p",	"Y2m",	"I",  	"I",  	"I",	...},
    *   "CZ",	"CZ",  	"I",  	"I",  	"I",	...},
    *   "I",	"Y2p",	"Y2m",  "I",  	"I",	...},
    *   "I",	"CZ",  	"CZ",  	"I", 	"I",	...},
    *   "I",	"I",  	"Y2p",	"Y2m", 	"I",	...},
    *   "I",	"I",  	"CZ",  	"CZ", 	"I",	...},
    *   "I",	"I",  	"I",  	"Y2p",	"Y2m",	...},
    *   "I",	"I",  	"I",   	"CZ",	"CZ",	...},
    *   "I",	"I",  	"I",    "I",	"Y2p",	...}};
    */
    private String[][] circuit;
    // 测量比特，比如 {"q1","q3","q8"}
    private String[] measureQubits;

    // 以上是QuantumTaskDO原有的属性，增加以下属性:

    // 是否使用历史数据
    // true: 如果相同任务之前有人提交过，不运行，直接返回历史数据
    // false: 总是运行
    private boolean useCache;
    // 测量统计次数, @大于零
    private int stats;
    private int userId;
    // 任务提交时间
    private String submissionTime;

    public QuantumTask(){}

    public long getTaskId() {
        return taskId;
    }

    public void setTaskId(long taskId) {
        this.taskId = taskId;
    }

    public long getSlot() {
        return slot;
    }

    public void setSlot(long slot) {
        this.slot = slot;
    }

    public String[][] getCircuit() {
        return circuit;
    }

    public void setCircuit(String[][] circuit) {
        this.circuit = circuit;
    }

    public long getSeed() {
        return seed;
    }

    public void setSeed(long seed) {
        this.seed = seed;
    }

    public int getStats() {
        return stats;
    }

    public void setStats(int stats) {
        if (stats <= 0){
            throw new IllegalArgumentException("zeros or negative stats "+stats);
        }
        this.stats = stats;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getSubmissionTime() {
        return submissionTime;
    }

    public void setSubmissionTime(String submissionTime) {
        this.submissionTime = submissionTime;
    }

    public String[] getMeasureQubits() {
        return measureQubits;
    }

    public void setMeasureQubits(String[] measureQubits) {
        this.measureQubits = measureQubits;
    }

    public boolean isUseCache() {
        return useCache;
    }

    public void setUseCache(boolean useCache) {
        this.useCache = useCache;
    }
}
