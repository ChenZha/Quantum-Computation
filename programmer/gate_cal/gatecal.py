# -*- coding: utf-8 -*-
'''qutip的circuit能识别的门的列表
["RX","RY","RZ","SQRTNOT","SNOT","PHASEGATE","CRX","CRY","CRZ","CPHASE","CNOT","CSIGN",
"BERKELEY","SWAPalpha","SWAP","ISWAP","SQRTSWAP","SQRTISWAP","FREDKIN","TOFFOLI","GLOBALPHASE"]
'''
from qutip import *
import numpy as np
import re
#print(re.match(r"(^[a-qs-z]\w*?)(\d+$)","ry90").groups())
gatenum = re.compile(r"(^[a-qs-zA-QS-Z]\w*?)(\d+$)")#多比特门的正则表达式
rtheta = re.compile(r"(^[rR][x-zX-Z])(-?\d+$)")#任意角度旋转的正则表达式
measure = re.compile(r"(^[mM][xzXZ])(-?$)")#测量的正则表达式
measuremsgn={"-":"","":"-"}
#print(gatenum.match("ry90"))
#gatetype,num=gatenum.match(gate).groups()
#rxyz,theta=rtheta.match(gate).groups()
#mxz,sgn=measure.match(gate).groups()
def init(filename="gateforcal.csv"):
    fin = open(filename, "r")
        
    gatelistT=[line.strip().split(",") for line in fin.readlines()]
    npip=len(gatelistT)#npip个比特
    lenpip=max([len(x) for x in gatelistT])
    
    for i in gatelistT:#补成满的矩阵
        i.extend(["" for i in range(lenpip-len(i))])
    gatelist=[[gatelistT[i][j].upper() for i in range(npip)] for j in range(lenpip)]#大写并转置
    return gatelist

def gatecheck(gate1,gate2):#检查两个门是否是同一组的多比特门
    out=0
    if gatenum.match(gate1) and gatenum.match(gate2):
        gate1,num1=gatenum.match(gate1).groups()
        gate2,num2=gatenum.match(gate2).groups()
        if gate1==gate2 and (int(num1)+1)//2==(int(num2)+1)//2:#12,34,56,78..
            out=(int(num1)+1)//2
    return out#返回该组门是第几组,0表示不是同组多比特门
    
def addonelist(onelist):
    npip=len(onelist)
    oneqc=QubitCircuit(npip)
    for j in range(npip):
         if onelist[j]:#非空
            if not gatenum.match(onelist[j]):#单比特门
                if onelist[j]=="X" or onelist[j]=="Y" or onelist[j]=="Z":
                    onelist[j]="R"+onelist[j]+"180"
                if onelist[j]=="H":#h=ry90*z
                    oneqc.add_gate("RZ", targets=j,arg_value=np.pi,arg_label=180)
                    oneqc.add_gate("RY", targets=j,arg_value=np.pi/2,arg_label=90)
                elif rtheta.match(onelist[j]):#任意角度旋转
                    rxyz,theta=rtheta.match(onelist[j]).groups()
                    oneqc.add_gate(rxyz, targets=j,arg_value=(float(theta)/180*np.pi),arg_label=theta)
                else:
                    oneqc.add_gate(onelist[j], targets=j)
            else:#多比特门
                for k in range(j+1,npip):
                    if gatecheck(onelist[j],onelist[k]):#找到和其同组的门
                        gate,num=gatenum.match(onelist[j]).groups()
                        if gate=="CN" or gate=="CX":
                            gate="CNOT";                        
                        if gate=="ISWAP":
                            oneqc.add_gate(gate, targets=[j,k])
                        elif gate=="CZ":
                            if int(num)%2:
                                oneqc.add_gate("CRZ", targets=k, controls=j,arg_value=np.pi,arg_label=180)
                            else:
                                oneqc.add_gate("CRZ", targets=j, controls=k,arg_value=np.pi,arg_label=180)
                        elif int(num)%2:
                            oneqc.add_gate(gate, targets=k, controls=j)
                        else:
                            oneqc.add_gate(gate, targets=j, controls=k)
    return oneqc



gatelist=init("gateforcal.csv")
npip=len(gatelist[0])
#lenpip=len(gatelist)
qc=QubitCircuit(npip)
for onelist in gatelist:
    qc.gates.extend(addonelist(onelist).gates)
qcp=qc.propagators()
propagator=qcp.pop(0)
for gate in qcp:
    propagator=gate*propagator
#propagator.dag()[0][0][0b01000]
output=abs(propagator.dag()[0][0]**2)
print(output)
try:#输出线路到pdf和tex,用于检查
    qc.png
except:
    pass


