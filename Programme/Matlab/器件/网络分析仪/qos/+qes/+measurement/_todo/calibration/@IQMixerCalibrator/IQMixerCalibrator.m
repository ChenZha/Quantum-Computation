classdef IQMixerCalibrator < Measurement
    % do IQ Mixer calibration
    % a wrapper that managers the mecessary waveforms and measurement,
    % uses the Optimizer class internally to do the real work.

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        freq     % Hz, side band frequency
        amp         % (initial)amplitude of I and Q
        
        qdelay = 0
        
        i_awg       % awg for I
        i_chnl      % awg chnl for I

        q_awg       % awg for Q
        q_chnl      % awg chnl for Q

        lo_source
        lo_freq      % Hz, carrier frequency
        lo_power
        
        i_wiring
        q_wiring
        lo_wiring
        mixer@char

        dcmin = 0.005 % dc min search step
        specampmin = 2 % spectrum amplitude min
        
        pulseln
        
        maxiter = 30
        
        plot = false;
        spc_amp_obj
    end
    properties (SetAccess = private)
        plotax
    end
    properties (SetAccess = private)
        results = struct(); 
    end
    properties (GetAccess = private, SetAccess = private)
        Param_DCI
        Param_DCQ
        Param_I_Amp
        Param_Q_Amp
        Param_Q_Phase
        I
        Q
        S
    end
    methods
        function obj = IQMixerCalibrator()
            obj = obj@Measurement([]);
            obj.numericscalardata = false;
        end
        function set.spc_amp_obj(obj,GetSpecAmpObj)
            if ~isa(GetSpecAmpObj,'GetSpecAmp') || ~IsValid(GetSpecAmpObj)
                error('IQMixerCalibrate:SetError','Invalid GetSpecAmpObj.');
            end
            obj.spc_amp_obj = GetSpecAmpObj;
        end
        function set.qdelay(obj,val)
            obj.qdelay = val;
            IQMixerCalibrator.Initialize(obj);
        end
        function set.pulseln(obj,PulseLn)
            if nargin > 1
                if isempty(PulseLn)
                    error('IQMixerCalibrate:InvalidInput','empty value!');
                end
                PulseLn = PulseLn(1);
                if PulseLn <= 0
                    error('IQMixerCalibrate:InvalidInput','pulseln value should be a positive integer!');
                elseif ceil(PulseLn) ~= PulseLn
                    warning('IQMixerCalibrate:ImproperInput', 'pulseln value rounded to integer!');
                    PulseLn = ceil(PulseLn);
                end
            else
                PulseLn = 5000;
            end
            DCI = Wv_Rect(PulseLn);
            DCI.amp = 0;
            DCQ = copy(DCI);
            
            I = Wv_Cos();
            I.length = PulseLn;
            I.period = 10;
            I.amp = 0;
            Q = I.AP(-pi/2);
            
            qdelay_i = floor(obj.qdelay);
            qdelay_r = obj.qdelay - qdelay_i;
            S = Wv_Spacer(abs(qdelay_i));
            
            % keep references to I, Q and S as shortcuts for settings
            obj.I = I;
            obj.Q = Q;
            obj.S = S;
            
            if qdelay_i > 0
                % the one point space S1 is to deal with a bug of tektronix
                % awg5k: if the first points of a waveform is not zero,
                % the awg will output this value instaed of zero
                % in between triggers, which is effective a dc
                DCI = [DCI S]; 
                DCQ = [S DCQ];
                I = [I S] + DCI;
                Q = [S Q] + DCQ;
                Q.t0 = -qdelay_r;
                obj.Param_DCI = ExpParam(DCI,'wvlist{1}.amp');
                obj.Param_DCQ = ExpParam(DCQ,'wvlist{2}.amp');
                obj.Param_I_Amp = ExpParam(I,'waveform1.wvlist{1}.amp');
                obj.Param_Q_Amp = ExpParam(Q,'waveform1.wvlist{2}.amp');
                obj.Param_Q_Phase = ExpParam(Q,'waveform1.wvlist{2}.phase');
            elseif qdelay_i < 0
                DCI = [S DCI];
                DCQ = [DCQ S];
                I = [S I] + DCI;
                Q = [Q S] + DCQ;
                obj.Param_DCI = ExpParam(DCI,'wvlist{2}.amp');
                obj.Param_DCQ = ExpParam(DCQ,'wvlist{1}.amp');
                obj.Param_I_Amp = ExpParam(I,'waveform1.wvlist{2}.amp');
                obj.Param_Q_Amp = ExpParam(Q,'waveform1.wvlist{1}.amp');
                obj.Param_Q_Phase = ExpParam(Q,'waveform1.wvlist{1}.phase');
            else
                DCI = [DCI S]; 
                DCQ = [S DCQ];
                I = [I S] + DCI;
                Q = [S Q] + DCQ;
                obj.Param_DCI = ExpParam(DCI,'wvlist{1}.amp');
                obj.Param_DCQ = ExpParam(DCQ,'wvlist{2}.amp');
                obj.Param_I_Amp = ExpParam(I,'waveform1.wvlist{1}.amp');
                obj.Param_Q_Amp = ExpParam(Q,'waveform1.wvlist{2}.amp');
                obj.Param_Q_Phase = ExpParam(Q,'waveform1.wvlist{2}.phase');
            end
            
            obj.Param_DCI.callbacks = {@(x) x.expobj.Off(), @(x) x.expobj.DoAll(),@(x) pause(0.25)};
            obj.Param_DCQ.callbacks = obj.Param_DCI.callbacks;
            obj.Param_I_Amp.callbacks = obj.Param_DCI.callbacks;
            obj.Param_Q_Amp.callbacks = obj.Param_DCI.callbacks;
            obj.Param_Q_Phase.callbacks = obj.Param_DCI.callbacks;

            DCI.name = 'DCI_for_IQMixerCalibration';
            DCQ.name = 'DCQ_for_IQMixerCalibration';
            I.name = 'I_for_IQMixerCalibration';
            Q.name = 'Q_for_IQMixerCalibration';
        end
        function set.freq(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val)
                error('IQMixerCalibrate:SetError','Invalid frequency value.');
            end
            if isempty(obj.i_awg) || isempty(obj.q_awg)
                error('IQMixerCalibrate:SetError','awgs must be set before setting freq.');
            end
            if abs(val) > obj.i_awg.smplrate || abs(val) > obj.q_awg.smplrate
                warning('IQMixerCalibrate:OutOfLimit','Frequency value might be out of feasible range.');
            end
            obj.freq = val;
            obj.I.period = obj.i_awg.smplrate/obj.freq;
            obj.Q.period = obj.q_awg.smplrate/obj.freq;
            obj.results.freq = val;
        end
        function set.lo_source(obj,val)
            if ~isa(val,'MWSource') || ~IsValid(val)
                error('IQMixerCalibrate:SetError','Invalid lo_source.');
            end
            obj.lo_source = val;
            obj.results.lo_source = val.name;
        end
        function set.lo_freq(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                error('IQMixerCalibrate:SetError','Invalid frequency value.');
            end
            if val < obj.freq
                warning('IQMixerCalibrate:OutOfLimit','Frequency value might be out of feasible range.');
                return;
            end
            if isempty(obj.lo_source)
                error('IQMixerCalibrate:SetError','lo_source not set.');
            end
            obj.lo_source.frequency = val;
            obj.lo_source.on = true;
            obj.lo_freq = val;
            obj.results.lo_freq = val;
        end
        function val = get.lo_freq(obj)
            val = obj.lo_source.frequency;
        end
        function set.lo_power(obj,val)
            if isempty(obj.lo_source)
                error('IQMixerCalibrate:SetError','lo_source not set.');
            end
            obj.lo_source.power = val;
            obj.lo_power  = val;
            obj.results.lo_power = val;
        end
        function val = get.lo_power(obj)
            val = obj.lo_source.power;
        end
        function set.i_awg(obj,val)
            if ~isa(val,'AWG') || ~IsValid(val)
                error('IQMixerCalibrate:InvalidInput','i_awg should be a valid AWG class object!');
            end
            val.runmode = 4; % continues;
            obj.i_awg = val;
            if ~isempty(obj.freq)
                obj.I.period = obj.i_awg.smplrate/obj.freq;
            end
%             obj.results.i_awg = HandleQES.ToStruct(val);
            obj.results.i_awg = val.name;
        end
        function set.q_awg(obj,val)
            if ~isa(val,'AWG') || ~IsValid(val)
                error('IQMixerCalibrate:InvalidInput','q_awg should be a valid AWG class object!');
            end
            val.runmode = 4; % continues;
            obj.q_awg = val;
            if ~isempty(obj.freq)
                obj.Q.period = obj.q_awg.smplrate/obj.freq;
            end
%             obj.results.i_awg = HandleQES.ToStruct(val);
            obj.results.q_awg = val.name;
        end
        function set.i_chnl(obj,val)
            if isempty(val)
                error('IQMixerCalibrate:InvalidInput','empty value!');
            end
            if ceil(val) ~=val || val <=0
                error('IQMixerCalibrate:InvalidInput','awgchnl should be a positive integer!');
            end
            if isempty(obj.i_awg) || ~IsValid(obj.i_awg)
                error('IQMixerCalibrate:InvalidInput', 'i_awg not set or not valid, set i_awg first!');
            end
            if  isempty(obj.i_awg.nchnls) || val > obj.i_awg.nchnls
                error('IQMixerCalibrate:InvalidInput','channel number inconsistent with the awg object or number of channels of the awg object not set!');
            end
            obj.i_chnl = val;
            obj.results.i_chnl = val;
        end
        function set.q_chnl(obj,val)
            if isempty(val)
                error('IQMixerCalibrate:InvalidInput','empty value!');
            end
            if ceil(val) ~=val || val <=0
                error('IQMixerCalibrate:InvalidInput','awgchnl should be a positive integer!');
            end
            if isempty(obj.q_awg) || ~IsValid(obj.q_awg)
                error('IQMixerCalibrate:InvalidInput', 'q_awg not set or not valid, set q_awg first!');
            end
            if  isempty(obj.q_awg.nchnls) || val > obj.q_awg.nchnls
                error('IQMixerCalibrate:InvalidInput','channel number inconsistent with the awg object or number of channels of the awg object not set!');
            end
            obj.q_chnl = val;
            obj.results.q_chnl = val;
        end
        function set.amp(obj,val)
            assert(val>0);
            obj.amp = val;
            obj.I.amp = val;
            obj.Q.amp = val;
            obj.results.amp = val;
        end
        function set.i_wiring(obj,val)
            obj.i_wiring = val;
            obj.results.i_wiring = val;
        end
        function set.q_wiring(obj,val)
            obj.q_wiring = val;
            obj.results.q_wiring = val;
        end
        function set.lo_wiring(obj,val)
            obj.lo_wiring = val;
            obj.results.lo_wiring = val;
        end
        function set.mixer(obj,val)
            obj.mixer = val;
            obj.results.mixer = val;
        end
%         function set.qdelay(obj,val) %  obsolete since continues waveform is used
%         for calibration, delay has no effect other than an extra phase
%         difference.
%             if isempty(val)
%                 error('IQMixerCalibrate:InvalidInput','empty value!');
%             end
%             val = val(1);
%             if ceil(val) ~= val
%                 warning('IQMixerCalibrate:ImproperInput', 'qdelay value rounded to integer!');
%                 val = ceil(val);
%             end
%             obj.qdelay = val;
%             obj.S.length = val;
%             obj.results.qdelay = val;
%         end
        function Run(obj)
            Run@Measurement(obj);
%             obj.ZeroCalibration();
            obj.PhaseCalibration();
            obj.data = obj.results;
            obj.dataready = true;
        end
        ZeroCalibration(obj)
        PhaseCalibration(obj)
        LinearCalibration(obj)
    end
end