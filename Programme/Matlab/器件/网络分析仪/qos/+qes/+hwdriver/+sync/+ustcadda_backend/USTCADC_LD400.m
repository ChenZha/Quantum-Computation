% 	FileName:USTCADC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.2.26
%   Description:The class of ADC
classdef USTCADC < handle
    properties % Yulin Wu, 170427
        mac = zeros(1,6)   %上位机网卡地址
        name = ''
        channel_amount = 2     %ADC通道，未使用，实际使用I、Q两个通道。
        sample_rate = 1e9      %ADC采样率，未使用
        demod@logical scalar = false;
    end
    
    properties(SetAccess = private)
        netcard_no         %上位机网卡号
        % mac = zeros(1,6)   %上位机网卡地址 % Yulin Wu, 170427
        isopen             %打开标识
        status             %打开状态
    end

    properties(SetAccess = private)
        % name = ''              %ADC名字 % Yulin Wu, 170427
        % sample_rate = 1e9      %ADC采样率，未使用 % Yulin Wu, 170427
        % channel_amount = 2     %ADC通道，未使用，实际使用I、Q两个通道。 % Yulin Wu, 170427
        sample_depth = 2000;    %ADC采样深度
        sample_count = 100     %ADC使能后采样次数
    end
    
    properties (GetAccess = private,Constant = true)
        driver = 'USTCADCDriver';
        driverh = 'USTCADCDriver.h';
    end
    
    methods
        function obj = USTCADC(num)
            obj.netcard_no = num;
            obj.isopen = false;
            obj.status = 'close';
            driverfilename = [obj.driver,'.dll'];
            if(~libisloaded(obj.driver))
                loadlibrary(driverfilename,obj.driverh);
            end
        end
        
        function set.mac(obj,val)
            % Yulin Wu, 170427
            mac_str = regexp(val,'-', 'split');
            obj.mac = hex2dec(mac_str);
        end
        
        function Open(obj)
            if obj.isopen
                return;
            end
            ret = calllib(obj.driver,'OpenADC',int32(obj.netcard_no));
            if(ret == 0)
                obj.status = 'open';
                obj.isopen = true;
            else
               throw(MException('USTCADC:OpenError',...
                   sprintf('Open ADC %s failed!',obj.name))); % Yulin Wu
            end 
            obj.Init()
        end
        
        function Init(obj)
            obj.SetMacAddr(obj.mac');
            obj.SetSampleDepth(obj.sample_depth);
            obj.SetTrigCount(obj.sample_count);
            obj.SetMode(0);
        end
        
        function Close(obj)
            if obj.isopen
                ret = calllib(obj.driver,'CloseADC');
                if(ret == 0)
                    obj.status = 'close';
                    obj.isopen = false;
                else
                   throw(MException('USTCADC:CloseError',...
                        sprintf('Close ADC %s failed!',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function SetSampleDepth(obj,depth)
             if obj.isopen
                data = [0,18,depth/256,mod(depth,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   throw(MException('USTCADC:SetSampleDepthError',...
                        sprintf('Set SampleDepth failed on ADC %s.',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function ClearBuff(obj)
             if obj.isopen
                ret = calllib(obj.driver,'ClearBuff');
                if(ret ~= 0)
                   error('USTCADC:ClearBuff','ClearBuff failed!');
                end 
            end
        end
        
        function SetTrigCount(obj,count)
             if obj.isopen
                data = [0,19,count/256,mod(count,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   throw(MException('USTCADC:SetTrigCountError',...
                        sprintf('Set TrigCount failed on ADC %s.',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function SetMacAddr(obj,mac)
           if obj.isopen
                data = [0,17];
                data = [data,mac];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(length(mac)+2),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetMacAddr failed!');
                end 
            end
        end
        
        function ForceTrig(obj)
           if obj.isopen
                data = [0,1,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','ForceTrig failed!');
                end 
           end
        end
        
        function EnableADC(obj)
           if obj.isopen
                data = [0,3,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','EnableADC failed!');
                end
           end
        end
        
        function SetMode(obj,mode)
            if obj.isopen
                if(mode == 0)
                    data = [1,1,17,17,17,17,17,17];
                else
                    data = [1,1,34,34,34,34,34,34];
                end
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SetMode','SetMode failed!');
                end
            end
        end
        
        function [ret,I,Q] = RecvData(obj,row,column)
            if obj.isopen
                I = zeros(row*column,1);
                Q = zeros(row*column,1);
                pI = libpointer('uint8Ptr', I);
                pQ = libpointer('uint8Ptr', Q);
                [ret,I,Q] = calllib(obj.driver,'RecvData',int32(row*column),int32(column),pI,pQ);
            end
        end
        
        % removed by Yulin Wu, 170427
%         function set(obj,properties,value)
%             switch properties
%                 case 'mac'
%                     mac_str = regexp(value,'-', 'split');
%                     obj.mac = hex2dec(mac_str);
%                 case 'name'; obj.name = value;
%                 case 'sample_rate'; obj.sample_rate = value;
%                 case 'channel_amount';obj.channel_amount = value;
%             end
%         end
%         
%         function value = get(obj,properties)
%             switch properties
%                 case 'mac';value = obj.mac;
%                 case 'name'; value = obj.name;
%                 case 'sample_rate'; value = obj.sample_rate;
%                 case 'channel_amount';value = obj.channel_amount;
%             end
%         end
     end
end