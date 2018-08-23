% CZ bring up:
czQSets = {{'q1','q2'},...
    {'q3','q2'},...
    {'q3','q4'},...
    {'q5','q4'},...
    {'q5','q6'},...
    {'q7','q6'},...
    {'q7','q8'},...
    {'q9','q8'},...
    {'q9','q10'},...
    {'q11','q10'},...
    {'q11','q12'},...
    };
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
%%
setQSettings('r_avg',1000);
czLength=[]; % empty to load from registry
czQSet=czQSets{1};
cQ = czQSet{1};
tQ = czQSet{2};
preset=sqc.util.getQSettings(['g_cz.' cQ '_' tQ '.amp'],'shared');
czAmp=linspace(preset*0.5,preset*1.1,30); 
acz1=simu_acz_ampLength('controlQ',cQ,'targetQ',tQ,...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','1',...
       'notes','','gui',true,'save',true);
acz0=simu_acz_ampLength('controlQ',cQ,'targetQ',tQ,...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','0',...
       'notes','','gui',true,'save',true);
cz0data=unwrap(acz0.data{1,1});
cz1data=unwrap(acz1.data{1,1});
czAmp=acz0.sweepvals{1,2}{1,1};
dp = unwrap(cz1data - cz0data);
cz0data = cz0data/pi;
cz1data = cz1data/pi;
dp = dp/pi;
fdp = polyfit(czAmp,dp,2);
figure;plot(czAmp,cz0data,'.b',czAmp,cz1data,'.r',...
    czAmp,polyval(fdp,czAmp),'-g',czAmp,dp,'.-m',...
    czAmp,ones(1,length(czAmp)),':k',czAmp,-ones(1,length(czAmp)),':k');
fdp1=fdp;
fdp1(3)=fdp1(3)-1;
rd1=roots(fdp1);

fdp2=fdp;
fdp2(3)=fdp2(3)+1;
rd2=roots(fdp2);

if numel(rd1) == 1
    if ~isreal(rd1)
        rd1 = [];
    end
elseif numel(rd1) == 2
    rd1 = rd1([isreal(rd1(1)), isreal(rd1(2))]);
end
if numel(rd2) == 1
    if ~isreal(rd2)
        rd2 = [];
    end
elseif numel(rd2) == 2
    rd2 = rd2([isreal(rd2(1)), isreal(rd2(2))]);
end

ampBnd = minmax([czAmp(1),czAmp(end)]);
czamp1=rd1(find(rd1>ampBnd(1)&rd1<ampBnd(end)));
czamp2=rd2(find(rd2>ampBnd(1)&rd2<ampBnd(end)));

czppp=[czamp1,czamp2];
[~,lsso]=min(abs(czppp));
czamp=czppp(lsso);

if isempty(czamp)
        fdp1=fdp;
        fdp1(3)=fdp1(3)-3;
        rd1=roots(fdp1);
        if numel(rd1) == 1
            if ~isreal(rd1)
                rd1 = [];
            end
        elseif numel(rd1) == 2
            rd1 = rd1([isreal(rd1(1)), isreal(rd1(2))]);
        end
        czamp=rd1(find(rd1>ampBnd(1)&rd1<ampBnd(end)));
end
    
sprintf('%.4e',czamp)
%% In circuit
setQSettings('r_avg',1000);
czLength=[]; % empty to load from registry
czQSet=czQSets{2};
cQ = czQSet{1};
tQ = czQSet{2};
preset=sqc.util.getQSettings(['g_cz.' cQ '_' tQ '.amp'],'shared');
czAmp=linspace(preset*0.9,preset*1.1,30); 
acz1=simu_acz_ampLength_incircuit('controlQ',cQ,'targetQ',tQ,...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','1',...
       'notes','','gui',true,'save',true);
acz0=simu_acz_ampLength_incircuit('controlQ',cQ,'targetQ',tQ,...
       'dataTyp','Phase',...
       'czLength',czLength,'czAmp',czAmp,'cState','0',...
       'notes','','gui',true,'save',true);
cz0data=unwrap(acz0.data{1,1});
cz1data=unwrap(acz1.data{1,1});
czAmp=acz0.sweepvals{1,2}{1,1};
dp = unwrap(cz1data - cz0data);
cz0data = cz0data/pi;
cz1data = cz1data/pi;
dp = dp/pi;
fdp = polyfit(czAmp,dp,2);
figure;plot(czAmp,cz0data,'.b',czAmp,cz1data,'.r',...
    czAmp,polyval(fdp,czAmp),'-g',czAmp,dp,'.-m',...
    czAmp,ones(1,length(czAmp)),':k',czAmp,-ones(1,length(czAmp)),':k');
fdp1=fdp;
fdp1(3)=fdp1(3)-1;
rd1=roots(fdp1);

fdp2=fdp;
fdp2(3)=fdp2(3)+1;
rd2=roots(fdp2);

if numel(rd1) == 1
    if ~isreal(rd1)
        rd1 = [];
    end
elseif numel(rd1) == 2
    rd1 = rd1([isreal(rd1(1)), isreal(rd1(2))]);
end
if numel(rd2) == 1
    if ~isreal(rd2)
        rd2 = [];
    end
elseif numel(rd2) == 2
    rd2 = rd2([isreal(rd2(1)), isreal(rd2(2))]);
end

ampBnd = minmax([czAmp(1),czAmp(end)]);
czamp1=rd1(find(rd1>ampBnd(1)&rd1<ampBnd(end)));
czamp2=rd2(find(rd2>ampBnd(1)&rd2<ampBnd(end)));

czppp=[czamp1,czamp2];
[~,lsso]=min(abs(czppp));
czamp=czppp(lsso);

if isempty(czamp)
        fdp1=fdp;
        fdp1(3)=fdp1(3)-3;
        rd1=roots(fdp1);
        if numel(rd1) == 1
            if ~isreal(rd1)
                rd1 = [];
            end
        elseif numel(rd1) == 2
            rd1 = rd1([isreal(rd1(1)), isreal(rd1(2))]);
        end
        czamp=rd1(find(rd1>ampBnd(1)&rd1<ampBnd(end)));
end
    
sprintf('%.4e',czamp)
%%
czQSets = {{'q1','q2'},...
    {'q3','q2'},...
    {'q3','q4'},...
    {'q5','q4'},...
    {'q5','q6'},...
    {'q7','q6'},...
    {'q7','q8'},...
    {'q9','q8'},...
    {'q9','q10'},...
    {'q11','q10'},...
    {'q11','q12'},...
    };
czQSet = czQSets{10};
data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true,'withtailCZ',false,'innerdelay',80,'checkread',false,'isinitfirst',false);
czQSet = czQSets{1};
data_taking.public.xmon.tuneup.optCZparams('controlQ',czQSet{1},'targetQ',czQSet{2},'gui',true,'save',true,'paramsinput',[],'withaczLn',true,'withtailCZ',false,'innerdelay',80,'checkread',false,'isinitfirst',false);

%%
setQSettings('r_avg',2000);
tuneup.czAmplitude('controlQ','q11','targetQ','q12','largeRange',false,...
    'notes','','gui',true,'save',true);
%% check |11> -> |02> state leakage, method: prepare |11>, apply CZ, measure P|0?>
setQSettings('r_avg',2500);
czAmp = linspace(-4.3976e+08*0.85,-4.3976e+08*1.2,25);
czAmp = linspace(sqc.util.detune2zpa('q3',-4.3976e+08*0.85),sqc.util.detune2zpa('q3',-4.3976e+08*1.2),25);
acz_ampLength('controlQ','q3','targetQ','q2',...
       'dataTyp','P',...
       'czLength',[40:20:300],'czAmp',czAmp,'cState','1',...
       'notes','','gui',true,'save',true);
%% Tomography
setQSettings('r_avg',2500);
CZTomoData = Tomo_2QProcess('qubit1','q7','qubit2','q6',...
       'process','CZ','notes','','gui',true,'save',true);
toolbox.data_tool.showprocesstomo_new(CZTomoData,CZTomoData)
datestr(now, 'yyyymmddHHMMSS')
%% Tomography
setQSettings('r_avg',2500);
CZTomoData = Tomo_2QProcess_incircuit('qubit1','q3','qubit2','q2',...
       'process','CZ','notes','','gui',true,'save',true);
toolbox.data_tool.showprocesstomo_new(CZTomoData,CZTomoData)
datestr(now, 'yyyymmddHHMMSS')
%%
setQSettings('r_avg',1000);
temp.czRBFidelityVsPhase('controlQ','q9','targetQ','q8',...
      'phase_c',[-pi:2*pi/10:pi],'phase_t',[-pi:2*pi/10:pi],...
      'numGates',4,'numReps',20,'notes','','gui',true,'save',true);
%%
sqc.measure.gateOptimizer.czOptPhase({'q7','q8'},4,20,1500, 50);
%%
sqc.measure.gateOptimizer.czOptPhaseAmp({'q7','q8'},4,20,1500, 100);
%%
sqc.measure.gateOptimizer.czOptLeakage({'q9','q8'},20, 5000, 50);
%%
setQSettings('r_avg',1000);
temp.czRBFidelityVsPlsCalParam('controlQ','q7','targetQ','q8',...
       'rAmplitude',[-0.02:0.005:0.03],'td',[464],'calcControlQ',false,...
       'numGates',4,'numReps',20,...
       'notes','','gui',true,'save',true);
%% two qubit gate benchmarking
sqc.util.setQSettings('r_avg',1000);
numGates = [1];
[Pref,Pi] = randBenchMarking('qubit1','q1','qubit2','q2',...
       'process','Cluster','numGates',numGates,'numReps',15,...
       'gui',true,'save',true);
[fidelity,h] = toolbox.data_tool.randBenchMarking(numGates, mean(Pref,1), mean(Pgate, 1),2, 'CZ');
%%
controlQ = 'q7';
targetQ = 'q8';
setQSettings('r_avg',5000);
czDetuneQPhaseTomo('controlQ',controlQ,'targetQ',targetQ,'detuneQ','q6',...
      'phase',[-pi:2*pi/30:pi],'numCZs',1,... % [-pi:2*pi/10:pi]
      'notes','','gui',true,'save',true);
%%
phase = tuneup.czDetuneQPhaseTomo('controlQ',controlQ,'targetQ',targetQ,'detuneQ','q6',...
        'maxFEval',40,...
       'notes','','gui',true,'save',true);