function ZeroCalibration(obj)
%

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.lo_freq)
        error('IQMixerCalibrate:RunError','lo_freq frequency not set.');
    end
    if isempty(obj.i_awg) || ~IsValid(obj.i_awg)  || isempty(obj.q_awg) || ~IsValid(obj.q_awg)
        error('IQMixerCalibrate:RunError','at least one of i_awg, q_awg is not set or not valid.');
    end
    if  isempty(obj.i_chnl) || isempty(obj.q_chnl)
        error('IQMixerCalibrate:RunError','at least one of i_chnl, q_chnl is not set.');
    end
    obj.Param_DCI.expobj.awg = obj.i_awg;
    obj.Param_DCI.expobj.awgchnl = obj.i_chnl;
    obj.Param_DCI.expobj.fixawgvpp = true;
    obj.Param_DCI.expobj.awgvpp = obj.i_awgvpp;

    obj.Param_DCQ.expobj.awg = obj.q_awg;
    obj.Param_DCQ.expobj.awgchnl = obj.q_chnl;
    obj.Param_DCQ.expobj.fixawgvpp = true;
    obj.Param_DCQ.expobj.awgvpp = obj.q_awgvpp;

    obj.Param_DCQ.val = 0;
    obj.Param_DCI.val = 0;
    obj.i_awg.on = true;
    obj.q_awg.on = true;

    obj.spc_amp_obj.freq = obj.lo_freq;  
    f = ExpFcn([obj.Param_DCI, obj.Param_DCQ],obj.spc_amp_obj);
    opts = optimset('Display','off','MaxIter',obj.maxiter,'TolX',obj.dcmin,'TolFun',obj.specampmin,...
        'PlotFcns',{@optimplotfval, @optimplotxhis}); % current value and history
    lb = [-obj.i_awgvpp, -obj.q_awgvpp]/2;
    ub = [obj.i_awgvpp, obj.q_awgvpp]/2;
    xsol = fminsearchbnd(f.fcn,[0,0],lb,ub,opts);
    obj.results.i_zero = xsol(1);
    obj.results.q_zero = xsol(2);
    hf = findobj('Name','Optimization PlotFcns'); % in case you want to save the figure, we have it here
end