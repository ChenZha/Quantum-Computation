classdef operator < handle %  & matlab.mixin.Copyable
    % base class of all physical quantum operators.
	% to avoid complication, in mtimes and times all operator properties
	% opened for tuning of the resulting operator are assigned with the according
	% values of the second operand, thus it is a rule to do mtimes and times before
	% tuning those property values.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	% delay_z is problematic for crosstalk qubits that are not in the qubits
	% consider remove delay_ in a future version
    properties % output delays for synchronization tuning, do not confuse with waveform t0
        % xy wave output delay, value in settings 'syncDelay_xy' is automatically
		% added as a small calibration in wave generation, thus should
		% not be included in this value
        % size must be equal to number of qubits
        delay_xy_i
        delay_xy_q
        % z wave output delay, settings 'syncDelay_z' is automatically
		% added as a small calibration in wave generation, thus should
		% not be included in this value
        % size must be equal to number of qubits
		% operators with different delays are not allowed to do mtimes operation
        delay_z  % problematic for crosstalk qubits that are not in the qubits;
        
        logSequenceSamples = false
    end
    properties (SetAccess = protected)
        % for atomic gates we can always use the Class(gate) to get the
        % class of the gate, yet this fails for composit gates, an X gate
        % built upon two X/2 gate for example, thus we use gateClass to
        % store the class of the gate.
        gateClass = 'operator';
		length
    end
    properties (SetAccess = private)
        qubits
		
		mw_src % follow some implicit setting rules, must be private 
        zdc_src % follow some implicit setting rules, must be private
		% buffer time in sampling points between gates, loaded from settings: session#/global/g_buffer.key
		gate_buffer
    end
    properties (SetAccess = protected, GetAccess = public)
%         isStatic = false;
%         wvGenerated = false;
		xy_wv = {}       % order: first applied first to follow the pulse generation time order convention
		xy_daChnl = {}
        loFreq
        loPower
        sbFreq
        z_wv = {}        % order: first applied first to follow the pulse generation time order convention
		z_daChnl = {}
        
        firstRun = true
    end
    properties (SetAccess = protected, GetAccess = protected)
		zdc_amp
% 		% not updated to instrument till Run is called because setting up the instrument in the set methods
%         % will leads to repeatedly setting or querying of the
%         % instrument in building up long processes
%         mw_src_power % will be removed in future versions, change power by mw_src directly
%         mw_src_frequency % will be removed in future versions, change frequency by mw_src directly
        
        phaseShift = 0;
    end
    properties
        mw_src_power % will be removed in future versions, change power by mw_src directly
        mw_src_frequency % will be removed in future versions, change frequency by mw_src directly
    end
    properties (SetAccess = private, GetAccess = private)
		needs_mwpower_setup
		needs_mwfreq_setup
        needs_zdc_setup
        sequenceSampleLogger
    end
    properties (SetAccess = protected, GetAccess = protected,Dependent = true)
        all_qubits
        all_qubits_names
    end
    methods
        function obj = operator(qs)
			% qs: cell array of qubit objects or qubit names
			% to the future: keep a static qubit registry/cache
			% so the common resource like mw soure, dc source etc are not handled repeatedly
            if ~iscell(qs)
                qs = {qs};
            end
            for ii = 1:numel(qs)
				if ischar(qs{ii})
					qs{ii} = obj.all_qubits{qes.util.find(qs{ii},obj.all_qubits)};
					if isempty(qs{ii})
						throw(MException('sqc_op_pysical_operator:invalidInput',...
							'at least one of qubits is not a sqc.qobj.qubit class object or not a valid qubit name.'));
					end
                elseif ~isa(qs{ii},'sqc.qobj.qubit')
                    throw(MException('sqc_op_pysical_operator:invalidInput',...
						'at least one of qubits is not a sqc.qobj.qubit class object.'));
                end
            end
            obj.qubits = qs;
            num_qubits = numel(obj.qubits);
            obj.xy_wv = cell(1,num_qubits);
            obj.loFreq = zeros(1,num_qubits);
            obj.loPower = zeros(1,num_qubits);
            obj.sbFreq = zeros(1,num_qubits);
            obj.z_wv = cell(1,num_qubits);
            obj.xy_daChnl = cell(2,num_qubits);
            obj.z_daChnl = cell(1,num_qubits);
            obj.delay_xy_i = zeros(1,num_qubits);
            obj.delay_xy_q = zeros(1,num_qubits);
            obj.delay_z = zeros(1,num_qubits);
            obj.phaseShift = zeros(1,num_qubits);
            mw_src_ = {};
            mw_src_power_ = [];
            mw_src_frequency_ = [];
            mw_src_names = {};
            mw_src_channels = [];
            zdc_src_ = {};
            zdc_amp_ = zeros(1,num_qubits);
            for ii = 1:num_qubits
                idx = find(strcmp(mw_src_names,obj.qubits{ii}.channels.xy_mw.instru));
                idx_ = find(mw_src_channels(idx) == obj.qubits{ii}.channels.xy_mw.chnl,1);
                if ~isempty(idx_)
                    idx = idx(idx_);
                    if obj.qubits{ii}.qr_xy_uSrcPower ~= mw_src_power_(idx)
                        throw(MException('sqc_op_pysical_operator:settingsMismatch',...
							'some qubits has the same mw source but has different qr_xy_uSrcPower values.'));
                    elseif ~isempty(idx) && obj.qubits{ii}.qr_xy_fc ~= mw_src_frequency_(idx)
                        throw(MException('sqc_op_pysical_operator:settingsMismatch',...
							'some qubits has the same mw source but has different qr_xy_fc values.'));
                    end
                else
                    uSrc = qes.hwdriver.hardware.FindHwByName(obj.qubits{ii}.channels.xy_mw.instru);
% 					uSrc = qes.qHandle.FindByClassProp(...
%                         'qes.hwdriver.hardware','name',obj.qubits{ii}.channels.xy_mw.instru);
                    if isempty(uSrc)
                        throw(MException('sqc_op_pysical_operator:hwNotFound',...
							'mw source %s for qubit %s not found, make sure hardware settings exist and mw source hardware object already created.',...
                        obj.qubits{ii}.channels.xy_mw.instru, obj.qubits{ii}.name));
                    end
                    mw_src_{end+1} = uSrc.GetChnl(obj.qubits{ii}.channels.xy_mw.chnl);
                    mw_src_power_(end+1) = obj.qubits{ii}.qr_xy_uSrcPower;
                    mw_src_frequency_(end+1) = obj.qubits{ii}.qr_xy_fc;
                    mw_src_names{end+1} = uSrc.name;
                    mw_src_channels(end+1) = obj.qubits{ii}.channels.xy_mw.chnl;
                end
                dcSrc = qes.hwdriver.hardware.FindHwByName(obj.qubits{ii}.channels.z_dc.instru);
% 				dcSrc = qes.qHandle.FindByClassProp(...
%                     'qes.hwdriver.hardware','name',obj.qubits{ii}.channels.z_dc.instru);
                if isempty(dcSrc)
                    throw(MException('sqc_op_pysical_operator:hwNotFound',...
							'dc source %s for qubit %s not found, make sure hardware settings exist and dc source hardware object already created.',...
                            obj.qubits{ii}.channels.z_dc.instru, obj.qubits{ii}.name));
                end
                zdc_src_{ii} = dcSrc.GetChnl(obj.qubits{ii}.channels.z_dc.chnl);
%                 zdc_amp2f01_ = obj.qubits{ii}.zdc_amp2f01;
%                 zdc_amp2f01_(end) = zdc_amp2f01_(end) - obj.qubits{ii}.f01(1)/obj.qubits{ii}.zdc_amp2f_freqUnit;
%                 r = roots(zdc_amp2f01_);
%                 r = sort(r(isreal(r)));
%                 if isempty(r)
%                     r = 0;
% %                     throw(MException('sqc_op_pysical_operator:invalidSetting',...
% % 						sprintf('zdc_amp2f01 for qubit %s has no root for f01 of %0.4fGHz.',...
% % 							obj.qubits{ii}.name,obj.qubits{ii}.f01)));
%                 end
%                 if isempty(obj.qubits{ii}.zdc_ampCorrection)
%                     zdc_amp_(ii) = r(1);
%                 else
%                     zdc_amp_(ii) = r(1)+obj.qubits{ii}.zdc_ampCorrection;
%                 end
                zdc_amp_(ii) = obj.qubits{ii}.zdc_amp;
            end
            obj.mw_src = mw_src_;
            obj.mw_src_power = mw_src_power_;
            obj.mw_src_frequency = mw_src_frequency_;
            obj.zdc_src = zdc_src_;
            obj.zdc_amp = zdc_amp_;
        end
		function set.length(obj,val)
			if numel(val) ~= 1 || val < 0 || round(val) ~= val
				throw(MException('sqc_op_pysical_operator:invalidInput',...
					'length not a non negative scalar interger.'));
            end
            obj.length = val;
		end
        function set.delay_xy_i(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_i size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_i must be non negative.'));
            end
            obj.delay_xy_i = val;
        end
        function set.delay_xy_q(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_q size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_q must be non negative.'));
            end
            obj.delay_xy_q = val;
        end
        function set.delay_z(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_z size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_z must be non negative.'));
            end
            obj.delay_z = val;
        end
		function set.mw_src(obj,val)
			% has some implicit rules, thus kept private
            numExistingMwSrc = numel(obj.mw_src);
			numMwSrc2Add = numel(val)-numExistingMwSrc;
			obj.mw_src = val;
			if numMwSrc2Add
				obj.needs_mwpower_setup = ...
					[obj.needs_mwpower_setup,...
					logical(zeros(1,numMwSrc2Add))];
				obj.mw_src_power = [obj.mw_src_power,...
					NaN*zeros(1,numMwSrc2Add)];
                obj.needs_mwfreq_setup = ...
					[obj.needs_mwfreq_setup,...
					logical(zeros(1,numMwSrc2Add))];
				obj.mw_src_frequency = [obj.mw_src_frequency,...
					NaN*zeros(1,numMwSrc2Add)];
			end
		end
        function set.mw_src_power(obj,val)
			% has some implicit rules, thus kept private
			numMwSrc = numel(obj.mw_src);
            if numel(val) ~= numMwSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of mw_src_power not matching the numbers of mw_src.'));
            end
			numExistingMwSrc = numel(obj.mw_src_power);
			for ii = 1:numMwSrc
% 				if ii <= numExistingMwSrc && obj.mw_src_power(ii) == val(ii)
% 					obj.needs_mwpower_setup(ii) = obj.needs_mwpower_setup(ii) | false;
%                 else
% 					obj.needs_mwpower_setup(ii) = true;
%                 end
                if ii <= numExistingMwSrc && obj.mw_src_power(ii) == val(ii)
					continue;
                else
					obj.needs_mwpower_setup(ii) = true;
				end
			end
			obj.mw_src_power = val;
        end
		function set.mw_src_frequency(obj,val)
			numMwSrc = numel(obj.mw_src);
            if numel(val) ~= numMwSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of mw_src_frequency not matching the numbers of mw_src.'));
            end
			numExistingMwSrc = numel(obj.mw_src_frequency);
% 			for ii = 1:numMwSrc
% 				if ii <= numExistingMwSrc && obj.mw_src_frequency(ii) == val(ii)
% 					obj.needs_mwfreq_setup(ii) = obj.needs_mwfreq_setup(ii) | false;
%                 else
% 					obj.needs_mwfreq_setup(ii) = true;
% 				end
%             end
            for ii = 1:numMwSrc
				if ii <= numExistingMwSrc && obj.mw_src_frequency(ii) == val(ii)
					continue;
                else
					obj.needs_mwfreq_setup(ii) = true;
				end
			end
			obj.mw_src_frequency = val;
        end
		function set.zdc_src(obj,val)
			% has some implicit rules, thus kept private
            numExistingDCSrc = numel(obj.zdc_src);
			numDCSrc2Add = numel(val)-numExistingDCSrc;
            obj.zdc_src = val;
			if numDCSrc2Add
				obj.needs_zdc_setup = ...
					[obj.needs_zdc_setup,...
					logical(zeros(1,numDCSrc2Add))];
				obj.zdc_amp = [obj.zdc_amp,...
					NaN*zeros(1,numDCSrc2Add)];
			end
		end
		function set.zdc_amp(obj,val)
			numZdcSrc = numel(obj.zdc_src);
            if numel(val) ~= numZdcSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of zdc_amp not matching the numbers of zdc_src.'));
            end
			
			numExistingDCSrc = numel(obj.zdc_amp);
			for ii = 1:numZdcSrc
				if ii <= numExistingDCSrc && obj.zdc_amp(ii) == val(ii)
					obj.needs_zdc_setup(ii) = false;
                else
					obj.needs_zdc_setup(ii) = true;
				end
			end
			obj.zdc_amp = val;
        end
%         function val = get.length(obj)
%             val = 0;
%             obj.GenWave(); % todo, get length in a more efficient way
%             for ii = 1:length(obj.xy_wv)
%                 if ~isempty(obj.xy_wv{ii})
%                     val = max(val,obj.xy_wv{ii}.length);
%                 end
%             end
%             for ii = 1:length(obj.z_wv)
%                 if ~isempty(obj.z_wv{ii})
%                     val = max(val,obj.z_wv{ii}.length);
%                 end
%             end
%         end
        function set.logSequenceSamples(obj,val)
            obj.logSequenceSamples = val;
            if val
                obj.sequenceSampleLogger = sqc.op.physical.sequenceSampleLogger.GetInstance();
            end
        end
        function val = get.gate_buffer(obj)
            val = sqc.op.physical.operator.gateBuffer();
        end
        function val = get.all_qubits(obj)
            val = sqc.op.physical.operator.allQubits();
        end
        function val = get.all_qubits_names(obj)
            val = sqc.op.physical.operator.allQubitNames();
        end
        function Run(obj)
            obj.Prep();
            obj.GenWave();
            for ii = 1:numel(obj.xy_wv)
                if isempty(obj.xy_wv{ii})
                    continue;
                end
				DASequence = qes.waveform.DASequence(obj.xy_daChnl{1,ii}.chnl,obj.xy_wv{ii});
				DASequence.outputDelay = [obj.delay_xy_i(ii),obj.delay_xy_q(ii)]...
                    + obj.qubits{ii}.syncDelay_xy;
				obj.xy_daChnl{1,ii}.SendWave(DASequence,true,obj.loFreq(ii),obj.loPower(ii),obj.sbFreq(ii)); % send I
				obj.xy_daChnl{2,ii}.SendWave(DASequence,false,obj.loFreq(ii),obj.loPower(ii),obj.sbFreq(ii)); % send Q
                if obj.logSequenceSamples
                    obj.sequenceSampleLogger.put(obj.qubits{ii}.name,DASequence,true);
                end
            end
            
            % removed temporarily, 2017/12/07
			zXTalkQubits2Add = {};
			xTalkSrcIdx = [];
			xTalkCoef = [];
            if obj.firstRun
                for ii = 1:numel(obj.z_wv) % correct z cross talk
                    if isempty(obj.z_wv{ii})
                        continue;
                    end
                    xTalkData = reshape(obj.qubits{ii}.xTalk_z,3,[]);
                    if isempty(xTalkData)
                        continue;
                    end
                    xTalk_zQubit_names = xTalkData(1,:);
                    for jj = 1: numel(xTalk_zQubit_names)
                        idx = qes.util.find(xTalk_zQubit_names{jj},obj.all_qubits);
                        if isempty(idx) %to future version: move all settings constraints into settings manager,
                                    % implemented as a database, phase out the necessity to do settings check
                                    % in operations.
                            throw(MException('sqc_op_pysical_operator:invalidSetting',...
                                sprintf('the crosstalk qubit %s of qubit %s dose not exist or not a selected/working qubit.',...
                                    xTalk_zQubit_names{jj},obj.qubits{ii}.name)));
                        end
                        xQ = obj.all_qubits{idx};
                        xtalk = xTalkData{2,jj};
                        if xtalk == 0
                            continue;
                        end
                        q2c_idx = qes.util.find(xTalk_zQubit_names{jj},obj.qubits);
                        if isempty(q2c_idx)
                            zXTalkQubits2Add = [zXTalkQubits2Add,{xQ}];
                            xTalkCoef = [xTalkCoef,xtalk];
                            xTalkSrcIdx = [xTalkSrcIdx,ii];
                            continue;
                        end
                        if isempty(obj.z_wv{q2c_idx})
                            obj.z_wv{q2c_idx} = (-xtalk)*copy(obj.z_wv{ii});
                            da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                                'name',obj.qubits{q2c_idx}.channels.z_pulse.instru);
                            obj.z_daChnl{1,q2c_idx} = da.GetChnl(obj.qubits{q2c_idx}.channels.z_pulse.chnl);
                        else
                            obj.z_wv{q2c_idx} = obj.z_wv{q2c_idx}+(-xtalk)*copy(obj.z_wv{ii});
                        end
                    end
                end
            end
            for ii = 1:numel(obj.z_wv)
                if isempty(obj.z_wv{ii})
                    continue;
                end
				DASequence = qes.waveform.DASequence(obj.z_daChnl{1,ii}.chnl,obj.z_wv{ii});
				DASequence.outputDelay = [obj.delay_z(ii) + obj.qubits{ii}.syncDelay_z,0,0,0,0];

				obj.z_daChnl{1,ii}.SendWave(DASequence,true,0,0,0);
                if obj.logSequenceSamples
                    obj.sequenceSampleLogger.put(obj.qubits{ii}.name,DASequence,false);
                end
            end
            
            % we don't care about other qubits, if we do the following, a process
            % can only run onece
%             % removed temporarily, 2017/12/07
% 			zWv2Add = {};
% 			addedZWvDAChnls = {};
% 			addedZWvSyncDelay = [];
% 			for ii = 1:numel(zXTalkQubits2Add)
% 				add2Idx = qes.util.find(zXTalkQubits2Add{ii},zXTalkQubits2Add(1:ii-1));
% 				if ~isempty(add2Idx)
%                     add2Idx = add2Idx(1);
%                     zWv2Add{add2Idx} = zWv2Add{add2Idx} -xTalkCoef(ii)*copy(obj.z_wv{xTalkSrcIdx(ii)});
% 				else
% 					zWv2Add{end+1} = obj.z_wv{xTalkSrcIdx(ii)}*(-xTalkCoef(ii)); 
% 					da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
%                         'name',zXTalkQubits2Add{ii}.channels.z_pulse.instru);
% 					addedZWvDAChnls{end+1} = da.GetChnl(zXTalkQubits2Add{ii}.channels.z_pulse.chnl);
% 					addedZWvSyncDelay(end+1) = zXTalkQubits2Add{ii}.syncDelay_z;
% 				end
% 			end
% 			for ii = 1:numel(zWv2Add)
% 				DASequence = qes.waveform.DASequence(addedZWvDAChnls{ii}.chnl,zWv2Add{ii});
% 				DASequence.outputDelay = [addedZWvSyncDelay(ii),0];
% 				addedZWvDAChnls{ii}.SendWave(DASequence,true);
%                 % disp(['z xtalk:', num2str(addedZWvDAChnls{ii}.chnl)])
% 			end

            obj.firstRun = false;
        end
        function delete(obj)
%             for ii = 1:numel(obj.zdc_src)	% obsolete, taken of dc and mw chnls are now non exclusive, 17/04/01
%                 if isvalid(obj.zdc_src{ii}) % can not do this: the zdc_src or mw_src reference might be used in another operator
%                     obj.zdc_src{ii}.delete();
%                 end
%             end
%             for ii = 1:obj.mw_src
%                 if isvalid(obj.mw_src{ii})
%                     obj.mw_src{ii}.delete();
%                 end
%             end
        end
        function newobj = Copy(obj)
            newobj = sqc.op.physical.operator(obj.qubits);
            newobj.delay_xy_i = obj.delay_xy_i;
            newobj.delay_xy_q = obj.delay_xy_q;
            newobj.delay_z = obj.delay_z;
            newobj.mw_src_power = obj.mw_src_power;
            newobj.mw_src_frequency = obj.mw_src_frequency;
            newobj.mw_src = obj.mw_src;
            newobj.zdc_src = obj.zdc_src;
            newobj.zdc_amp = obj.zdc_amp;
            newobj.length = obj.length;
            newobj.needs_mwpower_setup = obj.needs_mwpower_setup;
            newobj.needs_mwfreq_setup = obj.needs_mwfreq_setup;
            newobj.needs_zdc_setup = obj.needs_zdc_setup;
            obj.GenWave();
            newobj.xy_wv = obj.xy_wv;
            newobj.phaseShift = obj.phaseShift;
            for ii = 1:numel(newobj.xy_wv)
                if ~isempty(newobj.xy_wv{ii})
                    newobj.xy_wv{ii} = copy(newobj.xy_wv{ii});
                end
            end
            newobj.loFreq = obj.loFreq;
            newobj.loPower = obj.loPower;
            newobj.sbFreq = obj.sbFreq;
            newobj.xy_daChnl = obj.xy_daChnl;
            newobj.z_wv = obj.z_wv;
            for ii = 1:numel(newobj.z_wv)
                if ~isempty(newobj.z_wv{ii})
                    newobj.z_wv{ii} = copy(newobj.z_wv{ii});
                end
            end
            newobj.z_daChnl = obj.z_daChnl;
        end
    end
    methods (Access = protected)
% 		function newobj = copyElement(obj)
%             newobj = sqc.op.physical.operator(obj.qubits);
%             newobj.delay_xy_i = obj.delay_xy_i;
%             newobj.delay_xy_q = obj.delay_xy_q;
%             newobj.delay_z = obj.delay_z;
%             newobj.mw_src_power = obj.mw_src_power;
%             newobj.mw_src_frequency = obj.mw_src_frequency;
%             newobj.mw_src = obj.mw_src;
%             newobj.zdc_src = obj.zdc_src;
%             newobj.zdc_amp = obj.zdc_amp;
%             newobj.length = obj.length;
%             newobj.needs_mwpower_setup = obj.needs_mwpower_setup;
%             newobj.needs_mwfreq_setup = obj.needs_mwfreq_setup;
%             newobj.needs_zdc_setup = obj.needs_zdc_setup;
%             obj.GenWave();
%             newobj.xy_wv = obj.xy_wv;
%             newobj.phaseShift = obj.phaseShift;
%             for ii = 1:numel(newobj.xy_wv)
%                 if ~isempty(newobj.xy_wv{ii})
%                     newobj.xy_wv{ii} = copy(newobj.xy_wv{ii});
%                 end
%             end
%             newobj.loFreq = obj.loFreq;
%             newobj.loPower = obj.loPower;
%             newobj.sbFreq = obj.sbFreq;
%             newobj.xy_daChnl = obj.xy_daChnl;
%             newobj.z_wv = obj.z_wv;
%             for ii = 1:numel(newobj.z_wv)
%                 if ~isempty(newobj.z_wv{ii})
%                     newobj.z_wv{ii} = copy(newobj.z_wv{ii});
%                 end
%             end
%             newobj.z_daChnl = obj.z_daChnl;
% 		end
	end
    methods (Hidden = true)
        function GenWave(obj)
            % to subclasses: redefine your own GenWave.
            % operator(base) objects must have empty GenWave methods, do not add any code!
            % pass
        end
        % overide the MATLAB method
        function cls = class(obj)
            cls =  obj.gateClass;
        end
        function Prep(obj)
            % do necessary preparations before run
			numMwSrc = numel(obj.mw_src);
			if numMwSrc ~= numel(obj.mw_src_power)
				throw(MException('QOS_operator:MwPowerNotSet','mw power of some channnels are not set.'));
			elseif numMwSrc ~= numel(obj.mw_src_frequency)
				throw(MException('QOS_operator:MwFreqNotSet','mw frequency of some channnels are not set.'));
			end
			for ii = 1:numMwSrc
				if obj.needs_mwpower_setup(ii)
					obj.mw_src{ii}.power = obj.mw_src_power(ii);
				end
				if obj.needs_mwfreq_setup(ii)
					obj.mw_src{ii}.frequency = obj.mw_src_frequency(ii);
				end
				if obj.needs_mwpower_setup(ii) || obj.needs_mwfreq_setup(ii)
					obj.mw_src{ii}.on = true;
				end
				obj.needs_mwpower_setup(ii) = false;
				obj.needs_mwfreq_setup(ii) = false;
			end
			
			numDCSrc = numel(obj.zdc_src);
			if numDCSrc ~= numel(obj.zdc_amp)
				throw(MException('QOS_operator:zdcAmpNotSet','dc value of some channnels are not set.'));
			end
			for ii = 1:numDCSrc
				if obj.needs_zdc_setup(ii)
					obj.zdc_src{ii}.dcval = obj.zdc_amp(ii);
					obj.zdc_src{ii}.on = true;
					obj.needs_zdc_setup(ii) = false;
				end
			end  
        end
		function obj = mtimes(obj2, obj1)
            % change ordering for convinience
%        function obj = mtimes(obj1, obj2)
            
            if isempty(obj2)
				obj =  obj1;
				return;
            end
            if isempty(obj1)
				obj = obj2;
				return;
            end

            obj1ln = obj1.length;
            obj2ln = obj2.length;
            
			if obj2ln == 0 && ~isa(obj2,'sqc.op.physical.gate.Z_phase_base')
				obj =  obj1;
				return;
            end
            if  obj1ln == 0 && ~isa(obj1,'sqc.op.physical.gate.Z_phase_base')
				obj = obj2;
				return;
            end
            
            GB = obj1.gate_buffer; % gate_buffer is global
            obj = Copy(obj2);
            obj.gateClass = 'operator';
            
            if isa(obj2,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = -obj2.phase;
            end
            Obj2QInds = 1:numel(obj2.qubits);
            if isa(obj1,'sqc.op.physical.gate.Z_phase_base')
                idx = qes.util.find(obj1.qubits{1},obj.qubits);
                if ~isempty(idx)
                    obj.phaseShift(idx) = obj.phaseShift(idx) - obj1.phase;
                else
                    obj.phaseShift = [obj.phaseShift, -obj1.phase];
                    obj.qubits{end+1} = obj1.qubits{1};
                    obj.xy_wv{end+1} = [];
					obj.xy_daChnl{end+1} = [];
                    obj.loFreq(end+1) = 0;
                    obj.loPower(end+1) = 0;
                    obj.sbFreq(end+1) = 0;
            
					obj.xy_daChnl{end+1} = [];
                    obj.z_wv{end+1} = [];
                    obj.z_daChnl{end+1} = [];
                end
                return;
            end
            
%             obj1.GenWave();
            % in case like A*B*A*B, make a copy of B is necessary
            obj1 = Copy(obj1);
            
            addIdx = [];

            %%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%% OK up to now, removed for performance,
            %%%%%%%%%%%%%%%%%%% Yulin Wu, 2018/1/28
%             for jj = 1:numel(obj.xy_wv)
%                 if ~isempty(obj.xy_wv{jj}) && obj.xy_wv{jj}.length < obj.length
%                     % this will never happen if the gates are properly implemented, that is a gate
%                     % must has empty waveforms or the waveform length equals to the length of the gate.
%                     % its is added just in case some one implemented a gate not knowing the above rule
%                     error('bug!');
%                     % obj.xy_wv{jj} = [obj.xy_wv{jj},qes.waveform.spacer(obj.length-obj.xy_wv{jj}.length)];
%                 end
%             end
%             for jj = 1:numel(obj.z_wv)
%                 if ~isempty(obj.z_wv{jj}) && obj.z_wv{jj}.length < obj.length
%                     % this will never happen if the gates are properly implemented, that is a gate
%                     % eighter has empty waveforms or the waveform length equals to the length of the gate.
%                     % its is added just in case some one implemented a gate not knowing the above rule
%                     error('bug!');
% %                     obj.z_wv{jj} = [obj.z_wv{jj},qes.waveform.spacer(obj.length-obj.z_wv{jj}.length)];
%                 end
%             end
%             for jj = 1:numel(obj1.xy_wv)
%                 if ~isempty(obj1.xy_wv{jj}) && obj1.xy_wv{jj}.length < obj1.length
%                     % this will never happen if the gates are properly implemented, that is a gate
%                     % eight has empty waveforms or the waveform length equals to the length of the gate.
%                     % its is added just in case some one implemented a gate not knowing the above rule
%                     error('bug!');
%                     % obj1.xy_wv{jj} = [obj1.xy_wv{jj},qes.waveform.spacer(obj1.length-obj1.xy_wv{jj}.length)];
%                 end
%             end
%             for jj = 1:numel(obj1.z_wv)
%                 if ~isempty(obj1.z_wv{jj}) && obj1.z_wv{jj}.length < obj1.length
%                     % this will never happen if the gates are properly implemented, that is a gate
%                     % eighter has empty waveforms or the waveform length equals to the length of the gate.
%                     % its is added just in case some one implemented a gate not knowing the above rule
%                     error('bug!');
% %                     obj1.z_wv{jj} = [obj1.z_wv{jj},qes.waveform.spacer(obj1.length-obj1.z_wv{jj}.length)];
%                 end
%             end
            %%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%

            if GB+obj2ln < 1
                padWv1 = [];
            else
                padWv1 = qes.waveform.spacer(GB+obj2ln);
            end
            if GB+obj1ln < 1
                padWv2 = [];
                % error('zeros wavelength is not supported anymore');
            else
                padWv2 = qes.waveform.spacer(GB+obj1ln);
            end
            
            for ii = 1:numel(obj1.qubits)
				idx = qes.util.find(obj1.qubits{ii},obj.qubits);
                if isempty(idx)
					addIdx = [addIdx, ii];
					continue;
                end
                Obj2QInds(Obj2QInds == idx) = [];
                if ~isempty(obj1.xy_wv{ii})
                    if obj.phaseShift(idx) ~= 0
                        obj1.xy_wv{ii}.shiftPhase(obj.phaseShift(idx));
                    end
					if ~isempty(obj.xy_wv{idx})
						if GB
							obj.xy_wv{idx} = [obj.xy_wv{idx},...
                                qes.waveform.spacer(GB),obj1.xy_wv{ii}];
						else
							obj.xy_wv{idx} = [obj.xy_wv{idx},obj1.xy_wv{ii}];
						end
                    else
                        obj.xy_wv{idx} = [padWv1,...
                            obj1.xy_wv{ii}];
                        obj.xy_daChnl{1,idx} = obj1.xy_daChnl{1,ii};
                        obj.xy_daChnl{2,idx} = obj1.xy_daChnl{2,ii};
                        obj.loFreq(idx) = obj1.loFreq(ii);
                        obj.loPower(idx) = obj1.loPower(ii);
                        obj.sbFreq(idx) = obj1.sbFreq(ii);
                    end
                elseif ~isempty(obj.xy_wv{idx})
                    obj.xy_wv{idx} = [obj.xy_wv{idx},padWv2];
                end
                obj.phaseShift(idx) = obj.phaseShift(idx) + obj1.phaseShift(ii);
                if ~isempty(obj1.z_wv{ii})
                    if ~isempty(obj.z_wv{idx})
						if GB
							obj.z_wv{idx} = [obj.z_wv{idx},...
                                qes.waveform.spacer(GB),obj1.z_wv{ii}];
						else
							obj.z_wv{idx} = [obj.z_wv{idx},obj1.z_wv{ii}];
						end
                    else
                        obj.z_wv{idx} = [padWv1,...
                            obj1.z_wv{ii}];
                        obj.z_daChnl{1,idx} = obj1.z_daChnl{1,ii};
                    end
                elseif ~isempty(obj.z_wv{idx})
                    obj.z_wv{idx} = [obj.z_wv{idx},padWv2];
                end
            end
            
            for ii = 1:numel(Obj2QInds)
                if ~isempty(obj.xy_wv{Obj2QInds(ii)})
                    obj.xy_wv{Obj2QInds(ii)} = [obj.xy_wv{Obj2QInds(ii)},padWv2];
                end
                if ~isempty(obj.z_wv{Obj2QInds(ii)})
                    obj.z_wv{Obj2QInds(ii)} = [obj.z_wv{Obj2QInds(ii)},padWv2];
                end
            end
            ind = numel(obj.qubits);
            obj.qubits = [obj.qubits,obj1.qubits(addIdx)];
            obj.delay_xy_i = [obj.delay_xy_i, obj1.delay_xy_i(addIdx)];
            obj.delay_xy_q = [obj.delay_xy_q, obj1.delay_xy_q(addIdx)];
            obj.delay_z = [obj.delay_z, obj1.delay_z(addIdx)];
            obj.xy_wv = [obj.xy_wv,cell(1,numel(addIdx))];
            obj.loFreq = [obj.loFreq,zeros(1,numel(addIdx))];
            obj.loPower = [obj.loPower,zeros(1,numel(addIdx))];
            obj.sbFreq = [obj.sbFreq,zeros(1,numel(addIdx))];
            obj.z_wv = [obj.z_wv,cell(1,numel(addIdx))];
            obj.xy_daChnl = [obj.xy_daChnl,cell(2,numel(addIdx))];
            obj.z_daChnl = [obj.z_daChnl,cell(1,numel(addIdx))];
            obj.phaseShift = [obj.phaseShift,obj1.phaseShift(addIdx)];
            for ii = 1:numel(addIdx)
                if ~isempty(obj1.xy_wv{addIdx(ii)})
                    obj.xy_wv{ind+ii} = [padWv1,...
                        obj1.xy_wv{addIdx(ii)}];
					obj.xy_daChnl{1,ind+ii} = obj1.xy_daChnl{1,addIdx(ii)};
					obj.xy_daChnl{2,ind+ii} = obj1.xy_daChnl{2,addIdx(ii)};
                    obj.loFreq(ind+ii) = obj1.loFreq(addIdx(ii));
                    obj.loPower(ind+ii) = obj1.loPower(addIdx(ii));
                    obj.sbFreq(ind+ii) = obj1.sbFreq(addIdx(ii));
                end
                if ~isempty(obj1.z_wv{addIdx(ii)})
                    obj.z_wv{ind+ii} = [padWv1,...
                        obj1.z_wv{addIdx(ii)}];
                    obj.z_daChnl{1,ind+ii} = obj1.z_daChnl{1,addIdx(ii)};
                end
            end

			mwSrcIdx2Add = [];
			for ii = 1:numel(obj1.mw_src)
				idx = qes.util.find(obj1.mw_src{ii},obj.mw_src);
				if ~isempty(idx)
					if obj.mw_src_power(idx) ~= obj1.mw_src_power(ii) ||...
						obj.mw_src_frequency(idx) ~= obj1.mw_src_frequency(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting mw settings.'));
					end
					obj.needs_mwpower_setup(idx) =...
						obj.needs_mwpower_setup(idx)*obj1.needs_mwpower_setup(ii);
					obj.needs_mwfreq_setup(idx) =...
						obj.needs_mwfreq_setup(idx)*obj1.needs_mwfreq_setup(ii);
				else
					mwSrcIdx2Add = [mwSrcIdx2Add,ii];
				end
			end
			if ~isempty(mwSrcIdx2Add)
				obj.mw_src = [obj.mw_src, obj1.mw_src(mwSrcIdx2Add)];
				obj.mw_src_power(end-numel(mwSrcIdx2Add)+1:end) =...
                    obj1.mw_src_power(mwSrcIdx2Add);
				obj.needs_mwpower_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwpower_setup(mwSrcIdx2Add);
				obj.mw_src_frequency(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_frequency(mwSrcIdx2Add);
				obj.needs_mwfreq_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwfreq_setup(mwSrcIdx2Add);
			end

			dcSrcIdx2Add = [];
			for ii = 1:numel(obj1.zdc_src)
				idx = qes.util.find(obj1.zdc_src{ii},obj.zdc_src);
				if ~isempty(idx)
					if obj.zdc_amp(idx) ~= obj1.zdc_amp(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting dc settings.'));
					end
					obj.needs_zdc_setup(idx) =...
						obj.needs_zdc_setup(idx)*obj1.needs_zdc_setup(ii);
				else
					dcSrcIdx2Add = [dcSrcIdx2Add,ii];
				end
			end
			if ~isempty(dcSrcIdx2Add)
				obj.zdc_src = [obj.zdc_src, obj1.zdc_src(dcSrcIdx2Add)];
				obj.zdc_amp(end-numel(dcSrcIdx2Add)+1:end) = ...
                    obj1.zdc_amp(dcSrcIdx2Add);
				obj.needs_zdc_setup(end-numel(dcSrcIdx2Add)+1:end) = ...
					obj1.needs_zdc_setup(dcSrcIdx2Add);
			end
			
			% logical_op property will be removed
            % if ~isempty(obj1.logical_op) && ~isempty(obj2.logical_op)
                % obj.logical_op = obj1.logical_op*obj2.logical_op;
				% obj.logical_op = obj2.logical_op*obj1.logical_op;
            % end
            
            obj.length = obj.length + obj1.length + GB;
        end
        function obj = times(obj1, obj2)
           % implement .* as Kronecker tensor product
           obj = [obj1, obj2];
           
        end
		function obj = vertcat(varargin)
			% implement [] as Kronecker tensor product
			obj = horzcat(varargin);
		end
%        function obj = times(obj1, obj2)
%            % implement .* as Kronecker tensor product
		function obj = horzcat(varargin)
            % implement [] as Kronecker tensor product
			
			numGates = numel(varargin);
			if numGates == 1
				obj = Copy(varargin{1});
				return;
			end
			if numGates > 2
				obj = Copy(varargin{1});
				for ii = 2:numGates
					obj = [obj,varargin{ii}];
				end
				return;
			end
			if isempty(varargin{1})
				obj =  varargin{2};
				return;
			elseif isempty(varargin{2})
				obj = varargin{1};
				return;
			end
			obj1 = varargin{2};
			obj2 = varargin{1};
            if ~isa(obj1,'sqc.op.physical.operator') || ~isa(obj2,'sqc.op.physical.operator')
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'at least one of obj1, obj2 is not a sqc.op.physical.operator class object.'));
            end
            obj1.GenWave();
            obj = Copy(obj2);
            obj.gateClass = 'operator';

            if isa(obj2,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = -obj2.phase;
            end
            if isa(obj1,'sqc.op.physical.gate.Z_phase_base')
                obj1.phaseShift = - obj1.phase;
            end

            addIdx = [];
			dln = obj.length - obj1.length;
            if dln < 0
                obj.length = obj1.length;
                numQs = numel(obj.xy_wv);
                for ii = 1:numQs
                    if ~isempty(obj.xy_wv{ii})
                        obj.xy_wv{ii} = [obj.xy_wv{ii},qes.waveform.spacer(-dln)];
                    end
                end
                for ii = 1:numQs
                    if ~isempty(obj.z_wv{ii})
                        obj.z_wv{ii} = [obj.z_wv{ii},qes.waveform.spacer(-dln)];
                    end
                end
            end
            for ii = 1:numel(obj1.qubits)
			
				for jj = 1:numel(obj1.xy_wv)
					if ~isempty(obj1.xy_wv{jj}) && obj1.xy_wv{jj}.length < obj1.length
						% this will never happen if the gates are properly implemented, that is a fudamental gate
						% eight has empty waveforms or the waveform length equals to the length of the gate.
						% its is added just in case some one implemented a gate not knowing the above rule
						obj1.xy_wv{jj} = [obj1.xy_wv{jj},qes.waveform.spacer(obj1.length-obj1.xy_wv{jj}.length)];
					end
				end
				for jj = 1:numel(obj1.z_wv)
					if ~isempty(obj1.z_wv{jj}) && obj1.z_wv{jj}.length < obj1.length
						% this will never happen if the gates are properly implemented, that is a fudamental gate
						% eighter has empty waveforms or the waveform length equals to the length of the gate.
						% its is added just in case some one implemented a gate not knowing the above rule
						obj1.z_wv{jj} = [obj1.z_wv{jj},qes.waveform.spacer(obj1.length-obj1.z_wv{jj}.length)];
					end
				end

				idx = qes.util.find(obj1.qubits{ii},obj.qubits);
                if isempty(idx)
					addIdx = [addIdx, ii];
					continue;
				end
                
                if ~isempty(obj1.xy_wv{ii})
                    if ~isempty(obj.xy_wv{idx})
                        obj.xy_wv{idx} = obj.xy_wv{idx}+obj1.xy_wv{ii};
                    else
                        if dln > 0
                            obj.xy_wv{idx} = [obj1.xy_wv{ii},...
                                qes.waveform.spacer(dln)];
                        else
                            obj.xy_wv{idx} = obj1.xy_wv{ii};
                        end
                        obj.xy_daChnl{1,idx} = obj1.xy_daChnl{1,ii};
                        obj.xy_daChnl{2,idx} = obj1.xy_daChnl{2,ii};
                        obj.loFreq(idx) = obj1.loFreq(ii);
                        obj.loPower(idx) = obj1.loPower(ii);
                        obj.sbFreq(idx) = obj1.sbFreq(ii);
                    end
                end
%                 if (obj1.phaseShift(ii) ~=0 && obj.phaseShift(idx) ~=0 &&...
%                     obj1.phaseShift(ii) ~= obj.phaseShift(idx))
%                     error('BUG, this should never happen!');
%                 elseif obj1.phaseShift(ii) ~=0
%                     obj.phaseShift(idx) = obj1.phaseShift(ii);
%                 end
                obj.phaseShift(idx) = obj.phaseShift(idx) + obj1.phaseShift(ii);
                
                if ~isempty(obj1.z_wv{ii})
                    if ~isempty(obj.z_wv{idx})
                        obj.z_wv{idx} = obj.z_wv{idx}+obj1.z_wv{ii};
                    else
                        if dln > 0
                            obj.z_wv{idx} = [obj1.z_wv{ii},...
                                qes.waveform.spacer(dln)];
                        else
                            obj.z_wv{idx} = obj1.z_wv{ii};
                        end
						obj.z_daChnl{1,idx} = obj1.z_daChnl{ii};
                    end
                end
            end
            obj.qubits = [obj.qubits,obj1.qubits(addIdx)];
            obj.delay_xy_i = [obj.delay_xy_i, obj1.delay_xy_i(addIdx)];
            obj.delay_xy_q = [obj.delay_xy_q, obj1.delay_xy_q(addIdx)];
            obj.delay_z = [obj.delay_z, obj1.delay_z(addIdx)];
            obj2numQ = numel(obj.xy_wv);
            obj.xy_wv = [obj.xy_wv,cell(1,numel(addIdx))];
            obj.loFreq = [obj.loFreq,zeros(1,numel(addIdx))];
            obj.loPower = [obj.loPower,zeros(1,numel(addIdx))];
            obj.sbFreq = [obj.sbFreq,zeros(1,numel(addIdx))];
            obj.z_wv = [obj.z_wv,cell(1,numel(addIdx))];
            obj.xy_daChnl = [obj.xy_daChnl,cell(2,numel(addIdx))];
            obj.z_daChnl = [obj.z_daChnl,cell(1,numel(addIdx))];
            obj.phaseShift = [obj.phaseShift,obj1.phaseShift(addIdx)];
            for ii = 1:numel(addIdx)
                wvInd = obj2numQ+ii;
                if ~isempty(obj1.xy_wv{addIdx(ii)})
					if dln > 0
						obj.xy_wv{wvInd} = [obj1.xy_wv{addIdx(ii)},...
								qes.waveform.spacer(dln)];
					else
						obj.xy_wv{wvInd} = obj1.xy_wv{addIdx(ii)};
                    end
					obj.xy_daChnl{1,wvInd} = obj1.xy_daChnl{1,addIdx(ii)};
                    obj.xy_daChnl{2,wvInd} = obj1.xy_daChnl{2,addIdx(ii)};
                    obj.loFreq(wvInd) = obj1.loFreq(addIdx(ii));
                    obj.loPower(wvInd) = obj1.loPower(addIdx(ii));
                    obj.sbFreq(wvInd) = obj1.sbFreq(addIdx(ii));
                end
                if ~isempty(obj1.z_wv{addIdx(ii)})
					if dln > 0
						obj.z_wv{wvInd} = [obj1.z_wv{addIdx(ii)},...
									qes.waveform.spacer(dln)];
					else
						obj.z_wv{wvInd} = obj1.z_wv{addIdx(ii)};
                    end
					obj.z_daChnl{1,wvInd} = obj1.z_daChnl{1,addIdx(ii)};
                end
            end
			
			mwSrcIdx2Add = [];
			for ii = 1:numel(obj1.mw_src)
				idx = qes.util.find(obj1.mw_src{ii},obj.mw_src);
				if ~isempty(idx)
					if obj.mw_src_power(idx) ~= obj1.mw_src_power(ii) ||...
						obj.mw_src_frequency(idx) ~= obj1.mw_src_frequency(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting mw settings.'));
					end
					obj.needs_mwpower_setup(idx) =...
						obj.needs_mwpower_setup(idx)*obj1.needs_mwpower_setup(ii);
					obj.needs_mwfreq_setup(idx) =...
						obj.needs_mwfreq_setup(idx)*obj1.needs_mwfreq_setup(ii);
				else
					mwSrcIdx2Add = [mwSrcIdx2Add,ii];
				end
			end
			if ~isempty(mwSrcIdx2Add)
				obj.mw_src = [obj.mw_src, obj1.mw_src(mwSrcIdx2Add)];
				obj.mw_src_power(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_power(mwSrcIdx2Add);
				obj.needs_mwpower_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwpower_setup(mwSrcIdx2Add);
				obj.mw_src_frequency(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_frequency(mwSrcIdx2Add);
				obj.needs_mwfreq_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwfreq_setup(mwSrcIdx2Add);
			end

			dcSrcIdx2Add = [];
			for ii = 1:numel(obj1.zdc_src)
				idx = qes.util.find(obj1.zdc_src{ii},obj.zdc_src);
				if ~isempty(idx)
					if obj.zdc_amp(idx) ~= obj1.zdc_amp(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting dc settings.'));
					end
					obj.needs_zdc_setup(idx) =...
						obj.needs_zdc_setup(idx)*obj1.needs_zdc_setup(ii);
				else
					dcSrcIdx2Add = [dcSrcIdx2Add,ii];
				end
			end
			if ~isempty(dcSrcIdx2Add)
				obj.zdc_src = [obj.zdc_src, obj1.zdc_src(dcSrcIdx2Add)];
				obj.zdc_amp(end-numel(dcSrcIdx2Add)+1:end) =...
                    obj1.zdc_amp(dcSrcIdx2Add);
				obj.needs_zdc_setup(end-numel(dcSrcIdx2Add)+1:end) = ...
					obj1.needs_zdc_setup(dcSrcIdx2Add);
			end
			
%             if ~isempty(obj1.logical_op) && ~isempty(obj2.logical_op)
%                  % operators acting on the same qubits set(or partially) can not form Kronecker tensor product
%                  % intersect for objects has to be re implemented
%                  if isempty(intersect(obj1.qubits,obj2.qubits))
%                      % by the identity kron(A,B) = kron(A,I)*kron(I,B) we
%                      % have:
%                      obj.logical_op = obj1.logical_op*obj2.logical_op;
%                  end
%              end
        end
		function obj = mpower(obj1,n)
            % power of operator object
            if n < 0 || round(n) ~= n
                throw(MException('operator:illegalArgument',...
                    'negative or non integer exponent is not supported in operator exponentiation.'));
            end
            if n == 0
				numQ = numel(obj1.qubits);
				obj = sqc.op.physical.gate.I(obj1.qubits{1});
				for ii = 2:numQ
					obj = sqc.op.physical.gate.I(obj1.qubits{ii}).*obj;
				end
            elseif n == 1
                obj = Copy(obj1);
            else
                numQ = numel(obj1.qubits);
                obj = obj1;
                if numQ == 1
                    for ii = 2:n
                        obj = obj1+obj;
                    end
                else
                    for ii = 2:n
                        obj = obj1*obj;
                    end
                end
            end
        end
        
        function obj = plus(obj2, obj1)
            % implement + as fast single qubit mtimes
            % warning: assumes obj2, obj1 are single qubit gates on the
            % same qubit
            
            if isempty(obj2)
				obj =  obj1;
				return;
            end
            if isempty(obj1)
				obj = obj2;
				return;
            end
            
            obj1ln = obj1.length;
            obj2ln = obj2.length;
            
			if obj2ln == 0 && ~isa(obj2,'sqc.op.physical.gate.Z_phase_base')
				obj =  obj1;
				return;
            end
            if  obj1ln == 0 && ~isa(obj1,'sqc.op.physical.gate.Z_phase_base')
				obj = obj2;
				return;
            end
            
            GB = obj1.gate_buffer; % gate_buffer is global
            
            obj = Copy(obj2);
            obj.gateClass = 'operator';
            
            if isa(obj2,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = -obj2.phase;
            end
            if isa(obj1,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = obj.phaseShift - obj1.phase;
                return;
            end
            
%             obj1.GenWave();
            % in case like A*X*A*X, make a copy of X is necessary
            obj1 = Copy(obj1);

            if ~isempty(obj1.xy_wv{1})
                if obj.phaseShift ~= 0
                    obj1.xy_wv{1}.shiftPhase(obj.phaseShift);
                end
                if ~isempty(obj.xy_wv{1})
                    if GB
                        obj.xy_wv{1} = [obj.xy_wv{1},...
                            qes.waveform.spacer(GB),obj1.xy_wv{1}];
                    else
                        obj.xy_wv{1} = [obj.xy_wv{1},obj1.xy_wv{1}];
                    end
                else
                    if GB+obj12n > 0
                        obj.xy_wv{1} = [qes.waveform.spacer(GB+obj2ln),obj1.xy_wv{1}];
                    end
                    obj.xy_daChnl{1,1} = obj1.xy_daChnl{1,1};
                    obj.xy_daChnl{2,1} = obj1.xy_daChnl{2,1};
                    obj.loFreq = obj1.loFreq;
                    obj.loPower = obj1.loPower;
                    obj.sbFreq = obj1.sbFreq;
                end
            elseif ~isempty(obj.xy_wv{1}) && GB+obj1ln > 0
                obj.xy_wv{1} = [obj.xy_wv{1},qes.waveform.spacer(GB+obj1ln)];
            end
            obj.phaseShift = obj.phaseShift + obj1.phaseShift(1);
            if ~isempty(obj1.z_wv{1})
                if ~isempty(obj.z_wv{1})
                    if GB
                        obj.z_wv{1} = [obj.z_wv{1},...
                            qes.waveform.spacer(GB),obj1.z_wv{1}];
                    else
                        obj.z_wv{1} = [obj.z_wv{1},obj1.z_wv{1}];
                    end
                else
                    if GB+obj2ln > 0
                        obj.z_wv{1} = [qes.waveform.spacer(GB+obj2ln),obj1.z_wv{1}];
                    end
                    obj.z_daChnl{1,1} = obj1.z_daChnl{1,1};
                end
            elseif ~isempty(obj.z_wv{1})  && GB+obj1ln > 0
                obj.z_wv{1} = [obj.z_wv{1},qes.waveform.spacer(GB+obj1ln)];
            end

			if isempty(obj.mw_src) && ~isempty(obj1.mw_src)
				obj.mw_src = obj1.mw_src;
				obj.mw_src_power = obj1.mw_src_power;
				obj.needs_mwpower_setup = obj1.needs_mwpower_setup;
				obj.mw_src_frequency = obj1.mw_src_frequency;
				obj.needs_mwfreq_setup = obj1.needs_mwfreq_setup;
            end

            if isempty(obj.zdc_src) && ~isempty(obj1.zdc_src)
				obj.zdc_src = obj1.zdc_src;
				obj.zdc_amp = obj1.zdc_amp;
				obj.needs_zdc_setup = obj1.needs_zdc_setup;
            end

            obj.length = obj.length + obj1.length + GB;
        end
        
        function obj = noCopyPlus(obj2, obj1)
            % % no copying version of plus, much faster
            % should not be used in copy necessary scennarios such as:
            % A*B*A etc.
            
            if isempty(obj2)
				obj =  obj1;
				return;
            end
            if isempty(obj1)
				obj = obj2;
				return;
            end

            obj1ln = obj1.length;
            obj2ln = obj2.length;
            
			if obj2ln == 0 && ~isa(obj2,'sqc.op.physical.gate.Z_phase_base')
				obj =  obj1;
				return;
            end
            if  obj1ln == 0 && ~isa(obj1,'sqc.op.physical.gate.Z_phase_base')
				obj = obj2;
				return;
            end
            
            GB = obj1.gate_buffer; % gate_buffer is global
            obj1.GenWave();
            obj = Copy(obj2); % copy the first is necessary
            obj.gateClass = 'operator';
            
            if isa(obj2,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = -obj2.phase;
            end
            if isa(obj1,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = obj.phaseShift - obj1.phase;
                return;
            end
            
            if ~isempty(obj1.xy_wv{1})
                if obj.phaseShift ~= 0
                    obj1.xy_wv{1}.shiftPhase(obj.phaseShift);
                end
                if ~isempty(obj.xy_wv{1})
                    if GB
                        obj.xy_wv{1} = [obj.xy_wv{1},...
                            qes.waveform.spacer(GB),obj1.xy_wv{1}];
                    else
                        obj.xy_wv{1} = [obj.xy_wv{1},obj1.xy_wv{1}];
                    end
                else
                    if GB+obj12n > 0
                        obj.xy_wv{1} = [qes.waveform.spacer(GB+obj2ln),obj1.xy_wv{1}];
                    end
                    obj.xy_daChnl{1,1} = obj1.xy_daChnl{1,1};
                    obj.xy_daChnl{2,1} = obj1.xy_daChnl{2,1};
                    obj.loFreq = obj1.loFreq;
                    obj.loPower = obj1.loPower;
                    obj.sbFreq = obj1.sbFreq;
                end
            elseif ~isempty(obj.xy_wv{1}) && GB+obj1ln > 0
                obj.xy_wv{1} = [obj.xy_wv{1},qes.waveform.spacer(GB+obj1ln)];
            end
            obj.phaseShift = obj.phaseShift + obj1.phaseShift(1);
            if ~isempty(obj1.z_wv{1})
                if ~isempty(obj.z_wv{1})
                    if GB
                        obj.z_wv{1} = [obj.z_wv{1},...
                            qes.waveform.spacer(GB),obj1.z_wv{1}];
                    else
                        obj.z_wv{1} = [obj.z_wv{1},obj1.z_wv{1}];
                    end
                else
                    if GB+obj2ln > 0
                        obj.z_wv{1} = [qes.waveform.spacer(GB+obj2ln),obj1.z_wv{1}];
                    end
                    obj.z_daChnl{1,1} = obj1.z_daChnl{1,1};
                end
            elseif ~isempty(obj.z_wv{1})  && GB+obj1ln > 0
                obj.z_wv{1} = [obj.z_wv{1},qes.waveform.spacer(GB+obj1ln)];
            end

			if isempty(obj.mw_src) && ~isempty(obj1.mw_src)
				obj.mw_src = obj1.mw_src;
				obj.mw_src_power = obj1.mw_src_power;
				obj.needs_mwpower_setup = obj1.needs_mwpower_setup;
				obj.mw_src_frequency = obj1.mw_src_frequency;
				obj.needs_mwfreq_setup = obj1.needs_mwfreq_setup;
            end

            if isempty(obj.zdc_src) && ~isempty(obj1.zdc_src)
				obj.zdc_src = obj1.zdc_src;
				obj.zdc_amp = obj1.zdc_amp;
				obj.needs_zdc_setup = obj1.needs_zdc_setup;
            end

            obj.length = obj.length + obj1.length + GB;
        end
        
        function obj = noCopyTimes(obj2, obj1)
            % no copying version of mtimes, much faster
            % should no be used in copy necessary scennarios such as:
            % A*B*A etc.
            
            if isempty(obj2)
				obj =  obj1;
				return;
            end
            if isempty(obj1)
				obj = obj2;
				return;
            end

            obj1ln = obj1.length;
            obj2ln = obj2.length;
            
			if obj2ln == 0 && ~isa(obj2,'sqc.op.physical.gate.Z_phase_base')
				obj =  obj1;
				return;
            end
            if  obj1ln == 0 && ~isa(obj1,'sqc.op.physical.gate.Z_phase_base')
				obj = obj2;
				return;
            end
            
            GB = obj1.gate_buffer; % gate_buffer is global
            obj1.GenWave();
            obj = Copy(obj2); % copy the first is necessary
            obj.gateClass = 'operator';
            
            if isa(obj2,'sqc.op.physical.gate.Z_phase_base')
                obj.phaseShift = -obj2.phase;
            end
            Obj2QInds = 1:numel(obj2.qubits);
            if isa(obj1,'sqc.op.physical.gate.Z_phase_base')
                idx = qes.util.find(obj1.qubits{1},obj.qubits);
                if ~isempty(idx)
                    obj.phaseShift(idx) = obj.phaseShift(idx) - obj1.phase;
                else
                    obj.phaseShift = [obj.phaseShift, -obj1.phase];
                    obj.qubits{end+1} = obj1.qubits{1};
                    obj.xy_wv{end+1} = [];
					obj.xy_daChnl{end+1} = [];
					obj.xy_daChnl{end+1} = [];
                    obj.loFreq(end+1) = 0;
                    obj.loPower(end+1) = 0;
                    obj.sbFreq(end+1) = 0;
                    obj.z_wv{end+1} = [];
                    obj.z_daChnl{end+1} = [];
                end
                return;
            end
 
            addIdx = [];

            if GB+obj2ln < 1
                padWv1 = [];
            else
                padWv1 = qes.waveform.spacer(GB+obj2ln);
            end
            if GB+obj1ln < 1
                padWv2 = [];
                % error('zeros wavelength is not supported anymore');
            else
                padWv2 = qes.waveform.spacer(GB+obj1ln);
            end
            
            for ii = 1:numel(obj1.qubits)
				idx = qes.util.find(obj1.qubits{ii},obj.qubits);
                if isempty(idx)
					addIdx = [addIdx, ii];
					continue;
                end
                Obj2QInds(Obj2QInds == idx) = [];
                if ~isempty(obj1.xy_wv{ii})
                    if obj.phaseShift(idx) ~= 0
                        obj1.xy_wv{ii}.shiftPhase(obj.phaseShift(idx));
                    end
					if ~isempty(obj.xy_wv{idx})
						if GB
							obj.xy_wv{idx} = [obj.xy_wv{idx},...
                                qes.waveform.spacer(GB),obj1.xy_wv{ii}];
						else
							obj.xy_wv{idx} = [obj.xy_wv{idx},obj1.xy_wv{ii}];
						end
                    else
                        obj.xy_wv{idx} = [padWv1,...
                            obj1.xy_wv{ii}];
                        obj.xy_daChnl{1,idx} = obj1.xy_daChnl{1,ii};
                        obj.xy_daChnl{2,idx} = obj1.xy_daChnl{2,ii};
                        obj.loFreq(idx) = obj1.loFreq(ii);
                        obj.loPower(idx) = obj1.loPower(ii);
                        obj.sbFreq(idx) = obj1.sbFreq(ii);
                    end
                elseif ~isempty(obj.xy_wv{idx})
                    obj.xy_wv{idx} = [obj.xy_wv{idx},padWv2];
                end
                obj.phaseShift(idx) = obj.phaseShift(idx) + obj1.phaseShift(ii);
                if ~isempty(obj1.z_wv{ii})
                    if ~isempty(obj.z_wv{idx})
						if GB
							obj.z_wv{idx} = [obj.z_wv{idx},...
                                qes.waveform.spacer(GB),obj1.z_wv{ii}];
						else
							obj.z_wv{idx} = [obj.z_wv{idx},obj1.z_wv{ii}];
						end
                    else
                        obj.z_wv{idx} = [padWv1,...
                            obj1.z_wv{ii}];
                        obj.z_daChnl{1,idx} = obj1.z_daChnl{1,ii};
                    end
                elseif ~isempty(obj.z_wv{idx})
                    obj.z_wv{idx} = [obj.z_wv{idx},padWv2];
                end
            end
            
            for ii = 1:numel(Obj2QInds)
                if ~isempty(obj.xy_wv{Obj2QInds(ii)})
                    obj.xy_wv{Obj2QInds(ii)} = [obj.xy_wv{Obj2QInds(ii)},padWv2];
                end
                if ~isempty(obj.z_wv{Obj2QInds(ii)})
                    obj.z_wv{Obj2QInds(ii)} = [obj.z_wv{Obj2QInds(ii)},padWv2];
                end
            end
            ind = numel(obj.qubits);
            obj.qubits = [obj.qubits,obj1.qubits(addIdx)];
            obj.delay_xy_i = [obj.delay_xy_i, obj1.delay_xy_i(addIdx)];
            obj.delay_xy_q = [obj.delay_xy_q, obj1.delay_xy_q(addIdx)];
            obj.delay_z = [obj.delay_z, obj1.delay_z(addIdx)];
            obj.xy_wv = [obj.xy_wv,cell(1,numel(addIdx))];
            obj.loFreq = [obj.loFreq,zeros(1,numel(addIdx))];
            obj.loPower = [obj.loPower,zeros(1,numel(addIdx))];
            obj.sbFreq = [obj.sbFreq,zeros(1,numel(addIdx))];
            obj.z_wv = [obj.z_wv,cell(1,numel(addIdx))];
            obj.xy_daChnl = [obj.xy_daChnl,cell(2,numel(addIdx))];
            obj.z_daChnl = [obj.z_daChnl,cell(1,numel(addIdx))];
            obj.phaseShift = [obj.phaseShift,obj1.phaseShift(addIdx)];
            for ii = 1:numel(addIdx)
                if ~isempty(obj1.xy_wv{addIdx(ii)})
                    obj.xy_wv{ind+ii} = [padWv1,...
                        obj1.xy_wv{addIdx(ii)}];
					obj.xy_daChnl{1,ind+ii} = obj1.xy_daChnl{1,addIdx(ii)};
					obj.xy_daChnl{2,ind+ii} = obj1.xy_daChnl{2,addIdx(ii)};
                    obj.loFreq(ind+ii) = obj1.loFreq(addIdx(ii));
                    obj.loPower(ind+ii) = obj1.loPower(addIdx(ii));
                    obj.sbFreq(ind+ii) = obj1.sbFreq(addIdx(ii));
                end
                if ~isempty(obj1.z_wv{addIdx(ii)})
                    obj.z_wv{ind+ii} = [padWv1,...
                        obj1.z_wv{addIdx(ii)}];
                    obj.z_daChnl{1,ind+ii} = obj1.z_daChnl{1,addIdx(ii)};
                end
            end

			mwSrcIdx2Add = [];
			for ii = 1:numel(obj1.mw_src)
				idx = qes.util.find(obj1.mw_src{ii},obj.mw_src);
				if ~isempty(idx)
					if obj.mw_src_power(idx) ~= obj1.mw_src_power(ii) ||...
						obj.mw_src_frequency(idx) ~= obj1.mw_src_frequency(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting mw settings.'));
					end
					obj.needs_mwpower_setup(idx) =...
						obj.needs_mwpower_setup(idx)*obj1.needs_mwpower_setup(ii);
					obj.needs_mwfreq_setup(idx) =...
						obj.needs_mwfreq_setup(idx)*obj1.needs_mwfreq_setup(ii);
				else
					mwSrcIdx2Add = [mwSrcIdx2Add,ii];
				end
			end
			if ~isempty(mwSrcIdx2Add)
				obj.mw_src = [obj.mw_src, obj1.mw_src(mwSrcIdx2Add)];
				obj.mw_src_power(end-numel(mwSrcIdx2Add)+1:end) =...
                    obj1.mw_src_power(mwSrcIdx2Add);
				obj.needs_mwpower_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwpower_setup(mwSrcIdx2Add);
				obj.mw_src_frequency(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_frequency(mwSrcIdx2Add);
				obj.needs_mwfreq_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwfreq_setup(mwSrcIdx2Add);
			end

			dcSrcIdx2Add = [];
			for ii = 1:numel(obj1.zdc_src)
				idx = qes.util.find(obj1.zdc_src{ii},obj.zdc_src);
				if ~isempty(idx)
					if obj.zdc_amp(idx) ~= obj1.zdc_amp(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting dc settings.'));
					end
					obj.needs_zdc_setup(idx) =...
						obj.needs_zdc_setup(idx)*obj1.needs_zdc_setup(ii);
				else
					dcSrcIdx2Add = [dcSrcIdx2Add,ii];
				end
			end
			if ~isempty(dcSrcIdx2Add)
				obj.zdc_src = [obj.zdc_src, obj1.zdc_src(dcSrcIdx2Add)];
				obj.zdc_amp(end-numel(dcSrcIdx2Add)+1:end) = ...
                    obj1.zdc_amp(dcSrcIdx2Add);
				obj.needs_zdc_setup(end-numel(dcSrcIdx2Add)+1:end) = ...
					obj1.needs_zdc_setup(dcSrcIdx2Add);
			end
			
			% logical_op property will be removed
            % if ~isempty(obj1.logical_op) && ~isempty(obj2.logical_op)
                % obj.logical_op = obj1.logical_op*obj2.logical_op;
				% obj.logical_op = obj2.logical_op*obj1.logical_op;
            % end
            
            obj.length = obj.length + obj1.length + GB;
        end

        function setGateClass(obj,val)
            obj.gateClass = val;
        end
    end
    methods (Static = true)
        function gate_buffer = gateBuffer(reload)
            persistent gate_buffer_
            if isempty(gate_buffer_) || (nargin && reload)
                QS = qes.qSettings.GetInstance();
                gate_buffer_ = QS.loadSSettings({'shared','gateBuffer'});
            end
            gate_buffer = gate_buffer_;
        end
        function all_qubits_ = allQubits(reload)
            persistent all_qubits
            if isempty(all_qubits) || (nargin && reload)
                all_qubits = sqc.util.loadQubits();
            end
            all_qubits_ = all_qubits;
        end
        function all_qubit_names_ = allQubitNames(reload)
            persistent all_qubit_names
            if isempty(all_qubit_names) || (nargin && reload)
                all_qubit_names = sqc.util.loadQubitNames();
            end
            all_qubit_names_ = all_qubit_names;
        end
        
        function PlotReal(obj,ax)
            % plot the real part of the operator matrix
            if isempty(obj.logical_op)
                error('this physical operator has no logical operator');
            end
            if nargin > 1
                obj.logical_op.PlotReal(obj.logical_op,ax);
            else
                obj.logical_op.PlotReal(obj.logical_op);
            end
        end
        function PlotImag(obj,ax)
            % plot the imaginary part of the operator matrix
            if isempty(obj.logical_op)
                error('this physical operator has no logical operator');
            end
            if nargin > 1
                obj.logical_op.PlotImag(obj.logical_op,ax);
            else
                obj.logical_op.PlotImag(obj.logical_op);
            end
        end
        function s = sequenceSamples()
            
        end
    end
end