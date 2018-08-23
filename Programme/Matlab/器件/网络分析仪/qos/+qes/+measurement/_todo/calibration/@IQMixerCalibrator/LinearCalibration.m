function LinearCalibration(obj)
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

    obj.Param_DCQ.expobj.awg = obj.q_awg;
    obj.Param_DCQ.expobj.awgchnl = obj.q_chnl;

    obj.Param_DCQ.val = 0;
    obj.Param_DCI.val = 0;
    obj.i_awg.on = true;
    obj.q_awg.on = true;

    obj.spc_amp_obj.freq = obj.lo_freq;

%     Param1 = ExpParam(obj.Param_DCI, 'val');
%     Param1.callbacks ={@(x) x.expobj.DoAll(),@(x) pause(1)};
%     sweep1 = Sweep(obj.Param_DCI);
%     sweep1.vals = {(0.1:0.01:1)};
%     ExpObj = Experiment();
%     ExpObj.sweeps = {sweep1};
%     ExpObj.measurements = obj.spc_amp_obj;  %   <- problem happens here
%     ExpObj.name = 'I Linearity';
%     ExpObj.Run;
    
    obj.Param_DCQ.val=0;  % Replaced with the zero point of Q
    I_range=-0.3:0.01:0.3;
    I_applied=zeros(1,length(I_range));
    hh=figure;
    
    for ii=1:length(I_range)
        obj.Param_DCI.val=I_range(ii);
        pause(.1)
        obj.spc_amp_obj.Run()
        spc_amp=obj.spc_amp_obj.data;
        I_applied(ii)=sqrt(10.^(spc_amp./10)).*sign(I_range(ii));
        plot(gca(hh),I_range(1:ii),I_applied(1:ii),'-o');
        xlabel('I Volt(V)')
        ylabel('sqrt Power (V)')
    end
    
    obj.Param_DCI.val=0;  % Replaced with the zero point of Q
    Q_range=-0.3:0.01:0.3;
    Q_applied=zeros(1,length(Q_range));
    
    for ii=1:length(Q_range)
        obj.Param_DCQ.val=Q_range(ii);
        pause(.1)
        obj.spc_amp_obj.Run()
        spc_amp=obj.spc_amp_obj.data;
        Q_applied(ii)=sqrt(10.^(spc_amp./10)).*sign(Q_range(ii));
        plot(gca(hh),I_range,I_applied,'-o',Q_range(1:ii),Q_applied(1:ii),'-*');
        xlabel('Q Volt(V)')
        ylabel('sqrt Power (V)')
    end
    legend('I','Q')
    
end