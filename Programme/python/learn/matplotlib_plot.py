'''
在绘图结构中，figure创建窗口，subplot创建子图。所有的绘画只能在子图上进行。plt表示当前子图
'''
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import os
import threading

def showpic(name):
    def _showpic(name=name):
        os.system('start explorer '+name)
    threading.Thread(target=_showpic).start()


# 创建数据
x = np.arange(-5,5,0.1)
y = x**3

# 创建窗口，子图
# 方法1：先创建窗口，再创建子图
# fig = plt.figure(num = 1,figsize = (15,8),dpi = 80)
# ax1 = fig.add_subplot(2,1,1)
# ax2 = fig.add_subplot(2,1,2)
# print(fig,ax1,ax2)

# 方法2：一次性创建窗口和多个子图

# fig,axarr = plt.subplots(4,1) # 开一个新窗口，并添加4个子图，返回子图数组 
# ax1 = axarr[0]
# print(fig,ax1)

# 方法3：一次性创建窗口和一个子图
# ax1 = plt.subplot(1,1,1,facecolor = 'white')
# print(ax1)

# 获取对窗口的引用，适用于上面三种方法
# fig = plt.gcf()


# fig.subplots_adjust(left = 0)

# plot1=ax1.plot(x,y,marker='o',color='g',label='legend1')   #点图：marker图标
# plot2=ax2.plot(x,y,linestyle='--',alpha=0.5,color='r',label='legend2')   #线图：linestyle线性，alpha透明度，color颜色，label图例文本
# plt.savefig('test.png',dpi=400,bbox_inches='tight')
# plt.show() 


'''一个窗口，多个图，多条数据'''
# sub1=plt.subplot(2,1,1,facecolor=(0.1843,0.3098,0.3098))  #将窗口分成2行1列，在第1个作图，并设置背景色
# sub2=plt.subplot(2,1,2)   #将窗口分成2行1列，在第2个作图
# sub1.plot(x,y)          #绘制子图
# sub2.plot(x,y)          #绘制子图

# axes1 = plt.axes([.2, .3, .1, .1], facecolor='y')  #添加一个子坐标系，rect=[左, 下, 宽, 高]
# axes1.plot(x,y)           #绘制子坐标系，
# axes2 = plt.axes([0.7, .2, .1, .1], facecolor='y')  #添加一个子坐标系，rect=[左, 下, 宽, 高]
# axes2.plot(x,y)
# plt.show()

'''极坐标'''
# fig = plt.figure(2)
# ax1 = fig.add_subplot(1,2,1,polar = True)
# theta = np.arange(0,2*np.pi,0.02)
# ax1.plot(theta,2*np.ones_like(theta),lw = 2)
# ax1.plot(theta,theta/6,linestyle = '--',lw = 4)

# ax2 = fig.add_subplot(1,2,2,polar=True)                  #启动一个极坐标子图
# ax2.plot(theta,np.cos(5*theta),linestyle='--',lw=2)
# ax2.plot(theta,2*np.cos(4*theta),lw=2)
# ax2.set_rgrids(np.arange(0.2,2,0.2),angle = 45)
# ax2.set_thetagrids([0,45,90])

# plt.show()

'''柱形图'''
# fig = plt.figure(3)
# axes = fig.add_subplot(1,1,1)
# x_index = np.arange(5) #柱的索引
# x_data = ('A','B','C','D','E')
# y1_data = (20,35,30,35,27)
# y2_data = (25,32,34,20,25)
# bar_width = 0.35

# rect1 = axes.bar(x_index,y1_data,width = bar_width,alpha = 0.4, color = 'b',label = 'legend1')
# rect2 = axes.bar(x_index + bar_width, y2_data, width=bar_width,alpha=0.5,color='r',label='legend2')
# plt.xticks(x_index + bar_width/2, x_data)   #x轴刻度线
# plt.legend()
# plt.tight_layout()
# plt.show()

'''直方图'''
# fig,(ax1,ax2) = plt.subplots(2,1,figsize = (9,6))
# sigma = 1
# mean = 0
# x = mean+sigma*np.random.randn(10000)
# ax1.hist(x,bins = 40,normed = False , histtype = 'bar',facecolor = 'yellowgreen',alpha = 0.75)
# ax2.hist(x,bins=20,normed=1,histtype='bar',facecolor='pink',alpha=0.75,cumulative=True,rwidth=0.8)
# plt.show()

'''散点图'''
# fig = plt.figure(4)
# ax = fig.add_subplot(1,1,1)
# x = np.random.random(100)
# y = np.random.random(100)
# ax.scatter(x,y,s=x*1000,c='y',marker=(3,1),alpha=0.5,lw=2,facecolors='none')  #x横坐标，y纵坐标，s图像大小，c颜色，marker图片，lw图像边框宽度
# plt.show()


'''三维图'''
# fig = plt.figure()
# ax = fig.add_subplot(111,projection='3d')
# x,y=np.mgrid[-2:2:20j,-2:2:20j]
# z = x*np.exp(-x**2-y**2)
# ax.plot_surface(x,y,z,rstride=2,cstride=1,cmap=cm.coolwarm,alpha=0.8)  #绘制三维图表面
# ax.set_xlabel('x-name')     #x轴名称
# ax.set_ylabel('y-name')     #y轴名称
# ax.set_zlabel('z-name')     #z轴名称
# plt.show()

'''画矩形，多边形，圆形，和椭圆'''
fig = plt.figure(6)   #创建一个窗口
ax=fig.add_subplot(1,1,1)   #添加一个子图
rect1 = plt.Rectangle((0.1,0.2),0.2,0.3,color='r')  #创建一个矩形，参数：(x,y),width,height
circ1 = plt.Circle((0.7,0.2),0.15,color='r',alpha=0.3)  #创建一个椭圆，参数：中心点，半径，默认这个圆形会跟随窗口大小进行长宽压缩
pgon1 = plt.Polygon([[0.45,0.45],[0.65,0.6],[0.2,0.6]])  #创建一个多边形，参数：每个顶点坐标
ax.add_patch(rect1)  #将形状添加到子图上
ax.add_patch(circ1)  #将形状添加到子图上
ax.add_patch(pgon1)  #将形状添加到子图上
fig.canvas.draw()  #子图绘制
plt.show()
