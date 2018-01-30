# -*- coding: utf-8 -*-
from multiprocessing import Pool
import os, time, random
import sys
starttime = time.time()
def task(n,m):
    a = 0
    b = 0
    for i in range(n):
        a += i
    for j in range(m):
        b += j
    return a,b

if __name__=='__main__':
    print("Start")
    p = Pool()
    List = []
    for n in [10,50,100]:
        for m in [2,4,6]:
            
            [a,b] = p.apply(task,[n,m])
            A = [a,b]
            print (A)
            List.append(A)
            print("task%d,%d,\t%f" %(n,m,time.time()-starttime))
        
    p.close()
    p.join()
    print('All subprocesses done.')
    print (List)
    #print("%s,%f"%(sys._getframe().f_lineno,time.time()-starttime))
    
    