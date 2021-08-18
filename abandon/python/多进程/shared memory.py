import multiprocessing as mp
'''
通过使用value数据存储在一个共享的内存中
'''
value1 = mp.Value('i',0)
value2 = mp.Value('d',3.14)#i和d都是设置数据类型

'''
Array类也可以共享数据类型，只能是一维的，而且必须设置数据类型
'''
array  = mp.Array('i',[1,2,3,4])