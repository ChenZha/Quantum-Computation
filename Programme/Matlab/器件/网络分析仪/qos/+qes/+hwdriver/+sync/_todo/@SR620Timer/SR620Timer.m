classdef SR620Timer < Instrument
    % dirver for Stanford Research SR620 Universal Time Interval Counter,
    % used as Timer
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        timeout = 30;   % seconds, default:30 seconds.
        samplesize % number of samples
        avgnum = 1 % average number of each measurement, default: 1
        triglevel = 0.5; % trig/gate level, V
        signallevel % signal level, V
    end
    methods (Access = private)
        function obj = SR620Timer(name,interfaceobj,drivertype)
            % drivertype is not important for SR620Timer class objects, any
            % str is ok.
            if isempty(interfaceobj)
                error('SR620Timer:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            set(interfaceobj,'Timeout',10); 
            set(interfaceobj,'InputBufferSize',524280);
            if nargin < 3
                drivertype = [];
            end
            obj = obj@Instrument(name,interfaceobj,drivertype);
            try
                fprintf(obj.interfaceobj,'MODE 0');
                fprintf(obj.interfaceobj,'SRCE 0');           % START: A, STOP: B
                fprintf(obj.interfaceobj,'ARMM 1'); 
                fprintf(obj.interfaceobj,['LEVL 1,',num2str(obj.triglevel,'%0.1f')]);
                fprintf(obj.interfaceobj, 'AUTM 0');
            catch
                error('SR620Timer:SeInstruError',[obj.name, ': %s'], 'Unable to set instrument.');
            end
        end
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end

    methods
        function set.timeout(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('SR620Timer:InvalidInput','timeout should be a positive integer!');
            end
            obj.timeout = val;
            set(obj.interfaceobj,'Timeout',val);
        end
        function set.samplesize(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('SR620Timer:InvalidInput','samplesize should be a positive integer!');
            end
            obj.samplesize = val;
        end
        function set.avgnum(obj,val)
            val = round(val);
            if isempty(val) || val <=0
                error('SR620Timer:InvalidInput','avgnum should be a positive integer!');
            end
            obj.avgnum = val;
            fprintf(obj.interfaceobj,['SIZE ', num2str(val)]);
        end
        function set.triglevel(obj,val)
            obj.triglevel = val;
            fprintf(obj.interfaceobj,['LEVL 1,',num2str(val,'%0.2f')]);
        end
        function set.signallevel(obj,val)
            obj.signallevel = val;
            fprintf(obj.interfaceobj,['LEVL 2,',num2str(val,'%0.2f')]);
        end
        function SwitchingEvents = Run(obj)
            if isempty(obj.samplesize)
                error('SR620Timer:RunError','sample size n not set.');
            end
            framemax = min(65535, obj.samplesize);
            frameptr = 0;
            temp = zeros(1,2*obj.samplesize);
            while (frameptr < obj.samplesize)
                framechunk = min(framemax, obj.samplesize - frameptr);
                fprintf(obj.interfaceobj, ['BDMP ' num2str(framechunk)]);
                temp(2*frameptr+1:2*frameptr+2*framechunk) = fread(obj.interfaceobj, 2*framechunk, 'uint32');
                frameptr = frameptr + framechunk;
            end
            fprintf(obj.interfaceobj, 'AUTM 1');           % set idle run mode to automatic
            fprintf(obj.interfaceobj,['SIZE ', num2str(1)]);
            SwitchingEvents =((temp(1:2:(2*obj.samplesize-1)) + ...
                temp(2:2:(2*obj.samplesize))*2^32) * 2.712673611111111E-12 / 256);
        end
    end
    
end