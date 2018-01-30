function [  ] = TriJJFluxQubitELFitting( )
%TRIJJFLUXQUBITELFITTING Summary of this function goes here
%   Detailed explanation goes here

data = [
59.5654	7.84452
67.087	7.54417
74.6076	7.23498
78.9012	7.02297
83.1968	6.82862
87.4905	6.61661
91.7784	6.35159
94.9949	6.15724
99.2799	5.86572
103.035	5.66254
107.856	5.33569
113.224	5.07951
118.047	4.77032
121.264	4.58481
124.489	4.46996
137.433	4.41696
140.14	4.5053
142.847	4.58481
143.935	4.67314
147.2	4.92049
154.247	5.22968
160.771	5.68021
167.286	6.05124
173.258	6.39576
180.852	6.76678
185.193	6.99647
192.24	7.29682
196.575	7.46466
201.998	7.72085
234.493	8.84276
243.146	9.02827
251.264	9.24912
258.837	9.4258
266.95	9.61131
272.357	9.71731
279.385	9.84099
285.332	9.947];

%   func,c0,xdata,ydata,errFunc,step0,minStep,maxNumofSteps,options
func = @ELFunc;
errFunc = @ErrFunc1;

Ej0 = 54.5025000000000; % GHz
Ec0 = 9.18510000000000; % GHz
alpha0 = 0.325000000000000;
beta0 = 0;
kappa0 = 0;
sigma0 = 25.5;
c0 = [Ej0,Ec0,alpha0,beta0,kappa0,sigma0];

bias0 = 100;
xdata = {(data(:,1)+bias0)*0.5/(131.88+bias0)};
ydata = {data(:,2)};

EjStep0 = 5; % GHz
EcStep0 = 0.2; % GHz
alphaStep0 = 0.025;
betaStep0 = 0;
kappaStep0 = 0;
sigmaStep0 = 0.5;
step0 = [EjStep0,EcStep0,alphaStep0,betaStep0,kappaStep0,sigmaStep0];

EjMinStep = 0.1; % GHz
EcMinStep = 0.01; % GHz
alphaMinStep = 0.0005;
betaMinStep = 1;
kappaMinStep = 1;
sigmaMinStep = 0.01;
minStep = [EjMinStep,EcMinStep,alphaMinStep,betaMinStep,kappaMinStep,sigmaMinStep];

maxNumofSteps = 1000;

[FileName,PathName] = GetSaveFileName();
options = struct('display',true,'saved',true,'filename',FileName,'pathname',PathName);
if FileName ~=0
    [ cs,fittingdatas,errs,step,finished ] =...
        StepFitting(func,c0,xdata,ydata,errFunc,step0,minStep,maxNumofSteps,options);    
    save([PathName FileName '.mat'],'cs','fittingdatas',...
        'errs','step','finished','xdata','ydata');
end

end

function [FileName,PathName] = GetSaveFileName()
FilterSpec = {'*.mat;*.fig;*.png','*.mat;*.fig;*.png'};
DialogTitle = 'Save data as';
DefaultName = 'Default.mat';
[fileName,pathName,FilterIndex] = uiputfile(FilterSpec,DialogTitle,DefaultName);
if fileName == 0
    FileName = fileName;
    PathName = pathName;
else
    [pathstr,name,ext]= fileparts(fileName);
    PathName = pathName;
    FileName = name;
end
end
