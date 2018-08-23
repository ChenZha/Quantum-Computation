function GHZ_Prob(qNames,r_avg,numTakes)
% data_taking.yulin.GHZ_Prob();
import sqc.measure.*
import sqc.util.qName2Obj
    
import sqc.op.physical.*
import sqc.measure.*
import sqc.util.qName2Obj
    
import sqc.util.getQSettings
import sqc.util.setQSettings

numQs = numel(qNames);
switch numQs
    case 8
        gateMat = {'Y2p','Y2m','I',  'I',  'I',  'I',  'I',  'I';
                   'CZ','CZ',  'I',  'I',  'I',  'I',  'I',  'I';
                   'I','Y2p','Y2m',  'I',  'I',  'I',  'I',  'I';
                   'I','CZ',  'CZ',  'I', 'I',  'I',  'I',  'I';
                   'I','I',  'Y2p','Y2m', 'I',  'I',  'I',  'I';
                   'I','I',  'CZ',  'CZ', 'I',  'I',  'I',  'I';
                   'I','I',  'I',  'Y2p','Y2m',  'I',  'I',  'I';
                   'I','I',  'I',   'CZ','CZ',  'I',  'I',  'I';
                   'I','I',  'I',    'I','Y2p',  'Y2m',  'I',  'I';
                   'I','I',  'I',   'I', 'CZ',  'CZ',  'I',  'I';
                   'I','I',  'I',    'I','I',  'Y2p',  'Y2m',  'I';
                   'I','I',  'I',   'I', 'I',  'CZ',  'CZ',  'I';
                   'I','I',  'I',    'I','I',  'I',  'Y2p',  'Y2m';
                   'I','I',  'I',   'I', 'I',  '',  'CZ',  'CZ';
                   'I','I',  'I',    'I','I',  'I',  'I',  'Y2p';
                   };
    case 7      
        gateMat = {'Y2p','Y2m','I',  'I',  'I',  'I',  'I';
                   'CZ','CZ',  'I',  'I',  'I',  'I',  'I';
                   'I','Y2p','Y2m',  'I',  'I',  'I',  'I';
                   'I','CZ',  'CZ',  'I', 'I',  'I',  'I';
                   'I','I',  'Y2p','Y2m', 'I',  'I',  'I';
                   'I','I',  'CZ',  'CZ', 'I',  'I',  'I';
                   'I','I',  'I',  'Y2p','Y2m',  'I',  'I';
                   'I','I',  'I',   'CZ','CZ',  'I',  'I';
                   'I','I',  'I',    'I','Y2p',  'Y2m',  'I';
                   'I','I',  'I',   'I', 'CZ',  'CZ',  'I';
                   'I','I',  'I',    'I','I',  'Y2p',  'Y2m';
                   'I','I',  'I',   'I', 'I',  'CZ',  'CZ';
                   'I','I',  'I',    'I','I',  'I',  'Y2p';
                   };
    case 6      
        gateMat = {'Y2p','Y2m','I',  'I',  'I',  'I';
                   'CZ','CZ',  'I',  'I',  'I',  'I';
                   'I','Y2p','Y2m',  'I',  'I',  'I';
                   'I','CZ',  'CZ',  'I', 'I',  'I';
                   'I','I',  'Y2p','Y2m', 'I',  'I';
                   'I','I',  'CZ',  'CZ', 'I',  'I';
                   'I','I',  'I',  'Y2p','Y2m',  'I';
                   'I','I',  'I',   'CZ','CZ',  'I';
                   'I','I',  'I',    'I','Y2p',  'Y2m';
                   'I','I',  'I',   'I', 'CZ',  'CZ';
                   'I','I',  'I',    'I','I',  'Y2p';
                   };
    case 5      
        gateMat = {'Y2p','Y2m','I',  'I',  'I';
                   'CZ','CZ',  'I',  'I',  'I';
                   'I','Y2p','Y2m',  'I',  'I';
                   'I','CZ',  'CZ',  'I', 'I';
                   'I','I',  'Y2p','Y2m', 'I';
                   'I','I',  'CZ',  'CZ', 'I';
                   'I','I',  'I',  'Y2p','Y2m';
                   'I','I',  'I',   'CZ','CZ';
                   'I','I',  'I',    'I','Y2p';
                   };
    case 4       
        gateMat = {'Y2p','Y2m','I',  'I';
                   'CZ','CZ',  'I',  'I';
                   'I','Y2p','Y2m',  'I';
                   'I','CZ',  'CZ',  'I';
                   'I','I',  'Y2p','Y2m';
                   'I','I',  'CZ',  'CZ';
                   'I','I',  'I',  'Y2p';
                   };
    case 3        
        gateMat = {'Y2p','Y2m','I';
                   'CZ','CZ',  'I';
                   'I','Y2p','Y2m';
                   'I','CZ',  'CZ';
                   'I','I',  'Y2p';
                   };
    otherwise
        error('unsupported number of qubits: %d', numQs);
end
       
qubits = cell(1,numQs);
for ii = 1:numQs
    qubits{ii} = qName2Obj(qNames{ii});
    qubits{ii}.r_avg = r_avg;
end

proc = sqc.op.physical.gateParser.parse(qubits,gateMat);

R = resonatorReadout(qubits);
R.delay = proc.length;
for ii = 1:numTakes
    proc.Run();
    if ii == 1
        data = R();
    else
        data = data + R();
    end
end
data = data/numTakes;

hf = figure();bar(data);

QS = qes.qSettings.GetInstance();
dataFolder = fullfile(QS.loadSSettings('data_path'),'GHZ');
if ~exist(dataFolder,'dir')
    mkdir(dataFolder);
end
dataFileName = ['GHZ_Prob_',datestr(now,'yymmddTHHMMSS'),...
        num2str(ceil(99*rand(1,1)),'%0.0f'),'_'];
if ~isempty(hf) && isvalid(hf)
    figName = fullfile(dataFolder,[dataFileName,'.fig']);
    saveas(hf,figName);
end
dataFileName = fullfile(dataFolder,[dataFileName,'.mat']);
save(dataFileName,'data','gateMat','r_avg','numTakes');

end