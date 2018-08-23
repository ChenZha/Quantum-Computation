classdef (Abstract = true) Z_z_base < sqc.op.physical.operator
    % base class for z gates implement by using the z line
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp % expose qubit setting g_Z<?>_z_amp for tunning
    end
    methods
        function obj = Z_z_base(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
     
            wvArgs = {obj.length,obj.amp};
            wvSettings = struct(obj.qubits{1}.qr_z_wvSettings); % use struct() so we won't fail in case of empty
            fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				wvArgs{end+1} = wvSettings.(fnames{ii});
            end
%             s1 = qes.waveform.spacer(g.g_Z_z_padLn(1));
%             s2 = qes.waveform.spacer(g.g_Z_z_padLn(2));
%             obj.z_wv{1} = [s1,...
%                 feval(['qes.waveform.',obj.qubits{1}.qr_z_wvTyp],wvArgs{:}),...
%                 s2];
            obj.z_wv{1} = qes.waveform.sequence(...
                feval(['qes.waveform.',obj.qubits{1}.qr_z_wvTyp],wvArgs{:}));
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.hwdriver.hardware.FindHwByName(obj.qubits{1}.channels.z_pulse.instru);
%                 da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
%                         'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_daChnl{1} = da.GetChnl(obj.qubits{1}.channels.z_pulse.chnl);
        end
    end
end