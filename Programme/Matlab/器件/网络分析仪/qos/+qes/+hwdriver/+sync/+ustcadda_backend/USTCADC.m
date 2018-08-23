% 	FileName:USTCADC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.9.11
%   Description:The class of ADC
classdef USTCADC < handle
    properties(SetAccess = private)
        name    = 'Unnamed';            % ADC name.
        netcard = 1;                    % net card number.
        isopen  = 0;                    % open flag.
        status  = 'close';              % open state.
        id      = [];                   % id of adc.
        dstmac  = '00-00-00-00-00-00';  % mac of dstination.
        srcmac  = '00-00-00-00-00-00';  % mac address of pc.
        isdemod = 0;                    % is run demod mode.
        sample_rate    = 1e9;           % ADC sample rate.
        channel_amount = 2;             % ADC channel amount, I & Q.
        channel_gain   = [80,80];       % channel gain.
        sample_depth   = 2000;          % ADC sample depth.
        trig_count     = 1;             % ADC accept trigger count.
        window_start   = 0;             % start position of demod window.
        window_width   = 2000;          % demod window width.
        demod_freq     = 100e6;         % demod frequency.
    end
    
    properties (GetAccess = private,Constant = true)
        driver    = 'USTCADCDriver';
        driverh   = 'USTCADCDriver.h';
        driverdll = 'USTCADCDriver.dll';
    end
    
    methods(Static = true)
        function LoadLibrary()
            if(~libisloaded(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver))
                loadlibrary(qes.hwdriver.sync.ustcadda_backend.USTCADC.driverdll,qes.hwdriver.sync.ustcadda_backend.USTCADC.driverh);
            end
        end
        function info = GetDriverInformation()
            str = libpointer('cstring',blanks(1024));
            [ErrorCode,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver,'GetSoftInformation',str);
            qes.hwdriver.sync.ustcadda_backend.USTCADC.DispError('USTCDAC:GetDriverInformation:',ErrorCode);
        end
        function DispError(MsgID,errorcode,id)
            if nargin == 2
                id = 0;
            end
            if(errorcode ~= 0)
                str = libpointer('cstring',blanks(1024));
                [~,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver,'GetErrorMsg',int32(id),int32(errorcode),str);
                msg = ['Error code:',num2str(errorcode),' --> ',info];
                qes.hwdriver.sync.ustcadda_backend.WriteErrorLog([MsgID,' ',msg]);
                error(MsgID,[MsgID,' ',msg]);
            end
        end
    end
    
    methods
        function obj = USTCADC(srcmac,dstmac)
            obj.srcmac = srcmac;
            obj.dstmac = dstmac;
            obj.isopen = false;
            obj.status = 'close';
        end
        function Open(obj)
            if ~obj.isopen
                obj.LoadLibrary();
                pMacSrc = libpointer('string',obj.srcmac);
                pMacDst = libpointer('string',obj.dstmac);
                [ErrorCode,obj.id] = calllib(obj.driver,'OpenADC',0,pMacSrc,pMacDst);
                obj.DispError('USTCADC:Open',ErrorCode,obj.id);
                obj.status = 'open';
                obj.isopen = true;
            end
        end
        function Close(obj)
			if(obj.isopen == true)
				ErrorCode = calllib(obj.driver,'CloseADC',int32(obj.id));
				obj.DispError('USTCADC:Close',ErrorCode,obj.id);
				obj.status = 'close';
				obj.isopen = false;
                obj.id = [];
			end
        end
        function Init(obj)
            obj.GetMacAddr(0); % Acquire mac address of PC from dll.
            obj.SetMacAddr();  % Set PC's mac address as ADC's destination address.
            obj.SetSampleDepth();
            obj.SetTrigCount();
            obj.SetMode();
            obj.ConfigDemod();
            obj.SetGain();
        end
        function EnableADC(obj)
            data = [0,3,238,238,238,238,238,238];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
            obj.DispError('USTCADC:EnableADC',ErrorCode,obj.id);
        end
        function ForceTrig(obj)
            data = [0,1,238,238,238,238,238,238];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
            obj.DispError('USTCADC:ForceTrig',ErrorCode,obj.id);
        end
        function GetMacAddr(obj,isDst)
            data = zeros(1,6);
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,data] = calllib(obj.driver,'GetMacAddress',int32(obj.id),int32(isDst),pdata);
            obj.DispError('USTCADC:GetMacAddr',ErrorCode,obj.id);
            str(1:17) = '-';data = dec2hex(data);
            for k = 1:6
                str(3*k-2:3*k-1) = data(k,1:2);
            end
            if(isDst == false)
                obj.srcmac = str;
            else
                obj.dstmac = str;
            end
        end
        function SetMacAddr(obj,srcmac)
            if(nargin == 2)
                obj.srcmac = srcmac;
            end
            if(obj.isopen)
                macdata = regexp(obj.srcmac,'-', 'split');
                macdata = hex2dec(macdata)';
                data = [0,17,macdata];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(length(data)),pdata);
                obj.DispError('USTCADC:SetMacAddr',ErrorCode,obj.id);
            end
        end
        function SetSampleDepth(obj,depth)
            if(nargin == 2)
                obj.sample_depth = depth;
            end
            if(obj.isopen)
                data = [0,18,obj.sample_depth/256,mod(obj.sample_depth,256)];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(4),pdata);
                obj.DispError('USTCADC:SetSampleDepth',ErrorCode,obj.id);
            end
        end
        function SetTrigCount(obj,count)
            if(nargin == 2)
                obj.trig_count = count;
            end
            if(obj.isopen)
                data = [0,19,obj.trig_count/256,mod(obj.trig_count,256)];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(4),pdata);
                obj.DispError('USTCADC:SetTrigCount',ErrorCode,obj.id);
            end
        end
        function SetMode(obj,isdemod)
            if(nargin == 2)
                obj.isdemod = isdemod;
            end
            if(obj.isopen)
                if(obj.isdemod == 0)
                    data = [1,1,17,17,17,17,17,17];
                else
                    data = [1,1,34,34,34,34,34,34];
                end
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:SetMode',ErrorCode,obj.id);
            end
        end
        function SetWindowWidth(obj,width)
            if(obj.isopen)
                data = [0,20,floor(width/256),mod(width,256),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:SetWindowLength',ErrorCode,obj.id);
            end
        end
        function SetWindowStart(obj,pos)
            if(obj.isopen)
                data = [0,21,floor(pos/256),mod(pos,256),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:SetWindowStart',ErrorCode,obj.id);
            end
        end
        function SetDemoFre(obj,freq)
            if(obj.isopen)
                step = floor(freq/1e9*16777216 + 0.5);
                data1 = 0;
                if(step < 0)
                    data1 = 128;
                    step = abs(step);
                end
                data1 = data1 + floor(step/131072);
                data2 = mod(floor(step/512),256);
                data3 = mod(floor(step/2),256);
                data4 = mod(step,2)*128;
                data = [0,22,data1,data2,data3,data4,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:SetDemoFre',ErrorCode,obj.id);
            end
        end
        function ConfigDemod(obj,start,width,freq)
            if(nargin == 4)            
                obj.window_start = start;
                obj.window_width = width;
                obj.demod_freq = freq;
            end
            for k = 1:length(obj.demod_freq)
                obj.SetWindowStart(obj.window_start(k));
                obj.SetWindowWidth(obj.window_width(k));
                obj.SetDemoFre(obj.demod_freq(k));
                obj.CommitDemodSet(k-1);
            end
        end
        function SetGain(obj,gain)
            if(nargin == 2)
                if(length(gain) == obj.channel_amount)
                    obj.channel_gain = gain;
                end
            end
            if(obj.isopen)
                data = [0,23,obj.channel_gain(1),obj.channel_gain(2),0,0,0,0];
                pdata = libpointer('uint8Ptr',data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:SetGain',ErrorCode,obj.id);
            end
        end
        
        function CommitDemodSet(obj,module)
            if(obj.isopen)
                data = [0,24,module*16,0,0,0,0,0];
                pdata = libpointer('uint8Ptr',data);
                [ErrorCode,~] = calllib(obj.driver,'SendData',int32(obj.id),int32(8),pdata);
                obj.DispError('USTCADC:CommitDemodSet',ErrorCode,obj.id);
            end
        end
        
        function SetADName(obj,name)
            obj.name = name;
        end
        function SetSampleFreq(obj,freq)
            obj.sample_rate = freq;
        end
        function SetChannelNum(obj,num)
            if(~obj.isopen)
                if(num ~= obj.channel_amount)
                    obj.channel_amount = num;
                    obj.channel_gain = zeros(1,num) + 80;
                end
            end
        end
        function [ret,I,Q] = RecvData(obj)
            if(obj.isdemod)
                IQ = zeros(24*obj.trig_count,1);
                pIQ = libpointer('int32Ptr', IQ);
                [ret,IQ] = calllib(obj.driver,'RecvDemo',int32(obj.id),int32(obj.trig_count),pIQ);
                I = IQ(1:2:length(IQ));
                I = reshape(I,12,obj.trig_count);
                Q = IQ(2:2:length(IQ));
                Q = reshape(Q,12,obj.trig_count);
            else
                I = zeros(obj.trig_count*obj.sample_depth,1);
                Q = zeros(obj.trig_count*obj.sample_depth,1);
                pI = libpointer('uint8Ptr', I);
                pQ = libpointer('uint8Ptr', Q);
                [ret,I,Q] = calllib(obj.driver,'RecvData',int32(obj.id),int32(obj.trig_count),int32(obj.sample_depth),pI,pQ);
                I = (reshape(I,[obj.sample_depth,obj.trig_count]))';
                Q = (reshape(Q,[obj.sample_depth,obj.trig_count]))';
           end
        end
     end
end