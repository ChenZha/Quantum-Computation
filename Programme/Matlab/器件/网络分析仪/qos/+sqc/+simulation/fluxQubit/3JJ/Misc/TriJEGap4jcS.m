function TriJEGap4jcS(jc,c,S,alpha,varargin)
% TriJEGap plots the three-junction flux qubit energy gap - energy difference
% between the lowest two (four actually) energy levels at the symmetric flux
% bias point (0.5 flux quantum) for diffrent junction area sizes (S) and 
% different jc values. See ref.
% example:
% TriJEGap4jcS(jc,c,S,alpha,beta)
%
% jc: critical current density, unit: muA/mum^2
% jc can be an array.
% c: junction capacitance per mu^2, unit: fF/mum^2
% S: junction area of the bigger junctions(area of one junction), unit: mum^2
% S must be an array !
% alpha: s/S, s is the junction area of the small junction.
% beta: beta_Q in ref.,=(2*pi*L_qubit/Phi_0)*alpha*Ic_bigjunction/(1+2*alpha);
% alpha = 0.76,=L_qubit*Ic_bigjunction*9.15e14¡Ö1e15*L*Ic,
% L£º1nH ¡ú 0.45£¬L<<1nH in flux qubit.
% Ref.: Robertson et al., Phys. Rev. Letts. B 73, 174526 (2006).
%
% Calculation can work in a BREAK and CONTINUE mode. You can exit the 
% calculation when it has not been finished and restart the programme
% next time with the same parameters, the calculation will continue 
% from the break point.
% This function has a subfunction: 'TriJFlxQbtEL.m'.
%
% Author: Yulin Wu <mail2ywu@gmail.com>
% Date: 2011/5/3
clc;
NMatlabpools = 1; 
% NMatlabpools = 2; 
% NMatlabpools = 4; 
% NMatlabpools = 8; 
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
beta = 0;
if nargin > 4
    beta = varargin{1};
end
if beta < 0
    beta =0;
    disp('Warnning: beta < 0 ! beta will be set to 0 !');
    disp('Beta value has been set to 0 !');
end
if beta == 0
    nm = 1;
elseif beta < 0.05
    nm = 2;
elseif beta <0.1
    nm = 3;
elseif beta <0.2
    nm = 4;
else
    nm = 6;
    disp('Warnning: beta value too big !');
end
if length(S)<2
    error('S is not an array, impossible to plot a curve !')
end
tmp1 = jc;
tmp2 = S;
NN = length(jc);
MM = length(S);
OutputDataName=['Data\3JJQbtEGap-c' num2str(c) 'alpha' num2str(alpha) 'beta' num2str(beta), '_'];
if isempty(dir('Data'))
    mkdir('Data');
end
fid = dir([OutputDataName, '*.mat']);
flag = 0;
if ~isempty(fid)
    for kk = 1:length(fid)
        filename = ['Data\', fid(kk).name];
        load(filename);
        if NN==length(jc) && MM==length(S) && sum(tmp1==jc)==length(tmp1) && sum(tmp2==S)==length(tmp2)
            flag = 1;
            OutputDataName = filename;
            if hh <= NN
                disp('A previous calculation for the present set of paramenters has been carried out but not finished.');
                disp('This calculation will continue the unfinished caculation job.');
                disp('If you want to do a new calculation, delete the following file(or move it to another location):');
                disp(OutputDataName);
            else
                disp('Calculation for the present set of paramenters has been done before.');
                disp('Energy level diagram will be ploted directly by loading the saved data file.')
                disp('If you want to do a new calculation, delete the following file(or move it to another location):');
                disp(OutputDataName);
                flag =2;
            end
            break;
        end
    end
end
if flag == 0
   jc = tmp1;
   S = tmp2;
   hh = 1;
   EGap = zeros(NN,MM);
   OutputDataName = [OutputDataName, num2str(int32(1e5*rand())) '.mat'];
end
if flag ~= 2
    if NMatlabpools > 1        % Start parallel language worker pool
        matlabpool(NMatlabpools);
    end
    disp('Calculation start ... ...');
    tic;
    hh0=hh-1;
    while hh <=NN
        Ej = 10*S*jc(hh)*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
        Ec = ee^2./(2*S*c*1e-15)/PlanksConst/1e9;   % Unit: GHz.
        L = length(S);
        for ii = 1:L
            if Ej(ii)/Ec(ii) > 400
                nk(ii) = 15;
                nl(ii) = 25;
            elseif Ej(ii)/Ec(ii) > 200
                nk(ii) = 10;
                nl(ii) = 20;
            elseif Ej(ii)/Ec(ii) > 100 || Ej(ii)/Ec(ii) < 5
                nk(ii) = 8;
                nl(ii) = 15;
            else
                nk(ii) = 5;
                nl(ii) = 10;
            end
        end
        Gap = zeros(1,L);
        parfor ii = 1:L
            EL = TriJFlxQbtEL(Ej(ii),Ec(ii),alpha,beta,0,0,0.5,nk(ii),nl(ii),nm,4);
            Gap(ii) = (EL(3) + EL(4) - EL(2) -EL(1))/2;
        end
        EGap(hh,:) = Gap;
        toc;
        time = toc/60;
        timeremaining = time*(NN-hh)/(hh-hh0);
        clc;
        disp(['Time elapsed: ', num2str(time)]);
        disp(['Estimated time remaining: ', num2str(timeremaining)]);
        disp('Calculation can work in a BREAK and CONTINUE mode. You can exit the calculation when it has not');
        disp('been finished and restart the programme next time with the same parameters, the calculation');
        disp('will continue from the break point.');
        hh = hh+1;
        save(OutputDataName,'jc','S','hh','EGap');
    end
    if NMatlabpools > 1
        matlabpool close; 
    end
end
figure(int32(1e5*rand()));
YMAX = max(max(EGap));
if YMAX > 25
    YMAX = 25;
end
axis([min(S),max(S),0,YMAX]);
hold on;
Ncurves = NN;
COLOR = colormap(jet(Ncurves));
x = 1:Ncurves;
for hh = x
    h(hh) = plot(S,EGap(hh,:),'Color',COLOR(hh,:),'LineWidth',2);
    s{hh} = sprintf('jc:%g', jc(hh));
    hold on;
end
legend(h(x), s{x});
xlabel('Junction Area (\mum^2)');
ylabel('\Delta (GHz)');
set(gca,'ytick',0:0.5:YMAX);
grid on;
title(['J_c: *\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \alpha:',num2str(alpha), ';  \beta:', num2str(beta)]);



