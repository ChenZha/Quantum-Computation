function varargout = photonNumberCal(varargin)
% calibrate photon number in readout resonator
% 
% <_o_> = photonNumberCal('qubit',_c|o_,...
%       'time',[_i_],'detuning',[_f_],...
%       'r_amp',<_f_>,'r_ln',<_i_>,...
%       'ring_amp',<_f_>,'ring_w',<_i_>,...
%       'r_avg',<_i_>,...
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

fcn_name = 'data_taking.public.xmon.photonNumberCal'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*
import qes.waveform.spacer

START_OFFSET =500;

args = util.processArgs(varargin,{'r_avg',[],'r_amp',[],'r_ln',[],'ring_amp',[],'gui',false,'notes',''});
q = data_taking.public.util.getQubits(args,{'qubit'});

if any(args.time < -START_OFFSET)
    warning('time points shorter smaller than -%0.0f are dropped.',START_OFFSET);
    args.time(args.time < -START_OFFSET) = [];
end

if ~isempty(args.r_avg)
    q.r_avg=args.r_avg;
end
if isempty(args.r_amp)
    args.r_amp=q.r_amp;
end
if isempty(args.r_ln)
    args.r_ln=q.r_ln;
end
if isempty(args.ring_amp)
    args.ring_amp=q.r_wvSettings.ring_amp;
end
if isempty(args.ring_w)
    args.ring_w=q.r_wvSettings.ring_w;
end

if max(args.time)<args.r_ln
    throw(MException('QOS_photonNumberCal:invalidTimeRange','time range shorter than readout length.'));
end
D = max(args.time)-args.r_ln;

rWv = sqc.wv.rr_ring(args.r_ln);
rWv.amp = args.r_amp;
rWv.ring_amp = args.ring_amp;
rWv.ring_w = args.ring_w;
da =  qHandle.FindByClassProp('qes.hwdriver.hardware',...
    'name',q.channels.r_da_i.instru);
rWv.df = (q.r_freq - q.r_fc)/da.samplingRate; % note: here initial phase not important
rWv = [spacer(START_OFFSET),rWv,spacer(D)];

X = gate.X(q);
I = gate.I(q);
    function proc = procFactory(delay)
        I.ln = delay;
        proc = I*X;
        proc.Run();
    end
R = measure.resonatorReadout_ss(q);
R.delay = rWv.length;
R.state = 2;
R.startWv = rWv;

x = expParam(X.mw_src{1},'frequency');
x.name = [q.name,' pi pulse freq. detuning(Hz)'];
x.offset = q.qr_xy_fc;
y = expParam(@procFactory);
y.offset = START_OFFSET;
y.name = [q.name,' pi pulse delay time(da sampling interval)'];

X.Run(); % by doing so, the mw source will be set, from this point on,
         % any operators drived from X will assume that the corresponding
         % mw source has been set and will not set it again, this is
         % important here because if not so, the setting mw frequency
         % operation of x will be undo by y.
         % use I.Run() here also ok.

s1 = sweep(x);
s1.vals = -args.detuning;
s2 = sweep(y);
s2.vals = args.time;
e = experiment();
e.name = 'Photon Number Calibration';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s',q.name);
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