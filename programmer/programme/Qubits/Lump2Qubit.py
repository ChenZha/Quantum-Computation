'''
针对研究少量量子比特性能进行研发，从集总元件出发，生成其哈密顿量，进而进行演化
'''
from qutip import *
from scipy.optimize import *
import matplotlib.pyplot as plt
import numpy as np
from multiprocessing import Pool
import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
from functools import reduce

class Lump2Qubit():
    def __init__(self , qubits_parameter , *args , **kwargs):
        self.CMatrix , self.EjMatrix , self.Josephson , self.N_level = qubits_parameter
        
