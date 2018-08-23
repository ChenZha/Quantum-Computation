import com.alibaba.quantum.domain.ResultModel;
import domain.*;

import java.util.List;

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
public interface QuantumComputerPlatformService {
    // 获取任务
    ResultModel<QuantumTask> getTask();
    // 推送结果
    ResultModel pushResult(QuantumResult var1);
    // 获取列队任务（等待执行任务）数
    ResultModel<Integer> getNumQueuingTasks ();
    // 更新系统设置
    ResultModel updateSystemConfig(SystemConfig var1);
    // 更新系统状态
    ResultModel updateSystemStatus(SystemStatus var1);
    // 更新单比特门保真度
    ResultModel updateOneQGateFidelities(OneQGateFidelities var1);
    // 更新双比特门保真度
    ResultModel updateTwoQGateFidelities(TwoQGateFidelity var1);
    // 更新比特参数
    ResultModel updateQubitParemeters(QubitParameters var1);
    // 获取所有用户信息
    ResultModel<List<UserInfo>> getUserInfo();
    // 获取特定用户信息
    ResultModel<UserInfo> getUserInfo(int userId);
    // 把 msg 通知到所有用户
    ResultModel notify(String msg);
    // 把 msg 通知到特定用户
    ResultModel notify(String msg, int userId);
    // 获取所有未回复用户信息
    ResultModel<List<UserMessage>> getUserMessage();
    // 获取最近一段时间内未回复用户信息, days: 最近几天，含当天
    ResultModel<List<UserMessage>> getUserMessage(int days);
    // 回复用户信息
    ResultModel replyUserMessage(UserMessageReply reply);
    // 获取统计信息：
    ResultModel<Statistics> getStatistics();
}
