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
 * 物理系统的状态信息，定时更新到网页
  */
public final class SystemStatus {
    public enum Status{
        ACTIVE,         // 正常运行
        MAINTANANCE,    // 维护中
        CALIBRATION,     // 校准中
        OFFLINE         // 离线
    }

    // 系统当前状态
    private Status status;
    // 制冷机当前温度
    private float fridgeTemperature;
    // 系统最后校准时间
    private String lastCalibrationTime;
    // 公告，通知，说明等(中文)
	private String noticeCN;
	// 公告，通知，说明等(英文)
	private String noticeEN;


    public SystemStatus(){}

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public float getFridgeTemperature() {
        return fridgeTemperature;
    }

    public void setFridgeTemperature(float fridgeTemperature) {
        this.fridgeTemperature = fridgeTemperature;
    }

    public String getLastCalibrationTime() {
        return lastCalibrationTime;
    }

    public void setLastCalibrationTime(String lastCalibrationTime) {
        this.lastCalibrationTime = lastCalibrationTime;
    }

    public String getNoticeCN() {
        return noticeCN;
    }

    public String getNoticeEN() {
        return noticeEN;
    }

    public void setNoticeCN(String notice){
		this.noticeCN = notice;
	}
	
	public void setNoticeEN(String notice){
		this.noticeEN = notice;
	}
}
