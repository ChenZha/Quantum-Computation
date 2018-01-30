# -*- coding: utf-8 -*-
import math
import matplotlib.pyplot as plt
import numpy as np
import random
import yaml

from copy import copy
from multiprocessing import Pool
from multiprocessing import Process
from pprint import pprint
from time import time

CORE = 8

class Individual(object):
    '''
    个体类
    '''
    def __init__(self, *args, **kwargs):
        length = args[0]
        self.chromosome = np.empty(shape=(length, ), dtype=np.uint8) # 染色体(二进制编码)
        for i in range(length):
            if random.random() > 0.5: 
                self.chromosome[i] = 1
            else:
                self.chromosome[i] = 0                       
        self.chromosome_gray = np.empty_like(self.chromosome) # 染色体(格雷码编码)
        self.object_value = 0.0                               # 目标值
        self.object_fitness = 0.0                             # 适应度值
        

class Population(object):
    '''
    种群类
    '''
    def __init__(self, *args, **kwargs):
        self.population_capacity = args[0] # 种群容量
        self.params = []                   # 目标参数
        self.chromosome_length = 0         # 染色体长度
        self.individuals = []              # 个体集合
        self.read_parameters('parameters.yaml')
        import xlrd
        book = xlrd.open_workbook('fittingtarget.xls')
        sheet = book.sheet_by_index(0)
        self.S11_m = np.array(sheet.col_value(1))
        self.S11_m_weight = np.empty_like(self.S11_m)
        _top = np.max(self.S11_m)
        _S11_m = np.abs(self.S11_m - _top)
        _sum = np.sum(_S11_m) 
        for i in range(self.S11_m_weight.shape[0]):
            self.S11_m_weight[i] = _S11_m[i] / _sum

    def read_parameters(self, configuration_file='parameters.yaml'):
        '''
        读取配置文件
        '''
        with open(configuration_file, 'r') as fd:
            _yaml = yaml.load(fd)
            params = _yaml['params']
            for param in params:
                for k, v in param.items():
                    length = math.ceil(math.log2(int((v[1] - v[0]) / v[2])))
                    self.params.append((v[0], v[1], length))
                    self.chromosome_length += length  # 多参数级联编码
        
    def initialize_population(self):
        '''
        初始化种群
        '''
        self.individuals = [Individual(self.chromosome_length) for _ in range(self.population_capacity)]

    def binarycode_to_graycode(self):
        '''
        二进制编码转格雷编码
        '''
        for individual in self.individuals:
            individual.chromosome_gray[0] = individual.chromosome[0]
            for i in range(1, individual.chromosome.shape[0]):
                individual.chromosome_gray[i] = individual.chromosome[i - 1] ^ individual.chromosome[i]

    def graycode_to_binarycode(self):
        '''
        格雷编码转二进制编码
        '''
        for individual in self.individuals:
            individual.chromosome[0] = individual.chromosome_gray[0]
            for i in range(1, individual.chromosome_gray.shape[0]):
                individual.chromosome[i] = individual.chromosome[i - 1] ^ individual.chromosome_gray[i]

    def evaluate_object_value(self):
        '''
        个体目标值计算
        '''
        for individual in self.individuals:
            # ***** core decode *****
            start = 0
            end = 0

            x = []
            for param in self.params:
                end += param[2]

                partial_chromosome = individual.chromosome[start : end]
                value = 0
                for i in range(len(partial_chromosome), 0, -1):
                    shift = len(partial_chromosome) - i
                    t = 1
                    t <<= shift
                    value += individual.chromosome[i - 1] * t
                value = (param[1] - param[0]) * (value / math.pow(2, param[2])) + param[0]
                x.append(value)

                start += param[2]
            # ***** core decode *****

            # ***** core compute *****
            f = np.arange(2, 18.1, 0.1) * 1e9
            w = 2 * np.pi * f
            # Cj = np.complex(0, -1/(w * x[0])) * 1e-12 
            # Cd = np.complex(0, -1/(w * x[1])) * 1e-12 
            # Ci = np.complex(0, -1/(w * x[2])) * 1e-12 
            # Rj = np.complex(x[3], 0)
            # Ri = np.complex(x[4], 0)
            Rs = np.complex(x[5], 0)
            Ls = np.complex(0, w * x[6]) * 1e-9
            Cp = np.complex(0, -1/(w * x[7])) * 1e-12 
            # Z1 = 1(1/Cj + 1/Rj + 1/Cd)
            # Z2 = (Ri * Ci) / (Ri + Ci)
            Z3 = Rs
            Z4 = Ls
            # Z_1_2_3_4 = Z1 + Z2 + Z3 + Z4
            Z_1_2_3_4 = Z3 + Z4
            Z5 = Cp
            Z = (Z_1_2_3_4 * Z5) / (Z_1_2_3_4 + Z5)
            S11_s = 20 * np.log10(np.abs(Z / (2 * np.sqrt(50) + Z)))
            individual.object_value = np.sqrt(self.S11_m - S11_s) * self.S11_m_weight
            # ***** core compute *****

    def evaluate_object_fitness(self):
        '''
        个体适应度值计算
        '''
        for individual in self.individuals:
            individual.object_fitness = -1 * individual.object_value

class ParallelGeneticAlgorithm(object):
    '''
    遗传算法类
    '''
    def __init__(self, *args, **kwargs):
        self.population_capacity = 0  # 种群容量
        self.e = 0                    # 当前进化代数
        self.epochs = 0               # 最大进化代数
        self.pc = 0.0                 # 交叉概率
        self.px = 0.0                 # 编译概率
        self.read_parameters('parameters.yaml')

    def read_parameters(self, configuration_file='parameters.yaml'):
        '''
        读取配置文件
        '''
        with open(configuration_file, 'r') as fd:
            _yaml = yaml.load(fd)
            # 遗传参数赋值
            self.population_capacity = _yaml['population_capacity']
            self.epochs = _yaml['epochs']
            self.pc = _yaml['pc']
            self.px = _yaml['px']

    def run(self):
        '''
        主循环
        '''
        self.populations = [Population(self.population_capacity) for _ in range(CORE)]
        for population in self.populations:
            population.initialize_population()
        self.current_best_individual = [Individual(self.populations[i].chromosome_length) for i in range(CORE)]
        self.current_best_individual_from_vote = Individual(self.populations[0].chromosome_length)
        self.current_best_individual_index = [0 for _ in range(CORE)]
        self.current_worst_individual = [Individual(self.populations[i].chromosome_length) for i in range(CORE)]
        self.current_worst_individual_index = [0 for _ in range(CORE)]
        self.best_individual = Individual(self.populations[0].chromosome_length)
    
        while self.e < self.epochs:
            for i in range(CORE):
                self.estimate(i)
            self.preserve_the_best()
            for i in range(CORE):
                self.generate_next_population(i, self.best_individual.object_fitness)

            self.make_visualization(self.e + 1)
            self.e += 1
        
        self.output()
    
    def estimate(self, index):
        '''
        个体评估
        '''
        self.evaluate_object_value(index)
        self.evaluate_object_fitness(index)
        self.select_best_and_worst_individual(index)

    def evaluate_object_value(self, index):
        '''
        计算目标值
        '''
        self.populations[index].evaluate_object_value()

    def evaluate_object_fitness(self, index):
        '''
        计算适应度值
        '''
        self.populations[index].evaluate_object_fitness()

    def select_best_and_worst_individual(self, index):
        '''
        筛选当前最优和最差个体，更新全局最优个体，即所谓的精英保存策略
        '''
        self.current_best_individual[index] = copy(self.populations[index].individuals[0])
        self.current_best_individual_index[index] = 0
        self.current_worst_individual[index] = copy(self.populations[index].individuals[0])
        self.current_worst_individual_index[index] = 0
        for i in range(1, self.population_capacity):
            if self.populations[index].individuals[i].object_fitness > self.current_best_individual[index].object_fitness:
                self.current_best_individual[index] = copy(self.populations[index].individuals[i])
                self.current_best_individual_index[index] = i
            elif self.populations[index].individuals[i].object_fitness < self.current_worst_individual[index].object_fitness:
                self.current_worst_individual[index] = copy(self.populations[index].individuals[i])
                self.current_worst_individual_index[index] = i
    
    def preserve_the_best(self):
        if self.e == 0:
            self.best_individual = copy(self.current_best_individual[0])
            for i in range(1, CORE):
                if self.current_best_individual[i].object_fitness > self.best_individual.object_fitness:
                    self.best_individual = copy(self.current_best_individual[i])
        else:
            self.current_best_individual_from_vote = copy(self.current_best_individual[0])
            for i in range(1, CORE):
                if self.current_best_individual[i].object_fitness > self.current_best_individual_from_vote.object_fitness:
                    self.current_best_individual_from_vote = copy(self.current_best_individual[i])
            if self.current_best_individual_from_vote.object_fitness > self.best_individual.object_fitness:
                self.best_individual = copy(self.current_best_individual_from_vote)
        
        self.improve_evolution()
    
    def improve_evolution(self):
        '''
        改善进化
        '''
        for i in range(CORE):
            self.populations[i].individuals[self.current_worst_individual_index[i]] = copy(self.best_individual)

    def generate_next_population(self, index):
        self.populations[index].binarycode_to_graycode()

        self.select_operator(index)
        self.crossover_operator(index)
        self.mutate_operator(index)

        self.populations[index].graycode_to_binarycode()

    def select_operator(self, index):
        '''
        选择算子
        '''
        def proportional_model_selector():
            '''
            比例选择
            '''
            _sum = 0.0
            for i in range(self.population_capacity):
                _sum += self.populations[index].individuals[i].object_fitness
            _cum = [self.populations[index].individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            for i in range(1, self.population_capacity):
                _cum[i] = _cum[i] + _cum[i - 1]

            for i in range(self.population_capacity):
                count = 0
                while (random.random() > _cum[i] and count < self.population_capacity):
                    count += 1
                if count < self.population_capacity:
                    self.populations[index].individuals[i] = copy(self.populations[index].individuals[count])
        
        def deterministic_sampling_selector():
            '''
            确定式采样选择
            '''
            _sum = 0.0
            for i in range(self.population_capacity):
                _sum += self.populations[index].individuals[i].object_fitness
            _n = [self.population_capacity * self.populations[index].individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            _n_integer_part = [math.floor(_n[i]) for i in range(self.population_capacity)]
            _n_integer_part_sum = sum(_n_integer_part)
            _n_decimal_part = [(_n[i] - _n_integer_part[i], i) for i in range(self.population_capacity)]
            _ret = sorted(_n_decimal_part, key=lambda x:x[0], reverse=True)

            for i in range(self.population_capacity - _n_integer_part_sum):
                 select_individual_index = random.randint(0, self.populations[index].chromosome_length)
                 self.populations[index].individuals[select_individual_index] =  copy(self.populations[index].individuals[_ret[i][1]])

        def expected_value_model_selector():
            '''
            期望值选择
            '''
            # TODO

        def remainder_stochastic_sampling_with_replacement_selector():
            '''
            无回放余数随机选择
            '''
            _sum = 0.0
            for i in range(self.population_capacity):
                _sum += self.populations[index].individuals[i].object_fitness
            _n = [self.population_capacity * self.populations[index].individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            _n_integer_part = [math.floor(_n[i]) for i in range(self.population_capacity)]
            _n_integer_part_sum = sum(_n_integer_part)
            _new = [self.populations[index].individuals[i].object_fitness - _n_integer_part[i] * _sum / self.population_capacity for i in range(self.population_capacity)]
            for i in range(1, self.population_capacity):
                _new[i] = _new[i] + _new[i - 1]

            counter = 0
            for i in range(self.population_capacity):
                count = 0
                while (random.random() > _new[i] and count < self.population_capacity):
                    count += 1
                if count < self.population_capacity:
                    self.populations[index].individuals[i] = copy(self.populations[index].individuals[count])
                    counter += 1
                if counter == self.population_capacity - _n_integer_part_sum:
                    break

        def rank_based_selector():
            '''
            排序选择
            '''
            # _ret = sorted(self.population.individuals, key=lambda x:x.object_fitness, reverse=True)
            # TODO

        def stochastic_tournament_model():
            '''
            随机联赛选择
            '''
            for i in range(self.population_capacity):
                _index_1 = random.randint(0, self.populations[index].chromosome_length)
                _index_2 = random.randint(0, self.populations[index].chromosome_length)
                if self.populations[index].individuals[_index_1].object_fitness > self.populations[index].individuals[_index_2].object_fitness:
                    self.populations[index].individuals[i] = copy(self.populations[index].individuals[_index_1])
                else:
                    self.populations[index].individuals[i] = copy(self.populations[index].individuals[_index_2])

        remainder_stochastic_sampling_with_replacement_selector()

    def crossover_operator(self, index):
        '''
        交叉算子[全局搜索算子]，精英保存策略要求最优个体不参与交叉操作
        '''
        def one_point_crossover():
            '''
            单点交叉
            '''
            index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index[index]:
                    index[i] = (i + random.randint(0, self.populations[index].chromosome_length)) % self.population_capacity
                else:
                    index[i] = i
            np.random.shuffle(index)

            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    crossover_point = random.randint(1, self.populations[index].chromosome_length)
                    for j in range(crossover_point, self.populations[index].chromosome_length):
                        self.populations[index].individuals[_index[i]].chromosome_gray[j], self.populations[index].individuals[_index[i + 1]].chromosome_gray[j] =\
                        self.populations[index].individuals[_index[i + 1]].chromosome_gray[j], self.populations[index].individuals[_index[i]].chromosome_gray[j]

        def two_point_crossover():
            '''
            双点交叉
            '''
            index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index[index]:
                    index[i] = (i + random.randint(0, self.populations[index].chromosome_length)) % self.population_capacity
                else:
                    index[i] = i
            np.random.shuffle(index)

            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    crossover_point_1 = 2
                    crossover_point_2 = 1
                    while crossover_point_1 >= crossover_point_2:
                        crossover_point_1 = random.randint(1, self.populations[index].chromosome_length)
                        crossover_point_2 = random.randint(1, self.populations[index].chromosome_length)
                    for j in range(crossover_point_1, crossover_point_2):
                        self.populations[index].individuals[_index[i]].chromosome_gray[j], self.populations[index].individuals[_index[i + 1]].chromosome_gray[j] =\
                        self.populations[index].individuals[_index[i + 1]].chromosome_gray[j], self.populations[index].individuals[_index[i]].chromosome_gray[j]

        def uniform_crossover():
            '''
            均匀交叉
            '''
            _index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index[index]:
                    _index[i] = (i + random.randint(0, self.populations[index].chromosome_length)) % self.population_capacity
                else:
                    _index[i] = i
            np.random.shuffle(_index)

            _W = np.empty(shape=(self.populations[index].chromosome_length, ), dtype=np.uint8)
            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    for j in range(self.populations[index].chromosome_length):
                        if random.random() > 0.5: 
                            _W[j] = 1
                        else:
                            _W[j] = 0  
                    for j in range(self.populations[index].chromosome_length):
                        if _W[j] == 1:
                            self.populations[index].individuals[_index[i]].chromosome_gray[j], self.populations[index].individuals[_index[i + 1]].chromosome_gray[j] =\
                            self.populations[index].individuals[_index[i + 1]].chromosome_gray[j], self.populations[index].individuals[_index[i]].chromosome_gray[j]
                            
        def arithmetic_crossover():
            '''
            算数交叉
            '''
            # TODO
        
        uniform_crossover()

    def mutate_operator(self, index):
        '''
        变异算子[局部搜索算子]，精英保存策略要求最优个体不参与变异操作
        '''
        def simple_mutatation():
            '''
            基本位变异
            '''
            for i in range(self.population_capacity):
                if i != self.current_best_individual_index[index]:
                    for j in range(self.populations[index].chromosome_length):
                        if (random.random() < self.px):
                            if self.populations[index].individuals[i].chromosome_gray[j] == 0:
                                self.populations[index].individuals[i].chromosome_gray[j] == 1
                            else:
                                self.populations[index].individuals[i].chromosome_gray[j] == 0

        def uniform_mutation():
            '''
            均匀变异
            '''
            # TODO

        def boundary_mutation():
            '''
            边界变异
            '''
            # TODO

        def non_uniform_mutation():
            '''
            非均匀变异
            '''
            # TODO

        def gaussian_mutation():
            '''
            高斯变异
            '''
            # TODO
        
        simple_mutatation()

    def adapt_operator_probabilities(self):
        pass
    
    def make_visualization(self, epoch, value):
        print(f"[+] epoch - {epoch} : current best value is {value} ...")

    def output(self):
        x = []
        for param in self.params:
            end += param[2]

            partial_chromosome = self.best_individual.chromosome[start : end]
            value = 0
            for i in range(len(partial_chromosome), 0, -1):
                shift = len(partial_chromosome) - i
                t = 1
                t <<= shift
                value += self.best_individual.chromosome[i - 1] * t
            value = (param[1] - param[0]) * (value / math.pow(2, param[2])) + param[0]
            x.append(value)

            start += param[2]
        
        f = np.arange(2, 18.1, 0.1) * 1e9
        w = 2 * np.pi * f
        # Cj = np.complex(0, -1/(w * x[0])) * 1e-12 
        # Cd = np.complex(0, -1/(w * x[1])) * 1e-12 
        # Ci = np.complex(0, -1/(w * x[2])) * 1e-12 
        # Rj = np.complex(x[3], 0)
        # Ri = np.complex(x[4], 0)
        Rs = np.complex(x[5], 0)
        Ls = np.complex(0, w * x[6]) * 1e-9
        Cp = np.complex(0, -1/(w * x[7])) * 1e-12
        # print(f'Cj : {} pF')
        # print(f'Cd : {} pF')
        # print(f'Ci : {} pF')
        # print(f'Rj : {} ohm')
        # print(f'Ri : {} ohm')
        print(f'Rs : {Rs} ohm')
        print(f'Ls : {Ls} nH')
        print(f'Cp : {Cp} pF')

        # Z1 = 1(1/Cj + 1/Rj + 1/Cd)
        # Z2 = (Ri * Ci) / (Ri + Ci)
        Z3 = Rs
        Z4 = Ls
        # Z_1_2_3_4 = Z1 + Z2 + Z3 + Z4
        Z_1_2_3_4 = Z3 + Z4
        Z5 = Cp
        Z = (Z_1_2_3_4 * Z5) / (Z_1_2_3_4 + Z5)
        S11_s = 20 * np.log10(np.abs(Z / (2 * np.sqrt(50) + Z)))

        freq = np.arange(2, 18.1, 0.1)
        plt.plot(freq, self.S11_m, 'k-', label='Measuring Data')
        plt.plot(freq, S11_s, 'r-', label='Fitting Data')
        plt.xlabel('Freq(GHz)')
        plt.xlabel('S11(dB)')
        plt.xlim(2.0, 18.0)
        plt.ylim(-20.0, 10.0)
        plt.legend()
        plt.show()

if __name__ == '__main__':
    ga = ParallelGeneticAlgorithm()
    ga.run()
    