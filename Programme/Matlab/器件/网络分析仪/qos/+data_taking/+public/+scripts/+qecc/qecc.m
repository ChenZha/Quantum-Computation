% 
% %%
% import sqc.op.physical.*
% import sqc.measure.*
% import sqc.util.qName2Obj
% import sqc.util.setQSettings
% QS = qes.qSettings.GetInstance();
%%
S='S';H='H';CZ='CZ';I='I';Sd='Sd';
mX='Y2p';mY='X2m';mZ='I';mI='I';

Y2p='Y2p';Y2m='Y2m';

% circuit={S,H,H,H,H;...
% 	H,CZ,CZ,I,I;...
% 	I,I,I,CZ,CZ;...
% 	CZ,CZ,I,I,S;...
% 	I,I,CZ,CZ,I;...
% 	H,S,S,H,I;...
% 	S,I,H,Sd,I;...
% 	H,I,CZ,CZ,I;...
% 	I,I,H,H,I;...
% 	I,I,CZ,CZ,I;...
% 	I,I,H,H,I;...
% 	I,I,CZ,CZ,I;...
% 	I,CZ,CZ,I,I;...
% 	I,H,H,I,I;...
% 	I,CZ,CZ,I,I;...
% 	I,H,H,I,I;...
% 	CZ,CZ,I,I,I;...
% 	H,Sd,I,I,I;...
% 	I,H,I,I,I;...
% 	I,CZ,CZ,I,I;...
% 	I,H,Sd,I,I;...
% 	I,S,H,I,I;...
% 	I,H,I,I,I};

circuit={S,H,H,H,H;...
	H,CZ,CZ,I,I;...
	I,I,I,CZ,CZ;...
	CZ,CZ,I,I,S;...
	I,I,CZ,CZ,I;...
	H,S,S,H,I;...
	S,H,I,Sd,I};

   
g1={mX,mI,mZ,mX,mZ};
g2={mI,mX,mX,mZ,mZ};
g3={mX,mZ,mI,mZ,mX};
g4={mZ,mZ,mX,mX,mI};
Xbar={mX,mX,mX,mX,mX};
Ybar={mY,mY,mY,mY,mY};
Zbar={mZ,mZ,mZ,mZ,mZ};

% measure={g1,g2,g3,g4,Xbar,Ybar,Zbar};
measure={Zbar};

qubits = {'q9','q8','q7','q6','q5'};
r_avg = 2e4;
setQSettings('r_avg',r_avg);
numReps = 10;

data = NaN(numReps,numel(measure),2^5);
timeStamp = datestr(now,'_yymmddTHHMMSS_');
dataFileName = ['QECC_',timeStamp,'.mat'];
dataPath = QS.loadSSettings('data_path');
dataFileName = fullfile(dataPath,dataFileName);

for ii = 1:numReps
    for jj = 1:numel(measure)
        disp(['repeation: ', num2str(ii), ' | measure: ',num2str(jj)]);
        circuit_ = [circuit;measure{jj}];
        p = gateParser.parse(qubits,circuit_);
        p.Run();
        R = resonatorReadout(qubits);
        R.delay = p.length;
        data(ii,jj,:) = R();
        save(dataFileName,'circuit','measure','qubits','data','r_avg');
    end
end
%%
datam = squeeze(mean(data,1));
figure();bar(datam(1,:));
% Fidelity = data_taking.public.scripts.qecc.qeccData2Fid(datam)