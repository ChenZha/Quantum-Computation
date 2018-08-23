classdef alazarATS_Server < qes.qHandle
    % dirver for Alazar Tech ATS Digitizer to run on a remote Matlab
    % 

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        isopen = false
    end
    properties (SetAccess = private, GetAccess = private)
        tcpipobj
        digitizer
    end
    methods
        function obj = alazarATS_Server(name, BoardGroupID, BoardID,port,...
                smplrate,chnl1enabled,chnl2enabled,chnl1range,chnl2range,...
                num_records,record_ln)
            obj = obj@qes.qHandle();
            if nargin == 1
                obj.digitizer = qes.hwdriver.sync.alazarATS.GetInstance(name);
            else
                obj.digitizer = qes.hwdriver.sync.alazarATS.GetInstance(name, BoardGroupID, BoardID);
            end
            obj.digitizer.smplrate = smplrate;
            obj.digitizer.chnl1enabled = chnl1enabled;
            obj.digitizer.chnl2enabled = chnl2enabled;
            obj.digitizer.chnl1range = chnl1range;
            obj.digitizer.chnl2range = chnl2range;
            obj.digitizer.num_records = num_records; % number of records to take, each record is record_ln samples long, a record is recorded at each trigger event
            obj.digitizer.record_ln = record_ln; % need to be power of 2 and no less than 2^8
            obj.digitizer.clocksource = 1; % internal
            numsamples = obj.digitizer.num_records*obj.digitizer.record_ln;
            obj.tcpipobj = tcpip('0.0.0.0',port,...
                'NetworkRole','server',...
                'InputBufferSize',1024*10,'OutputBufferSize',numsamples*2*8);
            obj.tcpipobj.BytesAvailableFcn = {@qes.hwdriver.sync.alazarATS_Server.BytesAvailableFcn,obj};
            disp('Waiting for connection...');
            fopen(obj.tcpipobj);
        end
        function Restart(obj)
            % to do
        end
        function Open(obj)
            if obj.tcpipobj.Status(1) == 'c'
                fopen(obj.tcpipobj);
                obj.isopen = true;
            end
        end
        function Close(obj)
            if obj.tcpipobj.Status(1) == 'o'
                fclose(obj.tcpipobj);
                obj.isopen = false;
            end
        end
        function delete(obj)
            fclose(obj);
        end
    end
    methods (Static = true)
        function BytesAvailableFcn(~,~,obj)
            cmd = fscanf(obj.tcpipobj);
            cmd = cmd(1:end-1);
            disp(sprintf('%s Command received: %s', datestr(now,'yy/mm/dd HH:MM:SS'),cmd));
            switch cmd
                case 'FetchData'
                    NumSamplesExpected = obj.digitizer.num_records*obj.digitizer.record_ln;
                    try
                        out_ = obj.digitizer.FetchData();
                        NumSamples = size(out_,2);
                        if NumSamples < NumSamplesExpected
                            out_ = [out_,zeros(2,NumSamplesExpected-NumSamples)];
                            disp(['Digitizer error: not enough samples captured, concat with zeros.']);
                        elseif NumSamples > NumSamplesExpected
                            out_(:,NumSamplesExpected+1:end) = [];
                            disp(['Digitizer error: more samples captured than expected, trucate.']);
                        end
                        out = [out_(1,:), out_(2,:)];
                        fwrite(obj.tcpipobj,  typecast(out,'uint8'),0);
                    catch ME
                        disp(['Digitizer error: ', getReport(ME,'basic'), ' return zeros.']);
                        fwrite(obj.tcpipobj, typecast(zeros(1,2*NumSamplesExpected),'uint8'),0);
                    end
                case 'NumSamples'
                    N = obj.digitizer.num_records*obj.digitizer.record_ln;
                    fprintf(obj.tcpipobj,'%d',N);
                case '*IDN?'
                    out = 'AlazarATS Digitizer Server';
                    fprintf(obj.tcpipobj,out);
                otherwise
                    out = sprintf('unrecognized command: %s', cmd);
                    fprintf(obj.tcpipobj,out);
            end
            disp('Command handled.');
        end
    end
end