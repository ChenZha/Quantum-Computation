function varargout = spectroscopy111_zpa(varargin)
% spectroscopy111: qubit spectroscopy
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or different qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
% 
% <_o_> = spectroscopy111_zpa('biasQubit',_c|o_,'biasAmp',<[_f_]>,...
%       'driveQubit',_c|o_,'driveFreq',<[_f_]>,...
%       'readoutQubit',_c|o_,'dataTyp',<_c_>,...
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

fcn_name = 'data_taking.public.xmon.spectroscopy111_zpa'; % this and args will be saved with data
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
        R.name = '|IQ|';
%         R.datafcn = @(x)mean(abs(x));
        R.datafcn = @(x)mean(abs(imag(x))+abs(real(x)));
    otherwise
        throw(MException('QOS_spectroscopy111_zdc',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end
R.delay = X.length;

Z = op.zBias4Spectrum(biasQubit);
function proc = procFactory(amp)
    Z.amp = amp;
    proc = X.*Z;
end

x = expParam(@procFactory,true);
x.name = [biasQubit.name,' z bias amplitude'];
y = expParam(X.mw_src{1},'frequency');
% y = expParam(X,'mw_src_frequency'); % change mw_src_frequency is problematic, Yulin Wu 2018/2/18
y.offset = -driveQubit.spc_sbFreq;
y.name = [driveQubit.name,' driving frequency (Hz)'];
y.callbacks ={@(x_)x.fcnval.Run()};

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
