# -*- coding: utf-8 -*-
# date: 2018-06-26
#初始化
import pya
import paintlib
from math import *

def intersection_get(a,b,phi):
    '''
    通过给出两个中心点到直线的距离，以及第一个距离的角度，得到直线交点
    '''
    painter0=paintlib.CavityPainter(pya.DPoint(0,0),angle=phi,widout=20000,widin=10000)
    painter0.Run(lambda painter:painter.Straight(a))
    painter0.Run(lambda painter:painter.Turning(0,angle = 90))
    painter0.Run(lambda painter:painter.Straight(sqrt(2)*b-a))
    return(pya.DPoint(painter0.brush.centerx,painter0.brush.centery))
    
    
layout,top = paintlib.IO.Start("guiopen")#在当前的图上继续画,如果没有就创建一个新的
layout.dbu = 0.001#设置单位长度为1nm
paintlib.IO.pointdistance=3000#设置腔的精度,转弯处相邻两点的距离
layer1 = layout.layer(10, 10)

#变换方向的交界点
dis = [3200000,3300000,3400000,3500000,3600000,3700000,3800000,3900000]#中心点距直线的距离
intersection = [intersection_get(dis[0],dis[1],90),intersection_get(dis[1],dis[2],45),intersection_get(dis[2],dis[3],0),intersection_get(dis[3],dis[4],-45),intersection_get(dis[4],dis[5],270),intersection_get(dis[5],dis[6],225),intersection_get(dis[6],dis[7],180)]
distanceinter = 200000 #圆弧起始点距离交点的距离
radius = distanceinter/tan(pi/8)

#画传输线

cell1 = layout.create_cell("Transmission")#cell
top.insert(pya.CellInstArray(cell1.cell_index(),pya.Trans()))
startpoint = pya.DPoint(-dis[-2]+360000,dis[0]) #起始位置
electrode1=paintlib.BasicPainter.Electrode(startpoint.x,startpoint.y,180)#electrode1
painter1=paintlib.CavityPainter(pya.DPoint(startpoint.x,startpoint.y),angle=0,widout=20000,widin=10000)#painter
cavity_loc = [paintlib.CavityBrush(pointc=pya.DPoint(-650000,dis[0]), angle=0,widout=20000,widin=10000,bgn_ext=0)]#将要画腔的位置
painter1.Run(lambda painter:painter.Straight((intersection[0]).distance(startpoint)-distanceinter))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[1]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[1]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[2]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[2]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[3]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[3]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[4]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[4]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[5]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[5]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)

painter1.Run(lambda painter:painter.Straight(((intersection[6]).distance(curpos)-distanceinter)/4))
cavity_loc.append(painter1.brush)
painter1.Run(lambda painter:painter.Straight(((intersection[6]).distance(curpos)-distanceinter)/4*3))
painter1.Run(lambda painter:painter.Turning(120000,angle = 45))
painter1.Run(lambda painter:painter.Straight(250000))
painter1.Run(lambda painter:painter.Turning(120000,angle = -45))
painter1.Run(lambda painter:painter.Straight(250000))
curpos = pya.DPoint(painter1.brush.centerx , painter1.brush.centery)
electrode2=paintlib.BasicPainter.Electrode(curpos.x,curpos.y,90)#electrode

print(painter1)
painter1.Draw(cell1,layer1)
paintlib.BasicPainter.Draw(cell1,layer1,electrode1)
paintlib.BasicPainter.Draw(cell1,layer1,electrode2)

# 画传输线上airbridge

centerlinelist = []
for i in painter1.Getcenterlineinfo():
    centerlinelist.append(i[0])

painter7=paintlib.TransfilePainter("[airbridge].gds","airbridge")
painter7.airbridgedistance=350000#设置Crossover的间距
painter7.DrawAirbridge(cell1,centerlinelist,"airbridge")

# 画腔
cell2 = layout.create_cell("Cavity")#cell
top.insert(pya.CellInstArray(cell2.cell_index(),pya.Trans()))
cavity_length = [10000000,9900990,9803921,9708737,9615384,9523809,9433962,9345794]#半波长腔长
for ii in range(len(cavity_loc)):
    painter2 = paintlib.CavityPainter(cavity_loc[ii]) #用以转移的画笔

    painter2.Run(lambda painter:painter.Turning(0,angle = 90))
    
    painter2.Run(lambda painter:painter.Straight(25000))
    painter2.Run(lambda painter:painter.Turning(0,angle = 90))
    
    start_cavity_point = painter2.brush #画腔的起始位置
    painter3=paintlib.CavityPainter(pointc=pya.DPoint(start_cavity_point.centerx,start_cavity_point.centery), 
                                    angle=start_cavity_point.angle,
                                    widout=24000,widin=8000,bgn_ext=8000,end_ext=0)  #用以画腔的画笔
    length=0 #用以计算长度
    length += painter3.Run(lambda painter:painter.Straight(300000))
    length += painter3.Run(lambda painter:painter.Turning(50000,angle = -90))
    length += painter3.Run(lambda painter:painter.Straight(550000))
    for j in range(6):
        length += painter3.Run(lambda painter:painter.Straight(500000))
        length += painter3.Run(lambda painter:painter.Turning(50000,angle = -180))
        length += painter3.Run(lambda painter:painter.Straight(500000))
        length += painter3.Run(lambda painter:painter.Turning(50000,angle = 180))
    # if ii == 0 :
    #     length += painter3.Run(lambda painter:painter.Straight(500000))
    #     length += painter3.Run(lambda painter:painter.Turning(50000,angle = -180))
    #     length += painter3.Run(lambda painter:painter.Straight(500000))
    #     length += painter3.Run(lambda painter:painter.Turning(50000,angle = 180))
    # else:
    if ii != 6:
        length += painter3.Run(lambda painter:painter.Straight(500000))
        length += painter3.Run(lambda painter:painter.Turning(50000,angle = -180))
    
    painter3.bgn_ext = 8000
    length += painter3.Run(lambda painter:painter.Straight(cavity_length[ii]-length))
    

    print(length)

    
    painter3.Draw(cell2,layer1)


#画边界
layer2 = layout.layer(1, 1)
border=paintlib.BasicPainter.Border(leng=500000,siz=5000000,wed=40000)
paintlib.BasicPainter.Draw(top,layer2,border)

#输出
paintlib.IO.Show()#输出到屏幕上
#paintlib.IO.Write()#输出到文件中
#