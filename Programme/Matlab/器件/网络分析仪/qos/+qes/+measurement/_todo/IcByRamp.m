classdef IcByRamp < Measurement
    % measure Ic of a dc SQUID/Josephson junction by driving the SQUID/junction
    % with current ramp.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        N  % number of samples, integer times of SwIObj.N, if empty, N = SwIObj.N;
    end
    properties (Hidden = true, SetAccess = private, GetAccess = private)
        SwIObj
    end
	methods
        function obj = IcByRamp(SwIObjObject)
            if ~isa(SwIObjObject,'GetSwI') || ~isvalid(SwIObjObject)
                error('IcByRamp:InvalidInput','SwIObjObject is not a valid  GetSwI class object!');
            end
            obj = obj@Measurement(SwIObjObject);
            obj.numericscalardata = true;
            obj.SwIObj = SwIObjObject;
            obj.timeout = 120; % default timeout 120 seconds.
        end
        function set.N(obj,val)
            if isempty(val)
                obj.N = val;
                return;
            end
            if ceil(val) ~=val || val <=0
                error('GetP_NIDAQUSB5132:InvalidInput','N should be a positive integer!');
            end
            obj.N = ceil(val/obj.SwIObj.N)*obj.SwIObj.N;
        end
        function Run(obj)
            if isempty(obj.N)
                M = 1;
            else
                M = obj.N/obj.SwIObj.N;
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            I = [];
            for ii = 1:M
                obj.SwIObj.Run();
                if ~isnan(obj.SwIObj.data)
                    I = [I,obj.SwIObj.data];
                end
            end
            if length(I) > obj.N;
                I(obj.N+1:end) = [];
            end
            I_mean = mean(I);
            I(abs(I-I_mean)>0.2*I_mean) = [];
            obj.data = mean(I);
            obj.extradata = I;
            obj.dataready = true;
        end
    end
end