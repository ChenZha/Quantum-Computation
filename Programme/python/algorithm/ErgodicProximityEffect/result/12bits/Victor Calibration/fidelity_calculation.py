from scipy.io import loadmat
import numpy as np
import matplotlib.pyplot as plt

if __name__ == '__main__':
    data_experiment_name ="ergodicEffect_Mzj_Mzj Strong DISORDER excitation=2__190811T195523_.mat"
    data_simluation_name = "Strong disorder, N =  3,excitation=2,correlator=7.npz"

    data_experiment = loadmat(data_experiment_name)['P']
    data_simluation = np.transpose(np.load(data_simluation_name)['Zlist'])


    experiment_tlist = np.arange(1,400,4)/2
    simulation_tlist = np.arange(201)

    simulation_get = np.arange(1,201,2)
    data_simluation_get = data_simluation[simulation_get,:]
    data_experiment[np.where(data_experiment<0)]=0
    data_experiment[np.where(data_experiment>1)]=1
    for ii in range(len(data_experiment)):
        data_experiment[ii] = data_experiment[ii]/np.sum(data_experiment[ii])

    fid_list = np.sum(np.sqrt(data_experiment*data_simluation_get),1)
    
    plt.figure();plt.plot(experiment_tlist,fid_list)
    plt.title(data_simluation_name[0:-4])
    plt.xlabel('time(ns)');plt.ylabel('fidelity')
    plt.savefig(data_experiment_name[0:-4])
    plt.show()

