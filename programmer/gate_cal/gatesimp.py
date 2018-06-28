# -*- coding: utf-8 -*-

import re
#print(re.match(r"(^[a-qs-z]\w*?)(\d+$)","ry90").groups())
gatenum = re.compile(r"(^[a-qs-z]\w*?)(\d+$)")#多比特门的正则表达式
rtheta = re.compile(r"(^r[x-z])(-?\d+$)")#任意角度旋转的正则表达式
measure = re.compile(r"(^m[xz])(-?$)")#测量的正则表达式
measuremsgn={"-":"","":"-"}
#print(gatenum.match("ry90"))
#gatetype,num=gatenum.match(gate).groups()
#rxyz,theta=rtheta.match(gate).groups()
#mxz,sgn=measure.match(gate).groups()
def init(filename="in.csv"):
    fin = open(filename, "r")
        
    gatelistT=[line.strip().split(",") for line in fin.readlines()]
    npip=len(gatelistT)#npip个比特
    lenpip=max([len(x) for x in gatelistT])
    
    for i in gatelistT:#补成满的矩阵
        i.extend(["" for i in range(lenpip-len(i))])
    gatelist=[[gatelistT[i][j] for i in range(npip)] for j in range(lenpip)]#转置
    return gatelist

def write(gatelist,filename="out.csv"):
    fout = open(filename, 'w')
    npip=len(gatelist[0])
    lenpip=len(gatelist)
    gatelistT=[[gatelist[j][i] for j in range(lenpip)] for i in range(npip)]
    for i in gatelistT:
        for j in i:
            fout.write("%s,"%(j))
        fout.write("\n")
    fout.close()#会覆盖原来的内容

def delvoid(gatelist):#删除空列
    void=["" for i in gatelist[0]]
    return [i for i in gatelist if i!=void]

def gatecheck(gate1,gate2):#检查两个门是否是同一组的多比特门
    out=0
    if gatenum.match(gate1) and gatenum.match(gate2):
        gate1,num1=gatenum.match(gate1).groups()
        gate2,num2=gatenum.match(gate2).groups()
        if gate1==gate2 and (int(num1)+1)//2==(int(num2)+1)//2:#12,34,56,78..
            out=(int(num1)+1)//2
    return out#返回该组门是第几组,0表示不是同组多比特门
        
def rightshift(gatelist):#右移补空位并删除最右边的门
    def rsonestep(gatelistold):
        lenpip=len(gatelistold)
        npip=len(gatelistold[0])
        gatelist=[[gatelistold[i][j] for j in range(npip)] for i in range(lenpip)]#复制
        for i in reversed(range(lenpip-1)):
            for j in range(npip):
                if gatelist[i][j] and not gatelist[i+1][j]:#非空且右侧空
                    if not gatenum.match(gatelist[i][j]):#单比特门
                        gatelist[i+1][j]=gatelist[i][j]
                        gatelist[i][j]=""
                    else:#多比特门
                        for k in range(j+1,npip):
                            if not gatelist[i+1][k] and gatecheck(gatelist[i][j],gatelist[i][k]):
                                gatelist[i+1][j]=gatelist[i][j]
                                gatelist[i][j]=""
                                gatelist[i+1][k]=gatelist[i][k]
                                gatelist[i][k]=""
        for i in range(npip):#删除测量之外的最末端的门
            if not measure.match(gatelist[-1][i]):
                gatelist[-1][i]=""
        return delvoid(gatelist)
    newlist=rsonestep(gatelist)
    while newlist!=gatelist:
        gatelist=newlist
        newlist=rsonestep(gatelist)
    return newlist

def cntocz(gatelist):
    newlist=[]    
    i=0
    for i in gatelist:
        acol=[]
        col=[]
        bcol=[]
        for j in i:            
            if j[0:2]=="cn" or j[0:2]=="cx":
                if int(j[2:])%2==0:
                    acol.append("h")
                    col.append("cz"+j[2:])
                    bcol.append("h")
                else:
                    acol.append("")
                    col.append("cz"+j[2:])
                    bcol.append("")
            elif j[0:2]=="mx":
                acol.append("h")
                col.append("mz"+j[2:])
                bcol.append("h")
            else:
                acol.append("")
                col.append(j)
                bcol.append("")
        newlist.extend([acol,col,bcol])
    return delvoid(newlist)

def htory90zANDytoxz(gatelist):
    newlist=[]    
    i=0
    for i in gatelist:
        col=[]
        bcol=[]
        for j in i:            
            if j=="h":
                col.append("ry90")
                bcol.append("z")
            elif j=="y":
                col.append("x")
                bcol.append("z")
            else:
                col.append(j)
                bcol.append("")
        newlist.extend([col,bcol])
    return delvoid(newlist)

def gatesimplify(gatelistold):
    gatelistold=delvoid(rightshift(gatelistold))
    lenpip=len(gatelistold)
    npip=len(gatelistold[0])
    gatelist=[[gatelistold[i][j] for j in range(npip)] for i in range(lenpip)]#复制
    i=0
    while i < len(gatelist)-1:#gatelist的长度在循环中可能会变
        insert=["" for numpip in range(npip)]
        for j in range(npip): 
            if gatelist[i][j] and not gatelist[i+1][j] and not gatenum.match(gatelist[i][j]):#非空单比特且右侧空
                gatelist[i+1][j]=gatelist[i][j]
                gatelist[i][j]=""
            if gatelist[i][j] and gatelist[i+1][j] and not gatenum.match(gatelist[i][j]):#非空单比特且右侧非空
                if gatelist[i][j]=="z":#===z===
                    if gatelist[i+1][j]=="z":#z z->i i
                        gatelist[i][j]=""
                        gatelist[i+1][j]=""
                    if gatelist[i+1][j]=="x":#z x->x z
                        gatelist[i][j]="x"
                        gatelist[i+1][j]="z"
                    elif rtheta.match(gatelist[i+1][j]):#z rtheta->rtheta z
                        rxyz,theta=rtheta.match(gatelist[i+1][j]).groups()
                        gatelist[i+1][j]="z"
                        if rxyz=="rz":
                            gatelist[i][j]=gatelist[i+1][j]
                        else:
                            gatelist[i][j]="%s%s"%(rxyz,-int(theta))
                    elif gatenum.match(gatelist[i+1][j]):#z 多比特
                        gatetype,num=gatenum.match(gatelist[i+1][j]).groups()
                        if gatetype=="cz":#z cz->cz z
                            insert[j]="z"
                            gatelist[i][j]=""
                    elif measure.match(gatelist[i+1][j]):#z measure
                        mxz,sgn=measure.match(gatelist[i+1][j]).groups()
                        if mxz=="mz":#z mz->mz i
                            gatelist[i][j]=gatelist[i+1][j]
                            gatelist[i+1][j]=""
                        elif mxz=="mx":#z mx->-mx z
                            gatelist[i+1][j]="z"
                            gatelist[i][j]="%s%s"%(mxz,measuremsgn[sgn])
                elif gatelist[i][j]=="x":#===x===
                    if gatelist[i+1][j]=="x":#x x->i i
                        gatelist[i][j]=""
                        gatelist[i+1][j]=""
                    if rtheta.match(gatelist[i+1][j]):#x rtheta->rtheta x
                        rxyz,theta=rtheta.match(gatelist[i+1][j]).groups()
                        gatelist[i+1][j]="x"
                        if rxyz=="rx":
                            gatelist[i][j]=gatelist[i+1][j]
                        else:
                            gatelist[i][j]="%s%s"%(rxyz,-int(theta))
                    elif gatenum.match(gatelist[i+1][j]):#x 多比特
                        gatetype,num=gatenum.match(gatelist[i+1][j]).groups()
                        if gatetype=="cz":#x cz->cz x,z
                            insert[j]="x"
                            gatelist[i][j]=""
                            for k in range(npip):
                                if k!=j and gatecheck(gatelist[i+1][j],gatelist[i+1][k]):
                                    insert[k]="z"
                    elif measure.match(gatelist[i+1][j]):#x measure
                        mxz,sgn=measure.match(gatelist[i+1][j]).groups()
                        if mxz=="mx":#x mx->mx i
                            gatelist[i][j]=gatelist[i+1][j]
                            gatelist[i+1][j]=""
                        elif mxz=="mz":#x mz->-mz x
                            gatelist[i+1][j]="x"
                            gatelist[i][j]="%s%s"%(mxz,measuremsgn[sgn])
                elif rtheta.match(gatelist[i][j]):#===rtheta===
                    rxyz,theta=rtheta.match(gatelist[i][j]).groups()
                    if rtheta.match(gatelist[i+1][j]):#rntheta rntheta->i rnsumtheta
                        rxyz2,theta2=rtheta.match(gatelist[i+1][j]).groups()
                        if rxyz==rxyz2:
                            gatelist[i][j]=""
                            newtheta=(int(theta)+int(theta2)+180)%360-180
                            if newtheta==0:
                                gatelist[i+1][j]=""#rn0->i
                            elif newtheta==-180:
                                gatelist[i+1][j]=rxyz[1]#rn180->n
                                if rxyz[1]=="y":
                                    gatelist[i][j]="x"
                                    gatelist[i+1][j]="z"
                            else:
                                gatelist[i+1][j]="%s%s"%(rxyz,newtheta)
            if gatenum.match(gatelist[i][j]) and gatelist[i+1][j]:#多比特且右侧非空
                gatetype,num=gatenum.match(gatelist[i][j]).groups()
                k=j+1
                while k < npip and not gatecheck(gatelist[i][j],gatelist[i][k]):#配对
                    k=k+1
                if gatetype=="cz":#===cz===
                    if gatenum.match(gatelist[i+1][j]) and gatenum.match(gatelist[i+1][k]):
                        if gatenum.match(gatelist[i+1][j]).group(1)=="cz" and gatecheck(
                        gatelist[i+1][j],gatelist[i+1][k]):#cz,cz cz,cz->i,i i,i
                            gatelist[i][j]=""
                            gatelist[i+1][j]=""
                            gatelist[i][k]=""
                            gatelist[i+1][k]=""
        if insert!=["" for numpip in range(npip)]:
            gatelist.insert(i+2,insert)
        i=i+1
    return gatelist




gatelist=init("in.csv")
gatelist=cntocz(gatelist)
gatelist=htory90zANDytoxz(gatelist)
newlist=rightshift(gatesimplify(gatelist))
while newlist!=gatelist:
    gatelist=newlist
    newlist=rightshift(gatesimplify(gatelist))
write(gatelist,"out.csv")