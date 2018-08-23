function varargout = xy_Rdelay(varargin)

fcn_name = 'data_taking.public.xmon.xy_Rdelay'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasDelay',[-50:1:50],'backgroundWithZBias',false,...
    'dataTyp','P','gui',true,'notes','','save',true});
qubit = data_taking.public.util.getQubits(args,{'qubit'});


if strcmp(qubit.g_XY_impl,'hPi')
    X2p = gate.X2p(qubit);
    X = X2p^2;
else
    X = gate.X(qubit);
end
function procFactory(delay)
    if strcmp(qubit.g_XY_impl,'hPi')
        X = X2p^2;
    end
    proc=X^5;
    proc.Run();
    R.delay = proc.length+delay;
end
	switch args.dataTyp
		case 'P'
            R = measure.resonatorReadout_ss(qubit);
			R.state = 2;
		case 'S21'
            R = measure.resonatorReadout_ss(qubit);
			R.swapdata = true;
			R.name = '|IQ|';
            R.datafcn = @(x)mean(abs(imag(x))+abs(real(x)));
    end
function rerunZ()
    if strcmp(qubit.g_XY_impl,'hPi')
        piAmpBackup = X2p.amp;
        X2p.amp = 0;
        procFactory(y.val);
        X2p.amp = piAmpBackup;
    else
        piAmpBackup = X.amp;
        X.amp = 0;
        procFactory(y.val);
        X.amp = piAmpBackup;
    end
end
if args.backgroundWithZBias
    R.postRunFcns = @rerunZ;
end

y = expParam(@procFactory);
y.name = [qubit.name,' xy R delay time (da sampling interval)'];
s1 = sweep(y);
s1.vals = args.biasDelay;
e = experiment();
e.name = 'XY R Delay';
e.sweeps = s1;
e.measurements = R;
% e.plotfcn = @qes.util.plotfcn.T1;
e.datafileprefix = sprintf('%s_xyRdelay_',qubit.name);
if ~args.gui
    e.showctrlpanel = false;
    e.plotdata = false;
end
if ~args.save
    e.savedata = false;
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
e.Run();
varargout{1} = e;
end