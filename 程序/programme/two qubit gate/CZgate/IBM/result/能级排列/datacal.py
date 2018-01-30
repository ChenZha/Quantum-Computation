# -*- coding：utf-8 -*-

import numpy as np
import os
from pylab import *
import matplotlib.pyplot as plt

g = 1.7
Sdelta = np.load(u'./g = '+str(g)+'M/能级间隔/Sdelta_'+str(g/1000)+'.npy')
delta = np.load(u'./g = '+str(g)+'M/能级间隔/delta_'+str(g/1000)+'.npy')
Sfid = np.load(u'./g = '+str(g)+'M/能级间隔/Sfidelity_'+str(g/1000)+'.npy')
fid = np.load(u'./g = '+str(g)+'M/能级间隔/fidelity_'+str(g/1000)+'.npy')
Stest = np.load(u'./g = '+str(g)+'M/能级间隔/Stest_'+str(g/1000)+'.npy')
test = np.load(u'./g = '+str(g)+'M/能级间隔/test_'+str(g/1000)+'.npy')
SZZ = np.load(u'./g = '+str(g)+'M/能级间隔/SZZ_'+str(g/1000)+'.npy')
ZZ = np.load(u'./g = '+str(g)+'M/能级间隔/ZZ_'+str(g/1000)+'.npy')
Stp = np.load(u'./g = '+str(g)+'M/能级间隔/Stp_'+str(g/1000)+'.npy')
tp = np.load(u'./g = '+str(g)+'M/能级间隔/tp_'+str(g/1000)+'.npy')


indexstart = np.where(abs(delta-Sdelta[0])<0.00001)[0][0]
indexend = np.where(abs(Sdelta-delta[-1])<0.00001)[0][0]

Tdelta = np.zeros(len(delta)+len(Sdelta)-(indexend+1))
Tfid = np.zeros(len(fid)+len(Sfid)-(indexend+1))
Ttest = np.zeros(len(test)+len(Stest)-(indexend+1))
TZZ = np.zeros(len(ZZ)+len(SZZ)-(indexend+1))
Ttp = np.zeros(len(tp)+len(Stp)-(indexend+1))



for i in range(len(delta)+len(Sdelta)-(indexend+1)):
    if i <indexstart:
        Tdelta[i] = delta[i];Tfid[i] = fid[i];Ttest[i] = test[i];TZZ[i] = ZZ[i];Ttp[i] = tp[i]
    elif i>=len(delta):
        Tdelta[i] = Sdelta[i-len(delta)+indexend+1];Tfid[i] = Sfid[i-len(delta)+indexend+1];Ttest[i] = Stest[i-len(delta)+indexend+1];TZZ[i] = SZZ[i-len(delta)+indexend+1];Ttp[i] = Stp[i-len(delta)+indexend+1]
    else:
        if fid[i]<Sfid[i-indexstart]:
            Tdelta[i] = Sdelta[i-indexstart];Tfid[i] = Sfid[i-indexstart];Ttest[i] = Stest[i-indexstart];TZZ[i] = SZZ[i-indexstart];Ttp[i] = Stp[i-indexstart]  
        else:
            Tdelta[i] = delta[i];Tfid[i] = fid[i];Ttest[i] = test[i];TZZ[i] = ZZ[i];Ttp[i] = tp[i]

figure();plot(Tdelta/2/np.pi,Ttest);xlabel('delta');ylabel('number of  CNOT gate');title(str(g)+'M')
plt.savefig('N_delta_'+str(g)+'M'+'.png')
figure();plot(Tdelta/2/np.pi,Tfid);xlabel('delta');ylabel('fidelity');title(str(g)+'M')
plt.savefig('fid_delta_'+str(g)+'M'+'.png')
figure();plot(Tdelta/2/np.pi,2*Ttp+60);xlabel('delta');ylabel('t');title(str(g)+'M')
plt.savefig('totlet_delta_'+str(g)+'M'+'.png')

np.save('Tdelta_'+str(g)+'M',Tdelta)
np.save('Tfid_'+str(g)+'M',Tfid)
np.save('Ttest_'+str(g)+'M',Ttest)
np.save('TZZ_'+str(g)+'M',TZZ)
np.save('Ttp_'+str(g)+'M',Ttp)

esitimate = []
for i in range(len(Tdelta)):
    es = 0
    for j in range(10):
        
        es += (Tfid[i]>(0.99+j/1000.0))*Ttest[i]*(j*0.1) if j !=0 else (Tfid[i]>(0.99+j/1000.0))*Ttest[i]*(1+j*0.1)
    esitimate.append(es)
    
esitimate = np.array(esitimate)
print(np.max(esitimate))
print(Tdelta[np.argmax(esitimate)]/2/np.pi,Ttest[np.argmax(esitimate)],Tfid[np.argmax(esitimate)],2*Ttp[np.argmax(esitimate)]+60)
print('Hello')