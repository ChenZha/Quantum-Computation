% 	FileName:USTCDAC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.4.26
%   Description:The class of DAC

classdef USTCDAC < handle
    properties (SetAccess = private)
        id = [];            %Ã¨Â®Â¾Ã¥Â¤â€¡Ã¦Â â?Ã¨Â¯â€?
        ip = '';            %Ã¨Â®Â¾Ã¥Â¤â€¡ip
        port = 80;          %Ã§Â«Â¯Ã¥?Â£Ã¥??
        status = 'close';   %Ã¦â€°â?Ã¥Â¼â‚¬Ã§Å Â¶Ã?
        isopen = 0;         %Ã¦â€°â?Ã¥Â¼â‚¬Ã§Å Â¶Ã?
        isblock = 0;        %Ã¦ËœÂ¯Ã¥?Â¦Ã¤Â»Â¥Ã©ËœÂ»Ã¥Â¡Å¾Ã¦Â¨Â¡Ã¥Â¼?Ã¨Â¿?Ã¨Â¡?
    end
    
    properties % (SetAccess = private) % changed to public, Yulin Wu, 170427
        name = '';              %DACÃ¥??Ã¥Â­â€?
        channel_amount = 4;     %DACÃ©â‚¬Å¡Ã?â€œÃ¦â?Â°Ã§â€ºÂ?
        sample_rate = 2e9;      %Ã©â€¡â?Ã¦Â Â·Ã§Å½?
        sync_delay = 0;         %DACÃ¦?Â¿Ã¥Â­?Ã§Å¡â€žÃ?Å’Ã¦Â­Â¥Ã¥Â»Â¶Ã¦â€?
        trig_delay = 0;         %DACÃ¨Â§Â¦Ã¥?â€˜Ã¨Â¾â?Ã¥â€¡ÂºÃ¥Â»Â¶Ã¦â?Â¶
        da_range = 0.8;         %Ã¦Å“?Â¤Â§Ã§â€?ÂµÃ¥Å½â€¹Ã¯Â¼Å’Ã¦Å“ÂªÃ¤Â½Â¿Ã§â?Â¨
        gain = zeros(1,4);      %Ã©â‚¬Å¡Ã?â€œÃ¥Â¢Å¾Ã§â?Å 
        offset = zeros(1,4);    %Ã©â‚¬Å¡Ã?â€œÃ??Ã§Â½Â®
        mixer_offset = zeros(1,4); % use to fix the offset of mixer
        offsetcorr  = zeros(1,4); % Ã¥â€¦Â³Ã©â?Â­DACÃ§â€?ÂµÃ¥Å½â€?
        
        trig_sel = 0;           %Ã¨Â§Â¦Ã¥?â€˜Ã¦Â?Ã©?Ã¦â€?
        trig_interval = 200e-6; %Ã¤Â¸Â»Ã¦?Â¿Ã¨Â¿Å¾Ã§Â»Â­Ã¨Â§Â¦Ã¥?â€˜Ã¨Â¾â?Ã¥â€¡ÂºÃ¦â?Â¶Ã©â€”Â´Ã©â?Â´Ã©Å¡â€?
%         ismaster = 0;           %Ã¤Â¸Â»Ã¦?Â¿Ã¦Â â€¡Ã¨Â¯â?
        ismaster = false;           %Yulin Wu
        daTrigDelayOffset = 0;  %Ã¦Å“ÂªÃ¤Â½Â¿Ã§â€??
    end
    
    properties (GetAccess = private,Constant = true)
        driver  = 'USTCDACDriver';   %Ã©Â©Â±Ã¥Å Â¨Ã¥??
        driverh = 'USTCDACDriver.h'; %Ã¥Â¤Â´Ã¦â€“â?Ã¤Â»Â¶Ã¥??
    end
    
    methods (Static = true)
        
        function info = GetDriverInformation()
            if(~libisloaded(USTCDAC.driver))
                driverfilename = [USTCDAC.driver,'.dll'];
                loadlibrary(driverfilename,USTCDAC.driverh);
            end
            str = libpointer('cstring',blanks(50));
            [ret,version] = calllib(USTCDAC.driver,'GetSoftInformation',str);
            if(ret == 0)
                info = version;
            else
                error('USTCDAC: Get information failed!');
            end
        end
        
        function device_array = ScanDevice()
            if(~libisloaded(USTCDAC.driver))
                driverfilename = [USTCDAC.driver,'.dll'];
                loadlibrary(driverfilename,USTCDAC.driverh);
            end
            [ret,data] = calllib(USTCDAC.driver,'ScanDevice','');
            if(ret == 0)
                device_array = data;
            else
                error('USTCDAC: Scan device failed!');
            end
        end
        
    end
    
    methods
        function obj = USTCDAC(ip,port) %construct function.
            obj.ip = ip;
            obj.port = port;
            driverfilename = [obj.driver,'.dll'];
            if(~libisloaded(obj.driver))
                loadlibrary(driverfilename,obj.driverh);
            end
        end
             
        function Open(obj)              %open the device
            if obj.isopen
                return;
            end
            [ret,obj.id,~] = calllib(obj.driver,'Open',0,obj.ip,obj.port);
            if(ret == 0)
                obj.status = 'open';
                obj.isopen = true;
            else
               throw(MException('USTCDAC:OpenError',...
                   sprintf('Open DAC %s failed!',obj.name))); % Yulin Wu
            end
            obj.Init();
        end
         
        function Init(obj)
            obj.SetTimeOut(10);% add by guocheng @20180107
            obj.SetIsMaster(obj.ismaster);
            obj.SetTrigSel(obj.trig_sel);
            obj.SetTrigInterval(obj.trig_interval);

            obj.SetTotalCount(obj.trig_interval/4e-9 - 5000); %20170411

            obj.SetDACStart(obj.sync_delay/4e-9 + 1);
            obj.SetDACStop(obj.sync_delay/4e-9 + 10);
            obj.SetTrigStart(obj.trig_delay/4e-9 + 1);
            obj.SetTrigStop(obj.trig_delay/4e-9 + 10);
            obj.SetLoop(1,1,1,1);
            
            try_count = 10;
            isDACReady = 0;
            
%             obj.InitBoard();
%             ret = obj.GetReturn(1);
%             data = double(ret(2))*65536 + double(ret(1));
%             qes.hwdriver.sync.ustcadda_backend.WriteLog(obj.ip,data);
            
            while(try_count > 0 && ~isDACReady)
                obj.isblock = 1;
                arr = zeros(1,8);
                idx = 1;
                for addr = 1136:1139
                    arr(idx) = obj.ReadAD9136_1(addr);
                    arr(idx+1) = obj.ReadAD9136_2(addr);
                    idx = idx + 2;
                end
                arr = mod(arr,256);
                if(sum(arr == 255) == length(arr))
                    islaneReady = 1;
                else
                    islaneReady = 0;
                end
                ret = obj.ReadReg(5,8);
                obj.isblock = 0;
                if(mod(floor(ret/(2^20)),4) == 3 && islaneReady)
                    isDACReady = 1;
                else
                    isDACReady = 0;
                    obj.InitBoard();
                    
                    pause(0.1);
                end
                try_count =  try_count - 1;
            end
            
            if(isDACReady == 0)
                disp(obj.ip);
                error('USTCDAC:InitError','Config DAC failed!');
            end

            for k = 1:obj.channel_amount
%                 obj.SetOffset(k,obj.offset(k));
                obj.SetGain(k,obj.gain(k));
                obj.SetDefaultVolt(k,-obj.offsetcorr(k)+32767);
            end
            obj.PowerOnDAC(1,0);
            obj.PowerOnDAC(2,0);
        end
        
        function Close(obj)
            if obj.isopen
                ret = calllib(obj.driver,'Close',uint32(obj.id));
                if(ret == -1)
                    throw(MException('USTCDAC:CloseError',...
                        sprintf('Close DAC %s failed!',obj.name))); % Yulin Wu         
                end
                obj.id = [];
                obj.status = 'closed';
                obj.isopen = false;
            end
        end
        
        function AutoOpen(obj)
            if(~libisloaded(obj.driver))
                driverfilename = [obj.driver,'.dll'];
                loadlibrary(driverfilename,obj.driverh);
            end
            if(~obj.isopen)
                obj.Open();
            end
        end
            
        function StartStop(obj,index)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000405')),uint32(index),0);
            if(ret == -1)
                throw(MException('USTCDAC:StartStopError',...
                        sprintf('Start/Stop DAC %s failed!',obj.name))); % Yulin Wu   
            end
        end
       % Ã¨Â¯Â¥Ã¥â€¡Â½Ã¦â?Â°Ã¦Å“ÂªÃ¤Â½Â¿Ã§â€?Â¨
        function FlipRAM(obj,index)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000305')),uint32(index),0);
            if(ret == -1)
                 error('USTCDAC:FlipRAMError','FlipRAM failed.');
            end
        end
        
        function SetLoop(obj,arg1,arg2,arg3,arg4)
            obj.AutoOpen();
            para1 = arg1*2^16 + arg2;
            para2 = arg3*2^16 + arg4;
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000905')),uint32(para1),uint32(para2));
            if(ret == -1)
                error('USTCDAC:SetLoopError','SetLoop failed.');
            end
        end

        function SetTotalCount(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),1,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetTotalCount','Set SetTotalCount failed.');
             end
        end
        
        function SetDACStart(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),2,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetDACStart','Set SetDACStart failed.');
             end
        end
         
        function SetDACStop(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),3,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetDACStop','Set SetDACStop failed.');
             end
        end
        
        function SetTrigStart(obj,count)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),4,uint32(count*2^16));
            if(ret == -1)
                error('USTCDAC:SetTrigStart','Set SetTrigStart failed.');
            end
        end
        
        function SetTrigStop(obj,count)
            obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),5,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetTrigStop','Set SetTrigStop failed.');
             end
         end
        
        function SetIsMaster(obj,ismaster)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),6,uint32(ismaster*2^16));
            if(ret == -1)
                error('USTCDAC:SetIsMaster','Set SetIsMaster failed.');
            end
        end
        
        function SetTrigSel(obj,sel)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),7,uint32(sel*2^16));
            if(ret == -1)
                error('USTCDAC:SetTrigSel','Set SetTrigSel failed.');
            end
        end
        
        function SendIntTrig(obj)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),8,uint32(2^16));
             if(ret == -1)
                 error('USTCDAC:SendIntTrig','Set SendIntTrig failed.');
             end
        end
                
        function SetTrigInterval(obj,T)
            % T unit: seconds, Step 4ns.
            obj.AutoOpen();
            count = T/4e-9;
            ret= calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001805')),9,uint32(count*2^12));
             if(ret == -1)
                 error('USTCDAC:SelectTrigIntervalError','Set trigger interval failed.');
             end
        end 
        
        function SetTrigCount(obj,count)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001805')),10,uint32(count*2^12));
             if(ret == -1)
                 error('USTCDAC:SetTrigCountError','Set trigger Count failed.');
             end
        end
        
        function SetGain(obj,channel,data)
             obj.AutoOpen();
             map = [2,3,0,1];       %Ã¦Å“â€°bugÃ¯Â¼Å’Ã©Å“â‚¬Ã¨Â?Ã¥?Å¡Ã¤Â¸?Â¬Â¡Ã¦ËœÂ Ã¥Â°â€?
             channel = map(channel);
             ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00000702')),uint32(channel),uint32(data));
             if(ret == -1)
                 error('USTCDAC:WriteGain','WriteGain failed.');
             end
        end
        
        function SetOffset(obj,channel,data)
            obj.AutoOpen();
            map = [6,7,4,5];       %Ã¦Å“â€°bugÃ¯Â¼Å’Ã©Å“â‚¬Ã¨Â?Ã¥?Å¡Ã¤Â¸?Â¬Â¡Ã¦ËœÂ Ã¥Â°â€?
            channel = map(channel);
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00000702')),uint32(channel),uint32(data));
            if(ret == -1)
                 error('USTCDAC:WriteOffset','WriteOffset failed.');
            end
        end
        
        function SetDefaultVolt(obj,channel,volt)
            obj.AutoOpen();
            channel = channel-1;
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001B05')),uint32(channel),uint32(volt));
            if(ret == -1)
                 error('USTCDAC:WriteOffset','WriteOffset failed.');
            end
        end
        
        function WriteReg(obj,bank,addr,data)
             obj.AutoOpen();
             cmd = bank*256 + 2; %1Ã¨Â¡Â¨Ã§Â¤ÂºReadRegÃ¯Â¼Å’Ã¦Å’â€¡Ã¤Â»Â¤Ã¥â?Å’bankÃ¥Â­ËœÃ¥â€šÂ¨Ã¥Å“Â¨Ã¤Â¸â‚¬Ã¤Â¸ÂªDWORDÃ¦â€¢Â°Ã?Â®Ã¤Â¸?
             ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(cmd),uint32(addr),uint32(data));
             if(ret == -1)
                 error('USTCDAC:WriteRegError','WriteReg failed.');
             end
        end
        
        function WriteWave(obj,ch,offset,wave)
            obj.AutoOpen();
            % Ã¨Å’Æ’Ã¥â€ºÂ´Ã©â„¢?Ã¥Ë†Â¶
            wave = wave + obj.mixer_offset(ch) + obj.offsetcorr(ch);
            wave(wave > 65535) = 65535;
            wave(wave < 0) = 0;
            % Ã¨Â¡Â¥Ã¥Â¤Å¸512bitÃ§Å¡â€žÃ¤Â?Ã¥Â®Â½Ã¦â€¢Â´Ã¦â?Â°Ã¥?
            data = wave;
            len = length(wave);
            if(mod(len,32) ~= 0)
                len = (floor(len/32)+1)*32;
                data = zeros(1,len);
                data(1:length(wave)) = wave;
            end            
            % Ã©Â¢Â Ã¥?Ã¥â€?Ã¥?Å½Ã¦â€¢Â°Ã?Â®Ã¯Â¼Å’Ã¨Â¿â„¢Ã¦ËœÂ¯Ã§â?Â±Ã¤ÂºÅ½FPGAÃ¦Å½Â¥Ã¦â€?Â¶Ã¥Â­â€”Ã¨Å â?Ã¥Âº?Ã©â€”Â®Ã©Â?
            for k = 1:length(data)/2
                temp = data(2*k);
                data(2*k) = data(2*k-1);
                data(2*k-1) = temp;
            end
            % Ã¦â€¢Â°Ã?Â®Ã¥??Ã§â€ºÂ¸Ã¯Â¼Å’Ã¤Â¸Â´Ã¦â?Â¶Ã©Å“â‚¬Ã¨Â?
            data = 65535 - data;
            % Ã¤Â»?Ã©â‚¬Å¡Ã?â€œÃ¥Â?Â§â€¹Ã§Â¼â?Ã¥?Â·
            ch = ch - 1;
            ch(ch < 0) = 0;
            startaddr = ch*2*2^18+2*offset;
            len = length(data)*2;
            pval = libpointer('uint16Ptr', data);
            [ret,~] = calllib(obj.driver,'WriteMemory',obj.id,uint32(hex2dec('000000004')),uint32(startaddr),uint32(len),pval);
            if(ret == -1)
                error('USTCDAC:WriteWaveError','WriteWave failed.');
            end
        end
        
        function WriteSeq(obj,ch,offset,seq)
            obj.AutoOpen();
            % Ã¨Â¡Â¥Ã¥Â¤Å¸512bitÃ¤Â½?Ã¥Â®Â½
            len = length(seq);
            data = seq;
            if(mod(len,32) ~= 0)
                len = (floor(len/32)+1)*32;
                data = zeros(1,len);
                data(1:length(seq)) = seq;
            end
            % Ã¤Â»?Ã©â‚¬Å¡Ã?â€œÃ¥Â?Â§â€¹Ã§Â¼â?Ã¥?Â·
            ch = ch - 1;
            ch(ch < 0) = 0;
            startaddr = (ch*2+1)*2^18+offset*8; %Ã¥Âº?Ã¥Ë†â€”Ã§Å¡â?Ã¥â€ â?Ã¥Â­ËœÃ¨ÂµÂ·Ã¥Â§â€¹Ã¥Å“Â°Ã??Â¼Å’Ã¥?â€¢Ã¤Â?Ã¦ËœÂ¯Ã¥Â­â€”Ã¨Å â?Ã£?
            len = length(data)*2;               %Ã¥Â­â€”Ã¨Å â?Ã¤Â¸ÂªÃ¦â€¢Â°Ã£â‚¬?
            pval = libpointer('uint16Ptr', data);
            [ret,~] = calllib(obj.driver,'WriteMemory',obj.id,uint32(hex2dec('00000004')),uint32(startaddr),uint32(len),pval);
            if(ret == -1)
                error('USTCDAC:WriteSeqError','WriteSeq failed.');
            end
        end
       % Ã¨Â¯Â¥Ã¥â€¡Â½Ã¦â?Â°Ã¦Å“ÂªÃ¤Â½Â¿Ã§â€?Â¨
        function wave = ReadWave(obj,ch,offset,len)
              obj.AutoOpen();
              ch = ch - 1;
              wave = [];
              startaddr = (ch*2)*2^18 + 2*offset;
              ret = calllib(obj.driver,'ReadMemory',obj.id,uint32(hex2dec('00000003')),uint32(startaddr),uint32(len*2));
              if(ret == 0)
                 if(obj.isblock == true)
                     wave = obj.GetReturn(1);
                 end
              else
                  error('USTCDAC:ReadWaveError','ReadWave failed.');
              end
        end
       % Ã¨Â¯Â¥Ã¥â€¡Â½Ã¦â?Â°Ã¦Å“ÂªÃ¤Â½Â¿Ã§â€?Â¨
        function seq = ReadSeq(obj,ch,offset,len)
              obj.AutoOpen();
              ch = ch - 1;
              startaddr = (ch*2+1)*2^18 + offset*8;
              ret = calllib(obj.driver,'ReadMemory',obj.id,uint32(hex2dec('00000003')),uint32(startaddr),uint32(len*8));
              if(ret == 0)
                 if(obj.isblock == true)
                     seq = obj.GetReturn(1);
                 end
              else
                  error('USTCDAC:ReadSeqError','ReadSeq failed.');
              end
        end
        
        function reg = ReadReg(obj,bank,addr)
             obj.AutoOpen();
             cmd = bank*256 + 1; %1Ã¨Â¡Â¨Ã§Â¤ÂºReadRegÃ¯Â¼Å’Ã¦Å’â€¡Ã¤Â»Â¤Ã¥â?Å’bankÃ¥Â­ËœÃ¥â€šÂ¨Ã¥Å“Â¨Ã¤Â¸â‚¬Ã¤Â¸ÂªDWORDÃ¦â€¢Â°Ã?Â®Ã¤Â¸?
             reg = 0;
             ret = calllib(obj.driver,'ReadInstruction',obj.id,uint32(cmd),uint32(addr));
             if(ret == 0)
                 if(obj.isblock == true)
                      ret = obj.GetReturn(1);
                      reg = double(ret(2))*65536 + double(ret(1));
                 end
              else
                  error('USTCDAC:ReadWaveError','ReadWave failed.');
              end
        end
        
        function data = ReadAD9136_1(obj,addr)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001c05')),uint32(addr),uint32(0));
            if(ret == -1)
                 error('USTCDAC:ReadAD9136','ReadAD9136 failed.');
            end
            ret = obj.GetReturn(1);
            data = double(ret(2))*65536 + double(ret(1));
        end
        
        function data = ReadAD9136_2(obj,addr)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001d05')),uint32(addr),uint32(0));
            if(ret == -1)
                 error('USTCDAC:ReadAD9136','ReadAD9136 failed.');
            end
            ret = obj.GetReturn(1);
            data = double(ret(2))*65536 + double(ret(1));
        end

        function [functiontype,instruction,para1,para2] = GetFuncType(obj,offset)
            obj.AutoOpen()
            [ret,functiontype,instruction,para1,para2] = calllib(obj.driver,'GetFunctionType',uint32(obj.id),uint32(offset),0,0,0,0);
            if(ret == -1)
                error('USTCDAC:GetFuncType','GetFuncType failed');
            end
        end
        
        function data = GetReturn(obj,offset)
           obj.AutoOpen();
           [func_type,~,~,para2] = obj.GetFuncType(1);
           if(func_type == 1 || func_type == 2)
               length = 4;
           else
               length = para2;
           end
           pData = libpointer('uint16Ptr',zeros(1,length/2));
           [ret,data] = calllib(obj.driver,'GetReturn',uint32(obj.id),uint32(offset),pData);
           if(ret == -1)
               error('USTCDAC:GetReturn','Get return failed!');
           end
        end
        
        function isSuccessed = CheckStatus(obj)
           obj.AutoOpen()
           [ret,isSuccessed] = calllib(obj.driver,'CheckSuccessed',uint32(obj.id),0);
           if(ret == -1)
               disp(obj.ip);
               error('USTCDAC:CheckStatus','Exist some task failed!');
           end
        end
        
        function InitBoard(obj)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001A05')),11,uint32(2^16));
            if(ret == -1)
                 error('USTCDAC:WriteRegError','WriteReg failed.');
            end
        end
        
        function PowerOnDAC(obj,chip,onoff)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001E05')),uint32(chip),uint32(onoff));
            if(ret == -1)
                 error('USTCDAC:PowerOnDAC','PowerOnDAC failed.');
            end
        end
        
        function SetGainPara(obj,channel,gain)
            if(channel <= obj.channel_amount)
                obj.gain(channel) = gain;
            end
        end
        
        function gain = GetGainPara(obj,channel)
            if(channel <= obj.channel_amount)
                gain = obj.gain(channel);
            end
        end
        
        function SetOffsetPara(obj,channel,offset)
            if(channel <= obj.channel_amount)
                obj.offset(channel) = offset;
            end
        end
        
        function offset = GetOffsetPara(obj,channel)
            if(channel <= obj.channel_amount)
                offset = obj.offset(channel);
            end
        end
        
        function SetTrigDelay(obj,num)
            obj.SetTrigStart(floor((obj.trig_delay+ num)/8)+1);
            obj.SetTrigStop(floor((obj.trig_delay+ num)/8)+ 10);
        end
        
        %modified at 20180107 by guocheng
        function SetTimeOut(obj,time)
            ret = calllib(obj.driver,'SetTimeOut',obj.id,uint32(0),time);
            ret = ret + calllib(obj.driver,'SetTimeOut',obj.id,uint32(1),time);
            if(ret ~= 0)
               error('USTCDAC:SetTimeOut','Set timeout failed!');
            end
        end
        
        function AddOffset(obj,ch,offset)
            obj.mixer_offset(ch) = offset;
            obj.SetDefaultVolt(ch,32767-obj.offsetcorr(k)-obj.mixer_offset(ch));
        end
        
        % removed by Yulin Wu, 170427
%         function value = get(obj,properties)
%             switch lower(properties)
%                 case 'isblock';value = obj.isblock ;
%                 case 'channel_amount';value = obj.channel_amount;
%                 case 'gain';value = obj.gain;
%                 case 'offset';value = obj.offset;
%                 case 'name';value = obj.name;
%                 case 'ismaster';value = obj.ismaster;
%                 case 'trig_sel';value = obj.trig_sel;
%                 case 'trig_interval';value = obj.trig_interval;
%                 case 'sync_delay';value = obj.sync_delay;
%                 case 'trig_delay';value = obj.trig_delay;
%                 case 'sample_rate';value = obj.sample_rate;
%                 otherwise; error('USTCDAC:get','do not exsis the properties')
%             end
%         end
%         
%         function set(obj,properties,value)
%              switch lower(properties)
%                 case 'isblock';obj.isblock = value;
%                 case 'channel_amount'
%                     obj.channel_amount = value;
%                     obj.offset = zeros(1,obj.channel_amount);
%                     obj.gain = zeros(1,obj.channel_amount);
%                 case 'gain';obj.gain = value;
%                 case 'offset';obj.offset = value;
%                 case 'name';obj.name = value;
%                 case 'ismaster';obj.ismaster = value;
%                 case 'trig_sel';obj.trig_sel = value;
%                 case 'trig_interval';obj.trig_interval = value;
%                 case 'sync_delay';obj.sync_delay = value;
%                 case 'trig_delay';obj.trig_delay = value;
%                 case 'sample_rate';obj.sample_rate = value;
%                 case 'datrigdelayoffset'; obj.daTrigDelayOffset = value;
%                 case 'offsetcorr';obj.offsetcorr = value;
%                 otherwise; error('USTCDAC:get','do not exsis the properties')
%             end
%         end
    end
end