__all__=['data','data_I','errorRate']
from ghztest1 import ghz as g1
g1=[list(g1[ii]['counts'].values()) for ii in range(4)]
from ghztest2 import ghz as g2
g2=[list(g2[ii]['counts'].values()) for ii in range(4)]
from ghztest3 import ghz as g3
g3=[list(g3[ii]['counts'].values()) for ii in range(4)]
from ghztest4 import ghz as g4
g4=[list(g4[ii]['counts'].values()) for ii in range(4)]
data=[[sum(arii) for arii in zip(g1[ii],g2[ii],g3[ii],g4[ii])] for ii in range(4)]

def errorRateBetween(twobitvector1,twobitvector2):
    return sum([abs(a-b) for a,b in zip(twobitvector1,twobitvector2)])/2

data_I=[[0.5,0,0,0.5],
        [0.5]+[0 for ii in range(6)]+[0.5],
        [0.5]+[0 for ii in range(14)]+[0.5],
        [0.5]+[0 for ii in range(30)]+[0.5]]

errorRate=[errorRateBetween([data[ii][jj]/4096 for jj in range(len(data[ii]))],data_I[ii]) for ii in range(4)]

