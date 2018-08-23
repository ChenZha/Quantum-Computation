function varargout = zDelay(varargin)
% measures the syncronization of Z pulse
% 
% <_o_> = zDelay('zQubit',_c|o_,'xyQubit',_c|o_,'zAmp',[_f_],'zLn',<_i_>,'zDelay',[_i_],...
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

% Yulin Wu, 2017/5/10

import qes.*
import sqc.*
import sqc.op.physical.*

if nargin > 1  % otherwise playback
	fcn_name = 'data_taking.public.xmon.zDelay'; % this and args will be saved with data
	args = util.processArgs(varargin,{'zLn',[],'r_avg',[],'gui',false,'notes','','save',true});
end
[qz,qxy] = data_taking.public.util.getQubits(args,{'zQubit','xyQubit'});

if ~isempty(args.r_avg)
    qxy.r_avg=args.r_avg;
end
if isempty(args.zLn) 
    args.zLn=qxy.g_XY_ln;
end

X = gate.X(qxy);
Z = op.zBias4Spectrum(qz);
Z.ln = args.zLn;
Z.amp = args.zAmp;
padLn11 = ceil(-min(X.length/2 - Z.length/2 + min(args.zDelay),0))+1;
padLn12 = ceil(max(max(X.length/2 + Z.length/2 + max(args.zDelay),X.length)-X.length,0))+1;
I1 = gate.I(qxy);
I1.ln = padLn11;
I2 = gate.I(qxy);
I2.ln = padLn12;
XY = I1*X*I2;
I3 = gate.I(qz);
function procFactory(delay)
    i3ln = X.length/2 + padLn11 - Z.length/2 + delay;
    assert(i3ln > 0);
    I3.ln = ceil(i3ln);
	proc = XY.*(I3*Z);
    proc.Run();
end
R = measure.resonatorReadout_ss(qxy);
R.state = 2;
R.delay = XY.length;

y = expParam(@procFactory);
y.name = [qz.name,' z Pulse delay(da sampling points)'];

s2 = sweep(y);
s2.vals = {args.zDelay};
e = experiment();
e.sweeps = s2;
e.measurements = R;
e.name = 'Z Pulse Delay';
e.datafileprefix = sprintf('%s%s_zDelay', qz.name,qxy.name);

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

ff=NaN(1,numel(e.sweepvals{1,1}{1,1}));
for ii=round(numel(e.sweepvals{1,1}{1,1})/4):round(numel(e.sweepvals{1,1}{1,1})/4*3)
    if ii<numel(e.sweepvals{1,1}{1,1})/2
        ff(ii)=sum((e.data{1,1}(1:ii)-e.data{1,1}(ii*2:-1:ii+1)).^2);
    else
        ff(ii)=sum((e.data{1,1}(2*ii-numel(e.sweepvals{1,1}{1,1})+1:ii)-e.data{1,1}(end:-1:ii+1)).^2);
    end
end

[~,lo]=min(ff);
delay=-e.sweepvals{1,1}{1,1}(lo)/2;
varargout{2} = delay;

end