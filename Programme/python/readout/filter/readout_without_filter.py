from scipy.optimize import *
import numpy as np
from functools import partial
from Qubits import Qubits
from multiprocessing import Pool
import copy
from qutip import *
import matplotlib.pyplot as plt

if __name__ == '__main__':

    frequency = np.array([5.1 , 6.558])*2*np.pi
    coupling = np.array([0.040])*2*np.pi
    eta_q=  np.array([-0.250 , 0]) * 2 * np.pi
    N_level= [3,40]
    parameter = [frequency,coupling,eta_q,N_level]
    QBE = Qubits(qubits_parameter = parameter)