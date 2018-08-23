function varargout = spectroscopy1_zpa(varargin)
% spectroscopy1, bias, drive, readout all on one qubit
% 
% <_o_> = spectroscopy1_zpa('qubit',_c|o_,...
%       'biasAmp',<[_f_]>,'driveFreq',<[_f_]>,'dataTyp',<_c_>,...
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
import data_taking.public.xmon.spectroscopy111_zpa
args = util.processArgs(varargin,{'dataTyp','P','biasAmp',0,'driveFreq',[],'r_avg',[],'gui',false,'notes','','save',true});
varargout{1} = spectroscopy111_zpa('biasQubit',args.qubit,'biasAmp',args.biasAmp,'driveQubit',args.qubit,'dataTyp',args.dataTyp,...
    'driveFreq',args.driveFreq,'readoutQubit',args.qubit,'notes',args.notes,'gui',args.gui,'save',args.save);

end