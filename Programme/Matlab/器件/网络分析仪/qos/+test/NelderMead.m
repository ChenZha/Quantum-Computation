%% NelderMead test
function_handle = @(x) (1-x(1))^2+(x(2)-x(1)^2)^2;
x0 = [-3,-3;...
    -3,3;...
    3,3];
tolX = [1e-4,1e-4];
tolY = [1e-4];
max_feval = 100;
figure()
axs(1) = subplot(3,1,3);
axs(2) = subplot(3,1,2);
axs(3) = subplot(3,1,1);
[ x_opt, x_trace, y_trace, n_feval] = qes.util.NelderMead (function_handle, x0, tolX, tolY, max_feval, axs);
