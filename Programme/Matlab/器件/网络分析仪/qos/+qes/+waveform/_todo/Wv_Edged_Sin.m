classdef Wv_Edged_Sin < Waveform
    % a SinWv Obj with edges

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % Sampling Frequency in Hz, if awg is set, SamplingFreq can be 
        % empty, the awg samplrate is used, if SamplingFreq is set, its 
        % value mush be the same as the awg samplrate
        SamplingFreq 
        Freq        % Hz
        Phase = pi/2  % initial phase
        Rise     % Readout pulse rise time, uint: points
        PulseDuration       % Pulse duration time, uint: points, edge not included
        Amp        % Readout pulse amplitude
    end
    properties (Hidden = true, SetAccess = protected, GetAccess = protected)
        SinWvObj
        Envelop
    end
    methods
        function obj = Wv_Edged_Sin()
            obj = obj@Waveform();
            obj.SinWvObj = Wv_Sin();
            obj.SinWvObj.temperory = true; % temperoy waveform, not regist in HandleQES object tracing list
                                                   % in this way, at the deletion of a Readout instance,
                                                   % its SinWvObj waveform object will also be deleted
            obj.Envelop = Wv_Square();
            obj.Envelop.temperory = true;
        end
        % set mothods to be added.
        %
        function GenWave(obj)
            if isempty(obj.Freq) || isempty(obj.Rise) ||...
                    isempty(obj.PulseDuration)  ||...
                    isempty(obj.Amp)
                error('Readout:GenWaveError','Some parameters are not set!');
            end
            if isempty(obj.SamplingFreq) 
                if (isempty(obj.awg) || isempty(obj.awg.smplrate))
                    error('Readout:GenWaveError','in case of no awg, SamplingFreq must be set!');
                else
                    obj.SamplingFreq = obj.awg.smplrate;
                end
            elseif ~isempty(obj.awg) && isempty(obj.awg.smplrate) && obj.SamplingFreq~= obj.awg.smplrate
                error('Readout:GenWaveError','SamplingFreq not the same the awg sampling rate!');
            end
            obj.length = 2*obj.Rise  + obj.PulseDuration+1;
            GenWave@Waveform(obj); % check parameters

            obj.SinWvObj.length = obj.length;
            obj.SinWvObj.phase = obj.Phase;
            obj.SinWvObj.period = obj.SamplingFreq/obj.Freq;
            obj.SinWvObj.amp = obj.Amp;
            
            obj.Envelop.length = obj.length;
            obj.Envelop.rise = obj.Rise;
            obj.Envelop.amp = 1;
            obj.Envelop.edgefunc = 3;
            
            tempwave = obj.Envelop*obj.SinWvObj;
            tempwave.GenWave();
            obj.wvdata  = tempwave.wvdata;
            obj.vpp =  tempwave.vpp;
            obj.offset = tempwave.offset;
            tempwave.delete(); % since tempwave is not set to be a temperoy HandleQES, better delete it here,
                               % otherwise it will stays in HandleQES registry.
        end
    end
end