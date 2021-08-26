    def _R2E(self,R):
        hbar=1.054560652926899e-34
        h = hbar*2*np.pi
        e = 1.60217662e-19 
        I0 = 280e-9
        R0 = 1000
        I = I0*R0/R
        Ej = I*hbar/2/e/h
        return(Ej)
    # 计算Cinv
        Capa = -np.array(self.__capacity)
        for ii in range(np.shape(Capa)[0]):
            Capa[ii][ii] = -sum(self.__capacity[ii])
        CInv = np.linalg.inv(Capa)
        Ec = 1

        # 计算Linv
        LInv = -1/np.array(self.__inductance)
        for ii in range(np.shape(LInv)[0]):
            LInv[ii][ii] = -np.sum(LInv[ii])

        R2E = np.vectorize(self._R2E)
        # 计算EjMatrix
        EjMatrix = R2E(np.array(self.__resistance))
        Ej = np.diag(np.diag(EjMatrix))