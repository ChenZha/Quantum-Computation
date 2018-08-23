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
public class SystemConfig {
    // 可以做的单比特门，目前是 {"X","X2p","X2m","Y","Y2p","Y2m","Z","Z2p","Z2m","Z(p)"},
    // 其中 p 是参数， 比如 Z(1.7)
    private String[] oneQGates;
    // 单比特门网页上显示标签, 和 oneQGates 一一对应,
    // 目前是 {"X","X/2","-X/2","Y","Y/2","-Y/2","Z","Z/2","-Z/2","Z(p)"},
    // 这里 p 是用户输入的参数，可以是任意浮点数
    private String[] oneQGatesLabel;
    // 可以做的双比特门, 目前是 {"CZ"}
    private String[] twoQGates;
    // 双比特门网页上显示标签, 目前是 {"CZ"}
    private String[] twoQGatesLabel;

    public String[] getOneQGates() {
        return oneQGates;
    }

    public SystemConfig(){}

    public void setOneQGates(String[] oneQGates) {
        this.oneQGates = oneQGates;
    }

    public String[] getOneQGatesLabel() {
        return oneQGatesLabel;
    }

    public void setOneQGatesLabel(String[] oneQGatesLabel) {
        this.oneQGatesLabel = oneQGatesLabel;
    }

    public String[] getTwoQGates() {
        return twoQGates;
    }

    public void setTwoQGates(String[] twoQGates) {
        this.twoQGates = twoQGates;
    }

    public String[] getTwoQGatesLabel() {
        return twoQGatesLabel;
    }

    public void setTwoQGatesLabel(String[] twoQGatesLabel) {
        this.twoQGatesLabel = twoQGatesLabel;
    }
}
