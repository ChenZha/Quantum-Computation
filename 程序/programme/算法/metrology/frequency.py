
import numpy as np
from pylab import *
import matplotlib.pyplot as plt
from scipy.optimize import *
from DE_improvement import *
import functools




def energylevel(Ec, Ej,  phi):
    """
    Return the energy level 0 , 1 , 2 .(GHz)
    phi为输入磁通与磁通量子的比值
    """
    phi0 = 2.067833636*10**(-15)
    N = 30
    m = np.diag(4 * Ec * (arange(-N,N+1))**2) - 0.5 * Ej * np.cos(np.pi*phi) *(np.diag(-np.ones(2*N), 1) + 
                                                                  np.diag(-np.ones(2*N), -1))
    level = np.linalg.eigvals(m)
    level = np.sort(level)
    return([level[1]-level[0] , level[2]-level[1]])

def f2phi(Ec , Ej , f):
    '''
    给出Ec ， Ej和工作点频率，得到偏置磁通phi(phi/phi0)
    '''
    
    def deviation(Ec , Ej , f , phi):
        return(np.abs(f-energylevel(Ec, Ej,  phi)[0]))

    func = lambda phi: deviation(Ec , Ej , f , phi)
    
    fit_phi = fminbound(func , 0 , 0.5)

    return(fit_phi)
def T2phi_f(delta_f):
    '''
    不同频率变化下，T2phi的大小（ns）
    '''
    T2f = 8.92513*exp(-13.7361*delta_f)+2.48406
    return(T2f*1000)
def dephasing(x , work_point):
    '''
    Ec，Ej的qubit，当在工作点时，在单位磁通偏置下，积累单位相位所用的时间，与T2的比值（相位退相干影响大小）
    '''
    Ec = x[0]
    Ej = x[1]
    sweep_point , _ = energylevel(Ec, Ej,  0)
    phi = f2phi(Ec , Ej , work_point)
    T1phi = 18*1000
    T2phi = T2phi_f(abs(sweep_point-work_point))
    I = 1.5e-6
    deltaphi = 0.011
    deltaf = energylevel(Ec , Ej , phi)[0]-energylevel(Ec , Ej , phi+deltaphi)[0]

    t = 1/deltaf
    cost = t/T1phi+(t/T2phi)**2
    return(cost)

def sweep_point_find(work_point , method):
    '''
    确定工作点频率后，寻找最优的顶点频率
    '''
    if method == 'DE':
        evo_func = functools.partial(dephasing, work_point=work_point)
        x_l = np.array([0.200 , 15 ,])#Ec,Ej
        x_u = np.array([0.300 , 25 ,])
        de( evo_func , n = 2,m_size = 10,f = 0.9 , cr = 0.5 ,S = 0.9 , iterate_time = 400,x_l = x_l,x_u = x_u,inputfile = None,process = 1)
        return()
    elif method == 'LB':
        evo_func = lambda x : dephasing(x , work_point)
        x0 = [0.250 , 17]
        bound =  [(0.2,0.3),(15,25)]
        res = minimize(evo_func , x0 , method = 'L-BFGS-B' , bounds= bound )
        print(res.x , res.fun)
        res = minimize(evo_func , x0 , method = 'L-BFGS-B' , bounds= bound )
        el = energylevel(res.x[0],res.x[1],0)
        print(el)
        return(res.x , res.fun)
    elif 'BR':
        evo_func = lambda x : dephasing([0.245 , x] , work_point)
        cost = []
        Ej = np.linspace(16,22,60)
        for i in Ej:
            cost.append(evo_func(i))
        figure();plot(Ej , cost)
    else:       
        return()
def work_point_find(Ec , Ej , method = 'FB'):
    '''
    已知顶点频率，寻找最优的工作点频率
    '''
    x = [Ec , Ej]
    f01 , f12 = energylevel(Ec , Ej , 0)
    if method == 'FB':
        evo_func = lambda work_point : dephasing(x , work_point)
        opt_point , val , _ , _ = fminbound(evo_func , f01-1.5 , f01 , disp = 3 , full_output= True)
        print(opt_point , val)
        return(opt_point , val)
    elif method == 'LB':
        evo_func = lambda work_point : dephasing(x , work_point)
        x0 = [f01-0.3]
        bound =  [(f01-1.5 , f01) , ]
        res = minimize(evo_func , x0 , method = 'L-BFGS-B' , bounds= bound )
        print(res.x , res.fun)
        return(res.x , res.fun)
    else:
        return()
    
if __name__ == '__main__':
    
    phi0 = 2.067833636*10**(-15)
    sweep_point_find(5.6 , 'BR')
    # work_point_find(0.250 , 19 , method = 'LB')
    # result = dephasing(0.250 , 20 , 5.6)
    print(result)