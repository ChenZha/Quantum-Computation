########################################################################
# SwarmOps - Heuristic optimization for Python.
# Copyright (C) 2003-2016 Magnus Erik Hvass Pedersen.
# See the file README.md for instructions.
# See the file LICENSE.txt for license details.
# SwarmOps on the internet: http://www.Hvass-Labs.org/
########################################################################

########################################################################
# Pattern Search (PS). An early variant was originally
# due to Fermi and Metropolis at the Los Alamos nuclear
# laboratory as described by Davidon [1]. It is also
# sometimes called compass search. This is a slightly
# different variant by Pedersen [2]. It works especially
# well when only few optimization iterations are allowed.
#
# References:
#
# [1] W.C. Davidon. Variable metric method for minimization.
#     SIAM Journal on Optimization, 1(1):1-17, 1991
#
# [2] M.E.H. Pedersen. Tuning & Simplifying Heuristical Optimization (PhD thesis).
#     University of Southampton, School of Engineering Sciences. 2010
#     http://www.hvass-labs.org/people/magnus/thesis/pedersen08thesis.pdf
#
########################################################################

from swarmops.Optimize import SingleRun
from swarmops import tools
import time
import scipy.io as sio
import os


########################################################################

class PS(SingleRun):
    """
        Perform a single optimization run using Pattern Search (PS).

        In practice, you would typically perform multiple optimization runs using
        the MultiRun-class. The reason is that PS is a heuristic optimizer so
        there is no guarantee that an acceptable solution is found in any single
        run. It is more likely that an acceptable solution is found if you perform
        multiple optimization runs.
    """

    # Name of this optimizer.
    name = "PS"
    name_full = "Pattern Search"

    @staticmethod
    def parameters_dict(parameters):
        """
        Create and return a dict from a list of PS parameters.
        The dict is empty because PS does not have any control parameters.
        This is implemented to have a consistent API.
        """

        return {}

    @staticmethod
    def parameters_list():
        """
        Create an empty list because PS does not have any parameters.
        This is implemented to have a consistent API.
        """

        return []

    def __init__(self, problem, parameters=None, parallel=False, directoryname = 'result', *args, **kwargs):
        """
        Create object instance and perform a single optimization run using PS.

        :param problem: The problem to be optimized. Instance of Problem-class.

        :param parameters: None. There are no control parameters for PS.

        :param parallel: False. PS cannot run in parallel except through MultiRun.

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

        # Dimensionality of search-space.
        dim = self.problem.dim

        # Initialize the range-vector to full search-space.
        d = upper_bound - lower_bound

        # Initialize x with random position in search-space.
        x = tools.rand_array(lower=lower_init, upper=upper_init)

        # Compute fitness of initial position.
        evaluations = 0
        fitness = f(x)

        filename = './'+self.directoryname+'/PS'+str(evaluations)+'th_'+str(self.run_number)+'_'+time.strftime('%Y%m%d-%H-%M',time.localtime())+'.mat'
        sio.savemat(filename,{'fitness':fitness,'x':x,'d':d,})

        # Update the best-known fitness and position.
        # The parent-class is used for this.
        self._update_best(fitness=fitness, x=x)

        # Perform optimization iterations until the maximum number
        # of fitness evaluations has been performed.
        # Count starts at one because we have already calculated fitness once above.
        evaluations = 1
        while evaluations < self.max_evaluations:
            # Pick random index from {0, .., dim-1}
            idx = tools.rand_int(lower=0, upper=dim)

            # Save old element.
            t = x[idx]

            # Make new element.
            x[idx] = x[idx] + d[idx]

            # Bound new element to search-space.
            x[idx] = tools.bound_scalar(x=x[idx],
                                        lower=lower_bound[idx],
                                        upper=upper_bound[idx])

            # Compute new fitness.
            new_fitness = f(x, limit=fitness)

            # If improvement to fitness.
            if new_fitness < fitness:
                # Update just the fitness as the position is already updated.
                fitness = new_fitness

                # Update the best-known fitness and position.
                # The parent-class is used for this.
                self._update_best(fitness=fitness, x=x)
            else:
                # Otherwise restore the position.
                x[idx] = t

                # Reduce search-range and invert direction for this dimension.
                d[idx] *= -0.5

            # Call parent-class to print status etc. during optimization.
            self._iteration(evaluations)

            filename = './'+self.directoryname+'/PS'+str(evaluations)+'th_'+str(self.run_number)+'_'+time.strftime('%Y%m%d-%H-%M',time.localtime())+'.mat'
            sio.savemat(filename,{'fitness':fitness,'x':x,'d':d,})
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