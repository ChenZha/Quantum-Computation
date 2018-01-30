import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from qutip import *



delta = 0.004 * 2 * np.pi
omega = 0.002 * 2 * np.pi

wc = 5.0 * 2 *np.pi
wd = wc+delta
n = 10
a = destroy(n)
#H = -delta*a.dag()*a + omega*(a+a.dag())
Q = 10000
kappa = wc/Q
print(kappa)

H = wc*a.dag()*a
H1 = [2*omega*(a+a.dag()),'np.cos(wd*t)']
H = [H,H1]
#print(H)
args = {'wd':wd}

psi0 = fock(n,0)
tlist = np.linspace(0,250,501) 
result = mesolve(H,psi0,tlist,[],[],args = args)

n_x = []
n_p = []
n_a = []
for t in range(0,len(tlist)):
    U = 'basis(n,0)*basis(n,0).dag()'
    for i in range(1,n):
        U = U+'+np.exp(1j*'+str(i)+'*wd*tlist[t])*basis(n,'+str(i)+')*basis(n,'+str(i)+').dag()'
        
    U = eval(U)
#    print(U)
        
#    U = basis(n,0)*basis(n,0).dag()+np.exp(1j*wd*tlist[t])*basis(n,1)*basis(n,1).dag()+np.exp(1j*2*wd*tlist[t])*basis(n,2)*basis(n,2).dag()
    n_x.append(expect(U.dag()*(a+a.dag())*U/2,result.states[t]))
    n_p.append(expect(U.dag()*(a-a.dag())*U/2/1j,result.states[t]))
    n_a.append(expect(U.dag()*(a.dag()*a)*U,result.states[t]))

#    n_x.append(expect((a+a.dag())/2,result.states[t]))
#    n_p.append(expect((a-a.dag())/2/1J,result.states[t]))
#    n_a.append(expect((a.dag()*a),result.states[t]))

fig, axes = plt.subplots(1, 1, figsize=(10,6))
axes.plot(n_x,n_p)
fig, axes = plt.subplots(1, 1, figsize=(10,6))
axes.plot(tlist,n_a)

cops = []
cops.append(np.sqrt(kappa)*a)

#psi0 = coherent(n,0)
#tlist = np.linspace(0,250,501) 
#result = mesolve(H,psi0,tlist,cops,[(a+a.dag())/2,(a-a.dag())/2/1j,a.dag()*a])
#
#fig, axes = plt.subplots(1, 1, figsize=(10,6))
#axes.plot(result.expect[0],result.expect[1])
#fig, axes = plt.subplots(1, 1, figsize=(10,6))
#axes.plot(tlist,result.expect[2])