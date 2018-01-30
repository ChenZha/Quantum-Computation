import numpy as np
import random
import time
from multiprocessing import Pool
import scipy.io as sio
import os

''' 
SA算法，在每次迭代里，新的点xnew在当前点x附近产生，临时区域的半径随每次迭代下降，到目前为止，找到的最佳点xbest，也被追踪
如果f(xnew)<=f(xbest)，则xnew取代xbest和x，否则xnew以一定概率P=exp(b)取代x，b = -δf/T
'''

def init_population(targetfunc , population , Dimension , inputfile , process , x_l , x_u):
    x_all_init = np.zeros((population , Dimension))
    value_now_init = np.zeros(population)
    x_best_init = np.zeros((population , Dimension))
    value_best_init = np.zeros(population)
    
    if inputfile == None:  
        initial = []
        p = Pool(process)
        for i in range(population):
            for j in range(Dimension):
                x_all_init[i][j] =  x_l[j] + random.random()*(x_u[j]-x_l[j])
            initial.append(p.apply_async(targetfunc,(x_all_init[i],)))
        value_now_init = np.array([initial[i].get() for i in range(len(initial))])
        value_best_init = value_now_init
        x_best_init = x_all_init
        p.close()
        p.join()
        
    else:
        inputdata = sio.loadmat(inputfile)
        x_all_init = inputdata['x_all'][-1]
        value_now_init = inputdata['value_now'][-1]
        x_best_init = inputdata['x_best']
        value_best_init = inputdata['value_best']

    return(x_all_init , value_now_init , x_best_init , value_best_init)

def evolution_pop(targetfunc , index , generation , Dimension , Temperature , StepFactor , x_all , value_now , x_best , value_best , Markovlen , x_l , x_u):
    x_nextgeneration_index = x_all[generation][index]
    value_nextgeneration_index = value_now[generation][index]
    x_best_index = x_best[index]
    value_best_index = value_best[index]
    
    for i in range(Markovlen):
        xnew = np.array([0 for j in range(Dimension)])
        for j in range(Dimension):
            xnew[j] = x_all[generation][index][j]+(random.random()-0.5)*StepFactor*(x_u[j]-x_l[j])
        xnew = np.array([xnew[item] if xnew[item] < x_u[item] else x_u[item] for item in range(Dimension)])
        xnew = np.array([xnew[item] if xnew[item] > x_l[item] else x_l[item] for item in range(Dimension)])

        val = targetfunc(xnew)


        if val < value_nextgeneration_index:#更新当前点(小于则接受)
            x_nextgeneration_index = xnew
            value_nextgeneration_index = val
            if val < value_best_index:#更新最优值
                value_best_index = val
                x_best_index = xnew 
        else:#更新当前点(大于则以一定概率接受)
            # test = np.exp(-(val-value_nextgeneration_index)*np.log(generation+2)/10)
            test = np.exp(-(val-value_nextgeneration_index)/Temperature)
            
            if random.random() < test:
                x_nextgeneration_index = xnew
                value_nextgeneration_index = val

            else:
                x_nextgeneration_index = x_nextgeneration_index
                value_nextgeneration_index = value_nextgeneration_index

    return(x_nextgeneration_index , value_nextgeneration_index , x_best_index , value_best_index)
def SA_Evolution(targetfunc , Dimension = 4 , population = None , x_l = None , x_u = None , 
                Markovlen = 10 , BeginTem = 100 , EndTem = 0.11 , TemDecay = 0.95 , 
                StepFactor = 0.01 , StepDecay = 0.99 , inputfile = None , process = 2
                ):
    #初始化参数
    if population == None:#样本数
        population = min(2*Dimension,50)
    else:
        population = population
    if x_l == None:
        x_l = np.array([-10 for i in range(Dimension)])
    else:
        x_l = np.array(x_l)
    if x_u == None:
        x_u = np.array([10 for i in range(Dimension)])
    else:
        x_u = np.array(x_u)
    Temperature = BeginTem
    StepFactor = StepFactor
    iterate_time = int(np.ceil((np.log(EndTem)-np.log(BeginTem)/np.log(TemDecay))))

    #过程记录数据
    x_all = np.zeros((iterate_time , population , Dimension))
    value_now = np.zeros((iterate_time , population))
    x_best = np.zeros((population , Dimension))
    value_best = np.zeros(population)
    x_all[0] , value_now[0] , x_best , value_best = init_population(targetfunc , population , Dimension , inputfile , process , x_l , x_u)

    if os.path.exists('result'):
        pass
    else:
        os.mkdir('result')
    

    p = Pool(process)
    print('模拟退火初始化完成')
    print('寻优参数维度为：',Dimension)
    print('population为：',population)
    for g in range(iterate_time-1):
        print('第',g,'代')
        result = []
        for i in range(population):
            result.append(p.apply_async(evolution_pop,(targetfunc , i , g , Dimension , 
                                        Temperature , StepFactor , 
                                        x_all.copy() , value_now.copy() , x_best.copy() , value_best.copy() ,
                                        Markovlen , x_l , x_u ,)))
        
        res = np.array([result[i].get() for i in range(len(result))])
        
        x_all[g+1] = np.array([res[j][0] for j in range(population)])
        value_now[g+1] = np.array([res[j][1] for j in range(population)])
        x_best = np.array([res[j][2] for j in range(population)])
        value_best = np.array([res[j][3] for j in range(population)])
        

        print('Best parameters:',x_best[np.argmin(value_best)])    
        print('least cost function',np.min(value_best))
        print('std为：',np.std(value_best))

        filename = './result/SA'+str(g)+'_'+time.strftime('%Y%m%d%X',time.localtime())+'.mat'
        #sio.savemat(filename,{'x_all':x_all,'value_now':value_now,'x_best':x_best,'value_best':value_best,'min_fun':np.min(value_best),'best_x_parameter':x_best[np.argmin(value_best)]})

        #参数迭代
        Temperature = Temperature*TemDecay
        StepFactor = StepFactor*StepDecay

    print('best_value:',value_best)
    print('最小值：',np.min(value_best))
    print('最佳参数：',x_best[np.argmin(value_best)])   

    p.close()
    p.join()     
    return()
        

def evaluate_func(x):
    a = x[0]
    b = x[1]
    c = x[2]
    d = x[3]
    return(4*a**2 - 3*b + 5*c**3 - 6*d)
if __name__ == '__main__':
    SA_Evolution(evaluate_func,Dimension = 4 , population = 20 , x_l = [0,1,0,2] , x_u = [5,6,8,4] , inputfile = None , process = 2)

    print('stop')