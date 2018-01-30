# -*- coding: utf-8 -*-
"""
Created on Thu Dec 21 18:13:34 2017

@author: Liswer
用于对数据的管理与分析
updata_type:generation*[[update_name],[updata_para]]
"""

import numpy as np

class data_record:
    def __init__(self,generation , population ,n_dim):
        data_record.x_all=np.zeros((generation , population ,n_dim))
        data_record.v_all=np.zeros((generation , population ,n_dim))
        data_record.x_fun_value=np.zeros((generation , population))
        data_record.v_fun_value=np.zeros((generation , population))
        data_record.best_x=np.zeros((generation,n_dim))
        data_record.best_x_fun_value=np.zeros(generation)
        data_record.updata_type=[]
        data_record.generation=generation
        data_record.population=population
        data_record.n_dim=n_dim
        
    def DE_next_generation(self,error_new,x_new,g):
        self.v_fun_value[g+1]=error_new
        self.v_all[g+1]=x_new
        for i in range(self.population):
            if self.x_fun_value[g][i]>self.v_fun_value[g+1][i]:
                self.x_all[g+1][i] = self.v_all[g+1][i]
                self.x_fun_value[g+1][i] = self.v_fun_value[g+1][i]
            else:
                self.x_all[g+1][i] = self.x_all[g][i]
                self.x_fun_value[g+1][i] = self.x_fun_value[g][i]
        self.best_x[g+1] = self.x_all[g+1][np.argmin(self.x_fun_value[g+1])]
        self.best_x_fun_value[g+1]=np.min(self.x_fun_value[g+1])
        
    def NM_next_generation(self,error_new,x_new,g):
        NM_type=self.updata_type[g][1][0]
        if(NM_type==0):
            self.v_fun_value[g+1][1]=error_new[0]
            self.v_all[g+1][1]=x_new[0]
            if ((self.v_fun_value[g+1][1]>=self.x_fun_value[g][0])&(self.v_fun_value[g+1][1]<=self.x_fun_value[g][self.n_dim-1])):
                new_x_value=self.x_fun_value[g].copy()
                new_x_all=self.x_all[g].copy()
                new_x_value[self.n_dim]=self.v_fun_value[g+1][1]
                new_x_all[self.n_dim]=self.v_all[g+1][1]
                sort_index=np.argsort(new_x_value)
                for ii in range (0,self.n_dim+1):
                    self.x_all[g+1][ii]=new_x_all[sort_index[ii]]
                    self.x_fun_value[g+1][ii]=new_x_value[sort_index[ii]]
                next_updata=self.updata_type[g].copy()
                next_updata[1][0]=0
                self.updata_type=self.updata_type+[next_updata]
                self.best_x[g+1] = self.x_all[g+1][np.argmin(self.x_fun_value[g+1])]
                self.best_x_fun_value[g+1]=np.min(self.x_fun_value[g+1])
                return
            if (self.v_fun_value[g+1][1]<self.x_fun_value[g][0]):
                self.updata_type[g][1][0]=1
                return
            if (self.v_fun_value[g+1][1]>self.x_fun_value[g][self.n_dim-1]):
                self.updata_type[g][1][0]=2
                return
        if(NM_type==1):
            self.v_fun_value[g+1][2]=error_new[0]
            self.v_all[g+1][2]=x_new[0]
            if(self.v_fun_value[g+1][2]<self.v_fun_value[g+1][1]):
                new_x_value=self.x_fun_value[g].copy()
                new_x_all=self.x_all[g].copy()
                new_x_value[self.n_dim]=self.v_fun_value[g+1][2]
                new_x_all[self.n_dim]=self.v_all[g+1][2]
            else:
                new_x_value=self.x_fun_value[g].copy()
                new_x_all=self.x_all[g].copy()
                new_x_value[self.n_dim]=self.v_fun_value[g+1][1]
                new_x_all[self.n_dim]=self.v_all[g+1][1]
            sort_index=np.argsort(new_x_value)
            for ii in range (0,self.n_dim+1):
                self.x_all[g+1][ii]=new_x_all[sort_index[ii]]
                self.x_fun_value[g+1][ii]=new_x_value[sort_index[ii]]
            next_updata=self.updata_type[g].copy()
            next_updata[1][0]=0
            self.updata_type=self.updata_type+[next_updata]
            self.best_x[g+1] = self.x_all[g+1][np.argmin(self.x_fun_value[g+1])]
            self.best_x_fun_value[g+1]=np.min(self.x_fun_value[g+1])
            return
        if(NM_type==2):
            self.v_fun_value[g+1][3]=error_new[0]
            self.v_all[g+1][3]=x_new[0]
            if(self.v_fun_value[g+1][3]<self.x_fun_value[g][self.n_dim]):
                new_x_value=self.x_fun_value[g].copy()
                new_x_all=self.x_all[g].copy()
                new_x_value[self.n_dim]=self.v_fun_value[g+1][3]
                new_x_all[self.n_dim]=self.v_all[g+1][3]
                sort_index=np.argsort(new_x_value)
                for ii in range (0,self.n_dim+1):
                    self.x_all[g+1][ii]=new_x_all[sort_index[ii]]
                    self.x_fun_value[g+1][ii]=new_x_value[sort_index[ii]]
                next_updata=self.updata_type[g].copy()
                next_updata[1][0]=0
                self.updata_type=self.updata_type+[next_updata]
                self.best_x[g+1] = self.x_all[g+1][np.argmin(self.x_fun_value[g+1])]
                self.best_x_fun_value[g+1]=np.min(self.x_fun_value[g+1])
                return
            else:
                self.updata_type[g][1][0]=3
                return
        if(NM_type==3):
            new_x_value=self.x_fun_value[g].copy()
            new_x_all=self.x_all[g].copy()
            for ii in range (1,self.n_dim+1):
                new_x_value[ii]=error_new[ii-1]
                new_x_all[ii]=x_new[ii-1]
            sort_index=np.argsort(new_x_value)
            for ii in range (0,self.n_dim+1):
                self.x_all[g+1][ii]=new_x_all[sort_index[ii]]
                self.x_fun_value[g+1][ii]=new_x_value[sort_index[ii]]
            next_updata=self.updata_type[g].copy()
            next_updata[1][0]=0
            self.updata_type=self.updata_type+[next_updata]
            self.best_x[g+1] = self.x_all[g+1][np.argmin(self.x_fun_value[g+1])]
            self.best_x_fun_value[g+1]=np.min(self.x_fun_value[g+1])
            return
            
                
        
        
        
