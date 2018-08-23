classdef mwDrive4Spectrum < sqc.op.physical.operator
    % mw drive for spectrum, a long mw driving pulse with very weak amplitude
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        ln
        amp % expose qubit setting spc_driveAmp for tunning
    end
    methods
        function obj = mwDrive4Spectrum(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.mw_src_power = obj.qubits{1}.qr_xy_uSrcPower;
            obj.amp = obj.qubits{1}.spc_driveAmp;
			obj.length = obj.qubits{1}.spc_driveLn;
        end
        function set.ln(obj,val)
            obj.length = val+2*obj.qubits{1}.spc_zLonger;
        end
        function val = get.ln(obj)
            val = obj.length-2*obj.qubits{1}.spc_zLonger;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            wv = qes.waveform.flattop(obj.length,...
                obj.amp,obj.qubits{1}.spc_driveRise);
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_daChnl{1,1} = da.GetChnl(obj.qubits{1}.channels.xy_i.chnl);
            obj.xy_daChnl{2,1} = da.GetChnl(obj.qubits{1}.channels.xy_q.chnl);
            
            wv.carrierFrequency = obj.qubits{1}.spc_sbFreq/obj.xy_daChnl{1,1}.samplingRate;
			wv.phase = 0;
			% S = qes.waveform.spacer(obj.qubits{1}.spc_zLonger);
            S = qes.waveform.spacer(obj.qubits{1}.spc_zLonger+1);
			obj.xy_wv{1} = [S,wv,S];
            
            obj.loFreq = obj.mw_src_frequency(1);
            obj.loPower = obj.mw_src_power(1);
            obj.sbFreq = wv.carrierFrequency;
        end
    end
end