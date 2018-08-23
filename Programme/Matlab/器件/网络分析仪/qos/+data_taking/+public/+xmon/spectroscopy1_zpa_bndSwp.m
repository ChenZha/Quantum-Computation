function varargout = spectroscopy1_zpa_bndSwp(varargin)
% spectroscopy1: qubit spectroscopy with band sweep
% 
% <_o_> = spectroscopy1_zpa_bndSwp('qubit',_c|o_,'biasAmp',<[_f_]>,...
%       'swpBandCenterFcn',<_o_>,'swpBandWdth',<[_f_]>,...
%       'driveFreq',<[_f_]>,...
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

fcn_name = 'data_taking.public.xmon.spectroscopy1_zpa_bndSwp'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r_avg',[],'biasAmp',0,'driveFreq',[],...
    'swpBandCenterFcn',[],'swpBandWdth',10e6,'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});
if isempty(args.driveFreq)
    args.driveFreq = q.f01-3*q.t_spcFWHM_est:...
        q.t_spcFWHM_est/10:q.f01+3*q.t_spcFWHM_est;
end
if isempty(args.swpBandCenterFcn)
    args.swpBandCenterFcn = @(x_)1;
    args.swpBandWdth = Inf;
end
if ~isempty(args.r_avg)
    q.r_avg=args.r_avg;
end

X = op.mwDrive4Spectrum(q);
X.Run();
Z = op.zBias4Spectrum(q);
R = measure.resonatorReadout_ss(q);
R.delay = X.length;
R.state = 2;
function proc = procFactory(amp)
	Z.amp = amp;
	proc = Z.*X;
end

x = expParam(@procFactory,true);
x.name = [q.name,' z bias amplitude'];
y = expParam(X.mw_src{1},'frequency');
y.offset = -q.spc_sbFreq;
y.name = [q.name,' driving frequency (Hz)'];
y.callbacks ={@(x_)x.fcnval.Run()};

s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.driveFreq;

swpRngObj = util.dynMwSweepRngBnd(s1,s2);
swpRngObj.centerfunc = args.swpBandCenterFcn;
swpRngObj.bandwidth = args.swpBandWdth;

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
