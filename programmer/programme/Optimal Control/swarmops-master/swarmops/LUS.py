########################################################################
# SwarmOps - Heuristic optimization for Python.
# Copyright (C) 2003-2016 Magnus Erik Hvass Pedersen.
# See the file README.md for instructions.
# See the file LICENSE.txt for license details.
# SwarmOps on the internet: http://www.Hvass-Labs.org/
########################################################################

########################################################################
# Local Unimodal Sampling (LUS).
#
# Performs localized sampling of the search-space with a sampling range
# that initially covers the entire search-space and is decreased
# exponentially as optimization progresses. LUS works especially well
# for optimization problems where only short runs can be performed
# and the search-space is fairly smooth.
#
# References:
#
# [1] M.E.H. Pedersen. Tuning & Simplifying Heuristical Optimization (PhD thesis).
#     University of Southampton, School of Engineering Sciences. 2010
#     http://www.hvass-labs.org/people/magnus/thesis/pedersen08thesis.pdf
#
########################################################################
import numpy as np
from swarmops.Optimize import SingleRun
from swarmops import tools
import time
import scipy.io as sio
import os


########################################################################

class LUS(SingleRun):
    """
        Perform a single optimization run using Local Unimodal Sampling (LUS).

        In practice, you would typically perform multiple optimization runs using
        the MultiRun-class. The reason is that LUS is a heuristic optimizer so
        there is no guarantee that an acceptable solution is found in any single
        run. It is more likely that an acceptable solution is found if you perform
        multiple optimization runs.
    """

    # Name of this optimizer.
    name = "LUS"
    name_full = "Local Unimodal Sampling"

    # Number of control parameters for LUS. Used by MetaFitness-class.
    num_parameters = 1

    # Lower boundaries for the control parameters of LUS. Used by MetaFitness-class.
    parameters_lower_bound = [0.1]

    # Upper boundaries for the control parameters of LUS. Used by MetaFitness-class.
    parameters_upper_bound = [100.0]

    @staticmethod
    def parameters_dict(parameters):
        """
        Create and return a dict from a list of LUS parameters.
        This is useful for printing the named parameters.

        :param parameters: List with LUS parameters assumed to be in the correct order.
        :return: Dict with LUS parameters.
        """

        return {'gamma': parameters[0]}

    @staticmethod
    def parameters_list(gamma):
        """
        Create a list with LUS parameters in the correct order.

        :param gamma: Gamma-parameter (see paper reference for explanation).
        :return: List with LUS parameters.
        """

        return [gamma]

    # Default parameters for LUS which will be used if no other parameters are specified.
    parameters_default = [3.0]

    def __init__(self, problem, parameters=parameters_default, parallel=False, directoryname = 'result' , *args, **kwargs):
        """
        Create object instance and perform a single optimization run using LUS.

        :param problem:
            The problem to be optimized. Instance of Problem-class.

        :param parameters:
            Control parameters for LUS.

        :param parallel: False. LUS cannot run in parallel except through MultiRun.

        :return:
            Object instance. Get the optimization results from the object's variables.
            -   best is the best-found solution.
            -   best_fitness is the associated fitness of the best-found solution.
            -   fitness_trace is an instance of the FitnessTrace-class.
        """

        # Copy arguments to instance variables.
        self.problem = problem

        self.directoryname = directoryname
        if os.path.exists(self.directoryname):
            pass
        else:
            os.mkdir(self.directoryname)

        # Unpack control parameters.
        gamma = parameters[0]

        # Derived control parameter.
        self.decrease_factor = 0.5 ** (1.0 / (gamma * problem.dim))

        # Initialize parent-class which also starts the optimization run.
        SingleRun.__init__(self, *args, **kwargs)

    def _optimize(self):
        """
        Perform a single optimization run.
        This function is called by the parent-class.
        """

        # Convenience variable for fitness function.
        f = self.problem.fitness

        # Convenience variables for search-space boundaries.
        lower_init = self.problem.lower_init
        upper_init = self.problem.upper_init
        lower_bound = self.problem.lower_bound
        upper_bound = self.problem.upper_bound

        # Initialize the range-vector to full search-space.
        d = upper_bound - lower_bound

        # Search-space dimensionality.
        dim = self.problem.dim

        # Initialize x with random position in search-space.
        x = tools.rand_array(lower=lower_init, upper=upper_init)

        # Compute fitness of initial position.
        evaluations = 0
        fitness = f(x)

        filename = './'+self.directoryname+'/LUS'+str(evaluations)+'th_'+str(self.run_number)+'_'+time.strftime('%Y%m%d-%H-%M',time.localtime())+'.mat'
        sio.savemat(filename,{'fitness':fitness,'x':x,'d':d,'decrease_factor':self.decrease_factor})
        # Update the best-known fitness and position.
        # The parent-class is used for this.
        self._update_best(fitness=fitness, x=x)

        # Perform optimization iterations until the maximum number
        # of fitness evaluations has been performed.
        # Count starts at one because we have already calculated fitness once above.
        evaluations = 1
        while evaluations < self.max_evaluations :
            # Sample new position y from the bounded surroundings
            # of the current position x.
            y = tools.sample_bounded(x=x, d=d, lower=lower_bound, upper=upper_bound)

            # Compute new fitness.
            new_fitness = f(y, limit=fitness)

            # If improvement to fitness.
            if new_fitness < fitness:
                # Update fitness and position.
                fitness = new_fitness
                x = y

                # Update the best-known fitness and position.
                # The parent-class is used for this.
                self._update_best(fitness=fitness, x=x)
            else:
                # Otherwise decrease the search-range.
                d *= self.decrease_factor

            # Call parent-class to print status etc. during optimization.
            self._iteration(evaluations)

            filename = './'+self.directoryname+'/LUS'+str(evaluations)+'th_'+str(self.run_number)+'_'+time.strftime('%Y%m%d-%H-%M',time.localtime())+'.mat'
            sio.savemat(filename,{'fitness':fitness,'x':x,'d':d,'decrease_factor':self.decrease_factor})
            # Increment counter.
            evaluations += 1

    
        
########################################################################
    def refine(self,iter = 30):
        '''
        找到最优解后，利用L-BFGS-B继续寻优
        '''
        """
        iter:最大迭代次数

        Refine the best result from heuristic optimization using SciPy's L-BFGS-B method.
        This may significantly improve the results on some optimization problems,
        but it is sometimes very slow to execute.

        NOTE: This function imports SciPy, which should make it possible
        to use the rest of this source-code library even if SciPy is not installed.
        SciPy should first be loaded when calling this function.

        :return:
            A tuple with:
            -   The best fitness found.
            -   The best solution found.
        """

        # SciPy requires bounds in another format.
        bounds = list(zip(self.problem.lower_bound, self.problem.upper_bound))

        # Start SciPy optimization at best found solution.
        import scipy.optimize
        res = scipy.optimize.minimize(fun=self.problem.fitness,
                                      x0=self.best,
                                      method="L-BFGS-B",
                                      bounds=bounds,
                                      options = {'maxiter': iter,'disp':1})

        # Get best fitness and parameters.
        refined_fitness = res.fun
        refined_solution = res.x

        return refined_fitness, refined_solution

    def plot_fitness_trace(self, y_log_scale=True, filename=None):
        """
        Plot the fitness traces.

        NOTE: This function imports matplotlib, which should make it possible
        to use the rest of this source-code library even if it is not installed.
        matplotlib should first be loaded when calling this function.

        :param y_log_scale: Use log-scale for y-axis.
        :param filename: Output filename e.g. "foo.svg". If None then plot to screen.
        :return: Nothing.
        """

        import matplotlib.pyplot as plt

        # Setup plotting.
        plt.grid()

        # Axis labels.
        plt.xlabel("Iteration")
        plt.ylabel("Fitness (Lower is better)")

        # Title.
        title = "{0} - Optimized by {1}".format(self.problem.name_full, self.name)
        plt.title(title)

        # Use log-scale for Y-axis.
        if y_log_scale:
            plt.yscale("log", nonposy="clip")

        # Plot the fitness-trace .
        # Array with iteration counter .
        iteration = self.fitness_trace.iteration

        # Array with fitness-trace .
        fitness_trace = self.fitness_trace.fitness

        # Plot the fitness-trace.
        plt.plot(iteration, fitness_trace, 'r-', color='black', alpha=0.25)

        # Plot to screen or file.
        if filename is None:
            # Plot to screen.
            plt.show()
        else:
            # Plot to file.
            plt.savefig(filename, bbox_inches='tight')
            plt.close()