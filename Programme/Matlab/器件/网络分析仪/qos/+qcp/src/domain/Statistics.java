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
* 统计数据
 */
public class Statistics {
    // 用户数
    private int numberOfUsers;
    // 用户提总交任务数
    private int numberOfTasks;
    // 过去一年用户提交任务数
    private int numberOfTasksLastYear;
    // 过去一个月用户提交任务数
    private int numberOfTasksLastMoth;
    /* 活跃度曲线数据：
    * activity[0]: 时间，以天为单位，以上线日为零点
    * activity[1]：当天提交的任务数
    * activity[2]：当天完成的任务数
    */
    private int[][] activity;

    public Statistics(){}

    public int getNumberOfUsers() {
        return numberOfUsers;
    }

    public void setNumberOfUsers(int numberOfUsers) {
        this.numberOfUsers = numberOfUsers;
    }

    public int getNumberOfTasks() {
        return numberOfTasks;
    }

    public void setNumberOfTasks(int numberOfTasks) {
        this.numberOfTasks = numberOfTasks;
    }
}
