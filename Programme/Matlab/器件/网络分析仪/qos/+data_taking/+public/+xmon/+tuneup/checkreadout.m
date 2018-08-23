function [F,theta]=checkreadout(qc,qt)
% [F,theta] = data_taking.public.xmon.tuneup.checkreadout(qc,qt);

sqc.util.setQSettings('r_avg',3000);
result = data_taking.public.xmon.Tomo_2QState('qubit1',qc,'qubit2',qt,...
    'state','++',...
    'notes','','gui',true,'save',false);
drawnow;
temp=nan(1,9,4);
temp(1,:,:)=result;
set_fit=struct ();
set_fit.is_fit=1;
set_fit.tolX=0;
set_fit.tolY=1e-7;%P的标准差
set_fit.max_feval=1e5;
rho = stateTomoData2Rho(result,set_fit);
rho_single=0.5*[1 1;1 1];
rho2=kron(rho_single,rho_single);
[F,theta] = fidelity(rho,rho2);
disp(F)

end
function rho = stateTomoData2Rho(data,set_fit)
% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:I},... ,{q2:Z q1:Z}
%       X（Y）指把X（Y）翻转到Z轴，实际操作的矩阵是Y（X）
% colomn: P|00>,|01>,|10>,|11>
% qubit labeled as: |qubits{2},qubits{1}>
% in case of 2Q data(3,2): {qubits{2}:X qubits{1}:I} P|01> (|qubits{2},qubits{1}>)

    I = [1,0;0,1];
    sigma(:,:,1) = [0,1;1,0];
    sigma(:,:,2) = [0,-1i;1i,0];
    sigma(:,:,3) = [1,0;0,-1];
    
    single_mesure_matrix(:,:,1) = sigma(:,:,1);
    single_mesure_matrix(:,:,2) = sigma(:,:,2);
    single_mesure_matrix(:,:,3) = sigma(:,:,3);
    single_mesure_matrix(:,:,4) = I;
    
%single_trans_matrix(:,:,1)=expm(1j*(pi/4)*sigma(:,:,2));
%single_trans_matrix(:,:,2)=expm(-1j*(pi/4)*sigma(:,:,1));
%single_trans_matrix(:,:,3)=I;
%single_trans_matrix(:,:,4)=I;
    %X2p = expm(-1j*(pi/2)*sigmax/2);
    %X2m = expm(-1j*(-pi/2)*sigmax/2);
    %Y2p = expm(-1j*(pi/2)*sigmay/2);
    %Y2m = expm(-1j*(-pi/2)*sigmay/2);
    
    %求拉直化的U矩阵
    numQs = 2;
    U=zeros(2^(2*numQs),4^numQs);
    for ii=1:4^numQs
        Measure_matrix=1;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:numQs
            Measure_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_matrix(jj)),Measure_matrix);
        end
        for jj=1:2^numQs
            U((jj-1)*2^numQs+1:(jj)*2^numQs,ii)=Measure_matrix(:,jj);
        end
    end
    
    %根据U矩阵中的测量基矢选择方式生成对应的期望（拉直化的P）
    p_order_index=zeros(1,4^numQs);
    for ii=1:4^numQs
        p_order_index(ii)=0;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:2^numQs
            qubit_base_index_p=transform_index_fun(numQs,jj,2);
            factor=1;
            ii_trans=1;
            qubit_base_index_matrix_test=zeros(1,numQs);
            for kk=1:numQs
                if(qubit_base_index_matrix(kk)==4)
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk)-1;
                else
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk);
                    factor=factor*(-2*qubit_base_index_p(kk)+3);                    
                end
                ii_trans=ii_trans+3^(kk-1)*(qubit_base_index_matrix_test(kk)-1);
            end
            p_order_index(ii)=p_order_index(ii)+factor*data(ii_trans,jj);
        end 
    end
    
    %求拉直化的rho并将它矩阵化
    rho0=p_order_index/U;
    rho=zeros(2^numQs,2^numQs);
    for ii=1:2^numQs
        rho(ii,:)=rho0((ii-1)*2^numQs+1:ii*2^numQs);
    end
    if(set_fit.is_fit)
        [rho_opt]=fit_rho(rho,data,set_fit) ;
        rho=rho_opt;
    end
end

function [rho]=x2rho(x,numQs,V_pure_state)

P_pure_state=zeros(0,2^numQs);
%边界与归一处理
for ii=1:2^numQs-1
    P_pure_state(ii)=max(0,x(ii));    
end
P_pure_state(2^numQs)=max(1-sum(P_pure_state),0);
P_pure_state=P_pure_state/sum(P_pure_state);

rotate_value=zeros(1,length(x)-2^numQs+1);
for nn=1:length(rotate_value)
    rotate_value(nn)=x(2^numQs-1+ii);
end
nn=0;
rotate_matrix_all=V_pure_state;
for ii=2:2^numQs
    for jj=1:ii-1
        nn=nn+2;
        R_rotate=rotate_value(nn-1)+1i*rotate_value(nn);
        delta_matrix=eye(2^numQs);
        delta_matrix(ii,jj)=R_rotate;
        delta_matrix(jj,ii)=-R_rotate';
        delta_matrix(ii,ii)=sqrt(1-abs(R_rotate)^2);
        delta_matrix(jj,jj)=sqrt(1-abs(R_rotate)^2);
    end
    rotate_matrix_all=rotate_matrix_all*delta_matrix;
end

rho=rotate_matrix_all*diag(P_pure_state)*rotate_matrix_all';

end
function distance=x2distance(x,numQs,V_pure_state,data)
    [rho]=x2rho(x,numQs,V_pure_state);
    [P] = rho2p(rho);
    distance=sqrt((sum(sum((P-data).^2)))/(size(P(:),1)));    
end
function distance=x2distance_chi(x,numQs,V_pure_state,data,bata_order_index,rho_order_index)
    [chi]=x2rho(x,numQs,V_pure_state);
    [P,~]=chi2p(chi,bata_order_index,rho_order_index);
    distance=sqrt((sum(sum(sum((P-data).^2))))/(size(P(:),1)));   
end
function [F,theta] = fidelity(rho1,rho2)
Pideal = rho2p(rho2);
[theta] = thetafit(rho1,Pideal);
[pr] = rotatep(rho1,theta,1);
pr=reshape(pr,[9,4]);
set_fit=struct ();
set_fit.is_fit=0;
set_fit.tolX=0;
set_fit.tolY=1e-7;%P的标准差
set_fit.max_feval=1e5; 
rho = stateTomoData2Rho(pr,set_fit);

m = rho*rho2;
F = trace(m);
F = sqrt(real(F));
end
function [rho_opt]=fit_rho(rho,data,set_fit)

numQs = round(log(size(rho,2))/log(2));
[eigenstate,eigenvalue]=eig(rho);

%边界与归一处理

%%%%%%%%%%%%%%%%%%%%%%%%%%保留主要项方式选初始点
P_pure_state=zeros(1,2^numQs);
%主要项
P_pure_state(1)=min(real(eigenvalue(1,1)),1); 
%误差项
for ii=2:2^numQs
    P_pure_state(ii)=max(0,real(eigenvalue(ii,ii)));    
end
P_pure_state(2:2^numQs)=(1-P_pure_state(1))*P_pure_state(2:2^numQs)/sum(P_pure_state(2:2^numQs));

% %%%%%%%%%%%%%%%%%%%%%%%%%%非保留主要项方式选初始点
% P_pure_state=zeros(1,2^numQs);
% for ii=1:2^numQs
%     P_pure_state(ii)=max(0,real(eigenvalue(ii,ii)));    
% end
% P_pure_state=P_pure_state/sum(P_pure_state);


V_pure_state=eigenstate;

if (length(size(data))==2)
    fprintf('正在优化 statetomo\n')
    function_handle=@(x)x2distance(x,numQs,V_pure_state,data);
    x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
    x0=[x_center;x_center+0.01*eye(length(x_center))];
%     options = optimset('TolFun',1e-5,'TolX',1e-5,'MaxIter',100,'MaxFunEvals',200);
%     [X,FVAL,EXITFLAG,OUTPUT] = fminsearch
    [ x_opt, x_trace, y_trace, n_feval] = qes.util.NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
else
    fprintf('正在优化 processtomo\n')
    [bata_order_index,rho_order_index]=calculate_bata(round(numQs/2));
    function_handle=@(x)x2distance_chi(x,numQs,V_pure_state,data,bata_order_index,rho_order_index);
    x_center=[P_pure_state(1:2^numQs-1),zeros(1,round((2^numQs-1)*(2^numQs)))];
    x0=[x_center;x_center+0.01*eye(length(x_center))];
    [ x_opt, x_trace, y_trace, n_feval] = NelderMead (function_handle, x0, set_fit.tolX, set_fit.tolY, set_fit.max_feval);
    
    %%for test
    figure(200);
    clf;
    plot(1:length(y_trace),y_trace);
    xlabel('n feval')
    ylabel('delta(P_s_i_m-data)')
    title('y trace')

    [m,n]=size(x_trace);
    figure(201);
    clf;
    hold on;
    for ii=1:2^numQs-1
        plot(1:m,x_trace(:,ii))
    end
    plot(1:m,1-x_trace(:,1)-x_trace(:,2)-x_trace(:,3))
    xlabel('n feval')
    ylabel('eigen value')
    title('x trace1')
    figure(202);
    clf;
    hold on;
    for ii=2^numQs:n
        plot(1:m,x_trace(:,ii))
    end
    xlabel('n feval')
    ylabel('rotate angle')
    title('x trace2')
    figure(200)
    %%for test
end

[rho_opt]=x2rho(x_opt,numQs,V_pure_state);



end
function qubit_base_index=transform_index_fun(numQs,order_index,count_unit)
%用于下表转化（算法实质类似进制转换）
%order_index：是拉直化坐标
%numQs：新下标个数
%count_unit：新下标进制
%qubit_base_index：新下标（基于比特）的坐标
   old_index=order_index-1;
   qubit_base_index=NaN(1,numQs);
   for ii=1:numQs
       qubit_base_index(ii)=mod(old_index,count_unit)+1;
       old_index=fix(old_index/count_unit);
   end
end
function [P] = rho2p(rho)
% single_mesure_matrix(:,:,1) = [0 1;1 0];
% single_mesure_matrix(:,:,2) = [0 -1i;1i 0];
% single_mesure_matrix(:,:,3) = [1 0;0 -1];
numQs = round(log(size(rho,2))/log(2));
X = [0,1;1,0];
Y = [0, -1i; 1i,0];
I = [1,0;0,1];
Y2m = expm(-1i*(-pi)*Y/4);
X2p = expm(-1i*pi*X/4);
TomoGateSet = {Y2m,X2p,I};
P=zeros(3^numQs,2^numQs);
for ii=1:3^numQs
    qubit_base_index=transform_index_fun(numQs,ii,3);
    u_ii=1;
    for kk=1:numQs
        u_ii=kron(TomoGateSet{qubit_base_index(kk)},u_ii);
    end
    rho_ii=u_ii*rho*u_ii';
    for jj=1:2^numQs
        P(ii,jj)=rho_ii(jj,jj);
    end
    P=abs(P);
end
end
function [theta] = thetafit(statetomo_rho_prime,pid)
    function y = fitFunc(statetomo_rho_prime,pid,theta,sz)
        pe = rotatep(statetomo_rho_prime,theta,sz);
        pe=reshape(pe,[9,4]);
        D = (pe - pid).^2;
        y = sum(D(:));
    end
    numQs = round(log(size(statetomo_rho_prime,2))/log(2));
    sz=1;
    %theta = qes.util.fminsearchbnd(@(theta)fitFunc(statetomo_rho_prime,pid,theta,sz),zeros(1,numQs),-ones(1,numQs)*2*pi,ones(1,numQs)*2*pi);
    theta = fminsearchbnd(@(theta)fitFunc(statetomo_rho_prime,pid,theta,sz),zeros(1,numQs),-ones(1,numQs)*2*pi,ones(1,numQs)*2*pi);
end
function fval = intrafun(x,params)
% transform variables, then call original function

% transform
xtrans = xtransform(x,params);

% and call fun
fval = feval(params.fun,reshape(xtrans,params.xsize),params.args{:});

end % sub function intrafun end
function xtrans = xtransform(x,params)
% converts unconstrained variables into their original domains

xtrans = zeros(params.xsize);
% k allows some variables to be fixed, thus dropped from the
% optimization.
k=1;
for i = 1:params.n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      xtrans(i) = params.LB(i) + x(k).^2;
      
      k=k+1;
    case 2
      % upper bound only
      xtrans(i) = params.UB(i) - x(k).^2;
      
      k=k+1;
    case 3
      % lower and upper bounds
      xtrans(i) = (sin(x(k))+1)/2;
      xtrans(i) = xtrans(i)*(params.UB(i) - params.LB(i)) + params.LB(i);
      % just in case of any floating point problems
      xtrans(i) = max(params.LB(i),min(params.UB(i),xtrans(i)));
      
      k=k+1;
    case 4
      % fixed variable, bounds are equal, set it at either bound
      xtrans(i) = params.LB(i);
    case 0
      % unconstrained variable.
      xtrans(i) = x(k);
      
      k=k+1;
  end
end

end % sub function xtransform end
function xtrans = tolxtransform(tolx,params)
% by Yulin Wu
switch params.BoundClass(1)
case {1,2}
  % lower/upper bound only
  xtrans = tolx^2;
case 3
  % lower and upper bounds
  xtrans = sin(abs(tolx));
otherwise
  xtrans = abs(tolx);
end

end
function f = evaluate ( x, function_handle )

%*****************************************************************************80
%
% EVALUATE handles the evaluation of the function at each point.
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
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%
  [ temp, n_dim ] = size ( x );

  f = zeros ( 1, n_dim+1 );
  
  for i = 1 : n_dim + 1
    f(i) = feval(function_handle,x(i,:));
  end

  return
end
function [ x, f ] = shrink ( x, function_handle, sig )

%*****************************************************************************80
%
% SHRINK shrinks the simplex towards the best point.
%
%  Discussion:
%
%    In the worst case, we need to shrink the simplex along each edge towards
%    the current "best" point.  This is quite expensive, requiring n_dim new
%    function evaluations.
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
%    Input, real X(N_DIM+1,N_DIM), the points.
%
%    Input, real FUNCTION_HANDLE ( X ), the handle of a MATLAB procedure
%    to evaluate the function.
%
%    Input, real SIG, ?
%
%    Output, real X(N_DIM+1,N_DIM), the points after shrinking was applied.
%
%    Output, real F(1,NDIM+1), the value of the function at each point.
%
  [ temp, n_dim ] = size ( x );

  x1 = x(1,:);
  f(1) = feval ( function_handle, x1 );

  for i = 2 : n_dim + 1
    x(i,:) = sig * x(i,:) + ( 1.0 - sig ) * x(1,:);
    f(i) = feval ( function_handle, x(i,:) );
  end
  
  return
end
function [x,fval,exitflag,output] = fminsearchbnd(fun,x0,LB,UB,options,varargin)
% FMINSEARCHBND: FMINSEARCH, but with bound constraints by transformation
% usage: x=FMINSEARCHBND(fun,x0)
% usage: x=FMINSEARCHBND(fun,x0,LB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options)
% usage: x=FMINSEARCHBND(fun,x0,LB,UB,options,p1,p2,...)
% usage: [x,fval,exitflag,output]=FMINSEARCHBND(fun,x0,...)
% 
% arguments:
%  fun, x0, options - see the help for FMINSEARCH
%
%  LB - lower bound vector or array, must be the same size as x0
%
%       If no lower bounds exist for one of the variables, then
%       supply -inf for that variable.
%
%       If no lower bounds at all, then LB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
%  UB - upper bound vector or array, must be the same size as x0
%
%       If no upper bounds exist for one of the variables, then
%       supply +inf for that variable.
%
%       If no upper bounds at all, then UB may be left empty.
%
%       Variables may be fixed in value by setting the corresponding
%       lower and upper bounds to exactly the same value.
%
% Notes:
%
%  If options is supplied, then TolX will apply to the transformed
%  variables. All other FMINSEARCH parameters should be unaffected.
%
%  Variables which are constrained by both a lower and an upper
%  bound will use a sin transformation. Those constrained by
%  only a lower or an upper bound will use a quadratic
%  transformation, and unconstrained variables will be left alone.
%
%  Variables may be fixed by setting their respective bounds equal.
%  In this case, the problem will be reduced in size for FMINSEARCH.
%
%  The bounds are inclusive inequalities, which admit the
%  boundary values themselves, but will not permit ANY function
%  evaluations outside the bounds. These constraints are strictly
%  followed.
%
%  If your problem has an EXCLUSIVE (strict) constraint which will
%  not admit evaluation at the bound itself, then you must provide
%  a slightly offset bound. An example of this is a function which
%  contains the log of one of its parameters. If you constrain the
%  variable to have a lower bound of zero, then FMINSEARCHBND may
%  try to evaluate the function exactly at zero.
%
%
% Example usage:
% rosen = @(x) (1-x(1)).^2 + 105*(x(2)-x(1).^2).^2;
%
% fminsearch(rosen,[3 3])     % unconstrained
% ans =
%    1.0000    1.0000
%
% fminsearchbnd(rosen,[3 3],[2 2],[])     % constrained
% ans =
%    2.0000    4.0000
%
% See test_main.m for other examples of use.
%
%
% See also: fminsearch, fminspleas
%
%
% Author: John D'Errico
% E-mail: woodchips@rochester.rr.com
% Release: 4
% Release date: 7/23/06

% size checks
xsize = size(x0);
x0 = x0(:);
n=length(x0);

if (nargin<3) || isempty(LB)
  LB = repmat(-inf,n,1);
else
  LB = LB(:);
end
if (nargin<4) || isempty(UB)
  UB = repmat(inf,n,1);
else
  UB = UB(:);
end

if (n~=length(LB)) || (n~=length(UB))
  error 'x0 is incompatible in size with either LB or UB.'
end

% set default options if necessary
if (nargin<5) || isempty(options)
  options = optimset('fminsearch');
end

% stuff into a struct to pass around
params.args = varargin;
params.LB = LB;
params.UB = UB;
params.fun = fun;
params.n = n;
% note that the number of parameters may actually vary if 
% a user has chosen to fix one or more parameters
params.xsize = xsize;
params.OutputFcn = [];

% 0 --> unconstrained variable
% 1 --> lower bound only
% 2 --> upper bound only
% 3 --> dual finite bounds
% 4 --> fixed variable
params.BoundClass = zeros(n,1);
for i=1:n
  k = isfinite(LB(i)) + 2*isfinite(UB(i));
  params.BoundClass(i) = k;
  if (k==3) && (LB(i)==UB(i))
    params.BoundClass(i) = 4;
  end
end

% transform starting values into their unconstrained
% surrogates. Check for infeasible starting guesses.
x0u = x0;
k=1;
for i = 1:n
  switch params.BoundClass(i)
    case 1
      % lower bound only
      if x0(i)<=LB(i)
        % infeasible starting value. Use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(x0(i) - LB(i));
      end
      
      % increment k
      k=k+1;
    case 2
      % upper bound only
      if x0(i)>=UB(i)
        % infeasible starting value. use bound.
        x0u(k) = 0;
      else
        x0u(k) = sqrt(UB(i) - x0(i));
      end
      
      % increment k
      k=k+1;
    case 3
      % lower and upper bounds
      if x0(i)<=LB(i)
        % infeasible starting value
        x0u(k) = -pi/2;
      elseif x0(i)>=UB(i)
        % infeasible starting value
        x0u(k) = pi/2;
      else
        x0u(k) = 2*(x0(i) - LB(i))/(UB(i)-LB(i)) - 1;
        % shift by 2*pi to avoid problems at zero in fminsearch
        % otherwise, the initial simplex is vanishingly small
        x0u(k) = 2*pi+asin(max(-1,min(1,x0u(k))));
      end
      
      % increment k
      k=k+1;
    case 0
      % unconstrained variable. x0u(i) is set.
      x0u(k) = x0(i);
      
      % increment k
      k=k+1;
    case 4
      % fixed variable. drop it before fminsearch sees it.
      % k is not incremented for this variable.
  end
  
end
% if any of the unknowns were fixed, then we need to shorten
% x0u now.
if k<=n
  x0u(k:n) = [];
end

% were all the variables fixed?
if isempty(x0u)
  % All variables were fixed. quit immediately, setting the
  % appropriate parameters, then return.
  
  % undo the variable transformations into the original space
  x = xtransform(x0u,params);
  
  % final reshape
  x = reshape(x,xsize);
  
  % stuff fval with the final value
  fval = feval(params.fun,x,params.args{:});
  
  % fminsearchbnd was not called
  exitflag = 0;
  
  output.iterations = 0;
  output.funcCount = 1;
  output.algorithm = 'fminsearch';
  output.message = 'All variables were held fixed by the applied bounds';
  
  % return with no call at all to fminsearch
  return
end

% Check for an outputfcn. If there is any, then substitute my
% own wrapper function.
if ~isempty(options.OutputFcn)
  params.OutputFcn = options.OutputFcn;
  options.OutputFcn = @outfun_wrapper;
end

%%%%%%% % by Yulin Wu
if isfield(options,'TolX')
    options.TolX = tolxtransform(options.TolX,params);
end
%%%%%%%

% now we can call fminsearch, but with our own
% intra-objective function.
[xu,fval,exitflag,output] = fminsearch(@intrafun,x0u,options,params);

% undo the variable transformations into the original space
x = xtransform(xu,params);

% final reshape to make sure the result has the proper shape
x = reshape(x,xsize);

% Use a nested function as the OutputFcn wrapper
  function stop = outfun_wrapper(x,varargin)
    % we need to transform x first
    xtrans = xtransform(x,params);
    
    % then call the user supplied OutputFcn
    stop = params.OutputFcn(xtrans,varargin{1:(end-1)});
    
  end

end % mainline
function [pr] = rotatep(statetomo_rho_prime,theta,sz)
    Z = [1,0;0,-1];
    numQs = round(log(size(statetomo_rho_prime,2))/log(2));
    pr = NaN(sz,3^numQs,2^numQs);
    U=1;
    for ii=1:numQs
        U=kron(expm(-1i*theta(ii)*Z/2),U);
    end
    %U = kron(expm(-1i*theta2*Z/2),expm(-1i*theta1*Z/2));
        rho = statetomo_rho_prime(:,:);
        rho = U*rho*U';
        pr(1,:,:) = rho2p(rho);
    pr = real(pr);
end