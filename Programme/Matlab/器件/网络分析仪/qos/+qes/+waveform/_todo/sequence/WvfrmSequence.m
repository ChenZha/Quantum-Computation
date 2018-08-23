classdef (Abstract = true) WvfrmSequence < QHandle
    % bass class for all waveform sequence classes
    % awg, awgchnl etc are the same as the first waveform of the waveform
    % sequence.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        on
    end
    properties (SetAccess = protected)
        waveforms
        waveformnames
    end
    properties (SetAccess = private, GetAccess = private)
        waveformlength
    end
    methods
        function AddWaveform(obj,waveforms)
            for ii = 1:length(waveforms)
                if ~isa(waveforms(ii),'Waveform')
                    error('WvfrmSequence:InvalidInput','at least one of the waveforms is not a valid Waveform class object');
                end
                if isempty(obj.waveformlength)
                    obj.waveformlength = waveforms(ii).length;
                elseif obj.waveformlength ~= waveforms(ii).length;
                    error('WvfrmSequence:InvalidInput','waveforms are not of the same length');
                end
            end
            obj.waveforms = [obj.waveforms;waveforms(:)];
            obj.waveformnames = [];
            for ii = 1:length(obj.waveforms)
                obj.waveformnames = [obj.waveformnames,{obj.waveforms(ii).name}];
            end
        end
        function SendWave(obj)
            if isempty(obj.waveforms(1).awg) || ~isa(obj.waveforms(1).awg,'AWG')...
                    || ~IsValid(obj.waveforms(1).awg)
                error('WvfrmSequence:SendWaveError','awg of the first waveform must not set or not valid.');
            end
            if isempty(obj.waveforms(1).awgchnl)
                error('WvfrmSequence:SendWaveError','awgchnl of the first waveform must not set.');
            end
            NumWv = length(obj.waveforms);
            Vpp = zeros(1,NumWv);
            for ii = 1:NumWv
                obj.waveforms(ii).GenWave();
                if obj.waveforms(1).dacoffset
                    WvfrmVpp = obj.waveforms(ii).vpp;
                    Offset = obj.waveforms(ii).offset;
                    VHi = Offset + WvfrmVpp/2;
                    VLo = Offset - WvfrmVpp/2;
                    Vpp(ii) = 2*max(abs(VHi),abs(VLo));
                else
                    Vpp(ii) = obj.waveforms(ii).vpp;
                end
            end
            FIXVPP = false;
            FIXVPPVAL = []; 
            if length(unique(Vpp)) > 1
                FIXVPP = true;
                FIXVPPVAL = max(Vpp);
            end
            % send wave while running might very slow.
            obj.waveforms(ii).awg.on = false;
            for ii = 1:NumWv
                obj.waveforms(ii).awg = obj.waveforms(1).awg;
                obj.waveforms(ii).awgchnl = obj.waveforms(1).awgchnl;
                obj.waveforms(ii).fixawgvpp = FIXVPP;
                obj.waveforms(ii).awgvpp = FIXVPPVAL;
                obj.waveforms(ii).SendWave();
            end
        end
        function CreateSequence(obj)
            obj.waveforms(1).awg.CreateSequence(obj.waveforms(1).awgchnl,obj.waveformnames);
        end
        function SetVppOffset(obj)
            obj.waveforms(1).SetVppOffset();
        end
        function set.on(obj,val)
            if isempty(obj.waveforms)
                error('WvfrmSequence:SetError', 'waveform list empty');
            end
            if isempty(val)
                error('WvfrmSequence:SetError', 'value should be a bolean.');
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('WvfrmSequence:SetError', 'value should be a bolean.');
                end
            end
            obj.waveforms(1).on = val;
            obj.on = val;
        end
        function val = get.on(obj)
            if isempty(obj.waveforms)
                error('WvfrmSequence:SetError', 'waveform list empty');
            end
            val = obj.waveforms(1).on;
        end
        function SendCreateSet(obj)
            % do all
            obj.SendWave();
            obj.CreateSequence();
            obj.SetVppOffset();
            obj.on = true;
            obj.waveforms(1).awg.on = true;
        end
    end
end