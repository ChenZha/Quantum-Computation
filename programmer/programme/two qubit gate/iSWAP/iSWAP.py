import matplotlib.pyplot as plt
import numpy as np
from pylab import *
from qutip import *
from mpl_toolkits.mplot3d import Axes3D
from multiprocessing import Pool
def Operator_View(M,lab):
    if isinstance(M, Qobj):
        # extract matrix data from Qobj
        M = M.full()

    n = np.size(M)
    xpos, ypos = np.meshgrid(range(M.shape[0]), range(M.shape[1]))
    xpos = xpos.T.flatten() - 0.5
    ypos = ypos.T.flatten() - 0.5
    zpos = np.zeros(n)
    dx = dy = 0.8 * np.ones(n)
    
    dz = np.real(M.flatten())
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
    ax.set_title(lab+'_Real')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)
    
    dz = np.imag(M.flatten())
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
    ax.set_title(lab+'_Imag')
    cax, kw = mpl.colorbar.make_axes(ax, shrink=.75, pad=.0)
    mpl.colorbar.ColorbarBase(cax, cmap=cmap, norm=norm)

def evolution(psi):

    g = 0.002 * 2 * np.pi
    wq= np.array([5.100 , 5.100 ]) * 2 * np.pi
    eta_q=  np.array([-0.250 , -0.250]) * 2 * np.pi


    N = 3
    sm0=tensor(destroy(N),qeye(N))
    sm1=tensor(qeye(N),destroy(N))
    E_uc0 = tensor(basis(3,2)*basis(3,2).dag() , qeye(3)) 
    E_uc1 = tensor(qeye(3) , basis(3,2)*basis(3,2).dag())

    H0= (wq[0]) * sm0.dag()*sm0 + (wq[1]) * sm1.dag()*sm1 + eta_q[0]*E_uc0 + eta_q[1]*E_uc1 + g * (sm0.dag()+sm0) * (sm1.dag()+sm1)

    options=Options()
    options.atol=1e-8
    options.rtol=1e-6
    options.first_step=0.01
    options.num_cpus=8
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=True

    tlist = np.linspace(0 , np.pi/g/2 , 301)
    output = mesolve(H0,psi,tlist,[],[],options = options)

    U1 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[0])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    U2 = basis(N,0)*basis(N,0).dag()+np.exp(1j*(wq[1])*tlist[-1])*basis(N,1)*basis(N,1).dag()
    UT = tensor(U1,U2)
    return(UT*output.states[-1])

if __name__=='__main__':

    global wq,g,H0,options



    T = []
    T.append(tensor(basis(3,0),basis(3,0)))
    T.append(tensor(basis(3,0),basis(3,1)))
    T.append(tensor(basis(3,1),basis(3,0)))
    T.append(tensor(basis(3,1),basis(3,1)))

    p = Pool(4)
    outputstate = p.map(evolution,T)
    p.close()
    p.join()

    process = np.column_stack([outputstate[i].data.toarray() for i in range(len(outputstate))])[(0,1,3,4),:]
    angle = np.angle(process[0][0])
    process = process*np.exp(-1j*angle)
    targetprocess = np.array([[1,0,0,0],[0,0,-1j,0],[0,-1j,0,0],[0,0,0,1]])
    Ufidelity = np.abs(np.trace(np.dot(np.conjugate(np.transpose(targetprocess)),process)))/(2**2)
    print(Ufidelity)

    Operator_View(process , 'Simulation')



