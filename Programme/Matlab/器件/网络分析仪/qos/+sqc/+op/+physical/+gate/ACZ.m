classdef ACZ < sqc.op.physical.operator
    % adiabatic controled Z gate
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
        aczLn % length of the acz pulse, pad length and meetup longer not included
        
        amp
        thf
        thi
        lam2
        lam3
    end
    properties (SetAccess = private)
        detuneFreq
        detuneLonger
		padLn
        
        ampInDetune
        maxF01
        k
    end
    properties (SetAccess = private, GetAccess = private)
        
    end
    methods
        function obj = ACZ(q1, q2)
            if q1 == q2
                error('perform two qubit gate ACZ on the same qubit is not possible.');
            end
            czs = sqc.qobj.aczSettings(sprintf('%s_%s',q1.name,q2.name));
            ind1 = qes.util.find(czs,q1.aczSettings);
            if isempty(ind1)
                ind2 = qes.util.find(czs,q2.aczSettings);
            end
            
            if isempty(ind1) && isempty(ind2)
				czs.load();
            else
				if ~isempty(ind1)
					czs = q1.aczSettings(ind1);
				else
					czs = q1.aczSettings(ind2);
				end
            end
            
            numQs = numel(czs.qubits);
            qubits_ = cell(1,numQs);
			
			qRegs = sqc.qobj.qRegisters.GetInstance();
            for ii = 1:numQs
                qubits_{ii} = qRegs.get(czs.qubits{ii});
            end
            
            obj = obj@sqc.op.physical.operator(qubits_);
            obj.amp = czs.amp;
            obj.thf = czs.thf;
            obj.thi = czs.thi;
            obj.lam2 = czs.lam2;
            obj.lam3 = czs.lam3;
            obj.padLn = czs.padLn;
            if numel(czs.dynamicPhases) ~= numQs
                throw(MException('QOS_ACZ:invalidACZSettings',...
                            'number of dynamic phases not matching the number of qubits'));
            end
            obj.phaseShift = czs.dynamicPhases;
            obj.detuneFreq = czs.detuneFreq;
            obj.detuneLonger = czs.detuneLonger;
            
            obj.ampInDetune = czs.ampInDetune;
            if obj.ampInDetune
                zpa2f01 = qubits_{1}.zpls_amp2f01;
                maxF01 = polyval(zpa2f01,roots(polyder(zpa2f01)));
                if qubits_{1}.f01 > maxF01
                    if obj.f01 - maxF01 > 3e6
                        throw(MException('QOS_ACZ:invalidzplsamp2f01',...
                            sprintf('f01 greater than maximum of zpls_amp2f01(>3Mz) for qubit %s.', q.name)));
                    else
                        maxF01 = qubits_{1}.f01;
                    end
                end
                obj.maxF01 = maxF01;
                obj.k = 1/sqrt(-zpa2f01(1));
                if roots(polyder(zpa2f01)) + sqc.util.zpa2f01Shift(qubits_{1}) > 0
                    obj.k = -obj.k;
                end
            else
                obj.maxF01 = qubits_{1}.f01;
                obj.k = 0;
            end

            obj.aczLn = czs.aczLn; % must be after the setting of meetUpLonger, padLn and detuneLonger
            obj.gateClass = 'CZ';

        end
        function set.aczLn(obj,val)
            obj.aczLn = val;
            obj.length = val+sum(obj.padLn)+2*max(obj.detuneLonger);
        end
    end
	methods (Hidden = true)
        function GenWave(obj)
            aczWv = qes.waveform.acz(obj.aczLn, obj.amp, obj.thf, obj.thi, obj.lam2, obj.lam3,...
                obj.ampInDetune, obj.qubits{1}.f01, obj.maxF01, obj.k);
            maxDetuneLonger = max(obj.detuneLonger);
            padWv1 = qes.waveform.spacer(obj.padLn(1)+maxDetuneLonger);
            padWv2 = qes.waveform.spacer(obj.padLn(2)+maxDetuneLonger);
            obj.z_wv{1} = [padWv1, aczWv, padWv2];

            persistent da1
            if isempty(da1)
                da1 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_daChnl{1} = da1.GetChnl(obj.qubits{1}.channels.z_pulse.chnl);
			
%             persistent da2
%             if obj.meetUpDetuneFreq ~= 0
%                 wvArgs = {obj.aczLn+2*obj.meetUpLonger,...
%                     sqc.util.detune2zpa(meetUp_q,obj.meetUpDetuneFreq)};
%                 wvSettings = struct(meetUp_q.g_detune_wvSettings); % use struct() so we won't fail in case of empty
%                 fnames = fieldnames(wvSettings);
%                 for ii = 1:numel(fnames)
%                     wvArgs{end+1} = wvSettings.(fnames{ii});
%                 end
%                 meetupWv = feval(['qes.waveform.',meetUp_q.g_detune_wvTyp],wvArgs{:});
%                 
% %                 meetupWv = qes.waveform.rect(obj.aczLn+2*obj.meetUpLonger,...
% %                     sqc.util.detune2zpa(meetUp_q,obj.meetUpDetuneFreq));
% 
%                 padWv3 = qes.waveform.spacer(obj.padLn(1)+obj.detuneLonger);
%                 padWv4 = qes.waveform.spacer(obj.padLn(2)+obj.detuneLonger);
%                 
%                 obj.z_wv{2} = [padWv3,meetupWv,padWv4];
%                 if isempty(da2)
%                     da2 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
%                             'name',meetUp_q.channels.z_pulse.instru);
%                 end
%                 obj.z_daChnl{2} = da2.GetChnl(meetUp_q.channels.z_pulse.chnl);
%             end

            for ii = 2:numel(obj.detuneFreq)+1
                if obj.detuneFreq(ii-1) ~= 0
                    wvArgs = {obj.aczLn+2*obj.detuneLonger(ii-1),...
                        sqc.util.detune2zpa(obj.qubits{ii},obj.detuneFreq(ii-1))};
                    wvSettings = struct(obj.qubits{ii}.g_detune_wvSettings); % use struct() so we won't fail in case of empty
                    fnames = fieldnames(wvSettings);
                    for jj = 1:numel(fnames)
                        wvArgs{end+1} = wvSettings.(fnames{jj});
                    end
                    detuneWv = feval(['qes.waveform.',obj.qubits{ii}.g_detune_wvTyp],wvArgs{:});
                    
%                     detuneWv = qes.waveform.rect(obj.aczLn+2*obj.meetUpLonger+2*obj.detuneLonger,...
%                         sqc.util.detune2zpa(obj.qubits{ii},obj.detuneFreq(ii-2)));

                    padWv3 = qes.waveform.spacer(obj.padLn(1)+maxDetuneLonger-obj.detuneLonger(ii-1));
                    padWv4 = qes.waveform.spacer(obj.padLn(2)+maxDetuneLonger-obj.detuneLonger(ii-1));
                    obj.z_wv{ii} = [padWv3,detuneWv,padWv4];
                    % obj.z_wv{ii} = detuneWv ;
                    da2 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                                'name',obj.qubits{ii}.channels.z_pulse.instru);
                    obj.z_daChnl{ii} = da2.GetChnl(obj.qubits{ii}.channels.z_pulse.chnl);
                end
            end
        end
    end
end