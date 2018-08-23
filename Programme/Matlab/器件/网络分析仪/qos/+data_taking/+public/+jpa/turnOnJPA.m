function varargout = turnOnJPA(varargin)
% turn on JPA with spicified parameters
% 
% <_o_> = turnOnJPA('jpaName',_c&o_,...
%       'pumpFreq',[_f_],'pumpPower',[_f_],...
%       'bias',[_f_],...)
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

% Yulin Wu, 2017/2/14
% GM, 2017/05/12

    import qes.*
    
    args = util.processArgs(varargin,{'gui',false,'notes','','save',true});
    jpa = data_taking.public.util.getJPAs(args,{'jpa'});

    biasSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpa.channels.bias.instru);
	% needs checking here because biasSrc could be a DAC
	if ~isa(biasSrc,'qes.hwdriver.sync.dcSource')
        throw(MException('s21_BiasPumpPwrPumpFreq_networkAnalyzer:inValidSettings',...
              sprintf('the bias source %s is not a dc source.',jpa.channels.bias.instru)));
    end
	biasChnl = biasSrc.GetChnl(jpa.channels.bias.chnl);
    pumpMwSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpa.channels.pump_mw.instru);
	pumpMwSrc = pumpMwSrc.GetChnl(jpa.channels.pump_mw.chnl);
    
    if args.on
        biasChnl.dcval = args.bias;
        biasChnl.on = true;
    
        pumpMwSrc.frequency = args.pumpFreq;
        pumpMwSrc.power = args.pumpPower;
        pumpMwSrc.on = true;
    else
        biasChnl.on = false;
        pumpMwSrc.on = false;
    end
end