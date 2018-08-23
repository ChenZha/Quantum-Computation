function varargout = amplification(varargin)
% [amplification in dB] vs [pump frequency], [signal frequency] with network analyser
% 
% <_o_> = amplification('jpaName',_c&o_,...
%       'startFreq',_f_,'stopFreq',_f_,...
%       'numFreqPts',_i_,'avgcounts',_i_,...
%       'NAPower',_f_,'bandwidth',_f_,...
%       'pumpFreq',_f_,'pumpPower',[_f_],...
%       'biasAmp',[_f_],...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.

% Yulin Wu, 2017/5/24

fcn_name = 'data_taking.public.jpa.amplification'; % this and args will be saved with data
args = qes.util.processArgs(varargin,{'gui',false,'notes','','save',true});

if numel(args.pumpFreq) > 1
    throw(MException('QOS_invalidArgument','amplification can not sweep pumpFreq.'));
end
if numel(args.pumpPower) > 1 && numel(args.biasAmp) > 1
    throw(MException('QOS_invalidArgument','amplification can not do 3D sweep.'));
end

e0 = data_taking.public.jpa.jpaBringupNA('jpa',args.jpa,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',args.pumpFreq,'pumpPower',-120,...
    'biasAmp',args.biasAmp(1),...
    'gui',false,'save',false);
background = abs(e0.data{1}{1}(1,:));
frequency = e0.data{1}{1}(2,:);

e = data_taking.public.jpa.jpaBringupNA('jpa',args.jpa,...
    'startFreq',args.startFreq,'stopFreq',args.stopFreq,...
    'numFreqPts',args.numFreqPts,'avgcounts',args.avgcounts,...
    'NAPower',args.NAPower,'bandwidth',args.bandwidth,...
    'pumpFreq',args.pumpFreq,'pumpPower',args.pumpPower,...
    'biasAmp',args.biasAmp,...
    'notes',args.notes,'gui',args.gui,'save',args.save);

e.data{1} = e.data{1}(:);
for ii = 1:numel(e.data{1})
    e.data{1}{ii} = 20*log10(abs(e.data{1}{ii}(1,:))./background);
end
e.data{1} = cell2mat(e.data{1});
e.sweepvals = [e.sweepvals,{{frequency}}];
e.paramnames = [e.paramnames,{{'frequency(GHz)'}}];
e.measurementnames = {'amplification(dB)'};
e.plotfcn = [];
e.addSettings({'fcn','args'},{fcn_name,args});
if args.save
    e.SaveData(true);
end
if args.gui
    e.PlotData();
end
varargout{1} = e;

end