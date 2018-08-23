function varargout = spectroscopy1_zpa_s21(varargin)
% qubit spectroscopy of one qubit with s21 as measurement data.
% comparison: spectroscopy111_zpa and spectroscopy111_zdc measure
% probability of |1>.
% spectroscopy1_zpa_s21 is used during tune up when mesurement of 
% probability of |1> has not been setup.
% 
% <_o_> = spectroscopy1_zpa_s21('qubit',_c|o_,...
%       'biasAmp',<[_f_]>,'driveFreq',<[_f_]>,...
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


% Yulin Wu, 2017/3/13


error('spectroscopy1_zpa_s21 is obsolete, use spectroscopy1_zpa with dataTyp set to ''S21''');

import qes.*
import data_taking.public.xmon.spectroscopy111_zpa_s21
args = util.processArgs(varargin,{'biasAmp',0,'driveFreq',[],'r_avg',[],'gui',false,'notes','','save',true});
varargout{1} = spectroscopy111_zpa_s21('biasQubit',args.qubit,'biasAmp',args.biasAmp,'driveQubit',args.qubit,...
    'driveFreq',args.driveFreq,'readoutQubit',args.qubit,'notes',args.notes,'r_avg',args.r_avg,'gui',args.gui,'save',args.save);

end
