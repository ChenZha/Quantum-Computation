function varargout = T1_updater(varargin)
% GM, 20180422


fcn_name = 'data_taking.public.xmon.tuneup.T1_updater'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'qubits','','r_avg',[],'biasAmp',0,'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes','','save',true,'fit',true,'update',true});

qubits=args.qubits;
if ischar(qubits)
    qubits={qubits};
end
for ii=1:numel(qubits)
    [data,T1]=data_taking.public.xmon.T1_1('qubit',qubits{ii},'biasAmp',args.biasAmp,'biasDelay',args.biasDelay,'time',[20:500:50e3],... % [20:200:2.8e4]
        'gui',true,'save',true,'fit',true);
    if args.update
        sqc.util.setQSettings('T1',T1,qubits{ii});
    end
end
varargout{1}=data;
varargout{2}=T1;
end