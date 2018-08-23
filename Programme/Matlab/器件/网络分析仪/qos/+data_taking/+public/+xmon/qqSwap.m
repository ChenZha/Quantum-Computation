function qqSwap(varargin)
% twoQSwap: two qubits swap
% 
% <_o_> = qqQSwap('qubit1',_o|c_,'qubit2',_o|c_,...
%       'biasAmp1',[_f_],'biasAmp2',[_f_],'biasDelay1',<_i_>,'biasDelay2',<_i_>,...
%       'q1XYGate',_c_,'q2XYGate',_c_,...
%       'swapTime',[_i_],'readoutQubit',<_i_>,...
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

% Yulin Wu, 2017/7/3

fcn_name = 'data_taking.public.xmon.qqSwap'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasQubit',1,'readoutQubit',2,'biasDelay1',0,'biasDelay2',0,'gui',false,'notes',''});
[q1, q2] = data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});

if q1==q2
    throw(MException('QOS_TwoQSwap:sameQubitError',...
        'the source qubit and the target qubit are the same.'));
end

if args.readoutQubit==1
    readoutQ = q1;
else
    readoutQ = q2;
end

if any(args.swapTime < 10)
    error('swapTime time too short, minimum value is 10.');
end

if any(args.biasDelay1 < 1)
    error('biasDelay time too short, minimum value is 1.');
end

if any(args.biasDelay2 < 1)
    error('biasDelay time too short, minimum value is 1.');
end

G1 = feval(str2func(['@(q)sqc.op.physical.gate.',args.q1XYGate,'(q)']),q1);
G2 = feval(str2func(['@(q)sqc.op.physical.gate.',args.q2XYGate,'(q)']),q2);

I1 = gate.I(q1);
I1.ln = max(1,args.biasDelay1);
I2 = gate.I(q2);
I2.ln = max(1,args.biasDelay2);

Z1 = op.zBias4Spectrum(q1); % todo: use iSwap gate
Z2 = op.zBias4Spectrum(q2); % todo: use iSwap gate
R = measure.resonatorReadout_ss(readoutQ);
R.state = 2;
zAmp1 = qes.util.hvar(0);
zAmp2 = qes.util.hvar(0);
function procFactory(swapTime)
	Z1.ln = swapTime;
	Z2.ln = swapTime;
    Z1.amp = zAmp1.val;
	Z2.amp = zAmp2.val;
	proc = (G1.*G2)*((I1*Z1).*(I2*Z2));
    R.delay = proc.length;
    proc.Run();
end

if numel(args.biasAmp2) == 1
    x = expParam(zAmp1,'val');
    x.name = [q1.name,' zpa'];
    s1 = sweep(x);
    s1.vals = args.biasAmp1;
    zAmp2.val = args.biasAmp2;
elseif numel(args.biasAmp1) == 1
    x = expParam(zAmp2,'val');
    x.name = [q2.name,' zpa'];
    s1 = sweep(x);
    s1.vals = args.biasAmp2;
    zAmp2.val = args.biasAmp2;
else
    error('sweep both biasAmp1 and biasAmp2 is not supported.');
end

y = expParam(@procFactory);
y.name = [q1.name,', ',q2.name,' swap time'];
s2 = sweep(y);
s2.vals = args.swapTime;
e = experiment();
e.name = 'Q-Q swap';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s,%s', q1.name, q2.name);
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