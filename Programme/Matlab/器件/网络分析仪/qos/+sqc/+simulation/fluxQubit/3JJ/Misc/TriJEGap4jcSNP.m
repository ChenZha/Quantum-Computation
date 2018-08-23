function TriJEGap4jcSNP(jc,c,S,alpha,varargin)
% TriJEGapNP is the non parallel computing version of function TriJEGap4jcS.
% TriJEGap plots the three-junction flux qubit energy gap - energy difference
% between the lowest two (four actually) energy levels at the symmetric flux
% bias point (0.5 flux quantum) for diffrent junction area sizes (S) and 
% different jc values. See ref.
% jc: critical current density, unit: muA/mum^2
% c: junction capacitance per mu^2, unit: F/mum^2
% S: junction area of the bigger junctions(area of one junction), unit: mu^2
% S must be an array !
% alpha: s/S, s is the junction area of the small junction.
% beta: beta_Q in  ref.
% Ref.: Robertson et al., Phys. Rev. Letts. B 73, 174526 (2006).
% example:
% TriJEGap4jcSNP(jc,c,S,alpha,beta)
% Author: Yulin Wu <mail2ywu@gmail.com>
% Date: 2011/5/3
clc;
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
beta = 0;
if nargin > 4
    beta = varargin{1};
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
                disp('This calculation will continue the unfinished caculationn job.');
                disp('If you want to do a fresh calculation, delete the following file(or move it to another location):');
                disp(OutputDataName);
            else
                disp('Calculation for the present set of paramenters has been done before.');
                disp('Energy level diagram will be ploted directly by loading the saved data file.')
                disp('If you want to do a fresh calculation, delete the following file(or move it to another location):');
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
    tic;
    disp('Calculation start ... ...');
    hh0=hh-1;
    while hh <=NN
        Ej = 10*S*jc(hh)*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
        Ec = ee^2./(2*S*c*1e-15)/PlanksConst/1e9;   % Unit: GHz.
        for ii = 1:length(S)
            EL = TriJFlxQbtEL(Ej(ii),Ec(ii),alpha,beta,0,0,0.5,5,10,2,4);
            Gap(ii) = (EL(3) + EL(4) - EL(2) -EL(1))/2;
        end
        EGap(hh,:) = Gap;
        toc;
        time = toc/60;
        timeremaining = time*(NN-hh)/(hh-hh0);
        clc;
        disp(['Time elapsed: ', num2str(time)]);
        disp(['Estimated time remaining: ', num2str(timeremaining)]);
        hh = hh+1;
        save(OutputDataName,'jc','S','hh','EGap');
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
    h(hh) = plot(S,EGap(hh,:),'Color',COLOR(hh,:));
    s{hh} = sprintf('jc:%g', jc(hh));
end
legend(h(x), s{x});
xlabel('Junction Area (\mum^2)');
ylabel('\Delta (GHz)');
title(['J_c: *\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \alpha:',num2str(alpha), ';  \beta:', num2str(beta)]);
