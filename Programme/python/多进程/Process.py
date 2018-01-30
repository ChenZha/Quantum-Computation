'''
导入线程进程标准模块
'''
import multiprocessing as mp
import threading as td

'''
定义一个被线程和进程调用的函数
'''
def job(a,d):
    print('aaa')

'''
创建线程和进程
'''
t1 = td.Thread(target = job,args = (1,2))
p1 = mp.Process(target=job,  args=(1,2),)#被调函数的参数放在args中

t1.start()
p1.start()
t1.join()
p1.join()
