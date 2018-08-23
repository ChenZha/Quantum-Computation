function varargout = T2_updater(varargin)
% GM, 20180422


fcn_name = 'data_taking.public.xmon.tuneup.T2_updater'; % this and args will be saved with data
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
    [data,T2]=data_taking.public.xmon.ramsey('qubit',qubits{ii},'mode','dp',... % available modes are: df01, dp and dz
        'time',[0:100:5000],'detuning',[-2]*1e6,...
        'dataTyp','P','phaseOffset',0,'notes','','gui',true,'save',true,'fit',true);
    if args.update
        sqc.util.setQSettings('T2',T2,qubits{ii});
    end
end
varargout{1}=data;
varargout{2}=T2;

end