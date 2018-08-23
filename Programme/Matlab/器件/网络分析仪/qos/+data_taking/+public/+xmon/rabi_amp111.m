function varargout = rabi_amp111(varargin)
% support multi-qubit parallel process
%
% rabi_amp111: Rabi oscillation by changing the pi pulse amplitude
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or different qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
%
% sweeps xy drive pulse amplitude and frequency detuning(mixer lo frequency is fixed)
% 
% <_o_> = rabi_amp111('biasQubit',_c|o_,'biasAmp',<_f_>,'biasLonger',<_i_>,...
%       'driveQubit',_c|o_,...
%       'readoutQubit',_c|o_,...
%       'xyDriveAmp',[_f_],'detuning',<[_f_]>,'driveTyp',<_c_>,...
%       'dataTyp','_c_',...   % S21 or P
%		'numPi',<_i_>,... % number of pi rotations, default 1, use numPi > 1, e.g. 11 for pi pulse amplitude fine tuning.
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

fcn_name = 'data_taking.public.xmon.rabi_amp111'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasLonger',0,'detuning',0,'driveTyp','X','dataTyp','P',...
    'numPi',1,'r_avg',0,'gui',false,'notes','','save',true});

if iscell(args.driveQubit) && numel(args.driveQubit) > 1
	numQs = numel(args.driveQubit);	
	% when parallel, biasAmp, detuning must be zero
	if args.biasAmp ~=0 || args.detuning ~= 0
		throw(MException('QOS_rabi_amp111:illegalArguments','parallel mesurement with non-zero biasAmp or detuning not supported'));
	end
	if ~qes.util.identicalArray(args.driveQubit,args.biasQubit) ||...
		~qes.util.identicalArray(args.driveQubit,args.readoutQubit)
		throw(MException('QOS_rabi_amp111:illegalArguments',...
			'parallel mesurement with different driveQubits, biasQubits and readoutQubits is not supported'));
	end
	driveQubit = args.driveQubit;
    for ii = 1:numQs
        if ischar(driveQubit{ii})
            driveQubit{ii} = sqc.util.qName2Obj(driveQubit{ii});
        end
    end
	readoutQubit = driveQubit;
	biasQubit = driveQubit;
else
    if iscell(args.driveQubit)
        args.driveQubit = args.driveQubit{1};
    end
    if iscell(args.biasQubit)
        args.biasQubit = args.biasQubit{1};
    end
    if iscell(args.readoutQubit)
        args.readoutQubit = args.readoutQubit{1};
    end
	isParallel = false;	
	[readoutQubit, biasQubit, driveQubit] =...
		data_taking.public.util.getQubits(args,{'readoutQubit', 'biasQubit', 'driveQubit'});
	readoutQubit = {readoutQubit};
	biasQubit = {biasQubit};
	driveQubit = {driveQubit};
	numQs = numel(driveQubit);
end

if args.r_avg~=0 %add by GM, 20170414
	for ii = 1:numQs
		readoutQubit{ii}.r_avg=args.r_avg;
	end
end
g = cell(1,numQs);
for ii = 1:numQs
switch args.driveTyp
	case 'X'
		g{ii} = gate.X_(driveQubit{ii});
        n = 1;
	case {'X/2','X2p'}
		g{ii} = gate.X2p(driveQubit{ii});
        n = 2;
	case {'-X/2','X2m'}
		g{ii} = gate.X2m(driveQubit{ii});
        n = 2;
    case {'X/4','X4p'}
		g{ii} = gate.X4p(driveQubit{ii});
        n = 4;
    case {'-X/4','X4m'}
		g{ii} = gate.X4m(driveQubit{ii});
        n = 4;
	case 'Y'
		g{ii} = gate.Y_(driveQubit{ii});
        n = 1;
	case {'Y/2', 'Y2p'}
		g{ii} = gate.Y2p(driveQubit{ii});
        n = 2;
	case {'-Y/2', 'Y2m'}
		g{ii} = gate.Y2m(driveQubit{ii});
        n = 2;
    case {'Y/4','Y4p'}
		g{ii} = gate.Y4p(driveQubit{ii});
        n = 4;
    case {'-Y/4','Y4m'}
		g{ii} = gate.Y4m(driveQubit{ii});
        n = 4;
	otherwise
		throw(MException('QOS_rabi_amp111:illegalDriverTyp',...
			sprintf('the given drive type %s is not one of the allowed drive types: X, X/2, -X/2, X/4, -X/4, Y, Y/2, -Y/2, Y/4, -Y/4',...
			args.driveTyp)));
end
end
if numQs == 1
	I = gate.I(driveQubit);
	I.ln = args.biasLonger;
	Z = op.zBias4Spectrum(biasQubit);
	Z.amp = args.biasAmp;
end
m = n*args.numPi;
function procFactory(amp_)
	ln = 0;
	for ii_ = 1:numQs
		g{ii_}.amp = amp_(ii_);
		XY = g{ii_}^m;
		if numQs == 1
			Z.ln = XY.length + 2*args.biasLonger;
			proc = Z.*(I*XY);
		else
			proc = XY;
		end
		ln = max(ln,proc.length);
		proc.Run();
	end
	R.delay = ln;
end
if numQs == 1
	switch args.dataTyp
		case 'P'
            R = measure.resonatorReadout_ss(readoutQubit,false);
%             R = measure.resonatorReadout(readoutQubit,false);
			R.state = 2;
		case 'S21'
            R = measure.resonatorReadout_ss(readoutQubit,false,true);
			R.swapdata = true;
			R.name = '|IQ|';
% 			R.datafcn = @(x)abs(mean(x));
            R.datafcn = @(x)mean(abs(imag(x))+abs(real(x)));
		otherwise
			throw(MException('QOS_rabi_amp111:unsupportedDataTyp',...
				'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
				args.dataTyp));
		end
else
	if ~strcmp(args.dataTyp, 'P')
		throw(MException('QOS_rabi_amp111:unsupportedDataTyp',...
				'dataTyp %s not supported for parallel measurement.',...
				args.dataTyp));
	end
	R = measure.resonatorReadout(readoutQubit,false);
end

x = expParam(g{1},'f01'); % numQs == 1 only
x.offset = driveQubit{1}.f01;
x.name = [driveQubit{1}.name,' detunning(f-f01, Hz)'];
y = expParam(@procFactory);
if numQs == 1
    y.name = [driveQubit{1}.name,' xyDriveAmp'];
else
    y.name = 'xyDriveAmp';
end

s1 = sweep(x);
s1.vals = args.detuning;
s2 = sweep(y);
if numQs == 1
    s2.vals = args.xyDriveAmp;
else
    s2.vals = cell2mat(args.xyDriveAmp(:));
end
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.name = 'rabi_amp111';
if numQs == 1
    e.datafileprefix = sprintf('[%s]_rabi', readoutQubit{1}.name);
end

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