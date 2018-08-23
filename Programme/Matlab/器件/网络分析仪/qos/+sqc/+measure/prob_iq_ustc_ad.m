classdef prob_iq_ustc_ad < qes.measurement.prob
    % rename this class to events_iq_ustc_ad
    % this class measures the state of each shots(events)
    % data(k,:) is a 1 by n(number of shots), the single shot events of
    % the kth qubit: 0 for |0>,  1 for |1>, 2 for |2>
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        n
        threeStates@logical scalar = false % {|0>, |1>} system or {|0>, |1>, |2>} system
		iqAsExtraData@logical scalar = true % raw iq as extradata or event states as extradata
    end
    properties (SetAccess = private)
        qubits % qubit objects or qubit names
		
		jointReadout@logical scalar = false
		
		stateNames
        % convert to intrinsic state probability by using measurement
        % fidelity or not, this property can only be set by registry
        % setting: r_iq2prob_intrinsic
        intrinsic = false
    end
    properties (SetAccess = private, GetAccess = protected)
        num_qs
		center0
		center1
		center2
        
        invFMat
        
%        ref_angle % r_iq2prob_01rAngle
%        ref_point % r_iq2prob_01rPoint
%        threshold % r_iq2prob_01threshold
%        polarity % r_iq2prob_01polarity
    end
    methods
        function obj = prob_iq_ustc_ad(iq_ustc_ad_obj,qs,jointReadout)
            obj = obj@qes.measurement.prob(iq_ustc_ad_obj);
			if nargin > 2
				obj.jointReadout = jointReadout;
			end
            obj.n = iq_ustc_ad_obj.n;
            obj.numericscalardata = false;
            obj.qubits = qs;
			
			if obj.jointReadout
				obj.stateNames = cell(1,2^obj.num_qs);
				for ii = 0:2^obj.num_qs-1
					obj.stateNames{ii+1} = sprintf('|%s>',dec2bin(ii,obj.num_qs));
				end
				intrinsic_ = sqc.util.samePropVal(qs,{'r_iq2prob_intrinsic'});
				if numel(qs) > 1 && ~intrinsic_
					throw(MException('QOS_prob_iq_ustc_ad_j:settingsMismatch',...
						'the qubits to readout has different r_iq2prob_intrinsic setting.'));
				end
				obj.intrinsic = obj.qubits{1}.r_iq2prob_intrinsic;
				if obj.intrinsic
					F00 = obj.qubits{1}.r_iq2prob_fidelity(1);
					F11 = obj.qubits{1}.r_iq2prob_fidelity(2);
					fMat = [F00,1-F11;1-F00,F11];
					for ii = 2:numel(obj.qubits)
						F00 = obj.qubits{ii}.r_iq2prob_fidelity(1);
						F11 = obj.qubits{ii}.r_iq2prob_fidelity(2);
						fMat_ = [F00,1-F11;1-F00,F11];
						fMat = kron(fMat_,fMat);
					end
					obj.invFMat = inv(fMat);
				end
			else
				if obj.threeStates
					obj.stateNames = {'|0>','|1>'};
				else
					obj.stateNames = {'|0>','|1>','|2>'};
				end
				obj.invFMat = cell(1,obj.num_qs);
				for ii = 1:obj.num_qs
					if obj.qubits{ii}.r_iq2prob_intrinsic
						F00 = obj.qubits{ii}.r_iq2prob_fidelity(1);
						F11 = obj.qubits{ii}.r_iq2prob_fidelity(2);
						obj.invFMat{ii} = inv([F00,1-F11;1-F00,F11]);
					end
				end
			end
        end
        
%         function obj = prob_iq_ustc_ad(qubits)
%             if ~iscell(qubits)
%                 if ~ischar(qubits) && ~isa(qubits,'sqc.qobj.qubit')
%                     throw(MException('prob_iq_ustc_ad:invalidInput',...
% 						'the input qubits should be a cell array of qubit objects or qubit names.'));
%                 else
%                     qubits = {qubits};
%                 end
%             end
% 			for ii = 1:numel(qubits)
% 				if ischar(qubits{ii})
% 					qubits{ii} = sqc.util.qName2Qubit(qubits{ii});
% 				end
%             end
%             prop_names = {{'channels','r_ad_i','instru'},{'channels','r_ad_q','instru'},...
%                 {'channels','r_ad_i','chnl'},{'channels','r_ad_q','chnl'}};
%             b = sqc.util.samePropVal(qubits,prop_names);
%             if ~all(b)
%                 throw(MException('prob_iq_ustc_ad:settingsMismatch','the qubits to readout has different AD setting.'));
%             end
%             
%             da_i_chnl_ = qubits{1}.channels.r_da_i.chnl;
%             da_q_chnl_ = qubits{1}.channels.r_da_q.chnl;
%             if da_i_chnl_ == da_q_chnl_
%                 throw(MException('resonatorReadout:daChnlSettingError',...
% 					'can not output I and Q on the same channel.'));
%             end
% 
%             ad_i_names = qubits{1}.channels.r_ad_i.instru;
%             ad_q_names = qubits{1}.channels.r_ad_q.instru;
%             if ~strcmp(ad_q_names,ad_i_names)
%                 throw(MException('resonatorReadout:adMismatch',...
% 					'can not digitize I and Q on different ADs.'));
%             end
% 
%             ad_i_chnl_ = qubits{1}.channels.r_ad_i.chnl;
%             ad_q_chnl_ = qubits{1}.channels.r_ad_q.chnl;
%             if ad_i_chnl_ == ad_q_chnl_
%                 throw(MException('resonatorReadout:adChnlSettingError',...
% 					'can not digitize I and Q with the same channel.'));
%             end
%             
%             ad = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',ad_i_names);
%             da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',da_i_names);
% 			
% 			ad_i_chnl_ = ad.GetChnl(ad_i_chnl_);
% 			ad_q_chnl_ = ad.GetChnl(ad_q_chnl_);
%             
%             da_i_chnl_ = da.GetChnl(da_i_chnl_);
%             da_q_chnl_ = da.GetChnl(da_q_chnl_);
%             assert(da_i_chnl_.samplingRate == da_q_chnl_.samplingRate);
% 			
%             rs = ad_i_chnl_.samplingRate/da_i_chnl_.samplingRate;
% 			rln = ceil(rs*(qubits{1}.r_ln+ad_i_chnl_.delayStep)); % maximum startidx increment is ad.delayStep, in da sampling points
%             ad_i_chnl_.recordLength = rln;
%             ad_q_chnl_.recordLength = rln;
%             
%             iq_obj = sqc.measure.iq_ustc_ad(ad_i_chnl_,ad_q_chnl_);
%             iq_obj.n = qubits{1}.r_avg;
%             
%             demod_freq = zeros(1,num_qubits);
%             
%             for ii = 1:num_qubits
%                 demod_freq(ii) = qubits{ii}.r_freq- qubits{1}.r_fc;
%             end
%             iq_obj.freq = demod_freq;
%             
%             obj = obj@qes.measurement.prob(iq_ustc_ad_obj);
%             obj.n = iq_ustc_ad_obj.n;
%             obj.numericscalardata = false;
%             obj.qubits = qs;
%         end
        
        function set.qubits(obj,val)
            if ~iscell(val) && ischar(val)
                val = {val};
            end
            selected_qubits = sqc.util.loadQubits();
            num_qs_ = numel(val);
			obj.num_qs = num_qs_;
            qs = cell(1,num_qs_);
            for ii = 1:num_qs_
                if ~ischar(val{ii})
                    if ~isa(val{ii},'sqc.qobj.qobject')
                        error('input not a qubit.');
                    else
                        qs{ii} = val{ii}; % accepts qubit objects, typically virtual qubits
                        continue;
                    end
                end
                if ~qes.util.ismember(val{ii},selected_qubits)
                    if ischar(val{ii})
                        error('%s is not one of the selected qubits.',val{ii});
                    else
                        error('%s is not one of the selected qubits.',val{ii}.name);
                    end
                end
                qs{ii} = selected_qubits{qes.util.find(val{ii},selected_qubits)};
            end
            obj.qubits = qs;
			center0_ = zeros(1,num_qs_);
            center1_ = zeros(1,num_qs_);
            center2_ = zeros(1,num_qs_);
            for ii = 1:num_qs_
                center0_(ii) = obj.qubits{ii}.r_iq2prob_center0;
                center1_(ii) = obj.qubits{ii}.r_iq2prob_center1;
                center2_(ii) = obj.qubits{ii}.r_iq2prob_center2;
            end
            obj.center0 = center0_;
            obj.center1 = center1_;
            obj.center2 = center2_;
			
%            ref_angle_ = zeros(1,num_qs);
%            ref_point_ = zeros(1,num_qs);
%            threshold_ = zeros(1,num_qs);
%            polarity_ = zeros(1,num_qs);
%            for ii = 1:num_qs
%                ref_angle_(ii) = obj.qubits{ii}.r_iq2prob_01angle;
%                ref_point_(ii) = obj.qubits{ii}.r_iq2prob_01rPoint;
%                threshold_(ii) = obj.qubits{ii}.r_iq2prob_01threshold;
%                polarity_(ii) = obj.qubits{ii}.r_iq2prob_01polarity;
%            end
%            obj.ref_angle = ref_angle_;
%            obj.ref_point = ref_point_;
%            obj.threshold = threshold_;
%            obj.polarity = polarity_;
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('n should be a positive integer!');
            end
            obj.instrumentObject.n = val;
            obj.n = val;
        end
        function Run(obj)
            Run@qes.measurement.prob(obj);
            obj.instrumentObject.Run();
            iq_raw = obj.instrumentObject.extradata;
			if obj.threeStates
				p = zeros(obj.num_qs,obj.n);
                for ii = 1:obj.num_qs
                    d0 = abs(iq_raw(ii,:) - obj.center0);
                    d1 = abs(iq_raw(ii,:) - obj.center1);
                    d2 = abs(iq_raw(ii,:) - obj.center2);
                    [~,minIdx] = min([d0; d1; d2],[],1);
					p(ii,:) = minIdx-1;
                end
%                 p1 = zeros(1,obj.num_qs);
%                 for ii = 1:obj.num_qs
%                     if obj.polarity(ii) <0
%                         p1(ii) = mean((iq_raw{ii} - obj.ref_point(ii))*exp(-1j*obj.ref_angle(ii)) > obj.threshold(ii));
%                     else
%                         p1(ii) = mean((iq_raw{ii} - obj.ref_point(ii))*exp(-1j*obj.ref_angle(ii)) < obj.threshold(ii));
%                     end
%                 end
            else
				p = zeros(obj.num_qs,obj.n);
                for ii = 1:obj.num_qs
                    d0 = abs(iq_raw(ii,:) - obj.center0(ii));
                    d1 = abs(iq_raw(ii,:) - obj.center1(ii));
                    [~,minIdx] = min([d0; d1],[],1);
					p(ii,:) = minIdx-1;
                end
            end
            obj.data = p;
			if obj.iqAsExtraData
				obj.extradata = iq_raw; % raw iq data
			else
				obj.extradata = obj.data; % event states
			end
			if obj.jointReadout
				obj.DataProcessing_j();
			else
				obj.DataProcessing_i();
			end
            obj.dataready = true;
        end
    end
	methods (Access = private)
		function DataProcessing_j(obj)
			if obj.threeStates
				throw(MException('prob_iq_ustc_ad:jointReadoutThreeStates',...
					'joint readout of three states is not implemented.'));
			end
			d = 2.^(0:obj.num_qs-1)*obj.data;
			numStates = 2^obj.num_qs;
			obj.data = zeros(1,numStates);
			for ii = 0:numStates-1
				obj.data(ii+1) = sum(d==ii)/obj.n;
            end
            if obj.intrinsic
                obj.data = (obj.invFMat*obj.data.').';
            end
        end
		function DataProcessing_i(obj)
			data_ = nan(obj.num_qs,2);
			for ii = 1:obj.num_qs
				P1 = sum(obj.data(ii,:))/obj.n;
				p = [1-P1;P1];
				if ~isempty(obj.invFMat{ii})
					p = obj.invFMat{ii}*p;
				end
				data_(ii,:) = p.';
            end
            obj.data = data_;
        end
	end
end