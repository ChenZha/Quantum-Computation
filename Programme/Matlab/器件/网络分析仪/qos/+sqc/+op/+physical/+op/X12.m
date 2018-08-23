classdef X12 < sqc.op.physical.operator
    % pi pulse between |1> and |2>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp % expose qubit setting g_X_amp for tunning
        f02 % expose qubit setting f02 for tunning
    end
    methods
        function obj = X12(qubit)
			assert(numel(qubit) == 1);
            obj = obj@sqc.op.physical.operator(qubit);
			obj.length = obj.qubits{1}.g_XY_ln;
            obj.amp = obj.qubits{1}.g_X12_amp;
            obj.f01 = obj.qubits{1}.f02;
        end
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
            
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_daChnl{1,1} = da.GetChnl(obj.qubits{1}.channels.xy_i.chnl);
            obj.xy_daChnl{2,1} = da.GetChnl(obj.qubits{1}.channels.xy_q.chnl);
            
            wv.phase = obj.qubits{1}.g_XY_phaseOffset;
            wv.carrierFrequency = (obj.f02 - obj.qubits{1}.f01 - obj.mw_src_frequency(1))/...
                obj.xy_daChnl{1,1}.samplingRate;
            
            obj.xy_wv{1} = qes.waveform.sequence(wv);
        end
    end
end