function PhaseCalibration(obj)
%

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.i_awg) || ~IsValid(obj.i_awg)  || isempty(obj.q_awg) || ~IsValid(obj.q_awg)
        error('IQMixerCalibrate:RunError','at least one of i_awg, q_awg is not set or not valid.');
    end
    if  isempty(obj.i_chnl) || isempty(obj.q_chnl)
        error('IQMixerCalibrate:RunError','at least one of i_chnl, q_chnl is not set.');
    end
    if  isempty(obj.iq_amp)
        error('IQMixerCalibrate:RunError','iq_amp is not set.');
    end

    obj.Param_I_Amp.expobj.awg = obj.i_awg;
    obj.Param_I_Amp.expobj.awgchnl = obj.i_chnl;
    obj.Param_Q_Amp.expobj.awg = obj.q_awg;
    obj.Param_Q_Amp.expobj.awgchnl = obj.q_chnl;

    obj.Param_I_Amp.val = obj.amp; %  update the waveform on the awg
    obj.Param_Q_Amp.val = obj.amp; %  update the waveform on the awg
    obj.i_awg.on = true;
    obj.q_awg.on = true;

    if obj.plot
        plotax = obj.Param_Q_Amp.expobj.Show(obj.Param_I_Amp.expobj.Show); % plot the waveform after before the calibration
    end

    obj.spc_amp_obj.freq = obj.lo_freq-obj.iq_freq;
%     spcamp = obj.spc_amp_obj.data;
%     initialnsbandpwr = spcamp;
    f = ExpFcn([obj.Param_Q_Amp, obj.Param_Q_Phase],obj.spc_amp_obj);
    opts = optimset('Display','off','MaxIter',obj.maxiter,'TolX',obj.dcmin,'TolFun',obj.specampmin,...
        'PlotFcns',{@optimplotfval, @optimplotxhis}); % current value and history
    % use Wv_Cos

    initialphase = -pi/2;
    initialphase = -pi/2+pi;
    lb = [obj.iq_amp*0.75, initialphase-1.1*pi];
    ub = [obj.iq_amp/0.75, initialphase+1.1*pi];
    xsol = fminsearchbnd(f.fcn,[obj.iq_amp,initialphase],lb,ub,opts);
    obj.results.q_amp_corr = xsol(1)/obj.iq_amp;
    obj.results.q_phase_corr = rem(xsol(2)-(-pi/2),2*pi);
    
    obj.spc_amp_obj.Run()
    spcamp = obj.spc_amp_obj.data;
    finalnsbandpwr = spcamp;
    
    obj.spc_amp_obj.freq = obj.lo_freq+obj.iq_freq;
    obj.spc_amp_obj.Run()
    finalpsbandpwr = obj.spc_amp_obj.data;
    pnsband_pwr_diff = finalpsbandpwr - finalnsbandpwr; % positive band and negative band power difference
    obj.results.pnsband_pwr_diff = pnsband_pwr_diff;
    
    obj.spc_amp_obj.freq = obj.lo_freq;
    obj.spc_amp_obj.Run()
    finallopwr = obj.spc_amp_obj.data;
    pbandlo_pwr_diff = finalpsbandpwr - finallopwr;
    obj.results.pbandlo_pwr_diff = pbandlo_pwr_diff; % positive band and lo frequency power difference
    if obj.plot
        obj.Param_Q_Amp.expobj.Show(obj.Param_I_Amp.expobj.Show(plotax)); % plot the waveform after the calibration
    end
end