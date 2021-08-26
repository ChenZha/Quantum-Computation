# -*- coding: utf-8 -*-

#初始化
import pya
import paintlib
from imp import reload
reload(paintlib)
layout,top = paintlib.IO.Start("guiopen")#在当前的图上继续画,如果没有就创建一个新的
layout.dbu = 0.001#设置单位长度为1nm
paintlib.IO.pointdistance=2000#设置腔的精度,转弯处相邻两点的距离
TBD=paintlib.TBD.init(87985813)

#参数
from math import *
bitdistance=2540*2*1000
bitx=[bitdistance*ii for ii in range(-3,4)]
bity=[bitdistance*ii for ii in range(-3,4)]

holeradius=1800*1000
holedeltar=400*1000
holex=[bitdistance*ii+bitdistance/2 for ii in range(-4,4)]
holey=[bitdistance*ii+bitdistance/2 for ii in range(-4,4)]
holer=[[holeradius for jj in range(-4,4)] for ii in range(-4,4)]

cavityxlength=[[10000*1000 for jj in range(-3,4)] for ii in range(-3,3)]
cavityylength=[[10000*1000 for jj in range(-3,3)] for ii in range(-3,4)]
deltastart=200*1000

cavityreadoutlength=[[4300*1000 for jj in range(-3,4)] for ii in range(-3,4)]

feedlinebaselength=280000
feedliner=500000

controllinelength=500000

bordersize=4*bitdistance+2000*1000

#创建cell和layer的结构
layerh = layout.layer(1, 1)#创建新层
cellh = layout.create_cell("hole")#创建一个子cell
top.insert(pya.CellInstArray(cellh.cell_index(),pya.Trans()))
cellhplus = layout.create_cell("hole+")
top.insert(pya.CellInstArray(cellhplus.cell_index(),pya.Trans()))

layerb = layout.layer(1, 1)

layerCavity = layout.layer(10, 10)
cellreadout = layout.create_cell("readoutCavity")
top.insert(pya.CellInstArray(cellreadout.cell_index(),pya.Trans()))

cellb = layout.create_cell("Qubits")
top.insert(pya.CellInstArray(cellb.cell_index(),pya.Trans()))

cellcoupling = layout.create_cell("couplingCavity")
top.insert(pya.CellInstArray(cellcoupling.cell_index(),pya.Trans()))

cellfeedline = layout.create_cell("feedline")
top.insert(pya.CellInstArray(cellfeedline.cell_index(),pya.Trans()))

cellcontrolline = layout.create_cell("controlline")
top.insert(pya.CellInstArray(cellcontrolline.cell_index(),pya.Trans()))


#画孔
for ii in range(len(holex)):
    for jj in range(len(holey)):
        pts=paintlib.BasicPainter.arc(pya.DPoint(holex[ii],holey[jj]),holer[ii][jj],250,0,360)
        hole=pya.DPolygon(pts)
        paintlib.BasicPainter.Draw(cellh,layerh,hole)
        pts=paintlib.BasicPainter.arc(pya.DPoint(holex[ii],holey[jj]),holer[ii][jj]+holedeltar,250,0,360)
        hole=pya.DPolygon(pts)
        paintlib.BasicPainter.Draw(cellhplus,layerh,hole)

#画边界
border=paintlib.BasicPainter.Border(leng=bordersize+50000,siz=bordersize+50000,wed=50000)
paintlib.BasicPainter.Draw(top,layerb,border)

#画qubit
CavityBrush = paintlib.CavityBrush
class Qubit(object):
    readoutbrush=CavityBrush(pya.DPoint(0,0),0)
    coupling=185000-3
    readout=172530-3
    # readoute=844278.4421272138
    zx=302638-3
    zy=302637-3
    xyx=257382-3
    xyy=347893-3
class Qubit00(Qubit):
    def __init__(self,x,y,ii,jj,readoutlength):
        self.x=x
        self.y=y
        self.ii=ii
        self.jj=jj
        self.readoutlength=readoutlength
        brushs=[ 
            # 0123 上右下左的耦合腔
            CavityBrush(pointc=pya.DPoint(0,185000-3),angle=90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(184999-2,0),angle=0,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(0,-185000+3),angle=-90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(-184999+2,0),angle=180,widout=48000,widin=16000),
            # 4 读取腔
            CavityBrush(pointc=pya.DPoint(172530-3,172530-3),angle=45,widout=8000,widin=4000),
            # 5,6 z控制线 xy控制线
            CavityBrush(pointc=pya.DPoint(-302638+3,-302637+3),angle=-135,widout=8000,widin=4000),            CavityBrush(pointc=pya.DPoint(-257382+3,-347893+3),angle=-135,widout=8000,widin=4000),
            ]
        self.brushs=[brush.transform(pya.DCplxTrans(1,0,False,x,y)) for brush in brushs]
class Qubit10(Qubit):
    def __init__(self,x,y,ii,jj,readoutlength):
        self.x=x
        self.y=y
        self.ii=ii
        self.jj=jj
        self.readoutlength=readoutlength
        brushs=[ 
            # 0123 上右下左的耦合腔
            CavityBrush(pointc=pya.DPoint(0,185000-3),angle=90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(184999-2,0),angle=0,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(0,-185000+3),angle=-90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(-184999+2,0),angle=180,widout=48000,widin=16000),
            # 4 读取腔
            CavityBrush(pointc=pya.DPoint(-172530+3,172530-3),angle=135,widout=8000,widin=4000),
            # 5,6 z控制线 xy控制线
            CavityBrush(pointc=pya.DPoint(-302638+3,-302637+3),angle=-135,widout=8000,widin=4000),            CavityBrush(pointc=pya.DPoint(-257382+3,-347893+3),angle=-135,widout=8000,widin=4000),
            ]
        self.brushs=[brush.transform(pya.DCplxTrans(1,0,False,x,y)) for brush in brushs]
class Qubit01(Qubit):
    def __init__(self,x,y,ii,jj,readoutlength):
        self.x=x
        self.y=y
        self.ii=ii
        self.jj=jj
        self.readoutlength=readoutlength
        brushs=[ 
            # 0123 上右下左的耦合腔
            CavityBrush(pointc=pya.DPoint(0,185000-3),angle=90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(184999-2,0),angle=0,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(0,-185000+3),angle=-90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(-184999+2,0),angle=180,widout=48000,widin=16000),
            # 4 读取腔
            CavityBrush(pointc=pya.DPoint(172530-3,-172530+3),angle=-45,widout=8000,widin=4000),
            # 5,6 z控制线 xy控制线
            CavityBrush(pointc=pya.DPoint(302638-3,302637-3),angle=45,widout=8000,widin=4000),            CavityBrush(pointc=pya.DPoint(257382-3,347893-3),angle=45,widout=8000,widin=4000),
            ]
        self.brushs=[brush.transform(pya.DCplxTrans(1,0,False,x,y)) for brush in brushs]
class Qubit11(Qubit):
    def __init__(self,x,y,ii,jj,readoutlength):
        self.x=x
        self.y=y
        self.ii=ii
        self.jj=jj
        self.readoutlength=readoutlength
        brushs=[ 
            # 0123 上右下左的耦合腔
            CavityBrush(pointc=pya.DPoint(0,185000-3),angle=90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(184999-2,0),angle=0,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(0,-185000+3),angle=-90,widout=48000,widin=16000),
            CavityBrush(pointc=pya.DPoint(-184999+2,0),angle=180,widout=48000,widin=16000),
            # 4 读取腔
            CavityBrush(pointc=pya.DPoint(-172530+3,-172530+3),angle=-135,widout=8000,widin=4000),
            # 5,6 z控制线 xy控制线
            CavityBrush(pointc=pya.DPoint(302638-3,302637-3),angle=45,widout=8000,widin=4000),            
            CavityBrush(pointc=pya.DPoint(257382-3,347893-3),angle=45,widout=8000,widin=4000),
            ]
        self.brushs=[brush.transform(pya.DCplxTrans(1,0,False,x,y)) for brush in brushs]
Qubittpl=[[Qubit00,Qubit01],[Qubit10,Qubit11]]
pts=[[[],[]],[[],[]]]
painter00=paintlib.TransfilePainter("F:/laboratory/laboratory/task/4_4project(IBM)/layout/7-7/qubit1.gds")
painter01=paintlib.TransfilePainter("F:/laboratory/laboratory/task/4_4project(IBM)/layout/7-7/qubit4.gds")
painter10=paintlib.TransfilePainter("F:/laboratory/laboratory/task/4_4project(IBM)/layout/7-7/qubit2.gds")
painter11=paintlib.TransfilePainter("F:/laboratory/laboratory/task/4_4project(IBM)/layout/7-7/qubit5.gds")
qubits=[]
for ii in range(len(bitx)):
    qubits1d=[]
    for jj in range(len(bity)):
        mi=ii%2
        mj=jj%2
        pts[mi][mj].append(pya.Point(bitx[ii],bity[jj]))
        qubits1d.append(Qubittpl[mi][mj](bitx[ii],bity[jj],ii,jj,cavityreadoutlength[ii][jj]))
    qubits.append(qubits1d)

painter00.DrawMark(cellb,pts[0][0],"Qubit00")
painter01.DrawMark(cellb,pts[0][1],"Qubit01")
painter10.DrawMark(cellb,pts[1][0],"Qubit10")
painter11.DrawMark(cellb,pts[1][1],"Qubit11")

#画读取腔
def readoutCavity_path(painter,deltalength):
    dl=deltalength/12
    length=0
    length+=painter.Straight(248000)
    length+=painter.Turning(-20000)
    length+=painter.Straight(88000)
    for _index4 in range(6):
        length+=painter.Turning(20000,180)
        length+=painter.Straight(88000+dl)
        length+=painter.Turning(-20000,180)
        length+=painter.Straight(88000+dl)
    length+=painter.Turning(20000)
    length+=painter.Straight(130000)
    length+=painter.Turning(20000)
    length+=painter.Straight(250000)
    return length

for qubits1d in qubits:
    for qubit in qubits1d:
        painterrc=paintlib.CavityPainter(qubit.brushs[4])
        deltalength=TBD.get()
        length=painterrc.Run(lambda painter:readoutCavity_path(painter,deltalength))
        TBD.set(qubit.readoutlength-length)
        painterrc.Draw(cellreadout,layerCavity)

        qubit.centerlineinfo=painterrc.Getcenterlineinfo()

        painterrc.Run(lambda painter:painter.Turning(-8000,180))
        painterrc.Run(lambda painter:painter.Straight(250000-88000-24000))
        painterrc.Narrow(widout=20000,widin=10000,length=4000)
        qubit.readoutbrush=painterrc.brush

#画耦合腔
def couplingCavity_path(painter,deltalength,lx,mirror=1,dx=0,cx=bitdistance/2-185000+3,cy=bitdistance/2-48000/2,cr=holeradius+holedeltar):
    m = 1 if mirror==1 else -1
    dl=deltalength/10
    length=0
    xx=144000
    length+=painter.Straight(dx)
    xx+=dx
    length+=painter.Turning(m*-40000)
    def sl():
        return cy-sqrt(cr**2-(cx-xx)**2)-64000-16000
    yy=sl()
    length+=painter.Straight(yy)
    length+=painter.Turning(m*40000,180)
    for _index4 in range(5): # 160*5=960
        xx+=160000
        ny=sl()
        length+=painter.Straight(yy-ny+dl)
        length+=painter.Turning(m*-40000,180)
        length+=painter.Straight(dl)
        length+=painter.Turning(m*40000,180)
        yy=ny
    xx+=160000-144000
    length+=painter.Straight(yy)
    length+=painter.Turning(m*-40000)
    length+=painter.Straight(lx-xx)
    return length

    # 00 01位置 y 
    # 10 11位置 y
for ii in range(len(cavityylength)):
    brush=0
    deltajj=0
    if ii%2 ==1:
        brush=2
        deltajj=1
    for jj in range(len(cavityylength[ii])):
        paintercc=paintlib.CavityPainter(qubits[ii][jj+deltajj].brushs[brush])
        deltalength=TBD.get()
        length=paintercc.Run(lambda painter:couplingCavity_path(painter,deltalength=deltalength,dx=deltastart,lx=bitdistance-(185000-3)*2))
        TBD.set(cavityylength[ii][jj]-length)
        paintercc.Draw(cellcoupling,layerCavity)

    # 00 01位置 x 
    # 10 11位置 x
for ii in range(len(cavityxlength)):
    mirror=-1
    if ii%2 ==1:
        mirror=1
    for jj in range(len(cavityxlength[ii])):
        deltaii=0
        brush=1
        if jj%2 ==1:
            brush=3
            deltaii=1
        paintercc=paintlib.CavityPainter(qubits[ii+deltaii][jj].brushs[brush])
        deltalength=TBD.get()
        length=paintercc.Run(lambda painter:couplingCavity_path(painter,deltalength=deltalength,dx=deltastart,lx=bitdistance-(185000-3)*2,mirror=mirror))
        TBD.set(cavityxlength[ii][jj]-length)
        paintercc.Draw(cellcoupling,layerCavity)

#画读取电极

def readout_path(painter,dl1,dl2,dl3,feedliner=feedliner):
    painter.Straight(feedlinebaselength+dl1)
    painter.Turning(feedliner,-45)
    painter.Straight(2*dl2)
    painter.Turning(feedliner,-45)
    painter.Straight(feedlinebaselength+dl3)

    #获取参数
qubit=qubits[0][0]
paintertest=paintlib.CavityPainter(qubit.readoutbrush.reversed())
dl1=TBD.get()
dl2=TBD.get()
paintertest.Run(lambda painter:painter.Straight(feedlinebaselength+dl1))
paintertest.Run(lambda painter:painter.Turning(feedliner,-45))
paintertest.Run(lambda painter:painter.Straight(dl2))
testbrush=paintertest.brush
TBD.set(max(-sqrt(2)*(qubit.y+bitdistance/2-holeradius-holedeltar-20000/2-testbrush.centery),0),-2)
TBD.set(qubit.x+bitdistance/2-testbrush.centerx)
# # paintertest.Draw(cellfeedline,layerCavity)

for ii in range(len(qubits)):
    if ii%2==1:continue
    for jj in range(len(qubits[ii])):
        if jj%2==1:continue
        brushs=[qubits[ii][jj].readoutbrush]
        if jj+1 < len(qubits[ii]):
            brushs.append(qubits[ii][jj+1].readoutbrush)
        if ii+1 < len(qubits):
            brushs.insert(0,qubits[ii+1][jj].readoutbrush)
        if jj+1 < len(qubits[ii]) and ii+1 < len(qubits):
            brushs.append(qubits[ii+1][jj+1].readoutbrush)
        for brush in brushs[:-1]:
            painterfl=paintlib.CavityPainter(brush)
            painterfl.Run(lambda painter:readout_path(painter,dl1=dl1,dl2=dl2,dl3=dl1+3,feedliner=-feedliner))
            painterfl.Draw(cellfeedline,layerCavity)
        painterfl=paintlib.CavityPainter(brushs[0].reversed())
        painterfl.Run(lambda painter:painter.Straight(feedlinebaselength))
        painterfl.Electrode()
        painterfl.Draw(cellfeedline,layerCavity)
        painterfl=paintlib.CavityPainter(brushs[-1])
        painterfl.Run(lambda painter:painter.Straight(feedlinebaselength))
        painterfl.Electrode()
        painterfl.Draw(cellfeedline,layerCavity)

#画z线xy线电极
def zline_path(painter):
    painter.Turning(400000,45)
    painter.Straight(controllinelength)

def xyline_path(painter):
    painter.Turning(-400000,45)
    painter.Straight(controllinelength)

for qubits1d in qubits:
    for qubit in qubits1d:
        painterzcl=paintlib.CavityPainter(qubit.brushs[5])
        painterzcl.Narrow(widout=20000,widin=10000,length=10000)
        painterzcl.Run(zline_path)
        painterzcl.Electrode()
        painterzcl.Draw(cellcontrolline,layerCavity)
        painterzcl=paintlib.CavityPainter(qubit.brushs[6])
        painterzcl.Narrow(widout=20000,widin=10000,length=10000)
        painterzcl.Run(xyline_path)
        painterzcl.Electrode()
        painterzcl.Draw(cellcontrolline,layerCavity)


#输出
print(TBD.isFinish())
paintlib.IO.Show()#输出到屏幕上
#paintlib.IO.Write()#输出到文件中
#