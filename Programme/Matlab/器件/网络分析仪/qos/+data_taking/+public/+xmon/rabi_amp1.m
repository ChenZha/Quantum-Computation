function varargout = rabi_amp1(varargin)
% rabi_amp1: Rabi oscillation by changing the pi pulse amplitude
% bias, drive and readout all one qubit
% 
% <_o_> = rabi_amp1('qubit',_c|o_,'biasAmp',[_f_],'biasLonger',<_i_>,...
%       'xyDriveAmp',[_f_],'detuning',<[_f_]>,'driveTyp',<_c_>,...
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

% Yulin Wu, 2016/12/27

import qes.*
import data_taking.public.xmon.rabi_amp111
args = util.processArgs(varargin,{'biasLonger',0,'driveTyp','X','dataTyp','P','detuning',0,...
    'numPi',1,'r_avg',0,'gui',false,'notes','','save',true});
varargout{1} = rabi_amp111('biasQubit',args.qubit,'biasAmp',args.biasAmp,'biasLonger',args.biasLonger,...
    'driveQubit',args.qubit,'readoutQubit',args.qubit,'xyDriveAmp',args.xyDriveAmp,'driveTyp',args.driveTyp,...
    'numPi',args.numPi,...
    'dataTyp',args.dataTyp,... % S21 or P
	'detuning',args.detuning,'notes',args.notes,'r_avg',args.r_avg,'gui',args.gui,'save',args.save);

end