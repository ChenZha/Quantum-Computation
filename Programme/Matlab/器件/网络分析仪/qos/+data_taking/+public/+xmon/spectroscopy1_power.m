function varargout = spectroscopy1_power(varargin)
% spectroscopy1_power: qubit spectroscopy power dependence
% bias: zpa
% 
% <_o_> = spectroscopy111_zpa('qubit',_c|o_,'biasAmp',<_f_>,...
%       'driveFreq',<[_f_]>,'uSrcPower',[_f_],...
%       'dataTyp',<_c_>,...
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

fcn_name = 'data_taking.public.xmon.spectroscopy1_power'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'dataTyp','P','r_avg',[],'biasAmp',0,'driveFreq',[],'gui',false,'notes','','save',true});
[readoutQubit, biasQubit, driveQubit] = data_taking.public.util.getQubits(...
    args,{'readoutQubit','biasQubit','driveQubit'});
if isempty(args.driveFreq)
    args.driveFreq = driveQubit.f01-3*driveQubit.t_spcFWHM_est:...
        driveQubit.t_spcFWHM_est/15:driveQubit.f01+3*driveQubit.t_spcFWHM_est;
end

if ~isempty(args.r_avg)
    readoutQubit.r_avg=args.r_avg;
end

X = op.mwDrive4Spectrum(driveQubit);
switch args.dataTyp
    case 'P'
        R = measure.resonatorReadout_ss(readoutQubit);
        R.state = 2;
    case 'S21'
        R = measure.resonatorReadout_ss(readoutQubit,false,true);
        R.swapdata = true;
        R.name = '|S21|';
        R.datafcn = @(x)abs(mean(x));
    otherwise
        throw(MException('QOS_spectroscopy111_zdc',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end
R.delay = X.length;

Z = op.zBias4Spectrum(biasQubit);
Z.amp = args.biasAmp;
proc = X.*Z;

proc.Run(); % from this point on X will assume that the dc source and mw source are set
x = expParam(X.mw_src{1},'power');
x.name = [driveQubit.name,' mw source power (dBm)'];
y = expParam(X.mw_src{1},'frequency');
y.name = [driveQubit.name,' mw source frequency (dBm)'];
y.callbacks ={@(x_)porc.Run()};

s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.driveFreq;
e = experiment();
e.name = 'Spectroscopy';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s%s[%s]', biasQubit.name, driveQubit.name, readoutQubit.name);
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
