import multiprocessing as mp
import time


def job(x):
    time.sleep(1)
    return(x*x,x**3)


if __name__ == '__main__':
    '''
    Pool and map
    '''
    pool = mp.Pool(processes = 3)
    res = pool.map(job,range(10))
    print(res)


    '''
    apply_async()
    apply_async()只能输入一组参数,想要输出多个结果需要将其放入迭代器中
    '''
    t1 = time.time()
    mul_res = [pool.apply_async(job,(i,)) for i in range(10)]
    t2 = time.time()
    res1 = [(mul_res[i].get())[0] for i in range(len(mul_res))]
    t3 = time.time()
    res2 = [(mul_res[i].get())[1] for i in range(len(mul_res))]
    t4 = time.time()

    print(t2-t1,t3-t2,t4-t3)
    print(res1,res2)
