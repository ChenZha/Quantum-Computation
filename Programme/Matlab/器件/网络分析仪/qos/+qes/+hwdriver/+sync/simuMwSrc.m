classdef simuMwSrc < qes.hwdriver.icinterface_compatible
    % icinterface compatible interface for simulated mw source
    
% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties (SetAccess = private) % 20170414
        numChnls
    end
	properties (SetAccess = private)
		freqlimits
        powerlimits
    end
    properties (SetAccess = private, GetAccess = private)
        frequency
        power
        on
    end

    methods
		function setFrequency(obj, f, chnl)
            obj.frequency(chnl) = f;
		end
		function f = getFrequency(obj, chnl)
			f = obj.frequency(chnl);
		end
		function setPower(obj, p, chnl)
			obj.power(chnl) = p;
		end
		function f = getPower(obj, chnl)
			f = obj.power(chnl);
		end
		function setOnOff(obj, onoff, chnl)
			obj.on(chnl) = logical(onoff);
		end
		function val = getOnOff(obj, chnl)
			val = obj.on(chnl);
		end
    end
    methods (Access = private)
        function obj = simuMwSrc()
			QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('simuMwSrc_bknd');
            obj.numChnls = s.numChnls;
            obj.frequency = NaN*ones(1,obj.numChnls);
            obj.power = NaN*ones(1,obj.numChnls);
            obj.on = logical(zeros(1,obj.numChnls));
			obj.freqlimits = ...
				cell2mat(cellfun(@cell2mat,s.freq_limits(:),'UniformOutput',false));
            obj.powerlimits =...
				cell2mat(cellfun(@cell2mat,s.power_limits(:),'UniformOutput',false));
			
			obj.cmdList = {'*IDN?'};
			obj.ansList = {'SIMULATEDHW,SIMULATEDMWSRC,170424,1.0'};
            obj.fcnList = {{}};
        end
    end
    
    methods (Static = true)
        function obj = GetInstance() % Yulin Wu
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.simuMwSrc();
                objlst = obj;
            else
                obj = objlst;
            end
        end
    end
end