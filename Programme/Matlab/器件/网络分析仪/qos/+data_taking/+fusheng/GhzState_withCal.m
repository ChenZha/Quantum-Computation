function [Pzz,Pxx]=GhzState_withCal(N,Phase,numTakes,numRunsPerTake,issave,iscali)

import sqc.util.getQSettings

path=['E:\data\20180622_12bit\sampling\' datestr(now,'yymmdd') '\ghz'];

N_allowed=[2,3,5,7,9,11,12];
num_phase_allowed=N_allowed;[0,1,3,3,5,7,10]+2;
if ~ismember(N,N_allowed)
    error('N must be one of [2,3,5,7,9,11]')
end
id=find(N==N_allowed);
if numel(Phase)~=num_phase_allowed(id)
    error('Phase number is wrong')
end


if ~exist(path)
    mkdir(path)
end
if nargin<4
    error('input not enough')
elseif nargin==4
    dosave = 0;
    docali = 0;
elseif nargin==5
    dosave = issave;
    docali = 0;
elseif nargin==6
    dosave = issave;
    docali = iscali;
else nargin>6
    error('to many input')
end



stats = 3000;
measureType = 'Mzj';

if ~isempty(Phase)
    for ii=1:numel(Phase)
        GPhaseAll{ii}=sprintf('Rz(%0.6f)',-Phase(ii));
    end
else
    GPhaseAll={};
end
% GPhaseAll2=sprintf('Rz(%0.6f)',-Phase);

%% generate Ghz circuit
GPhase={};
for ii=1:numel(GPhaseAll)
    GPhase=[GPhase,GPhaseAll{ii}];
end
%% N=2
switch N
    case 2
        opQs = {'q6','q7'};
        measureQs = {'q6','q7'};
        circuits = [
            {'Y2p','Y2m';
            'CZ','CZ' };...
            GPhase;
            {'' ,'Y2p'};...
            ];
        M = [{'',''};
            {'Y2m','Y2m'}];
    case 3
        opQs = {'q6','q7','q8'};
        measureQs = {'q6','q7','q8'};
        %         way2: only buchang non-cz qubit before measurement
        circuits = [
            {'Y2p','Y2m',   '';
            'CZ','CZ' ,   '';
            '' ,'Y2p','Y2m';
            '' ,'CZ' ,'CZ' ;};
            GPhase;
            {'' , ''  ,'Y2p'};
%             {GPhaseAll{1},'',''}
            ];
        
        M = [{''  ,''   ,''   };
            {'Y2m','Y2m','Y2m'}
            ];
        
    case 5
        opQs = {'q5','q6','q7','q8','q9'};
        measureQs = {'q5','q6','q7','q8','q9'};
        circuits = [ 
            {''  ,'Y2p','Y2m', ''  ,''   ;
            ''  ,'CZ' ,'CZ' , ''  ,''   ;
            ''  ,''   ,'Y2p','Y2m',''   ;
            ''  ,''   ,'CZ' ,'CZ' ,''   ;
            'Y2m'  ,''   ,''   ,'Y2p','Y2m';
            'CZ','CZ' ,''   ,'CZ' ,'CZ'};
            GPhase;
            {'Y2p'  ,''   ,''   ,''   ,'Y2p'};
%             {''  ,''   ,GPhaseAll{1}  ,''   ,''   }
            ];
        
        M = [{'' ,''  ,''   ,''   ,''   };
            {'Y2m'  ,'Y2m','Y2m','Y2m','Y2m'}
            ];
        
    case 7
        opQs = {'q4','q5','q6','q7','q8','q9','q10'};
        measureQs = {'q4','q5','q6','q7','q8','q9','q10'};
        circuits = [
            {''  ,''   ,'Y2p','Y2m', ''  ,''   ,''   ;
            ''   ,''   ,'CZ' ,'CZ' , ''  ,''   ,''   ;
            ''   ,''   ,''   ,'Y2p','Y2m',''   ,''   ;
            ''   ,''   ,''   ,'CZ' ,'CZ' ,''   ,''   ;
            ''   ,'Y2m',''   ,'X'   ,'Y2p','Y2m',''   ;
            ''   ,'CZ' ,'CZ' ,''   ,'CZ' ,'CZ' ,''   ;
            'Y2m','Y2p','X'   ,''   ,''   ,'Y2p','Y2m';
            'CZ' ,'CZ' ,''   ,''   ,''   ,'CZ' ,'CZ' };
            GPhase;
            {'Y2p',''   ,'X'   ,'X'   ,''   ,''   ,'Y2p';};
%             {''  ,''  ,  GPhaseAll{1},GPhaseAll{2},GPhaseAll{3}  ,''   ,''   }
            ];
        
        M = [{''  ,''  ,'' ,''  ,''   ,''   ,''   };
            {'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m','Y2m','Y2m','Y2m'}
            ];
        
    case 9
        opQs = {'q3','q4','q5','q6','q7','q8','q9','q10','q11'};
        measureQs = {'q3','q4','q5','q6','q7','q8','q9','q10','q11'};
        circuits = [
            {''  ,''   ,''   ,'Y2p','Y2m', ''  ,''   ,''   ,''   ;
            ''   ,''   ,''   ,'CZ' ,'CZ' , ''  ,''   ,''   ,''   ;
            ''   ,''   ,''   ,''   ,'Y2p','Y2m',''   ,''   ,''   ;
            ''   ,''   ,''   ,''   ,'CZ' ,'CZ' ,''   ,''   ,''   ;
            ''   ,''   ,'Y2m',''   ,'X'  ,'Y2p','Y2m',''   ,''   ;
            ''   ,''   ,'CZ' ,'CZ' ,''   ,'CZ' ,'CZ' ,''   ,''   ;
            ''   ,'Y2m','Y2p','X'  ,''   ,'X'  ,'Y2p','Y2m',''   ;
            ''   ,'CZ' ,'CZ' ,''   ,''   ,''   ,'CZ' ,'CZ' ,''   ;
            'Y2m','Y2p',''   ,''   ,'X'  ,''   ,''   ,'Y2p','Y2m';
            'CZ' ,'CZ' ,''   ,''   ,''   ,''   ,''   ,'CZ' ,'CZ' };
            GPhase;
            {'Y2p',''   ,''   ,'X'  ,''   ,'X'  ,''   ,''   ,'Y2p';};
%             {'','',GPhaseAll{1},GPhaseAll{2},GPhaseAll{3},GPhaseAll{4},GPhaseAll{5},'',''}
            ];
        
        M = [{''  ,'' , ''  ,'' ,'' ,''  ,''   ,''   ,''   };
            {'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m','Y2m','Y2m','Y2m'}
            ];
        
    case 11
        opQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
        measureQs = {'q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};
        circuits = [
            {''  ,''   ,''   ,''   ,'Y2p','Y2m', ''  ,''   ,''   ,''   ,''   ;
            ''   ,''   ,''   ,''   ,'CZ' ,'CZ' , ''  ,''   ,''   ,''   ,''   ;
            ''   ,''   ,''   ,''   ,''   ,'Y2p','Y2m',''   ,''   ,''   ,''   ;
            ''   ,''   ,''   ,''   ,''   ,'CZ' ,'CZ' ,''   ,''   ,''   ,''   ;
            ''   ,''   ,''   ,'Y2m',''   ,'X'  ,'Y2p','Y2m',''   ,''   ,''   ;
            ''   ,''   ,''   ,'CZ' ,'CZ' ,''   ,'CZ' ,'CZ' ,''   ,''   ,''   ;
            ''   ,''   ,'Y2m','Y2p','X'  ,''   ,'X'  ,'Y2p','Y2m',''   ,''   ;
            ''   ,''   ,'CZ' ,'CZ' ,''   ,''   ,''   ,'CZ' ,'CZ' ,''   ,''   ;
            ''   ,'Y2m','Y2p',''   ,''  ,''   ,''    ,''   ,'Y2p','Y2m',''   ;
            ''   ,'CZ' ,'CZ' ,''   ,''   ,''   ,''   ,''   ,'CZ' ,'CZ' ,''   ;
            'Y2m','Y2p',''   ,''   ,''   ,'X'  ,''   ,''   ,''   ,'Y2p','Y2m';
            'CZ' ,'CZ' ,''   ,''   ,''   ,''   ,''   ,''   ,''   ,'CZ' ,'CZ' };
            GPhase;
            {'Y2p',''   ,''   ,''  ,'X'  ,''   ,'X'  , ''   ,''   ,''   ,'Y2p';};
%             {'','',GPhaseAll{1},GPhaseAll{2},GPhaseAll{3},GPhaseAll{4},GPhaseAll{5},GPhaseAll{6},GPhaseAll{7},'',''}
            ];
        
        M = [{''  ,'' ,''  ,'' , ''  ,'' ,'' ,''  ,''   ,''   ,''   };
            {'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m'  ,'Y2m','Y2m','Y2m','Y2m'}
            ];
        
end

%%
if dosave
    hf = qes.ui.qosFigure(['GhzState ',measureQs{1},' ',measureQs{end}],false);
    ax = axes('parent',hf);
end

Pzz = [];
Pxx = [];
% numTakes=3;
% numRunsPerTake = 5;
tic;
for ii=1:numTakes
    if docali
        maxRepeat=10;
        repeatid=1;
        F=0;
        while F<0.992 && repeatid<maxRepeat
            disp(['check readout No.' num2str(repeatid)])
            data_taking.public.xmon.tuneup.autoCalibration(measureQs,0,0)
            F=data_taking.public.xmon.tuneup.checkreadout(measureQs{1}, measureQs{2});
            repeatid=repeatid+1;
        end
    end
    for mm = 1:2
        circuit=[circuits;M(mm,:)];
        Ei=[];
        for jj = 1:numRunsPerTake
            [result, singleShotEvents, sequenceSamples, ~] =sqc.util.runCircuit(circuit,...
                opQs,measureQs,stats,measureType, false);
            if jj == 1
                Pi = result;
            else
                Pi = Pi+result;
            end
            Ei = [Ei,singleShotEvents];
        end
        P = Pi/numRunsPerTake;
        Events=Ei;
        Fidelities =  getQSettings('r_iq2prob_fidelity',(measureQs));
        
        
        if dosave
            datafile = [path,'\ghz',measureQs{1},'_',measureQs{end},'_L',num2str(mm),'_',datestr(now,'yymmddTHHMMSS'),'.mat'];
            save(datafile,'P','Events','Fidelities','circuit','sequenceSamples','opQs','measureQs','numTakes','numRunsPerTake');
            try
                Pavg = P;
                bar(ax,Pavg);
                xlabel(ax,'state');
                ylabel(ax,'P');
                if mm==1
                    title(ax,[measureQs{1},' ',measureQs{end} ' ZZ']);
                elseif mm==2
                    title(ax,[measureQs{1},' ',measureQs{end} ' XX']);
                end
            catch
                hf = qes.ui.qosFigure('',false);
                ax = axes('parent',hf);
            end
            drawnow;
            saveas(hf,replace(datafile,'.mat','.fig'))
        end
        if mm==1
            Pzz=[Pzz;P];
        else
            Pxx=[Pxx;P];
        end
        
    end
end
toc;
% disp(datestr(now, 'yyyymmddHHMMSS'));
end
% disp(['GHz fidelity is',num2str(fdl)])