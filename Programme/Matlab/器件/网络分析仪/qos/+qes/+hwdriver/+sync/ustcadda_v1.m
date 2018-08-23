% 	FileName:USTCADDA.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.9.11
%   Description:The class of ADDA
classdef ustcadda_v1 < qes.hwdriver.icinterface_compatible % extends icinterface_compatible, Yulin Wu
    properties % zyr compatible
        runReps = 1             %run repetition
        adRecordLength = 1      % daRecordLength
    end
    properties (SetAccess = private)
    
        numDABoards
        numDAChnls
        numADBoards
        numADChnls
    
        daOutputDelayStep
        daTrigDelayStep
        daSamplingRate

        adRange
        adDelayStep % unit: DA sampling points
    end
    
    properties (SetAccess = private) % Yulin Wu
        adTakenChnls
        daTakenChnls
    end
    
    properties(SetAccess = private) 
        da_list = []
        ad_list = []
        da_channel_list = []
        ad_channel_list = []
        
        da_master_index = 1
    end
    
    methods % Yulin Wu
        function TakeDAChnls(obj,chnls)
            if any(chnls>length(obj.da_channel_list))
                throw(MException('QOS_ustcadda:daChnlAlreadyTaken','some da channels are taken already'));
            end
            if any(ismember(chnls,obj.daTakenChnls))
                throw(MException('QOS_ustcadda:daChnlAlreadyTaken','some da channels are taken already'));
            end
            obj.daTakenChnls = [obj.daTakenChnls, chnls];
        end
		function ReleaseDAChnls(obj,chnls)
			obj.daTakenChnls = setdiff(obj.daTakenChnls,chnls);
        end
		function TakeADChnls(obj,chnls)
			if any(ismember(chnls,obj.adTakenChnls))
				throw(MException('QOS_ustcadda:adChnlAlreadyTaken','some ad channels are taken already'));
			end
			obj.adTakenChnls = [obj.adTakenChnls, chnls];
		end
		function ReleaseADChnls(obj,chnls)
			obj.adTakenChnls = setdiff(obj.adTakenChnls,chnls);
        end
		function val = GetDAChnlSamplingRate(obj, chnls)
			val = zeros(size(chnls));
			for ii = 1:numel(val)
				val(ii) = obj.da_list(obj.da_channel_list(chnls(ii)).index).da.sample_rate;
			end
        end
		function val = GetADChnlSamplingRate(obj,chnls)
			val = zeros(size(chnls));
			for ii = 1:numel(val)
				val(ii) = obj.ad_list(obj.ad_channel_list(chnls(ii)).index).ad.sample_rate;
			end
        end
        function val = GetTrigInterval(obj)
			val = obj.da_list(obj.da_master_index).da.trig_interval;
		end
    end
    methods (Access = private) % Yulin Wu
        function obj = ustcadda_v1()
            obj.Config();
            obj.Open();
        end
    end
    methods (Static = true)
        function obj = GetInstance() % Yulin Wu
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.ustcadda_v1();
                objlst = obj;
            else
                obj = objlst;
            end
        end
        function seq = GenerateTrigSeq(count,delay)
            if(mod(count,8) ~= 0)
                count = (floor(count/8)+1);
            else
                count = count/8;
            end
            seq  = zeros(1,8);
            function_ctrl = 64;     %53-63bits,set trig bits
            trigger_ctrl  = 0;      %48-55bits
            counter_ctrl  = 0;      %32-47bits
            length_wave   = 2;      %16-31bits
            address_wave  = 0;      %0-15bits
            seq(1) = function_ctrl*256 + trigger_ctrl;
            seq(2) = counter_ctrl;
            seq(3) = length_wave;
            seq(4) = address_wave;
            if(delay ~= 0)
                function_ctrl = 32+128;     %53-63bits,set delay bits and stop bit
                counter_ctrl  = delay-1;    %32-47bits,set counter
            else
                function_ctrl = 128;        %do not set delay bits and set stop bit.
                counter_ctrl  = 0;
            end
            trigger_ctrl = 0; 
            length_wave  = count;
            address_wave = count;
            seq(5) = function_ctrl*256 + trigger_ctrl;
            seq(6) = counter_ctrl;
            seq(7) = length_wave;
            seq(8) = address_wave;            
        end
        function seq = GenerateContinuousSeq(count)
            seq  = zeros(1,16384);
            if(mod(count,8) ~= 0)
                count = floor(count/8)+1;
            else
                count = count/8;
            end
            for k = 1:4096
                seq(4*k-3) = 0;
                seq(4*k-2) = 0;
                seq(4*k-1) = count;
                seq(4*k) = 0;
            end
        end
    end
    methods
        function Config(obj)
            obj.Close();
            QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('ustcadda');
            obj.numDABoards = length(s.da_boards);
            obj.numADBoards = length(s.ad_boards);
            obj.daOutputDelayStep = s.daOutputDelayStep;
            obj.daTrigDelayStep = s.daTrigDelayStep;
            obj.adDelayStep = s.adDelayStep;
            obj.adRange = s.adRange;
            for k = 1:obj.numDABoards
                obj.da_list(k).da = qes.hwdriver.sync.ustcadda_backend.USTCDAC(...
                    s.da_boards{k}.ip,s.da_boards{k}.port);
                obj.da_list(k).da.SetDAName(s.da_boards{k}.name);
                obj.da_list(k).da.SetChannelAmount(s.da_boards{k}.numChnls);
                % ========20180128=========
                % gain = cell2mat(s.da_boards{k}.gain);
                % =========================
                gain = s.da_boards{k}.gain;
                for kk = 1:obj.da_list(k).da.channel_amount    
                    obj.da_list(k).da.SetGain(kk,gain(kk));
                end
                obj.da_list(k).da.SetSampleRate(s.da_boards{k}.samplingRate);
                obj.da_list(k).da.SetSyncDelay(s.da_boards{k}.syncDelay);
                obj.da_list(k).da.SetTrigCorr(s.da_boards{k}.daTrigDelayOffset);
                obj.da_list(k).da.SetTrigSel(s.trigger_source);
                % ===================20180128=======================
                % obj.da_list(k).da.SetOffsetCorr(cell2mat(s.da_boards{k}.offsetCorr));
                % ==================================================
                obj.da_list(k).da.SetOffsetCorr(s.da_boards{k}.offsetCorr);
                obj.da_list(k).da.SetTrigInterval(s.triggerInterval);
                if isfield(s,'da_master') && s.da_master == k
                    obj.da_list(k).da.SetIsMaster(true);
                    obj.da_master_index = k;
                end
                obj.da_list(k).mask_plus = 0; % Use to control trigger delay channel.
                obj.da_list(k).mask_min  = 0; % Use to control continuous channel               
            end
            for k = 1:length(s.da_chnl_map)
                % da_chnl_map settting format changed, the following
                % lines has been changed accordingly, Yulin Wu, 170526
                chnlMap_i = strsplit(regexprep(s.da_chnl_map{k},'\s+',''),',');
                da_index = round(str2double(chnlMap_i{1}));
                ch = round(str2double(chnlMap_i{2}));
                numDAs = numel(obj.da_list);
                if da_index < 0
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('invalid settings found in da_chnl_map{%0.0f}: DA board index can not be an negative number.',...
                        ii, da_index)));
                elseif da_index > numDAs
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('da_chnl_map{%0.0f} points to DA board #%0.0f while only %0.0f DA boards exist.',...
                        ii, da_index, numDAs)));
                end
                if ch > obj.da_list(da_index).da.channel_amount
					throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('Channel %0.0f dose not exist on DA #%s',ch, obj.da_list(da_index).da.name)));
                end
                obj.da_channel_list(k).index = da_index; % bug fix: obj.da_channel_list(ch) -> obj.da_channel_list(k), Yulin Wu
                obj.da_channel_list(k).ch = ch;
                obj.da_channel_list(k).data = [];
                obj.da_channel_list(k).delay = 0;
                
%                 if isfield(s.da_boards{da_index}, 'mixerZeros')
%                     mixerZerosDataFiles = s.da_boards{da_index}.mixerZeros{ch};
%                     filepath = [s.SETTINGS_PATH_,'\','_data','\',mixerZerosDataFiles,'.mat'];
%                     obj.da_channel_list(k).mixerZeros = load(filepath);
%                 end
            end
            for k = 1:obj.numADBoards
                obj.ad_list(k).ad = qes.hwdriver.sync.ustcadda_backend.USTCADC(s.ad_boards{k}.srcmac,s.ad_boards{k}.dstmac);
                obj.ad_list(k).ad.SetADName(s.ad_boards{k}.name);
                obj.ad_list(k).ad.SetChannelNum(s.ad_boards{k}.numChnls);
                obj.ad_list(k).ad.SetSampleFreq(s.ad_boards{k}.samplingRate);
				obj.ad_list(k).ad.SetMode(s.ad_boards{k}.demod);
                obj.ad_list(k).ad.SetTrigCount(s.ad_boards{k}.records_para.trig_count);
                obj.ad_list(k).ad.SetSampleDepth(s.ad_boards{k}.records_para.sample_length);
                freq_num = length(s.ad_boards{k}.demod_para.demod_freq);
                window_start = zeros(1,freq_num);
                window_width = zeros(1,freq_num);
                demod_freq = zeros(1,freq_num);
                for t = 1:freq_num
                    window_start(t) = s.ad_boards{k}.demod_para.window_start(t);
                    window_width(t) = s.ad_boards{k}.demod_para.window_width(t);
                    demod_freq(t) = s.ad_boards{k}.demod_para.demod_freq(t);
                end
                obj.SetADDemodFreq(k,window_start,window_width,demod_freq);
                obj.ad_list(k).ad.SetGain([s.ad_boards{k}.channel_gain(1),s.ad_boards{k}.channel_gain(2)]);
                obj.ad_list(k).I = [];
                obj.ad_list(k).Q = [];
            end
            for k = 1:length(s.ad_chnl_map)
                % ad_chnl_map settting format changed, the following
                % lines has been changed accordingly, Yulin Wu, 170526
                chnlMap_i = strsplit(regexprep(s.ad_chnl_map{k},'\s+',''),',');
                ad_index = round(str2double(chnlMap_i{1}));
                ch = round(str2double(chnlMap_i{2}));
                numADs = numel(obj.ad_list);
                if ad_index < 0
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('invalid settings found in ad_chnl_map{%0.0f}: AD board index can not be an negative number.',...
                        ii, ad_index)));
                elseif ad_index > numADs
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('ad_chnl_map{%0.0f} points to AD board #%0.0f while only %0.0f AD boards exist.',...
                        ii, ad_index, numADs)));
                end
                if ch > obj.ad_list(ad_index).ad.channel_amount
					throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('Channel %0.0f dose not exist on AD #%s',ch, obj.ad_list(ad_index).ad.name)));
                end
                obj.ad_channel_list(k).index = ad_index; % bug fix: obj.ad_channel_list(ch) -> obj.ad_channel_list(k), Yulin Wu
                obj.ad_channel_list(k).ch = ch;
            end
            obj.numDAChnls = length(obj.da_channel_list);
            obj.numADChnls = length(obj.ad_channel_list);
            obj.adTakenChnls = [];
            obj.daTakenChnls = [];     
        end   
        function Close(obj)
            len = length(obj.da_list);
            while(len>0)
                obj.da_list(len).da.Close();
                len = len - 1;
            end
            len = length(obj.ad_list);
            while(len>0)
                obj.ad_list(len).ad.Close();
                len = len - 1;
            end
        end     
        function Open(obj)
            len = length(obj.da_list);
            while(len>0)
                obj.da_list(len).da.Open();
                obj.da_list(len).da.Init();
                len = len - 1;
            end
            len = length(obj.ad_list);
            while(len>0)
                obj.ad_list(len).ad.Open();
                obj.ad_list(len).ad.Init();
                len = len - 1;
            end
        end
        % Parameter adList is the index of ADCs, for example [1,3,4] mean use
        % ad1, ad3 and ad4.
        function isSuccessed = Run(obj,adList) 
            isSuccessed = 1;
            ret = ones(1,length(adList));
            %==============zyr for compatible==============================
            obj.SetDARuntimes(1:obj.numDABoards,zeros(1,obj.numDABoards)+obj.runReps(1));
            obj.SetDATrigCount(1:obj.numDABoards,zeros(1,obj.numDABoards)+obj.runReps(1));
            obj.SetADTrigCount(adList,obj.runReps);
            %==============================================================
            while(sum(ret) ~= 0)
                for k = 1:obj.numDABoards
                    obj.da_list(k).da.StartStop((15 - obj.da_list(k).mask_min)*16);
                    obj.da_list(k).da.StartStop(obj.da_list(k).mask_plus);
                end
                for k=1:obj.numDABoards
                    try
                        state = obj.da_list(k).da.CheckStatus();
                        if(state.isSuccessed ~= 1)
                            obj.da_list(k).da.GetReturn(state.position);% Throw an exception.
                        end
                    catch
                        obj.da_list(k).da.Close();
                        obj.da_list(k).da.Open();
                        obj.da_list(k).da.SetTimeOut(0,2);
                        obj.da_list(k).da.SetTimeOut(1,2);
                        isSuccessed = 0;
                        break
                    end
                end
                if isSuccessed ~= 0  % Add by GM, 20180402
                    for k = 1:length(adList)
                        obj.ad_list(adList(k)).ad.EnableADC();
                    end
                    obj.da_list(obj.da_master_index).da.SendIntTrig();
                    for k = 1:length(adList)
                        [ret(k),obj.ad_list(adList(k)).I,obj.ad_list(adList(k)).Q] = obj.ad_list(adList(k)).ad.RecvData();
                    end
                    if sum(ret)==0 % Add by GM, 20180403
                        for k = 1:obj.numDABoards
                            obj.da_list(k).mask_plus = 0; % This command clears the registry of DA boars, thus no output if ret~=0 and goes to the next circle.
                        end
                    end
                else
                    break
                end
            end

        end
        function SendWave(obj,channel,data,loFreq,loPower,sbFreq)
            
            % disabled temporarily by yulin wu
%             %           -----------fusheng:2018/2/5 add IQmixer calibtation parameter------------------------------
%             mixerZeros = obj.da_channel_list(channel).mixerZeros;
%             if ~isempty(mixerZeros)
%                 calibrated_freq=mixerZeros.lo_freq;
%                 calibrated_power=mixerZeros.lo_power;
%                 if loFreq>=calibrated_freq(1) && loFreq<=calibrated_freq(end) && ...
%                         loPower>=calibrated_power(1) && loPower<=calibrated_power(end)
%                     [mesh_freq,mesh_power]=meshgrid(calibrated_freq,calibrated_power);
%                     if ~ismember(loPower,calibrated_power)
%                         warning(['Attention:local_power is not calibrated,calibrated power is ',mat2str(calibrated_power)]);
%                     end
%                     isIChnl=isfield(mixerZeros,'I_offset');
%                     if(isIChnl)                        
%                         offset=interp2(mesh_freq,mesh_power,mixerZeros.I_offset',loFreq,loPower);
%                     else
%                         offset=interp2(mesh_freq,mesh_power,mixerZeros.Q_offset',loFreq,loPower);
%                     end
%                  obj.setDAChnlOutputOffset(channel,offset);
% %                  disp([num2str(loFreq),'   ',num2str(loPower),'   ',num2str(offset)]);
%                 end
%             end
% %           -----------------------------------------------------------------
            
            obj.da_channel_list(channel).data = data;
            ch_info = obj.da_channel_list(channel);
            ch_delay = obj.da_channel_list(channel).delay;
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            len = length(data);
            seq = obj.GenerateTrigSeq(len,ch_delay);       
            da_struct.da.WriteSeq(ch,0,seq);
            if(mod(len,8) ~= 0)
                data(len+1:(floor(len/8)+2)*8) = 32768;
            end
            len = length(data);
            data(len+1:len+16) = 32768;
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            % than a ustcadda property, Yulin Wu
            data = uint16(data +...
                obj.da_list(obj.da_channel_list(channel).index).da.offset(obj.da_channel_list(channel).ch)); 
            da_struct.da.WriteWave(ch,0,data);
            if(mod(floor(da_struct.mask_plus/(2^(ch-1))),2) == 0)
                obj.da_list(ch_info.index).mask_plus = da_struct.mask_plus + 2^(ch-1);
            end
        end
        function SendContinuousWave(obj,channel,voltage)
            if(length(voltage) == 1)
                voltage = zeros(1,8) + voltage;
            end
            len = length(voltage);
            if(mod(len,8) ~= 0)                     % 采样点个数不是8的整数倍，需要补齐
                t = floor(len/8);
                if(max(voltage) == min(voltage))    %前面是直流
                    voltage(length(voltage)+1:t*8+8) = voltage(1);
                else
                    voltage(length(voltage)+1:t*8+8) = 32768;
                end
            end
            ch_info = obj.da_channel_list(channel);
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            da_struct.da.StartStop(2^(ch-1)*16);
            seq = obj.GenerateContinuousSeq(length(voltage));
            da_struct.da.WriteSeq(ch,0,seq);
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            % than a ustcadda property, Yulin Wu
            da_struct.da.WriteWave(ch,0,uint16(voltage));
            if(mod(floor(da_struct.mask_min/(2^(ch-1))),2) == 0)
                obj.da_list(ch_info.index).mask_min = da_struct.mask_min + 2^(ch-1);
            end
            da_struct.da.StartStop(240);
            da_struct.da.StartStop(obj.da_list(ch_info.index).mask_min);
        end  
        function StopContinuousWave(obj,channel)
            ch_info = obj.da_channel_list(channel);
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            if(mod(floor(da_struct.mask_min/(2^(ch-1))),2) ~= 0)
                obj.da_list(ch_info.index).mask_min = da_struct.mask_min - 2^(ch-1);
                da_struct.da.StartStop(2^(ch-1)*16);
            end
        end
        function SetDAChnlOutputDelay(obj,ch,delay)
            if(length(ch) == length(delay))
                for k = 1:length(ch)
                    obj.da_channel_list(ch(k)).delay = delay(k);
                end
            else
                error('ustcadda_v1:SetDAChnlOutputDelay','参数维度不同！');
            end
        end
        function SetDABoardTrigDelay(obj,daList, delayList)
            if(length(daList) == length(delayList))
                for k = 1:length(daList)
                   obj.da_list(daList(k)).da.SetTrigDelay(delayList(k));
                end
            else
                error('ustcadda_v1:SetDABoardTrigDelay','参数维度不同！');
            end
        end
        function SetDAChnlOutputOffset(obj,ch,offset)
            if(length(ch) == length(offset))
                for k = 1:length(ch)
                    ch_info = obj.da_channel_list(ch(k));
                    da_struct = obj.da_list(ch_info.index);
                    da_struct.da.SetOffset(ch_info.ch,offset(ch(k)));
                end
            else
                error('ustcadda_v1:SetDAChnlOutputOffset','参数维度不同！');
            end
        end
        function SetDATrigCount(obj,daList,trig_count)
            if(length(daList) == length(trig_count))
                for k = 1:length(daList)
%                     daIdex = daList(k);
                    obj.da_list(k).da.SetTrigCount(trig_count(k));
                    obj.da_list(k).da.SetLoop(trig_count(k),trig_count(k),trig_count(k),trig_count(k));
                end
            else
                error('ustcadda_v1:SetDATrigCount','参数维度不同！');
            end
        end
        function SetDARuntimes(obj,daList,runResps)
            if(length(daList) == length(runResps))
                for k = 1:length(daList)
                    daIdex = daList(k);
                    obj.da_list(daIdex).da.SetLoop(runResps(daIdex),runResps(daIdex),runResps(daIdex),runResps(daIdex));
                end
            else
                error('ustcadda_v1:SetDARuntimes','参数维度不同！');
            end
        end
        function SetADDemod(obj,adList,isdemod)
            if(length(adList) == length(isdemod))
                for k = 1:length(adList)
                    obj.ad_list(adList(k)).ad.SetMode(isdemod(k));
                end
            else
                error('ustcadda_v1:SetADDemod','参数维度不同！');
            end
        end
        function SetADDemodFreq(obj,adList,window_start,window_width,demod_freq)
            [adCount,~] = size(demod_freq);
            if(length(adList) == adCount)
                for k = 1:length(adList)
                    obj.ad_list(adList(k)).ad.ConfigDemod(window_start(k,:),window_width(k,:),demod_freq(k,:));
                end
            else
                error('ustcadda_v1:SetADDemodFreq','参数维度不同！');
            end
        end
        function SetADTrigCount(obj,adList,trig_count)
            if(length(adList) == length(trig_count))
                for k = 1:length(adList)
                    obj.ad_list(adList(k)).ad.SetTrigCount(trig_count(k));
                end
            else
                error('ustcadda_v1:SetADTrigCount','参数维度不同！');
            end
        end
        function SetADSampleDepth(obj,adList,samp_depth)
            if(length(adList) == length(samp_depth))
                for k = 1:length(adList)
                    obj.ad_list(adList(k)).ad.SetSampleDepth(samp_depth(k));
                end
            else
                error('ustcadda_v1:SetADSampleDepth','参数维度不同！');
            end
        end
        function delay  = GetDABoardTrigDelay(obj,daList)
            delay = zeros(1,length(daList));
            for k = 1:length(daList)
                delay(k) = obj.da_list(daList(k)).da.trig_delay;
            end
        end
        function isdemod = GetADDemod(obj,adList)
            isdemod = zeros(1,length(adList));
            for k = 1:length(adList)
                isdemod(k) = obj.ad_list(adList(k)).ad.isdemod;
            end
        end
        function name    = GetDACNameByChnl(obj,ch)
            numChnls = numel(ch);
            ch_info = obj.da_channel_list(ch);
            name = cell(1,numChnls);
            for k = 1:numChnls
                name{k} = obj.da_list(ch_info(k).index).da.name;
            end
        end
        function num = GetDACNumByChnl(obj,ch) % Add by GM, 20180403
            numChnls = numel(ch);
            ch_info = obj.da_channel_list(ch);
            for k = 1:numChnls
                num(k) = ch_info(k).index;
            end
        end
        function name    = GetADCNameByChnl(obj,ch)
            numChnls = numel(ch);
            ch_info = obj.ad_channel_list(ch);
            name = cell(1,numChnls);
            for k = 1:numChnls
                name{k} = obj.ad_list(ch_info(k).index).ad.name;
            end
        end
        function delete(obj) % Yulin Wu
            obj.Close();
        end
        
        
        % =================zyr for compatible===========================
        function SetAdRecordLength(obj,chnl, val)
		% to future version, adRecordLength must be a channel property
			obj.adRecordLength = val;
            SetADSampleDepth(obj,1,val);
		end
		function val = GetAdRecordLength(obj,chnl)
		% to future version, adRecordLength must be a channel property
			val = obj.adRecordLength;
        end
        % ===============zyr for compatible=============================
    end
end