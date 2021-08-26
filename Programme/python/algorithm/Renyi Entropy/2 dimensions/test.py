from qutip import *
import numpy as np
psi = tensor((basis(2,0)+basis(2,1)).unit(),(basis(2,0)+basis(2,1)).unit())
U = tensor(qeye(2),Qobj([[1,0],[0,np.exp(1j*2)]]))
X1 = tensor(sigmax(),qeye(2));X2 = tensor(qeye(2),sigmax())
Y1 = tensor(sigmay(),qeye(2));Y2 = tensor(qeye(2),sigmay())
OP = X1*X2+Y1*Y2
print(expect(OP,U*psi))