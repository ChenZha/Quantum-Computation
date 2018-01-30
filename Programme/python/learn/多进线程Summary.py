# -*- coding: utf-8 -*-

#==============================================================================
 'Pool'
p = Pool()
    for i in range(5):
        p.apply_async(long_time_task, args=(i,))
    print 'Waiting for all subprocesses done...'
    p.close()
    p.join()
#==============================================================================



#==============================================================================
"multiprocessing"
from multiprocessing import Process
p = Process(target=run_proc, args=('test',))
    print 'Process will start.'
    p.start()
    p.join()
#==============================================================================

#==============================================================================
"启动一个线程就是把一个函数传入并创建Thread实例，然后调用start()开始执行："
"Thread"
import time, threading
t = threading.Thread(target=loop, name='LoopThread')
t.start()
t.join()
#==============================================================================

#==============================================================================
"Lock"
"""
多进程中，同一个变量，各自有一份拷贝存在于每个进程中，互不影响，
而多线程中，所有变量都由所有线程共享
"""
threading.Lock()

lock = threading.Lock()
lock.acquire()
        try:
            # 放心地改吧:
            change_it(n)
        finally:
            # 改完了一定要释放锁:
            lock.release()
            
在定义函数中使用全局变量，要先声明  global balance
#==============================================================================


#==============================================================================
 "打出当前print所在行与到此时的运行时间"
 
 print("%s,%f"%(sys._getframe().f_lineno,time.time()))
#==============================================================================


#==============================================================================
"性能分析工具cProfile"
python -m cProfile -o example.out example.py
python -c "import pstats; p=pstats.Stats('example.out'); p.sort_stats('time').print_stats()"
参数：calls, cumulative, file, line, module, name, nfl, pcalls, stdname, time
#==============================================================================
