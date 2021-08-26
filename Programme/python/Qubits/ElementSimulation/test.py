import numpy as np
from QubitSimulation import TransmonQubit

if __name__ == '__main__':
    hbar=1.054560652926899e-34
    h = hbar*2*np.pi
    CInv = np.array([
        [ 1.19757849e+13,  -7.42509100e+11, -1.25599090e+11],
        [-7.42509100e+11,   6.49446473e+12, 7.42509100e+11],
        [-1.25599090e+11,   7.42509100e+11, 1.19757849e+13],
    ])
    Linv = np.array([
        [0.0845, 0.0103, 0.0003],
        [0.0103, 0.1590,-0.0103],
        [0.0003,-0.0103, 0.0845],
    ])*1e-24
    Ej = np.array([
        [1.7384, 0.0, 0.0],
        [0.0, 11.300,0.0,],
        [0.0,0.0,1.7384],
    ])*1e10

    Nlevel = [6,6,6]
    para = [CInv,Linv,Ej,Nlevel]
    transmon = TransmonQubit(para)
    print(transmon.energyEig)