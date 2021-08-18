# -*- coding: utf-8 -*-
"""
Created on Mon Jan 02 21:55:33 2017

@author: lenovo
"""

from multiprocessing import Pool
def func(n):
    a = 0
    b = 0
    for i in range(n):
        a +=i
        b +=i*i
    return a,b
if __name__ == '__main__':
    p=Pool(4)
    A = []
#    for i in range(20):
#        [a,b] = p.map(func,i)
#        A.append([a,b])
    A = p.map(func,range(5))
    p.close()
    p.join()
    print(A)
    