function varargout = T1_111(varargin)
% T1_111: T1
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% 
% <_o_> = T1_111('biasQubit',_c|o_,'biasAmp',<[_f_]>,'biasDelay',<_i_>,...
%       'backgroundWithZBias',<_b_>,...
%       'driveQubit',_c|o_,'readoutQubit',_c|o_,...
%       'time',[_i_],...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.T1_111'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r_avg',[],'biasAmp',0,'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes',''});
[readoutQubit, biasQubit, driveQubit] =...
    data_taking.public.util.getQubits(args,{'readoutQubit', 'biasQubit', 'driveQubit'});

if ~isempty(args.r_avg)
    readoutQubit.r_avg=args.r_avg;
end

if strcmp(driveQubit.g_XY_impl,'hPi')
    X2p = gate.X2p(driveQubit);
    X = X2p^2;
else
    X = gate.X(driveQubit);
end
I = gate.I(biasQubit);
I.ln = args.biasDelay;
Z = op.zBias4Spectrum(biasQubit);
function procFactory(delay)
    if strcmp(driveQubit.g_XY_impl,'hPi')
        X = X2p^2;
    end
    if delay > 0
        Z.ln = delay;
        proc = X*I*Z;
    else
        proc = X*I;
    end
    proc.Run();
    R.delay = proc.length;
end
R = measure.rReadout4T1(readoutQubit,X.mw_src{1});
function rerunZ()
    if strcmp(driveQubit.g_XY_impl,'hPi')
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

x = expParam(Z,'amp');
x.name = [biasQubit.name,' z bias amplitude'];
y = expParam(@procFactory);
y.name = [driveQubit.name,' decay time(da sampling interval)'];
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.time;
e = experiment();
e.name = 'T1';
e.sweeps = [s1,s2];
e.measurements = R;
e.plotfcn = @qes.util.plotfcn.T1;
e.datafileprefix = sprintf('%s_T1_',biasQubit.name);
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