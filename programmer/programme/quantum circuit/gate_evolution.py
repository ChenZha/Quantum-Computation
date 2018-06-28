# -*- coding: utf-8 -*-
"""
Created on Fri Feb 24 16:20:57 2017

@author: Chen
"""

from qutip import *
import numpy as np
import matplotlib.pyplot as plt 
from pylab import *
from gate import *
from initialsetting import *
from GenerateH import *
from evolutionplot import *
from dissipation import *


#from time import clock
#starttime=clock()





#==============================================================================
def gate_evolution(psi0 , Operator , setting = qusetting()):
    options=Options()
#    options.atol=1e-11
#    options.rtol=1e-9
    options.first_step=0.01
    options.num_cpus= 4
    options.nsteps=1e6
    options.gui='True'
    options.ntraj=1000
    options.rhs_reuse=False
#==============================================================================

#==============================================================================
    H , args , tlist = GenerateH(Operator , setting)
    c_op_list = dissipation(setting)
#    print(c_op_list)
#    print(H)
#    print(psi0)
    result = mesolve(H,psi0,tlist,c_op_list,[],args = args,options = options)
#    print(ptrace(result.states[-1],1))
    return result , tlist
#==============================================================================



#==============================================================================    
#Operator = ['X'  ,  'X' ]
##H = HC + Hq0 + Hq1 + Hcoupling
#
#
##result = mesolve(H,psi0,tlist,[],[sxm0,sym0,sz0,sn0,E_uc0,sxm1,sym1,sz1,sn1,a.dag()*a,E_uc1])
#
#
#evolutionplot(0 , result , setting = plotsetting)
#evolutionplot(1 , result , setting = plotsetting)

#==============================================================================  

#finishtime=clock()
#print ('Time used: ', (finishtime-starttime), 's')
