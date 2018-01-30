'''
Queue的功能是将每个核或线程的运算结果放在队里中， 
等到每个线程或核运行完毕后再从队列中取出结果，
继续加载运算。原因很简单, 多线程调用的函数不能有返回值, 所以使用Queue存储多个线程运算的结果
'''
import multiprocessing as mp
import threading as td
'''
把结果放在Queue里
'''
def job(q):#该函数没有返回值
    '''
    q像一个队列，用来保存每次函数运行的结果
    '''
    res = 0
    for i in range(1000):
        res += i+i**2+i**3
    q.put(res)

'''
main function
'''
if __name__ == '__main__':
    q = mp.Queue()
    '''
    args 的参数只要一个值的时候，参数后面需要加一个逗号，表示args是可迭代的，后面可能还有别的参数，不加逗号会出错
    '''
    p1 = mp.Process(target=job, args=(q,), )
    p2 = mp.Process(target=job, args=(q,), )

    p1.start()
    p2.start()
    p1.join()
    p2.join()

    res1 = q.get()
    res2 = q.get()

    print(res1,res2)