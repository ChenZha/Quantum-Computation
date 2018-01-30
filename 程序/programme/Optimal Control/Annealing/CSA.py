"""
Main implementation of the coupled simulated annealing algorithm (CSA).

This modules makes use of the Python multiprocessing library in order to run
the annealing processes in parallel.
"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import math
import multiprocessing as mp
import random
import time


try:
    xrange
except NameError:
    xrange = range


class CoupledAnnealer(object):
    """
    Interface for performing coupled simulated annealing.

    **Parameters**:

      - target_function: function
            A function which outputs a float.

      - probe_function: function 
            a function which will randomly "probe" 
            out from the current state, i.e. it will randomly adjust the input 
            parameters for the `target_function`.

      - n_annealers: int
            The number of annealing processes to run.

      - initial_state: list
            A list of objects of length `n_probes`. 
            This is used to set the initial values of the input parameters for 
            `target_function` for all `n_probes` annealing processes.

      - steps: int
            The total number of annealing steps.

      - update_interval: int 
            Specifies how many steps in between updates 
            to the generation and acceptance temperatures.

      - tgen_initial: float 
            The initial value of the generation temperature.

      - tgen_schedule: float 
            Determines the factor that tgen is multiplied by during each update.

      - tacc_initial: float 
            The initial value of the acceptance temperature.

      - tacc_schedule: float 
            Determines the factor that `tacc` is multiplied by during each update.

      - desired_variance: float 
            The desired variance of the acceptance probabilities. If not specified, 
            `desired_variance` will be set to 

            :math:`0.99 * (\\text{max variance}) = 0.99 * \\frac{(m - 1)}{m^2}`,

            where m is the number of annealing processes.

      - verbose: int 
            Set verbose=2, 1, or 0 depending on how much output you wish to see 
            (2 being the most, 0 being no output).

      - processes: int 
            The number of parallel processes. Defaults to a single process.
            If `processes` <= 0, then the number of processes will be set to the
            number of available CPUs. Note that this is different from the 
            `n_annealers`. If `target_function` is costly to compute, it might 
            make sense to set `n_annealers` = `processes` = max number of CPUs.

            On the other hand, if `target_function` is easy to compute, then the
            CSA process will likely run a LOT faster with a single process due 
            to the overhead of using multiple processes.
    """

    def __init__(self, target_function, probe_function,
                 n_annealers=10, 
                 initial_state=[],
                 steps=100000,
                 update_interval=5,
                 tgen_initial=0.01,
                 tgen_schedule=0.99999,
                 tacc_initial=0.9, 
                 tacc_schedule=0.95,
                 desired_variance=None,
                 verbose=1,
                 processes=1):
        self.target_function = target_function
        self.probe_function = probe_function
        self.steps = steps
        self.m = n_annealers
        self.processes = processes if processes > 0 else mp.cpu_count()
        self.update_interval = update_interval
        self.verbose = verbose
        self.tgen = tgen_initial
        self.tacc = tacc_initial
        self.tgen_schedule = tgen_schedule
        self.tacc_schedule = tacc_schedule
        
        # Set desired_variance.
        if desired_variance is None:
            desired_variance = 0.99 * (self.m - 1) / (self.m ** 2)
        self.desired_variance = desired_variance

        # Initialize state.
        assert len(initial_state) == self.m
        self.probe_states = initial_state

        # Shallow copy.
        self.current_states = self.probe_states[:]

        # Initialize energies.
        self.probe_energies = self.current_energies = [None] * self.m

    def __update_state(self):
        """
        Update the current state across all annealers in parallel.
        """
        # Set up the mp pool.
        pool = mp.Pool(processes=self.processes)

        # Put the workers to work.
        results = []
        for i in xrange(self.m):
            pool.apply_async(worker_probe, args=(self, i,), 
                             callback=lambda x: results.append(x))

        # Gather the results from the workers.
        pool.close()
        pool.join()

        # Update the states and energies from each probe.
        for res in results:
            i, energy, probe = res
            self.probe_energies[i] = energy
            self.probe_states[i] = probe

    def __update_state_no_par(self):
        """
        Update the current state across all annealers sequentially.
        """
        for i in xrange(self.m):
            i, energy, probe = worker_probe(self, i)
            self.probe_energies[i] = energy
            self.probe_states[i] = probe

    def __step(self, k):
        """
        Perform one entire step of the CSA algorithm.
        """
        cool = True if k % self.update_interval == 0 else False

        max_energy = max(self.current_energies)
        exp_terms = []

        if cool:
            exp_terms2 = []

        for i in xrange(self.m):
            E = self.current_energies[i]
            exp_terms.append(math.exp((E - max_energy) / self.tacc))

            # No need to calculate this if we are not cooling this step.
            if cool:
                exp_terms2.append(math.exp(2.0 * (E - max_energy) / self.tacc))

        gamma = sum(exp_terms)
        prob_accept = [x / gamma for x in exp_terms]

        # Determine whether to accept or reject probe.
        for i in xrange(self.m):
            state_energy = self.current_energies[i]
            probe_energy = self.probe_energies[i]
            probe = self.probe_states[i]
            p = prob_accept[i]
            if (probe_energy < state_energy) or (random.uniform(0, 1) < p):
                self.current_energies[i] = probe_energy
                self.current_states[i] = probe

        # Update temperatures according to schedule.
        if cool:
            # Update generation temp.
            self.tgen = self.tgen * self.tgen_schedule

            # Update acceptance temp.
            sigma2 = (self.m * sum(exp_terms2) / (gamma ** 2) - 1) 
            sigma2 = sigma2 / (self.m ** 2)
            if sigma2 < self.desired_variance:
                self.tacc *= self.tacc_schedule
            else:
                self.tacc *= (2 - self.tacc_schedule)

    def __status_check(self, k, energy, temps=None, start_time=None):
        """
        Print updates to the user. Everybody is happy.
        """
        if start_time:
            elapsed = time.time() - start_time
            print("Step {:6d}, Energy {:,.4f}, Elapsed time {:,.2f} secs"
                  .format(k, energy, elapsed))
        else:
            print("Step {:6d}, Energy {:,.4f}".format(k, energy))
        if temps:
            print("Updated acceptance temp {:,.6f}".format(temps[0]))
            print("Updated generation temp {:,.6f}".format(temps[1]))
            print()

    def get_best(self):
        """
        Return the optimal state so far.
        """
        energy = min(self.current_energies)
        index = self.current_energies.index(energy)
        state = self.current_states[index]
        return energy, state

    def anneal(self):
        """
        Run the CSA annealing process.
        """
        start_time = time.time()

        if self.processes > 1:
            update_func = self.__update_state
        else:
            update_func = self.__update_state_no_par

        update_func()
        self.current_energies = self.probe_energies[:]

        # Run for `steps` or until user interrupts.
        for k in xrange(1, self.steps + 1):
            update_func()
            self.__step(k)
            
            if k % self.update_interval == 0 and self.verbose >= 1:
                temps = (self.tacc, self.tgen)
                self.__status_check(k, min(self.current_energies), 
                                    temps=temps, 
                                    start_time=start_time)
            elif self.verbose >= 2:
                self.__status_check(k , min(self.current_energies))


def worker_probe(annealer, i):
    """
    This is the function that will spread across different processes in 
    parallel to compute the current energy at each probe.
    """
    state = annealer.current_states[i]
    probe = annealer.probe_function(state, annealer.tgen)
    energy = annealer.target_function(probe)
    return i, energy, probe
