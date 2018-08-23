classdef detune < sqc.op.physical.gate.Z_z_base
    % detune pulse
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	properties
		ln=0 % length
		df=0 % detune amplitude
	end
    methods
        function obj = detune(qubit)
            obj = obj@sqc.op.physical.gate.Z_z_base(qubit);
        end
		function set.ln(obj,ln)
			obj.ln = ln;
			obj.length = ln;
		end
    end
	methods (Hidden = true)
        function GenWave(obj)
            
            amp = obj.df;
            % todo..
            % amp = sqc.util.detune2zpa(obj.qubits{1},obj.df);
            
            obj.z_wv{1} = qes.waveform.sequence(...
                qes.waveform.flattop(obj.length, amp,5));
            
            
% 
%             if false  % TODO
%                 obj.z_wv{1}.amp = sqc.util.detune2zpa(obj.qubits{1},obj.df);
%             else
%                 if obj.df
%                      throw(MException('QOS_op:zplsamp2f01NotSet',...
%                         sprintf('can not generate non zero detuning(%0.3fMHz given) pulse as z pulse amplitude to detuning(zpls_amp2f01Df) setting for qubit %s is not set.',...
%                         obj.df/1e6, obj.qubits{1}.name)));
%                 else
%                     obj.z_wv{1}.amp = 0;
%                 end
%             end
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_daChnl{1} = da.GetChnl(obj.qubits{1}.channels.z_pulse.chnl);
        end
    end
end