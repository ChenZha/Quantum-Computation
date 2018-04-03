from qutip import *
import numpy as np
from pylab import *
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D



def processTomo(E_process , E_ideal , N):
    Dimension = int(2**N)
    num_process = np.shape(E_process)[0]
    num_ideal = np.shape(E_ideal)[0]


    #检验完备性
    test = np.zeros((Dimension,Dimension),dtype = complex)
    for i in range(num_process):
        test = test + np.dot(np.conjugate(np.transpose(E_process[i])) , E_process[i])
    if np.abs((test-(qeye(Dimension)).full()) < 10**(-6)).all():
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
    return(fid,[matrix_e_process,matrix_e_ideal])

def process_view(chi_matrix , title_name):
    dimension = np.shape(chi_matrix)[0]
    coordinate_basic = ['I','X','Y','Z']
    label_list = []
    N = int(log(dimension)/log(4))
    for i in range(int(dimension)):#生成chi矩阵的basis
        index = np.zeros(dimension,dtype = np.int8)
        label = ''
        for j in range(dimension):
            i , m = divmod(i,4)
            index[N-1-j] = m
        for bas in index:
            label = label+coordinate_basic[bas]
        label_list.append(label)


    n = np.size(chi_matrix)
    xpos, ypos = np.meshgrid(range(chi_matrix.shape[0]), range(chi_matrix.shape[1]))
    xpos = xpos.T.flatten() - 0.5
    ypos = ypos.T.flatten() - 0.5
    zpos = np.zeros(n)
    dx = dy = 0.8 * np.ones(n)
    
    dz = np.real(chi_matrix.flatten())
    z_min = min(dz)
    z_max = max(dz)
    if z_min == z_max:
        z_min -= 0.1
        z_max += 0.1
    norm = mpl.colors.Normalize(z_min, z_max)
    cmap = cm.get_cmap('jet')  # Spectral
    colors = cmap(norm(dz))
    fig = plt.figure()
    ax = Axes3D(fig, azim=-35, elev=35)
    ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
    ax.set_xticklabels(label_list);ax.set_yticklabels(label_list)
    ax.set_title(title_name+'_Real')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)
    
    dz = np.imag(chi_matrix.flatten())
    z_min = min(dz)
    z_max = max(dz)
    if z_min == z_max:
        z_min -= 0.1
        z_max += 0.1
    norm = mpl.colors.Normalize(z_min, z_max)
    cmap = cm.get_cmap('jet')  # Spectral
    colors = cmap(norm(dz))
    fig = plt.figure()
    ax = Axes3D(fig, azim=-35, elev=35)
    ax.bar3d(xpos, ypos, zpos, dx, dy, dz, color=colors)
    ax.set_xticklabels(label_list);ax.set_yticklabels(label_list)
    ax.set_title(title_name+'_Imag')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)

if __name__ == '__main__':
    E_process = np.array([[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]],[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]])/np.sqrt(2)
    E_ideal = np.array([[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,-1]]])
    fid , chi = processTomo(E_process , E_ideal , 2)
    process_view(chi[0] , 'experiment')
    process_view(chi[1] , 'ideal')
    a  = 1