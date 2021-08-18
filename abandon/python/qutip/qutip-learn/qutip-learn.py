# -*- coding: utf-8 -*-
"""
Created on Sun Jan 01 17:33:39 2017

@author: lenovo
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from qutip import gates
#if __name__ == '__main__':
#    times = np.linspace(0.0, 10.0, 200)
#    psi0 = tensor(fock(2,1),fock(10,5))
#    a = tensor(qeye(2),destroy(10))
#    ad = tensor(qeye(2),create(10))
#    sm = tensor(destroy(2),qeye(10))
#    sp = tensor(create(2),qeye(10))
#    H = 2*np.pi*ad*a + 2*np.pi*sp*sm + 2*np.pi*0.25*(sm * ad + sp*a)
#    result = mcsolve(H, psi0, times, [np.sqrt(0.1)*a], [ad*a, sp*sm])
#    qsave(result,"data")
#    fig, ax = plt.subplots()
#    #fig, ax = plt.subplots()
#    ax.plot(result.times, result.expect[0]);
#    ax.plot(result.times, result.expect[1]);
#    ax.set_xlabel('Time');
#    ax.set_ylabel('Expectation values');
#    ax.legend(("cavity photon number", "atom excitation probability"));
#    plt.show()



#==============================================================================
"主方程中，collapse operator是随机作用的，但在某些具体系统中，这些作用及其几率是有具体物理解释的"
"Bloch-Redfield formalism"
#delta = 0.2 * 2*np.pi; eps0 = 1.0 * 2*np.pi; gamma1 = 0.5
#H = - delta/2.0 * sigmax() - eps0/2.0 * sigmaz()
#def ohmic_spectrum(w):
#    if w == 0.0: # dephasing inducing noise
#        return gamma1
#    else: # relaxation inducing noise
#        return gamma1 / 2 * (w / (2 * np.pi)) * (w > 0.0)
#
#R, ekets = bloch_redfield_tensor(H, [sigmax()], [ohmic_spectrum])
#tlist = np.linspace(0, 15.0, 1000)
#psi0 = (fock(2,1)).unit()
#e_ops = [sigmax(), sigmay(), sigmaz()]
#expt_list = bloch_redfield_solve(R, ekets, psi0, tlist, e_ops)
#sphere = Bloch()
#sphere.add_points([expt_list[0], expt_list[1], expt_list[2]])
#sphere.vector_color = ['r']
#sphere.add_vectors(np.array([delta, 0, eps0]) / np.sqrt(delta ** 2 + eps0 ** 2))
#sphere.make_sphere()
#plt.show()
#==============================================================================


#==============================================================================
"H也有可能随时间变化"
"一："
#H = [H0,[H1,H1_coeff]]
#def H1_coeff(t, args):
#    return 9 * np.exp(-(t / 5.) ** 2)
#c_ops = [[a, col_coeff]] 


#def H1_coeff(t, args):
#    return args['A'] * np.exp(-(t/args['sigma'])**2)
#output = mesolve(H, psi0, times, c_ops, [a.dag() * a], args={'A': 9, 'sigma': 5})

"二"
#H = [H0, [H1, '9 * exp(-(t / 5) ** 2)']]
#==============================================================================


#==============================================================================
"qutip.parfor function"
"parfor loops should be restricted to the qutip.mesolve function only"
"qutip.rhs_generate  before calling parfor"
"You must then set the qutip.Odedata object rhs_reuse=True for all solver"
"calls inside the parfor loop"

#delta = 0.1 * 2 * np.pi # qubit sigma_x coefficient
#w = 2.0 * 2 * np.pi # driving frequency
#T = 2 * np.pi / w # driving period
#gamma1 = 0.00001 # relaxation rate
#gamma2 = 0.005 # dephasing rate
#eps_list = np.linspace(-10.0, 10.0, 51) * 2 * np.pi # epsilon
#A_list = np.linspace(0.0, 20.0, 51) * 2 * np.pi # Amplitude
#sx = sigmax(); sz = sigmaz(); sm = destroy(2); sn = num(2)
#c_ops = [np.sqrt(gamma1) * sm, np.sqrt(gamma2) * sz] # relaxation and dephasing
#H0 = -delta / 2.0 * sx
#H1 = [sz, '-eps / 2.0 + A / 2.0 * sin(w * t)']
#H_td = [H0, H1]
#Hargs = {'w': w, 'eps': eps_list[0], 'A': A_list[0]}
#opts = Options(rhs_reuse=True)
#rhs_generate(H_td, c_ops, Hargs, name='lz_func')
#def task(args):
#    m, eps = args
#    p_mat_m = np.zeros(len(A_list))
#    for n, A in enumerate(A_list):
#        # change args sent to solver, w is really a constant though
#        Hargs = {'w': w, 'eps': eps,'A': A}
#        U = propagator(H_td, T, c_ops, Hargs, opts) #<- IMPORTANT LINE
#        rho_ss = propagator_steadystate(U)
#        p_mat_m[n] = expect(sn, rho_ss)
#    return [m, p_mat_m]
#==============================================================================




#==============================================================================
"Floquet Formalism"
"应用于strongly driven systems"
"有周期T"
#delta = 0.2 * 2*np.pi; eps0 = 1.0 * 2*np.pi; A = 2.5 * 2*np.pi; omega = 1.0 * 2*np.pi
#H0 = - delta/2.0 * sigmax() - eps0/2.0 * sigmaz()
#H1 = A/2.0 * sigmaz()
#args = {'w': omega}
#H = [H0, [H1, 'sin(w * t)']]
#T = 2*pi / omega
#f_modes_0, f_energies = floquet_modes(H, T, args)
#
#f_modes_t = floquet_modes_t(f_modes_0, f_energies, 2.5, H, T, args)#给出t=0时的mode，计算出t时的mode
#f_coeff = floquet_state_decomposition(f_modes_0, f_energies, psi0)#分解初态
#psi_t = floquet_wavefunction_t(f_modes_0, f_energies, f_coeff, t, H, T, args)#算出末态




##from qutip import *
#from scipy import *
#from pylab import *
#delta = 0.2 * 2*pi; eps0 = 1.0 * 2*pi
#A = 0.5 * 2*pi; omega = 1.0 * 2*pi
#T = (2*pi)/omega
#tlist = linspace(0.0, 10 * T, 101)
#psi0 = basis(2,0)
#H0 = - delta/2.0 * sigmax() - eps0/2.0 * sigmaz()
#H1 = A/2.0 * sigmaz()
#args = {'w': omega}
#H = [H0, [H1, lambda t,args: sin(args['w'] * t)]]
## find the floquet modes for the time-dependent hamiltonian
#f_modes_0,f_energies = floquet_modes(H, T, args)
## decompose the inital state in the floquet modes
#f_coeff = floquet_state_decomposition(f_modes_0, f_energies, psi0)
## calculate the wavefunctions using the from the floquet modes
#p_ex = zeros(len(tlist))
#for n, t in enumerate(tlist):
#    psi_t = floquet_wavefunction_t(f_modes_0, f_energies, f_coeff, t, H, T, args)
#    p_ex[n] = expect(num(2), psi_t)
## For reference: calculate the same thing with mesolve
#p_ex_ref = mesolve(H, psi0, tlist, [], [num(2)], args).expect[0]
## plot the results
#
#plot(tlist, real(p_ex), 'ro', tlist, 1-real(p_ex), 'bo')
#plot(tlist, real(p_ex_ref), 'r', tlist, 1-real(p_ex_ref), 'b')
#xlabel('Time')
#ylabel('Occupation probability')
#legend(("Floquet $P_1$", "Floquet $P_0$", "Lindblad $P_1$", "Lindblad $P_0$"))
#show()

"Pre-computing the Floquet modes for one period"

"整合成"
#output = fsesolve(H, psi0, times, [num(2)], args)
#p_ex = output.expect[0]


#==============================================================================




#==============================================================================
"solve steadystate"
#rho_ss = steadystate(H, c_ops)
#==============================================================================






#==============================================================================
"An Overview of the Eseries Class"
#es2 = eseries([0.5 * sigmax(), 0.5 * sigmax()], [1j * omega, -1j * omega])
#"evolution"
#times = [0.0, 1.0 * pi, 2.0 * pi]
#esval(es2, times)
#
#"expect value"
#rho = fock_dm(2, 1)
#es3_expect = expect(rho, es3)
#es3_expect.value([0.0, pi/2])
#
#
#"application"
#psi0 = basis(2,1)
#H = sigmaz()
#L = liouvillian(H, [sqrt(1.0) * destroy(2)])
#es = ode2es(L, psi0)
#es_expect = expect(sigmaz(), es)
#es_expect.value([0.0, 1.0, 2.0, 3.0])
##The qutip.essolve.ode2es function diagonalizes the Liouvillian L and 
##creates an exponential series

#==============================================================================


#b.add_points(x_list,y_list,z_list)
#b.add_vectors(vec)
#b.add_states(up)

#==============================================================================
"Plot"
#N = 20
#rho_coherent = coherent_dm(N, np.sqrt(2))
#fig, axes = plt.subplots(1, 3, figsize=(12,3))

##bar0 = axes[0].bar(np.arange(0, N)-0.5, rho_coherent.diag())
##lbl0 = axes[0].set_title("Coherent state")
##lim0 = axes[0].set_xlim([-.5, N])
#plot_fock_distribution(rho_coherent, fig=fig, ax=axes[0], title="Coherent state");


"Wigner function"
#xvec = np.linspace(-5,5,200)
#W_coherent = wigner(rho_coherent, xvec, xvec)
#cont0 = axes[0].contourf(xvec, xvec, W_coherent, 100)
#lbl0 = axes[0].set_title("Coherent state")
#plt.show()


"Custom Color Maps"
"""
plotting a Wigner function is to demonstrate that the underlying state is nonclassical,
as indicated by negative values in the Wigner function
"""
#from matplotlib import cm
#wmap = wigner_cmap(W_coherent) # Generate Wigner colormap
#nrm = mpl.colors.Normalize(-W_coherent.max(), W_coherent.max())
#plt1 = axes[0].contourf(xvec, xvec, W_coherent, 100, cmap=cm.RdBu, norm=nrm)
#axes[0].set_title("Standard Colormap");
#plt.show()
#==============================================================================

#==============================================================================
"Husimi Q-function" 
#N = 20
#rho_coherent = coherent_dm(N, np.sqrt(2))
#xvec = np.linspace(-5,5,200)
#Q_coherent = qfunc(rho_coherent, xvec, xvec)
#fig, axes = plt.subplots(1, 3, figsize=(12,3))
#cont0 = axes[0].contourf(xvec, xvec, Q_coherent, 100)
#lbl0 = axes[0].set_title("Coherent state")
#plt.show()
#axes[0].contourf()
#==============================================================================




#==============================================================================
"Visualizing operators"
#N = 5
#a = tensor(destroy(N), qeye(2))
#b = tensor(qeye(N), destroy(2))
#sx = tensor(qeye(N), sigmax())
#H = a.dag() * a + sx - 0.5 * (a * b.dag() + a.dag() * b)
## visualize H
#lbls_list = [[str(d) for d in range(N)], ["u", "d"]]
#xlabels = []
#for inds in tomography._index_permutations([len(lbls) for lbls in lbls_list]):
#    xlabels.append("".join([lbls_list[k][inds[k]]for k in range(len(lbls_list))]))
#fig, ax = matrix_histogram(H, xlabels, xlabels, limits=[-4,4])
#ax.view_init(azim=-55, elev=45)
#plt.show()



#fig, ax = hinton(rho_ss) for steadystate
#==============================================================================




#==============================================================================
"Quantum process tomography"

#U_psi = iswap()
#U_rho = spre(U_psi) * spost(U_psi.dag())
#op_basis = [[qeye(2), sigmax(), sigmay(), sigmaz()]] * 2 
#op_label = [["i", "x", "y", "z"]] * 2
#chi = qpt(U_rho, op_basis)
#fig = qpt_plot_combined(chi, op_label, r'$i$SWAP')
#plt.show()
#==============================================================================


#==============================================================================
"Parallel computation"
"qutip.parallel.parallel_map "
"qutip.parallel.parfor"
#def func1(x): 
#    return x, x**2, x**3
#if __name__ == '__main__':
#    a, b, c = parfor(func1, range(10)) #类似于Pool.map,  a,b,c分别返回三个返回值的序列
#   [array([0, 1, 2, 3, 4]), array([ 0, 1, 4, 9, 16]), array([ 0, 1, 8, 27, 64])]


#result = parallel_map(func1, range(10))
#result_array = np.array(result)  #在一个大的List里面 [:,0] [:,1][:,2]
#      [(0, 0, 0), (1, 1, 1), (2, 4, 8), (3, 9, 27), (4, 16, 64)]
    
    
'parallel_map only iterate over the values arguments'
'parfor function simultaneously iterates over all arguments:'

#def sum_diff(x, y, z=0): 
#    return x + y, x - y, z
#parfor(sum_diff, [1, 2, 3], [4, 5, 6], z=5.0) 
##solution：[array([5, 7, 9]), array([-3, -3, -3]), array([ 5., 5., 5.])]
#parallel_map(sum_diff, [1, 2, 3], task_args=(np.array([4, 5, 6]),), task_kwargs=dict(z=5))
##solution:[(array([5, 6, 7]), array([-3, -4, -5]), 5.0),
#        #(array([6, 7, 8]), array([-2, -3, -4]), 5.0),
#        #(array([7, 8, 9]), array([-1, -2, -3]), 5.0)]
#==============================================================================



#==============================================================================
'save and load'
#qsave(rho_ss, 'steadystate')
#rho_ss_loaded = qload('steadystate')


'store and load numpy arrays and matrices to files'
#file_data_store(filename, data, numtype="complex", numformat="decimal", sep=",")
#input_data = file_data_read('expect.dat')
#==============================================================================


#==============================================================================
'Generating Random Quantum States & Operators' 
#==============================================================================
