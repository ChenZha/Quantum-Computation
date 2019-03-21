# def funcfilter(x,xmap={}):
#     xstr = [''.join(x),''.join(x[::-1])]

#     boolin = xstr[0] in xmap or xstr[1] in xmap
#     xmap[xstr[0]]=1
#     xmap[xstr[1]]=1
#     return (not boolin)
# all_inistate  = [['0','0','0','1'],['1','0','0','0'],['0','1','0','0']]
# all_inistate=list(filter(funcfilter,all_inistate))
# print(all_inistate)
import numpy as np
import matlab.engine

def generate_all_state(Num_qubits):
    '''
    从0,1,+,-,+i,-i中选择,组成各种初始态,镜像的算一种态
    '''

    all_inistate = []
    Num_qubits = int(Num_qubits)
    number_basis= 6

    for ii in range(number_basis**Num_qubits):
        state_ii = []
        index = ii
        for jj in range(Num_qubits):
            codenum = np.int(np.mod(index,number_basis))
            if codenum == 0:
                state_ii.insert(0,'0')
            elif codenum == 1:
                state_ii.insert(0,'1')
            elif codenum == 2:
                state_ii.insert(0,'+')
            elif codenum == 3: 
                state_ii.insert(0,'-')
            elif codenum == 4: 
                state_ii.insert(0,'+i')
            elif codenum == 5: 
                state_ii.insert(0,'-i')
            else:   
                print('no such state')
            index = np.int(np.floor(index/number_basis))
        all_inistate.append(state_ii)

    def funcfilter(x,xmap={}):
        xstr = [''.join(x),''.join(x[::-1])]

        boolin = xstr[0] in xmap or xstr[1] in xmap
        xmap[xstr[0]]=1
        xmap[xstr[1]]=1
        return (not boolin)
    all_inistate=list(filter(funcfilter,all_inistate))
    return(all_inistate)
if __name__ == '__main__':
    rho = np.eye(2**6)/2**6
    rho = matlab.double(rho.tolist(),is_complex=True)
    eng = matlab.engine.start_matlab()
    a = eng.fdecwit(rho)
    print(a)