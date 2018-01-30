# -*- coding: utf-8 -*-
import math
import matplotlib.pyplot as plt
import numpy as np
import platform
import random
import yaml

from copy import copy
from pprint import pprint
from time import time

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
        self.read_parameters('default.yaml')

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
            start = 0
            end = 0

            x = []
            for param in self.params:
                end += param[2]
                # ***** core compute *****
                partial_chromosome = individual.chromosome[start : end]
                value = 0
                for i in range(len(partial_chromosome), 0, -1):
                    shift = len(partial_chromosome) - i
                    t = 1
                    t <<= shift
                    value += individual.chromosome[i - 1] * t
                value = (param[1] - param[0]) * (value / math.pow(2, param[2])) + param[0]
                x.append(value)
                # ***** core compute *****
                start += param[2]

            # ***** core compute *****
            individual.object_value = 100 * (x[0] * x[0] - x[1]) * (x[0] * x[0] - x[1]) + (1 - x[1]) * (1 - x[1])
            # ***** core compute *****

    def evaluate_object_fitness(self):
        '''
        个体适应度值计算
        '''
        for individual in self.individuals:
            if individual.object_value + (-2.048) > 0.0:
                individual.object_fitness = individual.object_value + (-2.048)
            elif individual.object_value + (-2.048) <= 0.0:
                individual.object_fitness = 0.0


class GeneticAlgorithm(object):
    '''
    遗传算法类
    '''
    def __init__(self, *args, **kwargs):
        self.population_capacity = 0  # 种群容量
        self.e = 0                    # 当前进化代数
        self.epochs = 0               # 最大进化代数
        self.pc = 0.0                 # 交叉概率
        self.px = 0.0                 # 编译概率
        self.read_parameters('default.yaml')

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
        self.population = Population(self.population_capacity)
        self.population.initialize_population()
        self.current_best_individual = Individual(self.population.chromosome_length)
        self.current_best_individual_index = 0
        self.current_worst_individual = Individual(self.population.chromosome_length)
        self.current_worst_individual_index = 0
        self.best_individual = Individual(self.population.chromosome_length)
    
        while self.e < self.epochs:
            self.estimate()
            self.generate_next_population()
            self.make_visualization(self.e + 1, self.best_individual.object_value)
            self.e += 1
    
    def estimate(self):
        '''
        个体评估
        '''
        self.evaluate_object_value()
        self.evaluate_object_fitness()
        self.select_best_and_worst_individual()

    def evaluate_object_value(self):
        '''
        计算目标值
        '''
        self.population.evaluate_object_value()

    def evaluate_object_fitness(self):
        '''
        计算适应度值
        '''
        self.population.evaluate_object_fitness()
        # self.use_microhabitat()

    def use_microhabitat(self):
        s = np.empty(shape=(self.population_capacity, ), dtype=np.uint32)
        for i in range(self.population_capacity):
            s[i] = 0
            for j in range(self.population_capacity):
                s[i] += self.compute_hamming_distance(i, j)
            s[i] += 1
        
        for i in range(self.population_capacity):
            self.population.individuals[i].object_fitness = self.population.individuals[i].object_fitness / s[i]
    
    def compute_hamming_distance(self, i, j):
        count = 0
        for k in range(self.population.chromosome_length):
            if self.population.individuals[i].chromosome_gray[k] != self.population.individuals[j].chromosome_gray[k]:
                count += 1
        return count

    def select_best_and_worst_individual(self):
        '''
        筛选当前最优和最差个体，更新全局最优个体，即所谓的精英保存策略
        '''
        self.current_best_individual = copy(self.population.individuals[0])
        self.current_best_individual_index = 0
        self.current_worst_individual = copy(self.population.individuals[0])
        self.current_worst_individual_index = 0
        for i in range(1, self.population_capacity):
            if self.population.individuals[i].object_fitness > self.current_best_individual.object_fitness:
                self.current_best_individual = copy(self.population.individuals[i])
                self.current_best_individual_index = i
            elif self.population.individuals[i].object_fitness < self.current_worst_individual.object_fitness:
                self.current_worst_individual = copy(self.population.individuals[i])
                self.current_worst_individual_index = i

        if self.e == 0:
            self.best_individual = copy(self.current_best_individual)
        else:
            if self.current_best_individual.object_fitness > self.best_individual.object_fitness:
                self.best_individual = copy(self.current_best_individual)
        
        self.improve_evolution()
    
    def improve_evolution(self):
        '''
        改善进化
        '''
        self.population.individuals[self.current_worst_individual_index] = copy(self.best_individual)

    def generate_next_population(self):
        self.population.binarycode_to_graycode()

        self.select_operator()
        self.crossover_operator()
        self.mutate_operator()

        self.population.graycode_to_binarycode()

    def select_operator(self):
        '''
        选择算子
        '''
        def proportional_model_selector():
            '''
            比例选择
            '''
            _sum = 0.0
            for i in range(self.population_capacity):
                _sum += self.population.individuals[i].object_fitness
            _cum = [self.population.individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            for i in range(1, self.population_capacity):
                _cum[i] = _cum[i] + _cum[i - 1]

            for i in range(self.population_capacity):
                count = 0
                while (random.random() > _cum[i] and count < self.population_capacity):
                    count += 1
                if count < self.population_capacity:
                    self.population.individuals[i] = copy(self.population.individuals[count])
        
        def deterministic_sampling_selector():
            '''
            确定式采样选择
            '''
            _sum = 0.0
            for i in range(self.population_capacity):
                _sum += self.population.individuals[i].object_fitness
            _n = [self.population_capacity * self.population.individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            _n_integer_part = [math.floor(_n[i]) for i in range(self.population_capacity)]
            _n_integer_part_sum = sum(_n_integer_part)
            _n_decimal_part = [(_n[i] - _n_integer_part[i], i) for i in range(self.population_capacity)]
            _ret = sorted(_n_decimal_part, key=lambda x:x[0], reverse=True)

            for i in range(self.population_capacity - _n_integer_part_sum):
                 select_individual_index = random.randint(0, self.population.chromosome_length)
                 self.population.individuals[select_individual_index] =  copy(self.population.individuals[_ret[i][1]])

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
                _sum += self.population.individuals[i].object_fitness
            _n = [self.population_capacity * self.population.individuals[i].object_fitness / _sum for i in range(self.population_capacity)]
            _n_integer_part = [math.floor(_n[i]) for i in range(self.population_capacity)]
            _n_integer_part_sum = sum(_n_integer_part)
            _new = [self.population.individuals[i].object_fitness - _n_integer_part[i] * _sum / self.population_capacity for i in range(self.population_capacity)]
            for i in range(1, self.population_capacity):
                _new[i] = _new[i] + _new[i - 1]

            counter = 0
            for i in range(self.population_capacity):
                count = 0
                while (random.random() > _new[i] and count < self.population_capacity):
                    count += 1
                if count < self.population_capacity:
                    self.population.individuals[i] = copy(self.population.individuals[count])
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
                _index_1 = random.randint(0, self.population.chromosome_length)
                _index_2 = random.randint(0, self.population.chromosome_length)
                if self.population.individuals[_index_1].object_fitness > self.population.individuals[_index_2].object_fitness:
                    self.population.individuals[i] = copy(self.population.individuals[_index_1])
                else:
                    self.population.individuals[i] = copy(self.population.individuals[_index_2])

        remainder_stochastic_sampling_with_replacement_selector()

    def crossover_operator(self):
        '''
        交叉算子[全局搜索算子]，精英保存策略要求最优个体不参与交叉操作
        '''
        def one_point_crossover():
            '''
            单点交叉
            '''
            index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index:
                    index[i] = (i + random.randint(0, self.population.chromosome_length)) % self.population_capacity
                else:
                    index[i] = i
            np.random.shuffle(index)

            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    crossover_point = random.randint(1, self.population.chromosome_length)
                    for j in range(crossover_point, self.population.chromosome_length):
                        self.population.individuals[i].chromosome_gray[j], self.population.individuals[i + 1].chromosome_gray[j] =\
                        self.population.individuals[i + 1].chromosome_gray[j], self.population.individuals[i].chromosome_gray[j]

        def two_point_crossover():
            '''
            双点交叉
            '''
            index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index:
                    index[i] = (i + random.randint(0, self.population.chromosome_length)) % self.population_capacity
                else:
                    index[i] = i
            np.random.shuffle(index)

            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    crossover_point_1 = 2
                    crossover_point_2 = 1
                    while crossover_point_1 >= crossover_point_2:
                        crossover_point_1 = random.randint(1, self.population.chromosome_length)
                        crossover_point_2 = random.randint(1, self.population.chromosome_length)
                    for j in range(crossover_point_1, crossover_point_2):
                        self.population.individuals[i].chromosome_gray[j], self.population.individuals[i + 1].chromosome_gray[j] =\
                        self.population.individuals[i + 1].chromosome_gray[j], self.population.individuals[i].chromosome_gray[j]

        def uniform_crossover():
            '''
            均匀交叉
            '''
            index = np.empty(shape=(self.population_capacity, ), dtype=np.int64)
            for i in range(self.population_capacity):
                if i == self.current_best_individual_index:
                    index[i] = (i + random.randint(0, self.population.chromosome_length)) % self.population_capacity
                else:
                    index[i] = i
            np.random.shuffle(index)

            _W = np.empty(shape=(self.population.chromosome_length, ), dtype=np.uint8)
            for i in range(0, self.population_capacity, 2):
                if (random.random() < self.pc):
                    for j in range(self.population.chromosome_length):
                        if random.random() > 0.5: 
                            _W[j] = 1
                        else:
                            _W[j] = 0  
                    for j in range(self.population.chromosome_length):
                        if _W[j] == 1:
                            self.population.individuals[i].chromosome_gray[j], self.population.individuals[i + 1].chromosome_gray[j] =\
                            self.population.individuals[i + 1].chromosome_gray[j], self.population.individuals[i].chromosome_gray[j]
                            
        def arithmetic_crossover():
            '''
            算数交叉
            '''
            # TODO
        
        uniform_crossover()

    def mutate_operator(self):
        '''
        变异算子[局部搜索算子]，精英保存策略要求最优个体不参与变异操作
        '''
        def simple_mutatation():
            '''
            基本位变异
            '''
            for i in range(self.population_capacity):
                if i != self.current_best_individual_index:
                    for j in range(self.population.chromosome_length):
                        if (random.random() < self.px):
                            if self.population.individuals[i].chromosome_gray[j] == 0:
                                self.population.individuals[i].chromosome_gray[j] == 1
                            else:
                                self.population.individuals[i].chromosome_gray[j] == 0

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
    
    def make_visualization(self, x, y):
        if platform.system() == 'Windows':
            print(f"[+] epoch - {x} : current best value is {y} ...")
        else:
            print(f"[+] epoch - {x} : current best value is \033[1;31;40m{y}\033[0m ...")

if __name__ == '__main__':
    ga = GeneticAlgorithm()
    ga.run()
    