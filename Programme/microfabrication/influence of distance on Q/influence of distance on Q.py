# -*- coding: utf-8 -*-

#初始化
import pya
import paintlib
from math import *
layout,top = paintlib.IO.Start("guiopen")#在当前的图上继续画,如果没有就创建一个新的
layout.dbu = 0.001#设置单位长度为1nm
paintlib.IO.pointdistance=500#设置腔的精度,转弯处相邻两点的距离
layer1 = layout.layer(10, 10)
#变换方向的交界点
intersection = [[1384062,3000000],[3200000,1184062],[3200000,-1466904],[1266904,-3400000],[-1549747,-3400000],[-3600000,-1349747]]
distance = 200000 #圆弧起始点距离交点的距离
radius = distance/tan(pi/8)
#画传输线

cell1 = layout.create_cell("Transmission")#cell
top.insert(pya.CellInstArray(cell1.cell_index(),pya.Trans()))
startpoint = [-7700000,3000000]
electrode1=paintlib.BasicPainter.Electrode(startpoint[0],startpoint[1],180)#electrode
painter1=paintlib.CavityPainter(pya.DPoint(startpoint[0],startpoint[1]),angle=0,widout=20000,widin=10000)#painter

painter1.Run(lambda painter:painter.Straight(intersection[0][0]-distance-startpoint[0]))
painter1.Run(lambda painter:painter.Turning(radius,angle = 45))
painter1.Draw(cell1,layer1)








#输出
paintlib.IO.Show()#输出到屏幕上
#paintlib.IO.Write()#输出到文件中
#