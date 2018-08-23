function qqRamsey(varargin)
% qqRamsey: two qubits ramsey for the calibration of the phase offset between
% two qubits by simultaneously applying a 90 deg. X pulse on qubit1 and and a 90 theta
% pulse on qubit2, where theta is an adjustable microwave phase angle. A plot of the
% occupation probabilities versus free evolution time gives oscillations whose amplitude depends
% on the phase angle theta. The oscillation amplitudes of P01 and P10 are maximized (minimized)
% whenever the relative phase between the |01> and |10> states is 90(0) degrees. 
% When the oscillation amplitude is maximized and P10 peaks first, theta corresponds to a y-rotation
% for the second qubit and serves as the calibration.
% Ref.: M. Steffen, Science Vol. 313, 1423; Bialczak, Phd. thesis P97
% 
% bias qubit q1 or q2, drive qubit q1 or q2 and readout qubit q1 and q2,
% q1, q2 all has to be the selected qubits in the current session,
% 
% <_o_> = twoQRamsey('qubit1',_o|c_,'qubit2',_o|c_,...
%       'biasAmp1',[_f_],'biasDelay1',<_i_>,...
%		'biasAmp2',[_f_],'biasDelay2',<_i_>,...
%       'theta',[_i_],'time',[_i_],...
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

% Yulin Wu, 2017/3/15

fcn_name = 'data_taking.public.xmon.qqRamsey'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasDelay1',0,'biasDelay2',0,'gui',false,'notes',''});
[q1, q2] =...
    data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});
	
if q1==q2
    throw(MException('QOS_qqRamsey:sameQubitError',...
        'qubit1 and qubit2 are the same qubit.'));
end

X1 = gate.X2p(q1);
I1 = gate.I(q1);
I1.ln = args.biasDelay1;
Z1 = op.zBias4Spectrum(q1); % todo: use iSwap gate
X2 = gate.XY2p(q1,0);
I2 = gate.I(q2);
I2.ln = args.biasDelay2;
Z2 = op.zBias4Spectrum(q2); % todo: use iSwap gate
function procFactory(delay)
	Z1.ln = delay;
	Z2.ln = delay;
	proc = ((Z1*I1).*(Z2*I2))*(X1.*X2);
    proc.Run();
    R.delay = proc.length;
end
R = measure.resonatorReadout({q1,q2});


error('todo...');


end