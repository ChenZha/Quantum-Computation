import warnings

import numpy as np
import scipy.linalg as spla
import scipy.special as spsp
import time
import scipy.io as sio
import os


class CovMatAdapt:
    """ Covariance Matrix Adaption Evolution Strategy
    Implements the Covariance Matrix Adaption Evolution Strategy
    as described in 'The CMA Evolution Strategy: A Tutorial' by
    Nikolaus Hansen. For exact details and meaning of the parameters,
    please see the tutorial.
    Args:
        func (numpy array -> float): Function to optimize.
        mean_vec (numpy array): Initiale locations to start the optimization.
        step_size (float > 0): Overall variance step size. Rule of thumb:
            Choose it in a way that the optimum is within mean_vec +/-
            3*step_size.
        pop_size (int > 0): How many samples should be generated in each
            generation?
        elite_size (int > 0): How many of the top samples are used to
            reproduce?
        weights (numpy array): To weight the contribution of the different
            elites.
        c_sig (float > 0): Learning rate for the cumulation for the step-size
            control.
        d_sig (float > 0): Dampening parameter for step-size updates.
        c_c (float > 0): Learning rate for cumulation for rank-one updates.
        c_1 (float > 0): Learning rate for rank-one updates.
        c_mu (float > 0): Learning rate for rank-mu updates.
        c_m (float > 0): Learning rate for mean vector updates.
        abs_tol (float > 0): Absolute change criterion for early stopping.
        rel_tol (float > 0): Relative change criterion for early stopping.
        maxgen (int > 0): Maximum number of generations/iterations before
            termination.
        verbose (bool): Provides extra feedback for the user.
    """

    def __init__(self, func, mean_vec, step_size, lower_bound, upper_bound,
                 pop_size=None,
                 elite_size=None, weights=None,
                 c_sig=None, d_sig=None, c_c=None,
                 c_1=None, c_mu=None, c_m=None, abs_tol=1e-5,
                 rel_tol=1e-4, maxgen=50, verbose=True , directoryname = 'result'):

        self.func = func
        self.mean_vec = mean_vec
        self.step_size = step_size
        self.abs_tol = abs_tol
        self.rel_tol = rel_tol
        self.maxgen = maxgen
        self.ndim = mean_vec.size
        # Boundaries for the search-space. Ensure they are numpy float arrays.
        self.lower_bound = np.array(lower_bound, dtype='float64')
        self.upper_bound = np.array(upper_bound, dtype='float64')

        # name of result directory
        self.directoryname = directoryname
        if os.path.exists(self.directoryname):
            pass
        else:
            os.mkdir(self.directoryname)
        
        self.filename = ''# 初始化存储文件的名称

        # Default values for population sizes and weights
        if pop_size:
            self.pop_size = pop_size
        else:
            self.pop_size = int(4 + np.floor(3 * np.log(self.ndim)))

        if elite_size:
            self.elite_size = elite_size
        else:
            self.elite_size = self.pop_size // 2

        if weights:
            self.weights = weights
        else:
            self.weights = (np.log(0.5 * (self.pop_size + 1)) -
                            np.log(np.arange(1, self.pop_size + 1)))

        norm_pos_weights = (self.weights[:self.elite_size] /
                            sum(self.weights[:self.elite_size]))
        self.mu_eff = (sum(norm_pos_weights)**2 /
                       sum(norm_pos_weights**2))

        # Initializes the step size parameters
        if c_sig:
            self.c_sig = c_sig
        else:
            self.c_sig = (self.mu_eff + 2) / (self.ndim + self.mu_eff + 5)

        if d_sig:
            self.d_sig = d_sig
        else:
            self.d_sig = (1 + 2 * max(0, np.sqrt((self.mu_eff - 1) /
                                                 (self.ndim + 1)) - 1) +
                          self.c_sig)

        # Initializes parameters for covariance adaption
        if c_c:
            self.c_c = c_c
        else:
            self.c_c = ((4 + self.mu_eff / self.ndim) /
                        (self.ndim + 4 + 2 * self.mu_eff / self.ndim))

        if c_1:
            self.c_1 = c_1
        else:
            self.c_1 = 2 / ((self.ndim + 1.3)**2 + self.mu_eff)

        if c_mu:
            self.c_mu = c_mu
        else:
            self.c_mu = min(1 - self.c_1, 2 *
                            ((self.mu_eff - 2 + 1 / self.mu_eff) /
                             ((self.ndim + 2)**2 + self.mu_eff)))

        if c_m:
            self.c_m = c_m
        else:
            self.c_m = 1

        # Set the negative weights, if not provided:
        if not weights:
            neg_weights = self.weights[self.elite_size:]
            mu_eff_neg = (sum(neg_weights)**2 /
                          sum(neg_weights**2))

            alpha_mu_neg = 1 + self.c_1 / self.c_mu
            alpha_mu_eff_neg = 1 + 2 * mu_eff_neg / (self.mu_eff + 2)
            alpha_pos_def_neg = ((1 - self.c_1 - self.c_mu) /
                                 (self.ndim * self.c_mu))
            self.weights[:self.elite_size] = norm_pos_weights
            denom = min(alpha_mu_neg, alpha_mu_eff_neg, alpha_pos_def_neg)
            self.weights[self.elite_size:] = (denom * neg_weights /
                                              -sum(neg_weights))

        self.cov_mat = np.identity(len(self.mean_vec))

        # Set the evolution paths
        self.p_sig = 0
        self.p_c = 0

        self.verbose = verbose

    def sample_and_evaluate(self, func, ndim, mean_vec,
                            cov_mat, pop_size, step_size):
        """ Samples the function evaluations
        Used to sample the candidate values and evaluates them.
        Args:
            func (numpy array -> float): Function to evaluate.
            ndim (int > 0): Number of dimensions.
            mean_vec (numpy array): Mean vector of the multivariate Gaussian
                distribution.
            cov_mat (numpy array): Covariance matrix of the multivariate
                Gaussian distribution.
            pop_size (int > 0): Number of samples.
            step_size (float > 0): Overall variance step size.
        Returns:
            Numpy array containing the function values, the mean-centered and
            step_size ajusted input values, and zero-centered and unadjusted
            input values as columns.
        """
        with warnings.catch_warnings():
            if not self.verbose:
                warnings.filterwarnings('ignore')

            y = np.random.multivariate_normal(np.zeros(ndim),
                                              cov_mat,
                                              size=pop_size)

        x = mean_vec + step_size * y

        ## bound 
        x_1 = np.where(x < self.lower_bound, self.lower_bound, x)
        x_2 = np.where(x_1 > self.upper_bound, self.upper_bound, x_1)
        x = x_2
        
        # Create a pool of workers sized according to the CPU cores available.
        import multiprocessing as mp
        pool = mp.Pool()

        # Calculate the fitness for each agent in parallel.
        func_values = pool.map(self.func, x)

        # Close the pool of workers and wait for them all to finish.
        pool.close()
        pool.join()


        conc_matrix = np.c_[func_values, x, y]
        conc_matrix = conc_matrix[conc_matrix[:, 0].argsort()]
        return conc_matrix

    def heaviside(self, gen, norm_p_sig, c_sig, ndim, expec_norm_gaussian):
        """Heaviside function
        Prevents too fast increases of axes of the covariance matrix.
        Args:
            gen (int > 0): The current generation the minimization procedure is
                in.
            norm_p_sig(float > 0): The norm of p_sig.
            c_sig (float > 0): Learning rate for the cumulation for the
                step-size control.
            ndim (int > 0): Number of dimensions.
            expec_norm_gaussian (float > 0): Expectation of the norm of a
                multivariate standard normal distribution.
        Returns:
            0 or 1.
        """
        a = norm_p_sig / (np.sqrt(1 - (1 - c_sig)**(2 * (gen + 1))))
        b = (1.4 + 2 / (ndim + 1)) * expec_norm_gaussian

        if a < b:
            return 1
        else:
            return 0

    def minimize(self):
        """Minimize objective function
        Returns:
            Dictionary containing following keys:
                'best fvalue' (float): Best function value that has been
                    reached.
                'best param' (numpy array): Parameters corresponding to best
                    function value.
                'mean vector' (numpy array): Last mean vector obtained during
                    the minimization.
                'cov matrix' (numpy array): Last covariance matrix obtained
                    during minimization.
                'converged in' (int): Generation in which the procedure
                    converged.
                'abs/rel conv': Information about absolute and relative
                    convergence.
        """

        
        # Matrix to fix some numerical issues with the cholesky decomposition.
        offset_matrix = np.identity(self.ndim) * 0.1
        expec_norm_gaussian = (np.sqrt(2) * spsp.gamma(0.5 * (self.ndim + 1)) /
                               spsp.gamma(0.5 * self.ndim))
        pop_matrix = self.sample_and_evaluate(self.func, self.ndim,
                                              self.mean_vec, self.cov_mat,
                                              self.pop_size, self.step_size)

        y = pop_matrix[:, (self.ndim + 1):]
        x = pop_matrix[:, 1:(self.ndim + 1)]
        func_values = pop_matrix[:, 0]
        best_fvalue = pop_matrix[0, 0]
        best_param = x[0, :]

        if self.verbose:
            print('Initial value:', best_fvalue)

        for gen in range(1, self.maxgen + 1):
            # 取精英的y乘以权重
            y_weighted = np.sum(y[:self.elite_size] *
                                self.weights[:self.elite_size, np.newaxis],
                                axis=0)
            # 利用精英的y , 生成新的mean_vec
            upd_mean_vec = (self.mean_vec + self.c_m * self.step_size *
                            y_weighted)
            # 计算差距
            diff_vec = abs(upd_mean_vec - self.mean_vec)

            if (max(diff_vec) < self.abs_tol or
                    max(diff_vec / abs(self.upper_bound-self.lower_bound)) < self.rel_tol):
                result_dict = {'best fvalue': best_fvalue,
                               'best param': best_param,
                               'mean vector': self.mean_vec,
                               'cov matrix': self.cov_mat,
                               'converged in': gen,
                               'abs/rel conv': (max(diff_vec),
                                                max(diff_vec /
                                                    abs(self.mean_vec)))}
                return result_dict

            self.mean_vec = upd_mean_vec # 更新mean_vec
            
            try:
                chol_covm_L = spla.cholesky(self.cov_mat, lower=True)
            except np.linalg.linalg.LinAlgError as err:
                if self.verbose:
                    print(('We have hit an linalg exception',
                           'in the cholesky decomposition'))
                    print(repr(err))
                try:
                    chol_covm_L = spla.cholesky(
                        self.cov_mat + offset_matrix, lower=True)
                except BaseException:
                    if self.verbose:
                        print(('Even the matrix with increased diagonal',
                               'elements failed.'))

            c_y_vec = spla.solve_triangular(
                chol_covm_L, y_weighted, lower=True)

            # Updating the step sizes
            self.p_sig = ((1 - self.c_mu) * self.p_sig +
                          np.sqrt(self.c_sig * (2 - self.c_sig) *
                                  self.mu_eff) * c_y_vec)
            norm_p_sig = np.linalg.norm(self.p_sig)
            self.step_size = (self.step_size *
                              np.exp(self.c_sig / self.d_sig *
                                     norm_p_sig /
                                     expec_norm_gaussian - 1))

            # Updating the covariance matrix
            h_sig = self.heaviside(gen, norm_p_sig, self.c_sig,
                                   self.ndim, expec_norm_gaussian)

            self.p_c = ((1 - self.c_c) * self.p_c +
                        h_sig * np.sqrt(self.c_c * (2 - self.c_c) *
                                        self.mu_eff) * y_weighted)
            c_y_mat = spla.solve_triangular(chol_covm_L,
                                            y[self.elite_size:, :].T,
                                            lower=True).T
            c_y_mat_norm = np.linalg.norm(c_y_mat, axis=1)

            w_adj = self.weights.copy()
            w_adj[self.elite_size:] = (w_adj[self.elite_size:] *
                                       (self.ndim / c_y_mat_norm))

            matrix_sum = (w_adj * y.T).dot(y)
            self.cov_mat = ((1 + self.c_1 * (1 - h_sig) * self.c_c *
                             (2 - self.c_c) - self.c_1 - self.c_mu *
                             sum(self.weights)) * self.cov_mat + self.c_1 *
                            np.outer(self.p_c, self.p_c)
                            + self.c_mu * matrix_sum)


            # save the  result


            # Create new generations
            pop_matrix = self.sample_and_evaluate(self.func,
                                                  self.ndim,
                                                  self.mean_vec,
                                                  self.cov_mat,
                                                  self.pop_size,
                                                  self.step_size)

            y = pop_matrix[:, (self.ndim + 1):]
            x = pop_matrix[:, 1:(self.ndim + 1)]
            func_values = pop_matrix[:, 0]

            if func_values[0] < best_fvalue:
                best_fvalue = pop_matrix[0, 0]
                best_param = x[0, :]

            ## save result
            self.filename = './'+self.directoryname+'/CMAES'+str(gen)+'th_'+'_'+time.strftime('%Y%m%d-%H-%M',time.localtime())+'.mat'
            sio.savemat(self.filename,{'best fvalue': best_fvalue,
                                        'best param': best_param,
                                        'mean vector': self.mean_vec,
                                        'cov matrix': self.cov_mat,
                                        'converged in': self.maxgen})
            if self.verbose and gen % 1 == 0:
                print('Best value after', gen, 'generations:', best_fvalue)

        else:
            print('Failed to converge within maximum generation bound.')
            result_dict = {'best fvalue': best_fvalue,
                           'best param': best_param,
                           'mean vector': self.mean_vec,
                           'cov matrix': self.cov_mat,
                           'converged in': self.maxgen}
            return result_dict