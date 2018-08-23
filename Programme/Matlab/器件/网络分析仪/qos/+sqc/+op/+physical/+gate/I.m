classdef I < sqc.op.physical.operator
    % I, single qubit
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (Dependent = true)
        ln
    end
    methods
        function obj = I(qubit,ln)
			assert(numel(qubit) == 1);
            obj = obj@sqc.op.physical.operator(qubit);
			if nargin < 2
				obj.length = obj.qubits{1}.g_I_ln;
			else
				obj.length = ln;
			end
            obj.setGateClass('I');
        end
        function set.ln(obj,val)
            obj.length = val;
        end
        function val = get.ln(obj)
            val = obj.length;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            if obj.ln == 0
                return;
            end
            obj.xy_wv{1} = qes.waveform.sequence(...
                qes.waveform.spacer(obj.length));
%             obj.z_wv{1} = qes.waveform.sequence(...
%                 qes.waveform.spacer(obj.length));
            persistent da_xy
            if isempty(da_xy) || ~isvalid(da_xy)
                da_xy = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_daChnl{1,1} = da_xy.GetChnl(obj.qubits{1}.channels.xy_i.chnl);
            obj.xy_daChnl{2,1} = da_xy.GetChnl(obj.qubits{1}.channels.xy_q.chnl);
 
            persistent da_z
            if isempty(da_z) || ~isvalid(da_z)
                da_z = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                    'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_daChnl{1} = da_z.GetChnl(obj.qubits{1}.channels.z_pulse.chnl);
        end
    end
end