function varargout = spectroscopy_zpa_withPi_driveDelay(varargin)
% sweep frequency, zamplitude
% spectroscopy111: qubit spectroscopy
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or different qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
% 
% <_o_> = spectroscopy_zpa_withPi_driveDelay('q',_c&o_,'biasAmp',_f_,...
%       'driveFreq',<[_f_]>,...
%       'driveDelay',[_i_],'zLength',_i_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.spectroscopy111_zpa'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'dataTyp','P','r_avg',[],'biasAmp',0,'gui',false,'notes','','save',true});
[q] = data_taking.public.util.getQubits(...
    args,{'qubit'});

if ~isempty(args.r_avg)
    q.r_avg=args.r_avg;
end

X = gate.X(q);
R = measure.resonatorReadout_ss(q);
R.state = 2;
I1 = gate.I(q);

Z_ = op.zBias4Spectrum(q);
Z_.ln = args.zLength;
Z_.amp = args.biasAmp;
I2 = gate.I(q);
minDelay = min(-1,min(args.driveDelay)-1);
I2.ln = -minDelay;
Z = I2*Z_;

R.delay = minDelay + max(args.zLength + max(args.driveDelay));

function proc = procFactory(delay)
    delay - minDelay
    I1.ln = delay - minDelay;
    proc = (I1*X).*Z;
end

x = expParam(@procFactory,true);
x.name = [q.name,' xy drive delay'];
y = expParam(X.mw_src{1},'frequency');
y.offset = -q.spc_sbFreq;
y.name = [q.name,' driving frequency (Hz)'];
y.callbacks ={@(x_)x.fcnval.Run()};

s1 = sweep(x);
s1.vals = args.driveDelay;
s2 = sweep(y);
s2.vals = args.driveFreq;
e = experiment();
e.name = 'Spectroscopy';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s', q.name);
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
