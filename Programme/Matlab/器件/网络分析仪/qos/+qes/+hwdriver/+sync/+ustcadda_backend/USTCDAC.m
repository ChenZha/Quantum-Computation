% 	FileName:USTCDAC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.9.12
%   Description:The class of DAC

classdef USTCDAC < handle
    properties (SetAccess = private)
        id = [];            % device id
        ip = '';            % device ip
        port = 80;          % port number
        status = 'close';   % open state
        isopen = 0;         % open flag
    end
    
    properties
        isblock = 0;            % is run in block mode
        name = 'Unnamed';       % DAC's name
        channel_amount = 4;     % DAC maximum channel number
        sample_rate = 2e9;      % DAC sample rate
        sync_delay = 0;         % DAC sync delay
        trig_delay = 0;         % DAC trig sync delay
        da_range = 0.8;         % maximum voltage，unused
        gain = zeros(1,4);      % DAC channel gain
        offset = zeros(1,4);    % DAC channel offset, unused
        offsetCorr = zeros(1,4);% DAC offset voltage code.
        trig_sel = 0;           % trigger source select
        trig_interval = 200e-6; % trigger interval
        ismaster = 0;           % master flag
        daTrigDelayOffset = 0;  % fix offset between trig and dac output.
    end
    
    properties (GetAccess = private,Constant = true)
        driver  = 'USTCDACDriver';      % dll module name
        driverh = 'USTCDACDriver.h';    % dll header file name
        driverdll = 'USTCDACDriver.dll' % dll binary file name
    end
    
    methods (Static = true)
        function LoadLibrary()
            if(~libisloaded(qes.hwdriver.sync.ustcadda_backend.USTCDAC.driver))
                loadlibrary(qes.hwdriver.sync.ustcadda_backend.USTCDAC.driverdll,qes.hwdriver.sync.ustcadda_backend.USTCDAC.driverh);
            end
        end 
        function info = GetDriverInformation()
            str = libpointer('cstring',blanks(1024));
            [ErrorCode,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCDAC.driver,'GetSoftInformation',str);
            qes.hwdriver.sync.ustcadda_backend.USTCDAC.DispError('USTCDAC:GetDriverInformation:',ErrorCode);
        end
        function DispError(MsgID,errorcode)
            if(errorcode ~= 0)
                str = libpointer('cstring',blanks(1024));
                [~,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCDAC.driver,'GetErrorMsg',int32(errorcode),str);
                msg = ['Error code:',num2str(errorcode),' --> ',info];
                qes.hwdriver.sync.ustcadda_backend.WriteErrorLog([MsgID,' ',msg]);
                error(MsgID,[MsgID,' ',msg]);
            end
        end
        function data = FormatData(datain)
            len = length(datain);
            data = datain;
            if(mod(len,32) ~= 0)     % 补齐512bit
                len = (floor(len/32)+1)*32;
                data = zeros(1,len);
                data(1:length(datain)) = datain;
            end
            for k = 1:length(data)/2 % 颠倒前后数据，这是由于FPGA接收字节序问题
                temp = data(2*k);
                data(2*k) = data(2*k-1);
                data(2*k-1) = temp;
            end
        end
    end
    
    methods
        function obj = USTCDAC(ip,port)   % Construct function 
            obj.ip = ip; obj.port = port;
        end
        function Open(obj)                % Connect to DAC board.
            obj.LoadLibrary();
            if ~obj.isopen
                [ErrorCode,obj.id,~] = calllib(obj.driver,'OpenDAC',0,obj.ip,obj.port);
                obj.DispError(['USTCDAC:Open:',obj.name],ErrorCode);
                obj.isopen = 1; obj.status = 'open';
            end
        end
        function Close(obj)               % Disconnect to DAC board.
            if obj.isopen
                ErrorCode = calllib(obj.driver,'CloseDAC',uint32(obj.id));
                obj.DispError(['USTCDAC:Close:',obj.name],ErrorCode);
                obj.id = [];obj.status = 'closed';obj.isopen = false;
            end
        end
        function Init(obj)                % Init DAC after first time connect DAC
            isDACReady = 0; try_count = 10;
            while(try_count > 0 && ~isDACReady)
                lane = zeros(1,8);idx = 1;
                for addr = 1136:1139
                    lane(idx)   = obj.ReadAD9136(1,addr);
                    lane(idx+1) = obj.ReadAD9136(2,addr);
                    idx = idx + 2;
                end
                light = obj.ReadReg(5,8);
                lane = mod(lane,256);
                if(sum(lane == 255) == length(lane) && mod(floor(light/(2^20)),4) == 3)
                    isDACReady= 1;
                else                 
                    obj.InitBoard();
                    pause(1); try_count =  try_count - 1;
                end
            end
            if(isDACReady == 0)
                error('USTCDAC:Init',['Init DAC ',obj.name,' failed']);
            end
            obj.SetTimeOut(0,2);
            obj.SetTimeOut(1,2);
            obj.SetIsMaster();
            obj.SetTrigSel();
            obj.SetTrigInterval();
            obj.SetTotalCount();
            obj.SetLoop(1,1,1,1);
            obj.SetSyncDelay();
            obj.SetTrigDelay();
            for k = 1:obj.channel_amount
                obj.SetGain(k,obj.gain(k));
                obj.SetDefaultVolt(k,32768);
            end
        end
        function WriteReg(obj,bank,addr,data)
             cmd = bank*256 + 2; %1表示ReadReg，指令和bank存储在一个DWORD数据中
             ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,cmd,addr,data);
             obj.DispError(['USTCDAC:WriteReg:',obj.name],ErrorCode);
             obj.Block();
        end
        function reg = ReadReg(obj,bank,addr)
             cmd = bank*256 + 1; %1表示ReadReg，指令和bank存储在一个DWORD数据中
             ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,cmd,addr,0);
             obj.DispError(['USTCDAC:ReadReg:',obj.name],ErrorCode);
             value = obj.GetReturn(1);
             reg = value.ResponseData;
        end
        function WriteWave(obj,ch,offset,wave)
            if(ch < 1 || ch > obj.channel_amount) % 从0通道开始编号
                error('Wrong channel!');
            end
            data = obj.FormatData(wave); % 调字节序以及补够512bit的位宽
            data = data + obj.offsetCorr(ch) + obj.offset(ch);
            data(data > 65535) = 65535;  % 范围限制
            data(data < 0) = 0;
            data = 65535 - data;         % 由于负通道接示波器，数据反相方便观察
            startaddr = (ch-1)*2*2^18+2*offset;
            len = length(data)*2;
            pval = libpointer('uint16Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'WriteMemory',obj.id,hex2dec('000000004'),startaddr,len,pval);
            obj.DispError(['USTCDAC:WriteWave:',obj.name],ErrorCode);
            obj.Block();
        end
        function WriteSeq(obj,ch,offset,seq)
            data = obj.FormatData(seq);
            if(ch < 1 || ch > obj.channel_amount)
                error('Wrong channel!');        % 检查通道编号
            end
            startaddr = (ch*2-1)*2^18+offset*8; %序列的内存起始地址，单位是字节。
            len = length(data)*2;               %字节个数。
            pval = libpointer('uint16Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'WriteMemory',obj.id,hex2dec('00000004'),startaddr,len,pval);
            obj.DispError(['USTCDAC:WriteSeq:',obj.name],ErrorCode);
            obj.Block();
        end
        function functype = GetFuncType(obj,offset)
             [ErrorCode,functiontype,instruction,para1,para2] = calllib(obj.driver,'GetFunctionType',obj.id,offset,0,0,0,0);
             obj.DispError(['USTCDAC:GetFuncType:',obj.name],ErrorCode);
             template = {{'Write instruction type'},{'Write memory type.'},{'Read memory type.'}};
             functype = struct('functiontype',functiontype,'instruction',instruction,'para1',para1,'para2',para2,'description',template{functiontype});
        end
        function SetTimeOut(obj,isOut,time)
            ErrorCode = calllib(obj.driver,'SetTimeOut',obj.id,isOut,time);
            obj.DispError(['USTCDAC:SetTimeOut:',obj.name],ErrorCode);
        end
        function Block(obj)
            if(obj.isblock)
                obj.GetReturn(1);
            end
        end
        function data  = ReadAD9136(obj,chip,addr)
            if(chip == 1)
                ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001c05'),addr,0);
            else
                ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001d05'),addr,0);
            end
            obj.DispError(['USTCDAC:ReadAD9136:',obj.name],ErrorCode);
            value = obj.GetReturn(1);
            data = value.ResponseData;
        end
        function value = GetReturn(obj,offset)
           functype = obj.GetFuncType(1);
           if functype.functiontype ~= 1
                pData = libpointer('uint16Ptr',zeros(1,functype.para2/2));
           else
                pData = libpointer('uint16Ptr',zeros(1,1));
           end
           [ErrorCode,ResStat,ResData,data] = calllib(obj.driver,'GetReturn',obj.id,offset,0,0,pData);
           obj.DispError(['USTCDAC:GetReturn:',obj.name],ErrorCode);
           obj.DispError(['USTCDAC:GetReturn:',obj.name],int32(ResStat));
           value = struct('ResponseState',ResStat,'ResponseData',ResData,'data',data);
        end
        function state = CheckStatus(obj)
           [ErrorCode,isSuccessed,pos] = calllib(obj.driver,'CheckSuccessed',obj.id,0,0);
           state = struct('isSuccessed',isSuccessed,'position',pos);
           obj.DispError(['USTCDAC:CheckStatus:',obj.name],ErrorCode);
        end
    end
    
    methods
        function InitBoard(obj)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001A05'),11,2^16);
            obj.DispError(['USTCDAC:InitBoard:',obj.name],ErrorCode);
            obj.Block();
        end
        function PowerOnDAC(obj,chip,onoff)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001E05'),chip,onoff);
            obj.DispError(['USTCDAC:PowerOnDAC:',obj.name],ErrorCode);
            obj.Block();
        end
        function StartStop(obj,index)
            ErrorCode = calllib(obj.driver,'WriteInstruction', obj.id,hex2dec('00000405'),index,0);
            obj.DispError(['USTCDAC:StartStop:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetLoop(obj,arg1,arg2,arg3,arg4)
            para1 = arg1*2^16 + arg2; para2 = arg3*2^16 + arg4;
            ErrorCode = calllib(obj.driver,'WriteInstruction', obj.id,hex2dec('00000905'),para1,para2);
            obj.DispError(['USTCDAC:SetLoop:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetTotalCount(obj,count)
            if(nargin == 1)
                count = obj.trig_interval/4e-9 - 2000;
            end
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),1,uint32(count*2^16));
            obj.DispError(['USTCDAC:SetTotalCount:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetDACStart(obj,count)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),2,count*2^16);
            obj.DispError(['USTCDAC:SetDACStart:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetDACStop(obj,count)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),3,count*2^16);
            obj.DispError(['USTCDAC:SetDACStop:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetTrigStart(obj,count)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),4,count*2^16);
            obj.DispError(['USTCDAC:SetTrigStart:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetTrigStop(obj,count)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),5,count*2^16);
            obj.DispError(['USTCDAC:SetTrigStop:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetIsMaster(obj,ismaster)
            if(nargin == 2)
                obj.ismaster = ismaster;
            end
            if(obj.isopen)
                ErrorCode= calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),6,obj.ismaster*2^16);
                obj.DispError(['USTCDAC:SetIsMaster:',obj.name],ErrorCode);
                obj.Block();
            end
        end
        function SetTrigSel(obj,sel)
            if(nargin == 2)
                obj.trig_sel = sel;
            end
            if(obj.isopen)
                ErrorCode= calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),7,obj.trig_sel*2^16);
                obj.DispError(['USTCDAC:SetTrigSel:',obj.name],ErrorCode);
                obj.Block();
            end
        end
        function SendIntTrig(obj)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),8,2^16);
            obj.DispError(['USTCDAC:SendIntTrig:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetTrigInterval(obj,T)
            if(nargin == 2)
                obj.trig_interval = T;
            end
            if(obj.isopen)
                ErrorCode= calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),9,floor(obj.trig_interval/4e-9)*2^12);
                obj.DispError(['USTCDAC:SetTrigInterval:',obj.name],ErrorCode);
                obj.Block();
            end
        end 
        function SetTrigCount(obj,count)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001805'),10,count*2^12);
            obj.DispError(['USTCDAC:SetTrigCount:',obj.name],ErrorCode);
            obj.Block();
        end
        function ClearTrigCount(obj)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001F05'),0,0);
            obj.DispError(['USTCDAC:ClearTrigCount:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetDefaultVolt(obj,channel,volt)
            volt = volt + obj.offsetCorr(channel) + obj.offset(channel);
            volt(volt > 65535) = 65535;  % 范围限制
            volt(volt < 0) = 0;
            volt = 65535 - volt;         % 由于负通道接示波器，数据反相方便观察
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001B05'),channel-1,volt);
            obj.DispError(['USTCDAC:SetDefaultVolt:',obj.name],ErrorCode);
            obj.Block();
        end
        function SetBoardcast(obj,isBoardcast,period)
            period = floor(period*5);
            period(period > 255) = 255;
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00001305'),isBoardcast,period);
            obj.DispError(['USTCDAC:SetBoardcast:',obj.name],ErrorCode);
            obj.Block();
        end
        function ConfigEEPROM(obj)
            ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00002005'),0,0);
            obj.DispError(['USTCDAC:ConfigEEPROM:',obj.name],ErrorCode);
            obj.Block();
        end
        function temp = GetDATemperature(obj,chip)
            tt1 = obj.ReadAD9136(chip,hex2dec('132'));
            tt2 = obj.ReadAD9136(chip,hex2dec('133'));
            tt1 = double(mod(tt1,256));
            tt2 = double(mod(tt2,256));
            temp = 30+7.3*(tt2*256+tt1-39200)/1000.0;
        end
        function SetDAName(obj,name)
            obj.name = name;
        end
        function SetChannelAmount(obj,amount)
            if(obj.channel_amount ~= amount)
                obj.channel_amount = amount;
                obj.offsetCorr = zeros(1,amount);
                obj.gain = zeros(1,amount);
                obj.offset = zeros(1,amount);
            end
        end
        function SetSampleRate(obj,sample_rate)
            obj.sample_rate = sample_rate;
        end
        function SetSyncDelay(obj,point)
            if(nargin == 2)
                obj.sync_delay = point;
            end
            if(obj.isopen)
                obj.SetDACStart(obj.sync_delay/8 + 1);
                obj.SetDACStop(obj.sync_delay/8 + 10);
            end
        end
        function SetTrigDelay(obj,point)
            if(nargin == 2)
                obj.trig_delay = point;
            end
            if(obj.isopen)
                obj.SetTrigStart((obj.daTrigDelayOffset + obj.trig_delay)/8+1);
                obj.SetTrigStop((obj.daTrigDelayOffset + obj.trig_delay)/8+10);
            end
        end
        function SetGain(obj,channel,data)
            obj.gain(channel) = data;
            if(obj.isopen)
                map = [2,3,0,1];ch_new = map(channel);
                ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00000702'),ch_new,obj.gain(channel));
                obj.DispError(['USTCDAC:SetGain:',obj.name],ErrorCode);
                obj.Block();
            end
        end
        function SetOffset(obj,channel,data)
            obj.offset(channel) = data;
            if(obj.isopen)
                % Do not use inchip offset,so I add offset in wave.
                % map = [6,7,4,5]; ch_new = map(channel);
                % ErrorCode = calllib(obj.driver,'WriteInstruction',obj.id,hex2dec('00000702'),ch_new,data);
                % obj.DispError(['USTCDAC:SetOffset:',obj.name],ErrorCode);
                % obj.Block();
                  obj.SetDefaultVolt(channel,32768);
            end
        end
        function SetTrigCorr(obj,data)
            obj.daTrigDelayOffset = data;
        end
        function SetOffsetCorr(obj,data)
            obj.offsetCorr = data;
        end
    end
end