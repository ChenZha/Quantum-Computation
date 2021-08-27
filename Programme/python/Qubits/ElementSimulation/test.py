from ctypes import Structure
import numpy as np
from QubitSimulation import TransmonQubit,DifferentialTransmon

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
        [0.0, 11.300,0.0],
        [0.0,0.0,1.7384],
    ])*1e10
    flux = np.array([
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
    ])

    Nlevel = [6,6,6]
    para = [CInv,Linv,Ej,flux,Nlevel]
    transmon = TransmonQubit(para)
    print(transmon.energyEig-transmon.energyEig[0])
    ## 
    CJ=8e-15;     SRatio=6.5;     
    C24=1.34e-15;     
    C12=1.38e-15+CJ;     
    C23=20.58e-15;  
    C34=20.58e-15;   
    C1=150e-15-C12-C24;     
    C2=150e-15-C12-C24;     
    C3=107e-15+SRatio*CJ-2*C23
    R=8000
    Capa = np.array([
        [C1,C12,0,0,0],
        [C12,C2,C23,C24,0],
        [0,C23,C3,C34,0],
        [0,C24,C34,C2,C12],
        [0,0,0,C12,C1],
    ])
    Linv = np.ones_like(Capa)*1e9
    RNAN = 1e9
    RList = np.array([
        [RNAN,R,RNAN,RNAN,RNAN],
        [R,RNAN,RNAN,RNAN,RNAN],
        [RNAN,RNAN,R/SRatio,RNAN,RNAN],
        [RNAN,RNAN,RNAN,RNAN,R],
        [RNAN,RNAN,RNAN,R,RNAN],
    ])
    flux = np.zeros_like(Capa)
    SMatrix = np.array([
        [1,-1,0,0,0],
        [1,1,0,0,0],
        [0,0,1,0,0],
        [0,0,0,1,-1],
        [0,0,0,1,1],
    ])
    structure = [[0,1],[2],[3,4]]
    Nlevel = [6,6,6]
    para = [Capa,Linv,RList,flux,SMatrix,structure,Nlevel]
    DT = DifferentialTransmon(para)
    print(DT.energyEig-DT.energyEig[0])