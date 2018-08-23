% 	FileName:USTCADDA.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.2.26
%   Description:The class of ADDA
classdef ustcadda_v1 < qes.hwdriver.icinterface_compatible % extends icinterface_compatible, Yulin Wu
    properties
        runReps = 1             %run repetition
        
    end
	
	% to future version, these properties must be a channel properties, Yulin Wu
	properties (SetAccess = private, GetAccess = private)
		adRecordLength = 1000;
		adRange
        adDelayStep % unit: DA sampling points
	end
    
    properties (SetAccess = private)
        numDABoards
        numDAChnls
        numADBoards
        numADChnls
    
        daOutputDelayStep
        daTrigDelayStep
        daSamplingRate
    end
    
    properties (SetAccess = private) % Yulin Wu
        adTakenChnls
        daTakenChnls
    end
    
    properties(SetAccess = private, GetAccess = private) 
        da_list = []
        ad_list = []
        da_channel_list = []
        ad_channel_list = []   
        da_master_index = 1
    end
    
    methods % Yulin Wu
		function SetAdRange(obj,chnl, val)
		% to future version, adRecordLength must be a channel property
			throw(MException('ad range is read only.'));
			% obj.adRange = val;
		end
		function val = GetAdRange(obj,chnl)
		% to future version, adRecordLength must be a channel property
			val = obj.adRange;
		end
		function SetAdDelayStep(obj,chnl, val)
		% to future version, adRecordLength must be a channel property
			throw(MException('ad delay step is read only.'));
		end
		function val = GetAdDelayStep(obj,chnl)
		% to future version, adRecordLength must be a channel property
			val = obj.adDelayStep;
		end
		function SetAdRecordLength(obj,chnl, val)
		% to future version, adRecordLength must be a channel property
			obj.adRecordLength = val;
		end
		function val = GetAdRecordLength(obj,chnl)
		% to future version, adRecordLength must be a channel property
			val = obj.adRecordLength;
        end
        
        function d = GetADDemodMode(obj,chnl)
            % to future version, adRecordLength must be a channel property
			d = obj.ad_list(1).ad.demod;
		end
		
		
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
            % 多输�?~7个多余的0
            if(mod(count,8) ~= 0)
                count = (floor(count/8)+1);
            else
                count = count/8;
            end
            % �?个�?列数??但是必须组�?512bit�?宽的数�??
            seq  = zeros(1,16384);
            %first sequence,会产�?6ns延时，用于触?��?�动输出�?
            function_ctrl = 64;   %53-63�?
            trigger_ctrl  = 0;      %48-55�?
            counter_ctrl  = 0;      %32-47�?，计时计数器
            length_wave   = 2;      %16-31�?,输出波形长度
            address_wave  = 0;  %0    %0-15波形起始地�??
            for  k = 1:2:4096 
                seq(4*k-3) = counter_ctrl;
                seq(4*k-2) = function_ctrl*256 + trigger_ctrl;
                seq(4*k-1) = address_wave;
                seq(4*k)   = length_wave;
            end

            if(delay ~= 0)
                function_ctrl = 32;     %53-63�?，计时输出加?�止标识
                counter_ctrl  = delay-1;%32-47�?，计时计数器
            else
                function_ctrl = 0;      %�?�?输出
                counter_ctrl  = 0;
            end
            
            trigger_ctrl = 0;       %48-55�?
            length_wave  = count;   %16-31�?,输出波形长度
            address_wave = count;   %0-15波形起始地�??���?是为了跳过多余的�?�?�?
            for k = 2:2:4096
                seq(4*k-3) = counter_ctrl;
                seq(4*k-2) = function_ctrl*256 + trigger_ctrl;
                seq(4*k-1) = address_wave;
                seq(4*k)   = length_wave;
            end
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
                seq(4*k-1) = 0;
                seq(4*k)   = count;
            end
        end
    end
    
    methods
        function Config(obj)
            obj.Close();
            QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('ustcadda');
            % �?置ADDA
            
            obj.numDABoards = length(s.da_boards);
            obj.numADBoards = length(s.ad_boards);
            obj.daOutputDelayStep = s.daOutputDelayStep;
            obj.daTrigDelayStep = s.daTrigDelayStep;
            obj.adDelayStep = s.adDelayStep;
            obj.adRange = s.adRange;

            % �?置DAC
            for k = 1:obj.numDABoards
                obj.da_list(k).da = qes.hwdriver.sync.ustcadda_backend.USTCDAC(...
                    s.da_boards{k}.ip,s.da_boards{k}.port);
                % set method removed, set properties directly, Yulin Wu, 170427
%                 obj.da_list(k).da.set('name',s.da_boards{k}.name); 
                obj.da_list(k).da.name=s.da_boards{k}.name;
%                 obj.da_list(k).da.set('channel_amount',s.da_boards{k}.numChnls);
                obj.da_list(k).da.channel_amount=s.da_boards{k}.numChnls;
%                 obj.da_list(k).da.set('gain',cell2mat(s.da_boards{k}.gain));
                obj.da_list(k).da.gain=s.da_boards{k}.gain;
%                 obj.da_list(k).da.set('sample_rate',s.da_boards{k}.samplingRate);
                obj.da_list(k).da.sample_rate=s.da_boards{k}.samplingRate;
%                 obj.da_list(k).da.set('sync_delay',s.da_boards{k}.syncDelay);
                obj.da_list(k).da.sync_delay=s.da_boards{k}.syncDelay; 
%                 obj.da_list(k).da.set('trig_delay',s.da_boards{k}.daTrigDelayOffset);
                obj.da_list(k).da.trig_delay=s.da_boards{k}.daTrigDelayOffset;
                %设置trig_sel默认�?
%                 obj.da_list(k).da.set('trig_sel',s.trigger_source);
                obj.da_list(k).da.trig_sel=s.trigger_source;
                %设置master?�，默认值为第一个�??
%                 obj.da_list(k).da.set('ismaster', 0); % ismaster is false byt default, Yulin Wu, 170427
                if isfield(s,'da_master') && s.da_master == k
                    % Yulin Wu, 170427
                    obj.da_list(k).da.ismaster=true;
                    obj.da_master_index = k;
                end
                % �?始化通�?�的mask�?
                obj.da_list(k).mask_plus = 0; %正mask
                obj.da_list(k).mask_min  = 0; %负mask
%                 obj.da_list(k).da.set('trig_interval',s.triggerInterval);
                obj.da_list(k).da.trig_interval=s.triggerInterval;
                % da_trig_delay属�?
                obj.da_list(k).da_trig_delay = 0;
                % redefined offsetCorr settings, Yulin Wu
%                 obj.da_list(k).da.set('offsetcorr',cell2mat(s.da_boards{k}.offsetCorr));
                obj.da_list(k).da.offsetcorr= s.da_boards{k}.offsetCorr;
            end

            % 设置主�??
            % removed by Yulin Wu, 170427
%             obj.da_list(obj.da_master_index).da.set('ismaster',true);
%             obj.da_list(obj.da_master_index).da.set('trig_interval',s.triggerInterval);
%             obj.da_list(obj.da_master_index).da.ismaster=true;
%             obj.da_list(obj.da_master_index).da.trig_interval=s.triggerInterval;
                        % 映射通�??
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
                        k, da_index)));
                elseif da_index > numDAs
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('da_chnl_map{%0.0f} points to DA board #%0.0f while only %0.0f DA boards exist.',...
                        k, da_index, numDAs)));
                end
                if ch > obj.da_list(da_index).da.channel_amount
					throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('Channel %0.0f dose not exist on DA #%s',ch, obj.da_list(da_index).da.name)));
				end
                obj.da_channel_list(k).index = da_index; % bug fix: obj.da_channel_list(ch) -> obj.da_channel_list(k), Yulin Wu
                obj.da_channel_list(k).ch = ch;
                % 添加数�?�结构体
                obj.da_channel_list(k).data = [];
                % 设置通�?�触?��?�输出延�?
                obj.da_channel_list(k).delay = 0;
                
            end
            % �?置ADC,目�??�支�?�?��网�??
            for k = 1:obj.numADBoards
                obj.ad_list(k).ad = qes.hwdriver.sync.ustcadda_backend.USTCADC(s.ad_boards{k}.netcard);
                % Yulin Wu, 170427
%                 obj.ad_list(k).ad.set('sample_rate',s.ad_boards{k}.samplingRate);
%                 obj.ad_list(k).ad.set('channel_amount',s.ad_boards{k}.numChnls);
%                 obj.ad_list(k).ad.set('mac',s.ad_boards{k}.mac);
                obj.ad_list(k).ad.sample_rate=s.ad_boards{k}.samplingRate;
                obj.ad_list(k).ad.channel_amount=s.ad_boards{k}.numChnls;
                obj.ad_list(k).ad.mac=s.ad_boards{k}.mac;
				obj.ad_list(k).ad.demod = s.ad_boards{k}.demod;
            end
            % 映射ADC的�???
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
                % 添加数�?�结构体
                % obj.da_channel_list(ch).data = []; % bug? Yulin Wu
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
                len = len - 1;
            end
            len = length(obj.ad_list);
            while(len>0)
                obj.ad_list(len).ad.Open();
                len = len - 1;
            end
        end
		
		function [I,Q] = Run(obj,freqOrIssample)
			 if obj.ad_list(1).ad.demod
				[I,Q] = RunDemo_(obj,freqOrIssample);
			 else
				[I,Q] = Run_(obj,freqOrIssample);
			 end
		end
        
        function [I,Q] = Run_(obj,isSample)
            I=0;Q=0;ret = -1;

            obj.da_list(obj.da_master_index).da.SetTrigCount(obj.runReps); %20170411

            obj.ad_list(1).ad.SetMode(0);
            obj.ad_list(1).ad.SetTrigCount(obj.runReps);
            obj.ad_list(1).ad.SetSampleDepth(obj.adRecordLength);
            % ?�止除连续波形外的�??�，?�动触�?��???
            for k = 1:obj.numDABoards
                obj.da_list(k).da.StartStop((15 - obj.da_list(k).mask_min)*16);
                obj.da_list(k).da.StartStop(obj.da_list(k).mask_plus);
                obj.da_list(k).da.SetTrigDelay(obj.da_list(k).da_trig_delay);
            end
            % �?��是�?��?功写入完�?
            
            for k=1:obj.numDABoards
%                 tic
                isSuccessed = obj.da_list(k).da.CheckStatus();
%                 toc
                if(isSuccessed ~= 1)
                    disp(obj.da_list(k).da.name);
                    error('ustcadda_v1:Run','There were some task failed!');
                end
            end
            % 采集数�??
            while(ret ~= 0)
                obj.ad_list(1).ad.EnableADC();  
                obj.da_list(obj.da_master_index).da.SendIntTrig();
                if(isSample == true)
                    [ret,I,Q] = obj.ad_list(1).ad.RecvData(obj.runReps,obj.adRecordLength);
                else
                    ret = 0;
                end
            end
            % 将数?�整?��?固定格�?
            if(isSample == true)
                I = (reshape(I,[obj.adRecordLength,obj.runReps]))';
                Q = (reshape(Q,[obj.adRecordLength,obj.runReps]))';
            end
            % 并清空�??�记�?
            for k = 1:obj.numDABoards
                obj.da_list(k).mask_plus = 0;
                obj.da_list(k).da_trig_delay = 0;
            end
        end
        
        function [I,Q] = RunDemo_(obj,frequency) %Unit:Hz
            I=0;Q=0;ret = -1;
            
            obj.da_list(obj.da_master_index).da.SetTrigCount(obj.runReps); %20170411
            
%             obj.ad_list(1).ad.SetGain(1); % Temp
            obj.ad_list(1).ad.SetMode(1);          
            obj.ad_list(1).ad.SetWindowStart(9);
            obj.ad_list(1).ad.SetWindowLength(obj.adRecordLength);
            obj.ad_list(1).ad.SetSampleDepth(obj.adRecordLength +24);  
            obj.ad_list(1).ad.SetDemoFre(frequency);
            obj.ad_list(1).ad.SetTrigCount(obj.runReps);
            
            % ?�止除连续波形外的�??�，?�动触�?��???
            for k = 1:obj.numDABoards
                obj.da_list(k).da.StartStop((15 - obj.da_list(k).mask_min)*16);
                obj.da_list(k).da.StartStop(obj.da_list(k).mask_plus);
                obj.da_list(k).da.SetTrigDelay(obj.da_list(k).da_trig_delay);
            end
            % �?��是�?��?功写入完�?
            
            for k=1:obj.numDABoards
%                 tic
                isSuccessed = obj.da_list(k).da.CheckStatus();
%                 toc
                if(isSuccessed ~= 1)
                    error('ustcadda_v1:Run','There were some task failed!');
                end
            end
            % 采集数�??
            while(ret ~= 0)
                obj.ad_list(1).ad.EnableADC();  
                obj.da_list(obj.da_master_index).da.SendIntTrig();
                [ret,I,Q] = obj.ad_list(1).ad.RecvData(obj.runReps,obj.adRecordLength);
                if ret ~= 0
                    pause(1)
                end
            end
            % 将数?�整?��?固定格�?
            I = double(I)/256/obj.adRecordLength*2/2^12;
            Q = double(Q)/256/obj.adRecordLength*2/2^12;
            % 并清空�??�记�?
            for k = 1:obj.numDABoards
                obj.da_list(k).mask_plus = 0;
                obj.da_list(k).da_trig_delay = 0;
            end
        end
        
        function SendWave(obj,channel,data,loFreq,loPower,sbFreq)
%             disp('in ustcadda_v1.SendWave: ');
%             loFreq
%             loPower
%             sbFreq
            
            if nargin < 4
                isIQ = false;
            end
            obj.da_channel_list(channel).data = data;
            ch_info = obj.da_channel_list(channel);
            ch_delay = obj.da_channel_list(channel).delay;
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            len = length(data);
            % 生�?格�?化的�?�?
            seq = obj.GenerateTrigSeq(len,ch_delay);
            % ?��?�?�?
            da_struct.da.WriteSeq(ch,0,seq);
            % 格�?化波�?�??与�?列数?��??��?�实现格�?
            if(mod(len,8) ~= 0)
                data(len+1:(floor(len/8)+2)*8) = 32768;
            end
            len = length(data);
            data(len+1:len+16) = 32768;    %16个采样点的起始�?
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            
            % redefined offsetCorr to be a da board specific property other
            % than a ustcadda property, Yulin Wu
            data = uint16(data); 
            % ?��?波形
            da_struct.da.WriteWave(ch,0,data);
            % 相当于或上一个�???
            if(mod(floor(da_struct.mask_plus/(2^(ch-1))),2) == 0)
                obj.da_list(ch_info.index).mask_plus = da_struct.mask_plus + 2^(ch-1);
            end
        end
       
        function SendContinuousWave(obj,channel,voltage)
            % 如果是直�?，则�??将其扩大�?*8数组
            if(length(voltage) == 1)
                voltage = zeros(1,8) + voltage;
            end
            % �������������8������������Ҫ����
            len = length(voltage);
            if(mod(len,8) ~= 0)
                t = floor(len/8);
                if(max(voltage) == min(voltage))    %ǰ����ֱ��
                    voltage(length(voltage)+1:t*8+8) = voltage(1);
                else
                    voltage(length(voltage)+1:t*8+8) = 32767;
                end
            end
            ch_info = obj.da_channel_list(channel);
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            % ?�止输出
            da_struct.da.StartStop(2^(ch-1)*16);
            % 写入�?�?
            seq = obj.GenerateContinuousSeq(length(voltage));
            da_struct.da.WriteSeq(ch,0,seq);
            % 写入波形
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            
            % redefined offsetCorr to be a da board specific property other
            % than a ustcadda property, Yulin Wu
            voltage = uint16(voltage +...
                obj.da_list(obj.da_channel_list(channel).index).da.offsetcorr(obj.da_channel_list(channel).ch)); 
            da_struct.da.WriteWave(ch,0,voltage);
            % 更新状�?
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
        
        function setDAChnlOutputDelay(obj,ch,delay)
            obj.da_channel_list(ch).delay = delay;
        end
        
        function SetDABoardTrigDelay(obj,da_name,point)
            for k = 1:obj.numDABoards
                name = obj.da_list(k).da.name;
                if(strcmpi(name,da_name))
                    obj.da_list(k).da_trig_delay = point;
                end
            end
        end
        
        function AddDAOffset(obj,ch,offset)
            if(length(ch)==length(offset))
                for k =1:length(ch)
                    ch_info = obj.da_channel_list(ch(k));
                    channel = ch_info.ch;
                    da = obj.da_list(ch_info.index).da;
                    da.AddOffset(channel,offset(k))
                end
            end
        end
        
        function delay = GetDABoardTrigDelay(obj,da_name)

            for k = 1:obj.numDABoards
                name = obj.da_list(k).da.name;
                if(strcmpi(name,da_name))
                   delay = list(k).da_trig_delay;
                end
            end
            
        end

        function name = GetDACNameByChnl(obj,ch) % Yulin Wu
            numChnls = numel(ch);
            ch_info = obj.da_channel_list(ch);
            name = cell(1,numChnls);
            for ii = 1:numChnls
                da = obj.da_list(ch_info(ii).index).da;
                name{ii} = da.name;
            end
        end

        function delete(obj) % Yulin Wu
            try % the object should be deletable under any circunstance
%                 for ch = obj.numDAChnls % zeroing might not be a good for
%                % qubit measurement, removed, Yulin Wu
%                     obj.SendContinuousWave(ch,32768+obj.offsetCorr(ch)); % zero all channels
%                 end
            catch
            end
            obj.Close();
        end
        
    end
end