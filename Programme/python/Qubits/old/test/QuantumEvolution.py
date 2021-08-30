import numpy as np
from qutip import *
def quantumEvolution(Hamilton, stateInitial, tList, cOps=[]):
    if len(cOps)==0:
        numslice = 30
        timeStep = np.linspace(tList[1],tList[-1],numslice*(len(tList)-1)+1)
        stateStep = []
        stateStep.append(stateInitial)
        HamiltonTimeList = np.diff(timeStep)/2+timeStep[0:-1-1]
        HamiltonList = []
        for ii in range(len(HamiltonTimeList)):#生成不同时间点时的哈密顿量
            HamiltonListTemp=Hamilton[0]
            if len(Hamilton)>1:
                for jj in range(1,len(Hamilton)):
                    timefunction = Hamilton[jj][1]
                    HamiltonListTemp = HamiltonListTemp+np.dot(Hamilton[jj][0],timefunction(HamiltonTimeList[ii]))

            stateStepNew = stateStep[ii]+HamiltonListTemp*stateStep[ii]*(timeStep[ii+1]-timeStep[ii])/(1j)
            stateStep.append(stateStepNew)

        stateEnd = stateStep[1:-1:numslice]
        return(stateEnd)
    else:
        numslice = 30
        timeStep = np.linspace(tList[1],tList[-1],numslice*(len(tList)-1)+1)
        stateStep = []
        stateInitialTJ = stateInitial.conj().T
        stateStep.append(np.dot(stateInitial,stateInitialTJ))
        HamiltonTimeList = np.diff(timeStep)/2+timeStep[0:-1-1]
        HamiltonList = []
        for ii in range(len(HamiltonTimeList)):#生成不同时间点时的哈密顿量
            HamiltonListTemp=Hamilton[0]
            if len(Hamilton)>1:
                for jj in range(1,len(Hamilton)):
                    timefunction = Hamilton[jj][1]
                    HamiltonListTemp = HamiltonListTemp+np.dot(Hamilton[jj][0],timefunction(HamiltonTimeList[ii]))

            stateStepTemp = -1j*(np.dot(HamiltonListTemp,stateStep[ii])-np.dot(stateStep[ii],HamiltonListTemp))
            for jj in range(len(cOps)):
                stateStepTemp = stateStepTemp + cOps[jj].dot(stateStep[ii]).dot(cOps[jj].conj().T)-(cOps[jj].conj().T.dot(cOps[jj]).dot(stateStep[ii])+stateStep[ii].dot(cOps[jj].conj().T).dot(cOps[jj]))/2
            stateStepNew = stateStep[ii]+stateStepTemp*(timeStep[ii+1]-timeStep[ii])
            stateStep.append(stateStepNew)

        stateEnd = stateStep[1:-1:numslice]
        return(stateEnd)


if __name__ == '__main__':
    Hamilton = 0.01*
    stateInitial = np.array([[0],[1]])
    tList = np.linspace(0,100,101)
    stateEnd = quantumEvolution(Hamilton, stateInitial, tList)
    print(stateEnd)
