function [ x_opt, x_trace, y_trace, n_feval] = NelderMead_RandWalk (function_handle, x0, tolX, tolY, max_feval, axs)

    % NELDER_MEAD performs the Nelder-Mead optimization search.
    %
    %  Licensing:
    %
    %    This code is distributed under the GNU LGPL license.
    %
    %  Modified:
    %
    %    19 January 2009
    %
    %  Author:
    %
    %    Jeff Borggaard
    %
    %  Reference:
    %
    %    John Nelder, Roger Mead,
    %    A simplex method for function minimization,
    %    Computer Journal,
    %    Volume 7, Number 4, January 1965, pages 308-313.
    %
    %  Parameters:
    %
    %    Input, real X(M+1,M), contains a list of distinct points that serve as 
    %    initial guesses for the solution.  If the dimension of the space is M,
    %    then the matrix must contain exactly M+1 points.  For instance,
    %    for a 2D space, you supply 3 points.  Each row of the matrix contains
    %    one point; for a 2D space, this means that X would be a
    %    3x2 matrix.
    %
    %    Input, handle FUNCTION_HANDLE, a quoted expression for the function,
    %    or the name of an M-file that defines the function, preceded by an 
    %    "@" sign;
    %
    %    Input, logical FLAG, an optional argument; if present, and set to 1, 
    %    it will cause the program to display a graphical image of the contours 
    %    and solution procedure.  Note that this option only makes sense for 
    %    problems in 2D, that is, with N=2.
    %
    %    Output, real X_OPT, the optimal value of X found by the algorithm.
    x = x0;
    if length(tolY)==1
        tolerance = tolY(1);
        is_AN_min_size= 0;
    else
        tolerance = tolY(1);
        is_AN_min_size=tolY(2);
    end
    
    rho = 1;    % rho > 0 反射参数
    xi  = 2;    % xi  > max(rho, 1) 在反射参数
    gam = 0.5;  % 0 < gam < 1 一维收缩参数
    sig = 0.5;  % 0 < sig < 1 高维收缩参数
    [ temp, n_dim ] = size ( x );
    plotTrace = false;
    if nargin < 6
        axs = [];
    elseif numel(axs) < n_dim + 1
        error('number of axes must equal to number of dimmension +1.');
    else
        plotTrace = true;
    end
    if ( temp ~= n_dim + 1 )
        fprintf ( 1, '\n' );
        fprintf ( 1, 'NELDER_MEAD - Fatal error!\n' );
        error('  Number of points must be = number of design variables + 1\n');
    end
    [f,delta] = evaluate ( x, function_handle ); 
    n_feval = n_dim + 1;
    [ f, index ] = rand_sort ( f ,delta);
    x = x(index,:);
    delta = delta(index);
    x_trace = x(1,:); 
    y_trace = f(1);
    traces = NaN(1,n_dim+1);
    if plotTrace
       for ww = 1:n_dim
          if isgraphics(axs(ww))
            traces(ww) = line('parent',axs(ww),'XData',1,'YData',x_trace(:,ww),'Marker','.','Color','b');
            ylabel(axs(ww),['X(',num2str(ww,'%0.0f'),')']);
            xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
          end
      end
      if isgraphics(axs(n_dim+1))
        traces(n_dim+1) = line('parent',axs(n_dim+1),'XData',1,'YData',y_trace,'Marker','.','Color','r');
        title(axs(n_dim+1),[num2str(n_feval),'th evaluation.']);
        ylabel(axs(n_dim+1),'Y');
      end
      drawnow;
    end
    %  Begin the Nelder Mead iteration.
        converged_Y = false;
        converged_X = false;
        converged=converged_X||converged_Y ;
        diverged  = false;
    while (( ~converged|| is_AN_min_size)&& ~diverged)
        %  Compute the midpoint of the simplex opposite the worst point.
        x_bar = sum ( x(1:n_dim,:) ) / n_dim;
        %  Compute the reflection point.
        x_r   = ( 1 + rho ) * x_bar - rho   * x(n_dim+1,:);
        [f_r,delta_r]   = feval(function_handle,x_r); 
        n_feval = n_feval + 1;
        x_trace = [x_trace;x_r]; 
        y_trace = [y_trace,f_r];
        if plotTrace
            [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
        end

    %  Accept the point:
        %if ( f(1) <= f_r && f_r <= f(n_dim) )
        if ( rand_compara(f(1),f_r,delta(1),delta_r) && rand_compara(f_r,f(n_dim),delta_r,delta(n_dim)))
            x(n_dim+1,:) = x_r;
            f(n_dim+1  ) = f_r; 
            delta(n_dim+1) = delta_r;
        %elseif ( f_r < f(1) )        %       Test for possible expansion.
        elseif ( ~rand_compara(f(1),f_r,delta(1),delta_r) ) 
            x_e = ( 1 + rho * xi ) * x_bar - rho * xi   * x(n_dim+1,:);
            [f_e,delta_e] = feval(function_handle,x_e); 
            n_feval = n_feval+1;
            % Yulin Wu
            x_trace = [x_trace;x_e]; 
            y_trace = [y_trace,f_e];
            if plotTrace
                [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
            end
            %if ( f_e < f_r )  %  Can we accept the expanded point?
            if(rand_compara(f_e,f_r,delta_e,delta_r))
                x(n_dim+1,:) = x_e;
                f(n_dim+1  ) = f_e;
                delta(n_dim+1  ) = delta_e; 
            else
                x(n_dim+1,:) = x_r;
                f(n_dim+1  ) = f_r;
                delta(n_dim+1  ) = delta_r; 
            end
        %elseif ( f(n_dim) <= f_r && f_r < f(n_dim+1) )%  Outside contraction.
        elseif ( rand_compara(f(n_dim),f_r,delta(n_dim),delta_r)&& rand_compara(f_r,f(n_dim+1),delta_r,delta(n_dim+1)) )
            x_c = (1+rho*gam)*x_bar - rho*gam*x(n_dim+1,:);
            [f_c,delta_c ]= feval(function_handle,x_c);
            x_trace = [x_trace;x_c]; 
            y_trace = [y_trace,f_c];
            if plotTrace
                [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
            end
            %if (f_c <= f_r) % accept the contracted point
            if (rand_compara(f_c,f_r,delta_c,delta_r))
                x(n_dim+1,:) = x_c;
                f(n_dim+1  ) = f_c;
                delta(n_dim+1  ) = delta_c; 
            else
                [x,f,delta] = shrink(x,function_handle,sig);
                n_feval = n_feval+n_dim;
                [ f_, index_ ] = rand_sort ( f ,delta);
                x_ = x(index_,:);
                delta_=delta(index);
                x_trace = [x_trace;x_(1,:)]; 
                y_trace = [y_trace,f_(1)];
                if plotTrace
                    [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
                end
            end
        else%  Try an inside contraction.
            x_c = ( 1 - gam ) * x_bar + gam   * x(n_dim+1,:);
            [f_c,delta_c] = feval(function_handle,x_c); 
            n_feval = n_feval+1;
            %if (f_c < f(n_dim+1)) %  Can we accept the contracted point?
            if (rand_compara(f_c,f(n_dim+1),delta_c,delta(n_dim+1))) 
                x(n_dim+1,:) = x_c;
                f(n_dim+1  ) = f_c;
                delta(n_dim+1  ) = delta_c; 
                x_trace = [x_trace;x_c]; 
                y_trace = [y_trace,f_c];
                if plotTrace
                    [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
                end
            else
                [x,f,delta] = shrink(x,function_handle,sig); n_feval = n_feval+n_dim;
                [ f_, index_ ] = rand_sort ( f,delta );
                x_ = x(index_,:);
                delta_=delta(index_);
                x_trace = [x_trace;x_(1,:)]; 
                y_trace = [y_trace,f_(1)];
                if plotTrace
                    [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs);
                end       
            end
        end
    %  Resort the points.  Note that we are not implementing the usual
    %  Nelder-Mead tie-breaking rules  (when f(1) = f(2) or f(n_dim) =
    %  f(n_dim+1)...
        [ f, index ] = rand_sort ( f,delta );
        x = x(index,:);
        delta = delta(index);
        %view_process(x);
        V=det(x(2:end,:)-x(1,:));
        if(length(tolX)==1)
            V_th=tolX^n_dim;
        else
            V_th=1;
            for kk=1:n_dim
                V_th=V_th*tolX(kk);
            end
        end
        % convergence smaller than tolerance, break, Yulin Wu
        %if all(range(x) - tolX < 0)
        if(abs(V)<abs(V_th))
            if isgraphics(traces(n_dim+1))
                title(axs(n_dim+1),[num2str(n_feval),'th evaluation, optimization terminate: X tolerance reached.'])
            end
            converged_X=true;
        else
            converged_X=false;
        end
        converged_Y = (f(n_dim+1)-f(1) < tolerance)||(f(n_dim+1)-f(1)<mean(delta));%Test for convergence
        if converged_Y && isgraphics(traces(n_dim+1))
            title(axs(n_dim+1),[num2str(n_feval),'th evaluation, optimization terminate: Y tolerance reached.'])
        end  
        converged=converged_Y||converged_X;
        diverged = ( max_feval < n_feval );%  Test for divergence
        if(converged_X)
            sig = 1.0; 
            gam=1.0;
        else
            sig = 0.5;
            gam=0.5;
        end
    end
    x_opt = x(1,:);
    if ( diverged )
        fprintf ( 1, '\n' );
        fprintf ( 1, 'NELDER_MEAD - Warning!\n' );
        fprintf ( 1, '  The maximum number of function evaluations was exceeded\n')
        fprintf ( 1, '  without convergence being achieved.\n' );
    end
end

function [traces,axs]=plot_date(n_dim,y_trace,x_trace,traces,n_feval,axs)
    for ww = 1:n_dim
        if isgraphics(traces(ww))
            set(traces(ww),'XData',1:length(y_trace),'YData',x_trace(:,ww));
            xlabel(axs(ww),num2str(x_trace(end,ww),'%0.4e'));
        end
    end
    if isgraphics(traces(n_dim+1))
        set(traces(n_dim+1),'XData',1:length(y_trace),'YData',y_trace);
        title(axs(n_dim+1),[num2str(n_feval),'th evaluation, outside contraction.'])
    end
    drawnow;
end

function [f,delta ]= evaluate ( x, function_handle )
% EVALUATE handles the evaluation of the function at each point.
%  Parameters:
%    Input, real X(N_DIM+1,N_DIM), the points.
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure to evaluate the function.
%    Output, real F(1,NDIM+1), the value of the function at each point.
    n_dim = size ( x,2 );
    f = zeros ( 1, n_dim+1 );  
    delta = zeros (1, n_dim+1);
    for i = 1 : n_dim + 1
        [f(i),delta(i) ]= feval(function_handle,x(i,:));
    end
end

function [ x, f, delta ] = shrink ( x, function_handle, sig )
% SHRINK shrinks the simplex towards the best point.
    n_dim = size ( x,2 );
    f=zeros(1,n_dim+1);
    delta=zeros(1,n_dim+1);
    x1 = x(1,:);
    [f(1),delta(1)] = feval ( function_handle, x1 );
    for ii = 2 : n_dim + 1
        x(ii,:) = sig * x(ii,:) + ( 1.0 - sig ) * x(1,:);
        [f(ii),delta(ii)] = feval ( function_handle, x(ii,:) );
    end
end

function [is_val1_smaller]=rand_compara(val1,val2,delta1,delta2)
%比较两个带有噪声的数，val1，val2时测量值，delta1，delta2是对应的测量偏差，
%假设噪声模型是高斯噪声
delta_eff=sqrt(delta1^2+delta2^2);
if(delta_eff<=0)
    is_val1_smaller=val1<val2;
else
    P=(erf((val2-val1)/delta_eff/sqrt(2))+1)/2;
    is_val1_smaller=(rand()<P);
end
end

function [f,index]=rand_sort(f,delta)
%考虑偏差为delta的高斯噪声后的随机排序
N=length(f);
f_rand=zeros(1,N);
for ii=1:N
    f_rand(ii)=f(ii)+erfinv(rand()*2-1)*delta(ii)*sqrt(2);
end
[~,index]=sort(f_rand);
f=f(index);
end
