classdef signalCore5511a < qes.hwdriver.icinterface_compatible
    % icinterface compatible interface for signalCore 5511a mw source
    
% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties (Dependent = true) 
        numChnls
    end
	properties (SetAccess = private)
		freqlimits
        powerlimits
    end
    properties (SetAccess = private, GetAccess = private)
		chnlName
    end
	
	properties (GetAccess = private,Constant = true)
        driver  = 'sc5511a'
        driverh = 'sc5511a.h'
    end
    methods
		function val = get.numChnls(obj)
			val = numel(obj.chnlName);
		end
		function setFrequency(obj, f, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_freq',devicehandle,f);
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
		function f = getFrequency(obj, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s] = calllib('sc5511a','sc5511a_get_rf_parameters',devicehandle,{});
			f = s.rf1_freq;
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
		function setPower(obj, p, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_level',devicehandle,p); 
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
		function f = getPower(obj, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s] = calllib('sc5511a','sc5511a_get_rf_parameters',devicehandle,{});
			f = s.rf_level;
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
		function setOnOff(obj, onoff, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_output',devicehandle,onoff);
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
		function val = getOnOff(obj, chnl)
			devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s]=calllib('sc5511a','sc5511a_get_device_status',devicehandle,{});
			val = s.operate_status.rf1_out_enable;
			calllib('sc5511a','sc5511a_close_device',devicehandle); 
		end
    end
    methods (Access = private)
        function obj = signalCore5511a()
			QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('signalCore5511a_bknd');
			obj.chnlName = s.chnlName;
			if(~libisloaded(obj.driver))
                driverfilename = [obj.driver,'.dll'];
                loadlibrary(driverfilename,obj.driverh);
            end
			for ii = 1:numel(obj.chnlName)
				devicehandle = calllib('sc5511a','sc5511a_open_device',obj.chnlName{ii}); 
				calllib('sc5511a','sc5511a_set_clock_reference',devicehandle,0,1);
				calllib('sc5511a','sc5511a_close_device',devicehandle);
			end
			
			obj.freqlimits = ...
				cell2mat(cellfun(@cell2mat,s.freq_limits(:),'UniformOutput',false));
            obj.powerlimits =...
				cell2mat(cellfun(@cell2mat,s.power_limits(:),'UniformOutput',false));
			
			obj.cmdList = {'*IDN?'};
			obj.ansList = {'SIGNALCORE,SC5511A,170410,1.0'};
            obj.fcnList = {{}};
        end
    end
    
    methods (Static = true)
        function obj = GetInstance()
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.signalCore5511a();
                objlst = obj;
            else
                obj = objlst;
            end
        end
    end
end