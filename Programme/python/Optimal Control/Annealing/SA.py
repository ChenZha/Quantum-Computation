import numpy as np
import random
import time
from multiprocessing import Pool
import scipy.io as sio
import os

''' 
SA算法，在每次迭代里，新的点xnew在当前点x附近产生，临时区域的半径随每次迭代下降，到目前为止，找到的最佳点xbest，也被追踪
如果f(xnew)<=f(xbest)，则xnew取代xbest和x，否则xnew以一定概率P=exp(b)取代x，b = -δflog(i+1)/10
'''
class SimulationAnnealing(object):
    def __init__(self , targetfunc , Dimension = 4,population = None,
                x_l = None,
                x_u = None,
                Markovlen = 10,
                BeginTem = 100,
                EndTem = 0.1,
                TemDecay = 0.96,
                StepFactor = 0.02,
                StepDecay = 0.99,
                inputfile = None,
                process = 2,
                ):
        self.targetfunc = targetfunc
        self.Dimension = Dimension
        if population == None:#样本数
            self.population = min(2*Dimension,50)
        else:
            self.population = population
        if x_l == None:
            self.x_l = np.array([-10 for i in range(Dimension)])
        else:
            self.x_l = np.array(x_l)
        if x_u == None:
            self.x_u = np.array([10 for i in range(Dimension)])
        else:
            self.x_u = np.array(x_u)
        self.Markovlen =  Markovlen#邻域搜索次数
        self.BeginTem =  BeginTem
        self.Temperature = BeginTem
        self.EndTem = EndTem
        self.TemDecay = TemDecay
        self.StepFactor = StepFactor
        self.StepDecay = StepDecay#步长缩减
        self.iterate_time = int(np.ceil((np.log(self.EndTem)-np.log(self.BeginTem)/np.log(self.TemDecay))))
        self.inputfile = inputfile
        self.process = process#并行处理的个数

        #过程记录
        self.x_all = np.zeros((self.iterate_time , self.population , self.Dimension))
        self.value_now = np.zeros((self.iterate_time , self.population))
        self.x_best = np.zeros((self.population , self.Dimension))
        self.value_best = np.zeros(self.population)
    def init_population(self):
        if self.inputfile == None:  
            initial = []
            p = Pool(self.process)
            for i in range(self.population):
                for j in range(self.Dimension):
                    self.x_all[0][i][j] =  self.x_l[j] + random.random()*(self.x_u[j]-self.x_l[j])
                initial.append(p.apply_async(self.targetfunc,(self.x_all[0][i],)))
            self.value_now[0] = np.array([initial[i].get() for i in range(len(initial))])
            self.value_best = self.value_now[0]
            self.x_best = self.x_all[0]
            p.close()
            p.join()
            
        else:
            inputdata = sio.loadmat(inputfile)
            self.x_all[0] = inputdata['x_all'][-1]
            self.value_now[0] = inputdata['value_now'][-1]
            self.x_best = inputdata['x_best']
            self.value_best = inputdata['value_best']

    def evolution_pop(self , index ,generation):
        
        for i in range(self.Markovlen):
            xnew = np.array([0 for j in range(self.Dimension)])
            for j in range(self.Dimension):
                xnew[j] = self.x_all[generation][index][j]+(random.random()-0.5)*self.StepFactor*(self.x_u[j]-self.x_l[j])
            xnew = np.array([xnew[item] if xnew[item] < self.x_u[item] else self.x_u[item] for item in range(self.Dimension)])
            xnew = np.array([xnew[item] if xnew[item] > self.x_l[item] else self.x_l[item] for item in range(self.Dimension)])
            val = self.targetfunc(xnew)
            
            if val < self.value_now[generation][index]:#更新当前点(小于则接受)
                self.x_all[generation+1][index] = xnew
                self.value_now[generation+1][index] = val
                print('update0')
                if val < self.value_best[index]:#更新最优值
                    self.value_best[index] = val
                    self.x_best[index] = xnew 
            else:#更新当前点(大于则以一定概率接受)
                test = np.exp(-(val-self.value_now[generation][index])*np.log(generation+2)/10)
                print(test)
                if random.random() < test:
                # if random.random() < np.exp(-(val-self.value_now[generation][index])/self.Temperature):
                    self.x_all[generation+1][index] = xnew
                    self.value_now[generation+1][index] = val
                    print('update1')
                else:
                    self.x_all[generation+1][index] = self.x_all[generation][index]
                    self.value_now[generation+1][index] = self.value_now[generation][index]

        return(self.x_all , self.value_now , self)
    def SA_Evolution(self):
        self.init_population()
        if os.path.exists('result'):
            pass
        else:
            os.mkdir('result')
        

        p = Pool(self.process)
        print('模拟退火初始化完成')
        print('寻优参数维度为：',self.Dimension)
        print('population为：',self.population)
        for g in range(self.iterate_time-1):
            print('第',g,'代')
            result = []
            for i in range(self.population):
                result.append(p.apply_async(self.evolution_pop,(i,g,)))
                # self.evolution_pop(i,g)
            res = np.array([result[i].get() for i in range(len(result))])
            

            # print('Best parameters:',self.x_best[np.argmin(self.value_best)])    
            # print('least cost function',np.min(self.value_best))
            # print('std为：',np.std(self.value_best))

            filename = './result/SA'+str(g)+'_'+time.strftime('%Y%m%d%X',time.localtime())+'.mat'
            #sio.savemat(filename,{'x_all':self.x_all,'value_now':self.value_now,'x_best':self.x_best,'value_best':self.value_best,'min_fun':np.min(self.value_best),'best_x_parameter':self.x_best[np.argmin(self.value_best)]})

            #参数迭代
            self.Temperature = self.Temperature*self.TemDecay
            self.StepFactor = self.StepFactor*self.StepDecay

        print('best_value:',self.value_best)
        print('最小值：',np.min(self.value_best))
        print('最佳参数：',self.x_best[np.argmin(self.value_best)])   

        p.close()
        p.join()     
        

def evaluate_func(x):
    a = x[0]
    b = x[1]
    c = x[2]
    d = x[3]
    return(4*a**2 - 3*b + 5*c**3 - 6*d)
if __name__ == '__main__':
    sa = SimulationAnnealing(evaluate_func,Dimension = 4 , population = 20 , x_l = [0,1,0,2] , x_u = [5,6,8,4] , inputfile = None , process = 2)
    sa.SA_Evolution()
    # sa.init_population()
    # sa.evolution_pop(1,1)
    print('stop')