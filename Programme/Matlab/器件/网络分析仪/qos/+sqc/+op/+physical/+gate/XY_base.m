classdef (Abstract = true) XY_base < sqc.op.physical.operator
    % base class of XY group gates
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp
        f01 % expose qubit setting f01 for tunning
        phaseOffset=0 % phaseOffset: expose phase offset for tuning
        % phaseOffset is a reference phase, it is the same for all xy gates
        % unless delibrately changed by the user for tuning purpos,
        % the phase property is gate type specific: 0 for X, pi/2 for Y
        % etc., actually it defined the gate type, tus it is private and
        % can not be changed.
    end
    properties (SetAccess = protected, GetAccess = private)
        phase
    end
    methods
        function obj = XY_base(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.f01 = obj.qubits{1}.f01;
            obj.phase = 0;
            obj.phaseOffset = obj.qubits{1}.g_XY_phaseOffset;
        end
    end
    methods
%         function set.phase(obj,val)
%             obj.phase = obj.phaseOffset + val;
%         end
    end
    methods (Hidden = true)
        function GenWave(obj)
            wvArgs = {obj.length,obj.amp};
            wvSettings = struct(obj.qubits{1}.qr_xy_wvSettings); % use struct() so we won't fail in case of empty
            fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				wvArgs{end+1} = wvSettings.(fnames{ii});
            end
            wv = feval(['qes.waveform.',obj.qubits{1}.qr_xy_wvTyp],wvArgs{:});
            if obj.qubits{1}.qr_xy_dragPulse
                wv = qes.waveform.fcns.DRAG(wv,...
                                            obj.qubits{1}.qr_xy_dragAlpha);
            end
            
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.hwdriver.hardware.FindHwByName(obj.qubits{1}.channels.xy_i.instru);
%                 da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
%                         'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_daChnl{1,1} = da.GetChnl(obj.qubits{1}.channels.xy_i.chnl);
            obj.xy_daChnl{2,1} = da.GetChnl(obj.qubits{1}.channels.xy_q.chnl);
            
            wv.phase = obj.phaseOffset + obj.phase;
            wv.carrierFrequency = (obj.f01-obj.mw_src_frequency(1))/obj.xy_daChnl{1,1}.samplingRate;
            obj.xy_wv{1} = qes.waveform.sequence(wv);
            
            obj.loFreq = obj.mw_src_frequency(1);
            obj.loPower = obj.mw_src_power(1);
            obj.sbFreq = wv.carrierFrequency;
        end
    end
end