function varargout = rabi_long1_freq(varargin)
% rabi_long1: Rabi oscillation by changing the pi pulse length
% bias, drive and readout all one qubit
%
% sweeps xy drive pulse length and frequency detuning(mixer lo frequency is fixed)
%
% <_o_> = rabi_long1_freq('qubit',_c|o_,'biasAmp',[_f_],'biasLonger',<_i_>,...
%       'xyDriveAmp',_f_,'detuning',<[_f_]>,...
%       'dataTyp','_c_',...   % S21 or P
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

% Yulin Wu, 2017/8/20


fcn_name = 'data_taking.public.xmon.rabi_long1_freq'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasLonger',0,'detuning',0,'dataTyp','P',...
    'r_avg',[],'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if ~isempty(args.r_avg) %add by GM, 20170414
    q.r_avg=args.r_avg;
end

q.spc_zLonger = args.biasLonger;
q.spc_sbFreq = q.f01-q.qr_xy_fc;

X = op.mwDrive4Spectrum(q);
X.amp = args.xyDriveAmp;
Z = op.zBias4Spectrum(q);
Z.amp = args.biasAmp;

function procFactory(ln)
	X.ln = ln;
	Z.ln = ln+2*args.biasLonger;
    proc = X.*Z;
    proc.Run();
    R.delay = proc.length;
end

switch args.dataTyp
    case 'P'
        R = measure.resonatorReadout_ss(q);
        R.state = 2;
    case 'S21'
        R = measure.resonatorReadout_ss(q,false,true);
        R.swapdata = true;
        R.name = '|IQ|';
%         R.datafcn = @(x)abs(mean(x));
        R.datafcn = @(x)mean(abs(real(x))+abs(imag(x)));
    otherwise
        throw(MException('QOS_rabi_long1',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end

x = expParam(q,'f01');
x.offset = q.f01;
x.name = [q.name,' detunning(f-f01, Hz)'];
y = expParam(@procFactory);
y.name = [q.name,' xy Drive Pulse Length'];
s1 = sweep(x);
s1.vals = args.detuning;
s2 = sweep(y);
s2.vals = args.xyDriveLength;
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.name = 'Rabi Long';
e.datafileprefix = sprintf('[%s]_rabi', q.name);

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