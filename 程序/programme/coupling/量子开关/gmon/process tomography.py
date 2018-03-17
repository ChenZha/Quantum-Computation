from qutip import *
import numpy as np



def processTomo(E_process , E_ideal , N):
    Dimension = int(2**N)
    num_process = np.shape(E_process)[0]
    num_ideal = np.shape(E_ideal)[0]


    #检验完备性
    test = np.zeros((Dimension,Dimension))
    for i in range(num_process):
        test = test + np.dot(np.conjugate(np.transpose(E_process[i])) , E_process[i])
    if ((test-(qeye(Dimension)).full()) < 10**(-6)).all():
        print('具备完备性')
    else:
        print('Error:完备性错误')
        return()



    basic = ['qeye(2)','sigmax()','sigmay()','sigmaz()']
    E_basic = []


    for i in range(int(Dimension**2)):#生成operator矩阵的basis
        index = np.zeros(N,dtype = np.int8)
        label = ''
        for j in range(N):
            i , m = divmod(i,4)
            index[N-1-j] = m
        for bas in index:
            label = label+basic[bas]+','
        label = 'tensor('+label+')' 
        E_basic.append((eval(label)).full())

    
    matrix_e_process = np.zeros((num_process,Dimension**2),dtype = complex)#计算实验process 的chi矩阵
    for i in range(num_process):
        for j in range(Dimension**2):
            matrix_e_process[i][j] = np.trace(np.dot(E_process[i],E_basic[j]))/Dimension
    chi_process = np.dot(np.conjugate(np.transpose(matrix_e_process)) , matrix_e_process)

    matrix_e_ideal = np.zeros((num_ideal,Dimension**2),dtype = complex)#计算理论process的chi矩阵
    for i in range(num_ideal):
        for j in range(Dimension**2):
            matrix_e_ideal[i][j] = np.trace(np.dot(E_ideal[i],E_basic[j]))/Dimension
    chi_ideal = np.dot(np.conjugate(np.transpose(matrix_e_ideal)) , matrix_e_ideal)

    fid = np.sqrt(np.trace(np.dot(chi_process,chi_ideal)))
    print(fid)
    return(fid)

if __name__ == '__main__':
    E_process = np.array([[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]])/np.sqrt(2)
    E_ideal = np.array([[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]]])
    processTomo(E_process , E_ideal , 2)