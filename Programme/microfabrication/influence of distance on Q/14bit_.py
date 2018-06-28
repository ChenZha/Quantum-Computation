# -*- coding: utf-8 -*-
#初始化
import pya
import paintlib
layout,top = paintlib.IO.Start("guiopen")#在当前的图上继续画,如果没有就创建一个新的
layout.dbu = 0.001#设置单位长度为1nm
paintlib.IO.pointdistance=500#设置腔的精度,转弯处相邻两点的距离

#画腔
dy=-300000
painter3=paintlib.CavityPainter(pya.DPoint(0,1050000+dy),angle=-90,widout=48000,widin=16000,bgn_ext=0,end_ext=0)
c1bgninfo=painter3.Getinfo()[0:3]
c1bgninfo[2]+=180
def path1(painter):#设置内轮廓路径
    dl=547.0693762227893-dy/11+0/22
    length=0
    length+=painter.Straight(570000+dy)
    length+=painter.Turning(40000)
    length+=painter.Straight(210000+dl)
    length+=painter.Turning(-40000)
    length+=painter.Turning(-40000)
    for i in range(5):
        length+=painter.Straight(500000+dl*2)#1
        length+=painter.Turning(40000)
        length+=painter.Turning(40000)
        length+=painter.Straight(500000+dl*2)#2
        length+=painter.Turning(-40000)
        length+=painter.Turning(-40000)
    length+=painter.Straight(210000+dl)
    length+=painter.Turning(40000)
    length+=painter.Straight(570000+dy)
    return length    
length=painter3.Run(path1)
print("length of Cavity1 : %s"%(length))
print("add %s to dl"%((8080000-length)/22))
c1endinfo=painter3.Getinfo()[0:3]
centerlineinfos=[]
regionlistout=[]
regionlistin=[]
centerlineinfos.extend(painter3.centerlineinfos)
regionlistout.extend(painter3.regionlistout)
regionlistin.extend(painter3.regionlistin)

    #画腔挂Qubit的延伸
c1info=[c1bgninfo for i in range(7)]
c1info.extend([c1endinfo for i in range(7)])
angle1=[-135, -90, -45, 0, 45, 90, 135,
        -135, -90, -45, 0, 45, 90, 135]
angle2=[45, 0, 45, 0, -45, 0, -45,
        45, 0, 45, 0, -45, 0, -45]
clen=[125663.70614359167,62831.85307179589,62831.85307179589,0,62831.85307179589,62831.85307179589,125663.70614359167,
        125663.70614359167,62831.85307179589,62831.85307179589,0,62831.85307179589,62831.85307179589,125663.70614359167]
connectioninfo=[]
for index in range(14):
    painter3.__init__(pya.DPoint(c1info[index][0],c1info[index][1]),c1info[index][2],widout=48000,widin=16000,bgn_ext=0,end_ext=0)
    clength=800000    
    length=0   
    length+=painter3.Run(lambda painter:painter.Turning(40000,angle1[index]))
    length+=painter3.Run(lambda painter:painter.Straight(clength-clen[index]))
    length+=painter3.Run(lambda painter:painter.Turning(40000,angle2[index]))
    print("length of c1 %s : %s"%(index,length))
    print("add %s to clen %s"%(length-clength,index))
    centerlineinfos.extend(painter3.centerlineinfos)
    regionlistout.extend(painter3.regionlistout)
    regionlistin.extend(painter3.regionlistin)
    connectioninfo.append(painter3.Getinfo())
    connection1=paintlib.BasicPainter.Connection(connectioninfo[-1][0],connectioninfo[-1][1],connectioninfo[-1][2],mod=48)
    regionlistout.append(connection1)

    #把数据形式保存的图形画出来
painter3.centerlineinfos=centerlineinfos
painter3.regionlistout=regionlistout
painter3.regionlistin=regionlistin
layer1 = layout.layer(10, 10)#创建新层
cell2 = layout.create_cell("Main")#创建一个子cell
top.insert(pya.CellInstArray(cell2.cell_index(),pya.Trans()))
cell3 = layout.create_cell("Cavity1")#创建一个子cell
cell2.insert(pya.CellInstArray(cell3.cell_index(),pya.Trans()))
painter3.Draw(cell3,layer1)#把画好的腔置入

    #画腔的Crossover
centerlinelist=[]#画腔的中心线并根据中心线画Crossover
for i in painter3.Getcenterlineinfo():
    centerlinelist.append(i[0])
painter4=paintlib.TransfilePainter("[Crossover48].gds","insert")
painter4.airbrigedistance=100000#设置Crossover的间距
painter4.DrawAirbrige(cell2,centerlinelist,"Crossover48")

#画Qubit
Painter = paintlib.Painter
CavityBrush = paintlib.CavityBrush
TransfilePainter = paintlib.TransfilePainter
class QubitPainter_p(Painter):
    def __init__(self,filename="[Xmon_20170112_p].gds",insertcellname="insert"):
        self.painter=TransfilePainter(filename,insertcellname)
        self.brushs=[
            CavityBrush(pointc=pya.DPoint(200000,174000),angle=90,widout=8000,widin=4000),
            CavityBrush(pointc=pya.DPoint(525000,0),angle=0,widout=20000,widin=10000),
            CavityBrush(pointc=pya.DPoint(525000,64000),angle=0,widout=20000,widin=10000),
            ]
    def DrawQubit(self,cell,newcellname,DCplxTrans1):
        self.painter.DrawGds(cell,newcellname,DCplxTrans1)
        return [brush.transformed(DCplxTrans1) for brush in self.brushs]
class QubitPainter_m(Painter):
    def __init__(self,filename="[Xmon_20170112_m].gds",insertcellname="insert"):
        self.painter=TransfilePainter(filename,insertcellname)
        self.brushs=[
            CavityBrush(pointc=pya.DPoint(200000,-174000),angle=270,widout=8000,widin=4000),
            CavityBrush(pointc=pya.DPoint(525000,0),angle=0,widout=20000,widin=10000),
            CavityBrush(pointc=pya.DPoint(525000,-64000),angle=0,widout=20000,widin=10000),
            ]
    def DrawQubit(self,cell,newcellname,DCplxTrans1):
        self.painter.DrawGds(cell,newcellname,DCplxTrans1)
        return [brush.transformed(DCplxTrans1) for brush in self.brushs]
qpainter_p = QubitPainter_p()
qpainter_m = QubitPainter_m()
mirror=[True, True, False, True, True, False, False,
        True, True, False, False, True, False, False]
qbrushsList=[qpainter_m.DrawQubit(cell2,'Qubit_m',pya.DCplxTrans(1,i[2],False,i[0],i[1])) if m else qpainter_p.DrawQubit(cell2,'Qubit_p',pya.DCplxTrans(1,i[2],False,i[0],i[1])) for i,m in zip(connectioninfo,mirror)]

#画最外圈把读取腔串起来的线
cell4 = layout.create_cell("Electrode")
cell2.insert(pya.CellInstArray(cell4.cell_index(),pya.Trans()))

painter8=paintlib.CavityPainter(pya.DPoint(-2900000,-3000000),angle=0,widout=20000,widin=10000)
electrode2=paintlib.BasicPainter.Electrode(-2900000,-3000000,180)
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Run(lambda painter:painter.Straight(1900000+500000))
painter8.Run(lambda painter:painter.Turning(150000))
painter8.Run(lambda painter:painter.Turning(150000))
painter8.Run(lambda painter:painter.Straight(1900000+500000))
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Run(lambda painter:painter.Straight(5000000))
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Run(lambda painter:painter.Straight(6000000))
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Run(lambda painter:painter.Straight(5000000))
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Run(lambda painter:painter.Straight(1900000+500000))
painter8.Run(lambda painter:painter.Turning(150000))
painter8.Run(lambda painter:painter.Turning(150000))
painter8.Run(lambda painter:painter.Straight(1900000+500000))
painter8.Run(lambda painter:painter.Turning(-150000))
painter8.Draw(cell4,layer1)
electrode1info=painter8.Getinfo()
electrode3=paintlib.BasicPainter.Electrode(electrode1info[0],electrode1info[1],electrode1info[2])
paintlib.BasicPainter.Draw(cell4,layer1,electrode2)
paintlib.BasicPainter.Draw(cell4,layer1,electrode3)

blength=515000# 特征间距515000
bx=[-2440000+blength,2840000-blength]  
by=[-2990000+blength,32900000-blength]


#画Qubit的腔和电极以及连线
centerlinelist=[]#记录传输线的中心线
def readoutCavityPath(painter,dlength=154000,n=4):
    length=0
    length+=painter.Straight(515000-3000-29000)
    length+=painter.Turning(26000)
    length+=painter.Straight(408000-29000-29000)
    length+=painter.Turning(26000)
    length+=painter.Straight(183000-29000-29000)
    length+=painter.Turning(26000)

    for i in range(n):
        length+=painter.Straight(280000)
        length+=painter.Turning(-26000)
        length+=painter.Turning(-26000)
        length+=painter.Straight(280000)
        length+=painter.Turning(26000)
        length+=painter.Turning(26000)
    length+=painter.Straight(dlength)
    return length    


q13=qbrushsList[-2]

painter6=paintlib.CavityPainter(q13[1])
painter6.Run(lambda painter:painter.Straight(40000))
painter6.Run(lambda painter:painter.Turning(-80000))
painter6.Run(lambda painter:painter.Straight(40000))
painter6.Run(lambda painter:painter.Turning(80000))
dx=painter6.Getinfo()[0]-bx[0]
painter6.Run(lambda painter:painter.Straight(dx))   
painter6.Draw(cell4,layer1)
electrode1info=painter6.Getinfo()
electrode1=paintlib.BasicPainter.Electrode(electrode1info[0],electrode1info[1],electrode1info[2])
paintlib.BasicPainter.Draw(cell4,layer1,electrode1)
for i in painter6.Getcenterlineinfo():
    centerlinelist.append(i[0])

painter6=paintlib.CavityPainter(q13[2])
painter6.Run(lambda painter:painter.Straight(20000))
painter6.Run(lambda painter:painter.Turning(-40000))
painter6.Run(lambda painter:painter.Straight(800000-176000))
painter6.Run(lambda painter:painter.Turning(40000))
dx=painter6.Getinfo()[0]-bx[0]
painter6.Run(lambda painter:painter.Straight(dx))    
painter6.Draw(cell4,layer1)
electrode1info=painter6.Getinfo()
electrode1=paintlib.BasicPainter.Electrode(electrode1info[0],electrode1info[1],electrode1info[2])
paintlib.BasicPainter.Draw(cell4,layer1,electrode1)
for i in painter6.Getcenterlineinfo():
    centerlinelist.append(i[0])


painter6=paintlib.CavityPainter(q13[0])
length=0
length+=painter6.Run(lambda painter:painter.Straight(1205000-61000+200000))
length+=painter6.Run(lambda painter:painter.Turning(40000))
dx=painter6.Getinfo()[0]-bx[0]
length+=painter6.Run(lambda painter:painter.Straight(dx)) 
length+=painter6.Run(lambda painter:readoutCavityPath(painter,154000-142637.091580268))
print(length)
painter6.Draw(cell4,layer1)


#画连线的Airbrige
painter7=paintlib.TransfilePainter("[Airbrige20].gds","insert")
painter7.airbrigedistance=100000#设置Crossover的间距
painter7.DrawAirbrige(cell2,centerlinelist,"Airbrige20")


#画边界
layer2 = layout.layer(1, 1)
border=paintlib.BasicPainter.Border(leng=4050000,siz=4050000,wed=50000)
paintlib.BasicPainter.Draw(top,layer2,border)

#输出
paintlib.IO.Show()#输出到屏幕上
#paintlib.IO.Write()#输出到文件中
#