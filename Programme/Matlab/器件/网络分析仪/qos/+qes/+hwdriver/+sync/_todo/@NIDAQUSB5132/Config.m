function Config(obj)
    % Config digitizer

    % USB-5132 Vpp: 0.04/0.1/0.2/0.4/1/2/4/10/20/40
    % Impedance: 50/1000000 (in unit of ohm)
    % Slope: 0/1 falling/Rising edge
    % TriggerCoupling 0/1/2/3 AC/DC/HF Reject/LF Reject/AC+HF Reject
    % Channel source/Channel list: '0', '1','0,1','VAL_PFI_1'
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    if isempty(obj.smplrate) || isempty(obj.chnl1range) || isempty(obj.chnl2range)
        error('NIDAQUSB5132:Config', 'some properties are not set!');
    end
    
    % Configure measurement type
    % 0/1 normal/dynamic sampling rate
    configuration = get(obj.deviceobj, 'configuration');
    invoke(configuration, 'configureacquisition',0);
    
    % Configure vertical settings:
    % Configurationfunctionsvertical = get(obj.deviceobj, 'Configurationfunctionsvertical');
    % invoke(Configurationfunctionsvertical, 'configurevertical',...
    %     ChannelList, Range, Offset, Coupling, ProbeAttenuation, Enabled);
    Configurationfunctionsvertical = get(obj.deviceobj, 'Configurationfunctionsvertical');
    if obj.chnl1enabled
        invoke(Configurationfunctionsvertical, 'configurevertical',...
            '0', obj.chnl1range, obj.chnl1offset,1, 1, 1);
    else
        invoke(Configurationfunctionsvertical, 'configurevertical',...
            '0', obj.chnl1range, obj.chnl1offset,1, 1, 0);
    end
    Configurationfunctionsvertical = get(obj.deviceobj, 'Configurationfunctionsvertical');
    if obj.chnl2enabled
        invoke(Configurationfunctionsvertical, 'configurevertical',...
            '1',obj.chnl2range, obj.chnl2offset, 1, 1, 1);
    else
        invoke(Configurationfunctionsvertical, 'configurevertical',...
            '1',obj.chnl2range, obj.chnl2offset, 1, 1, 0);
    end
    
    % Configure horizontal settings:
    % Configurationfunctionshorizontal = get(obj.deviceobj, 'Configurationfunctionshorizontal');
    % invoke(Configurationfunctionshorizontal, 'configurehorizontaltiming',...
    %      MinSampleRate, MinNumPts, RefPosition, NumRecords, EnforceRealtime);
    % RefPosition: 0-100, percentage of pretrigger data points
    % that are stored, a 0% reference position means that you have
    % the actual record length points stored after the trigger occurs,
    % while 100% reference position means that all the samples are stored before the trigger.
    % USB-5132 dose not support multirecords acquisition, NumRecords = 1 always. 
    Configurationfunctionshorizontal = get(obj.deviceobj, 'Configurationfunctionshorizontal');
    invoke(Configurationfunctionshorizontal, 'configurehorizontaltiming',...
         obj.smplrate, 1, 0, 1, 1);
     
    % set trigger
    % invoke(Configurationfunctionstrigger, 'configuretriggeredge',...
    %     TriggerSource, Level, Slope, TriggerCoupling,, Holdoff, Delay);  % edge
    % Trigger holdoff is an adjustable period of time during which the
    % digitizer cannot trigger, to guarantee a minimum time between two Reference Triggers.
    % Model USB5132 dose not support Trigger holdoff
    % invoke(Configurationfunctionstrigger, 'configuretriggersoftware',Holdoff, Delay); %software
    % ...
    Configurationfunctionstrigger = get(obj.deviceobj,'Configurationfunctionstrigger');
    if obj.workmode == 2     % acquire data in trigger mode
        invoke(Configurationfunctionstrigger, 'configuretriggerdigital',...
                'VAL_PFI_1', obj.triggerlevel, 0, 0); % digital
%         invoke(Configurationfunctionstrigger, 'configuretriggeredge',...
%                 'VAL_PFI_1', obj.triggerlevel, 1, 0,0,0); % edge
    elseif obj.workmode == 1            % continues
        invoke(Configurationfunctionstrigger, 'configuretriggersoftware',  0, 0);
    end
end