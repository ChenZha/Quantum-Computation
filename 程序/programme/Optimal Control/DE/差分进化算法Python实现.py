import numpy as np

def de(n = 4, m_size = 3 , f = 0.5 , cr = 0.3 , iterate_time = 100 , x_l = np.array([0,1,0,2]),x_u = np.array([5,6,8,4]) ):
    #初始化
    x_all = np.zeros((iterate_time , m_size , n))#m_size为population ，n为dimension
    for i in range(m_size):
        x_all[0][i] = x_l + np.random.random()*(x_u-x_l)
    print('差分进化算法初始化完成')
    print('寻优参数个数为',n,'优化区间分别为：',x_l,x_u)
    for g in range(iterate_time-1):
        print('第',g,'代')
        for i in range(m_size):
            #变异操作，对第g代随机抽取三个组成一个新的个体，对于第i个新个体来说，原来的第i个个体与它没有关系
            x_g_without_i = np.delete(x_all[g],i,0)
            np.random.shuffle(x_g_without_i)
            h_i = x_g_without_i[1]+f*(x_g_without_i[2]-x_g_without_i[3])
            #变异操作后，h_i个体可能会过上下限区间，为了保证在区间以内对超过区间外的值赋值为相邻的边界值
            #先处理上边界，如果h_i[item]大于x_u则取x_u，如果小于则取h_i[item]
            h_i = [h_i[item] if h_i[item]<x_u[item] else x_u[item] for item in range(n)] 
            h_i = [h_i[item] if h_i[item]>x_l[item] else x_l[item] for item in range(n)] 

            #交叉操作，对变异后的个体，根据随机数与交叉阈值确定最后的个体
            print(h_i)
            v_i = np.array([x_all[g][i][j] if (np.random.random() > cr) else h_i[j] for j in range(n) ])
            #根据评估函数确定是否更新新的个体
            if evaluate_func(x_all[g][i])>evaluate_func(v_i):
                x_all[g+1][i] = v_i
            else:
                x_all[g+1][i] = x_all[g][i]
    evaluate_result = [evaluate_func(x_all[iterate_time-1][i]) for i in range(m_size)]
    best_x_i = x_all[iterate_time-1][np.argmin(evaluate_result)]
    print(evaluate_result)
    print(np.min(evaluate_result))
    print(best_x_i)


def evaluate_func(x):
    a = x[0]
    b = x[1]
    c = x[2]
    d = x[3]
    return(4*a**2 - 3*b + 5*c**3 - 6*d)
if __name__ == '__main__':
    de() 