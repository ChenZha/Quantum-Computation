classdef rReadout4T1 < sqc.measure.resonatorReadout_ss
    % a wrapper of resonatorReadout to: 
    % measure state |1> probabilty with pi pulse and without pi pulse,
    % used only in T1 measurement

    % Copyright 2017 Yulin Wu, University of Science and Technology of China
    % mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties (GetAccess = private, SetAccess = private)
        drive_mw_src
        keep_bkgrnd          % keep background or not
    end
    methods
        function obj = rReadout4T1(qubit,drive_mw_src, keepBkcgrnd)
            % drive_mw_src: pi pulse lo mw source
            if numel(qubit) ~= 1
                throw(MException('QOS_rReadout4T1:illegalNumQubits',...
                    'rReadout4T1 only applicable to one qubit, %0.0f given', numel(qubit)));
            end
            obj = obj@sqc.measure.resonatorReadout_ss(qubit);
            if nargin < 3 || keepBkcgrnd
                obj.keep_bkgrnd = true;
                obj.numericscalardata = false;
            else
                obj.keep_bkgrnd = false;
                obj.numericscalardata = true;
            end
            obj.drive_mw_src = drive_mw_src;
            obj.name = 'diff(P|1>)';
        end
        function Run(obj)
%             obj.drive_mw_src.on = true;
            Run@sqc.measure.resonatorReadout_ss(obj);
            data_with_mw = obj.data;
            data_with_mw_e = mean(obj.extradata);
%             obj.drive_mw_src.on = false;
            Run@sqc.measure.resonatorReadout_ss(obj);
            data_without_mw = obj.data;
            data_without_mw_e = mean(obj.extradata);
            if obj.keep_bkgrnd
                obj.data = [data_without_mw,data_with_mw];
            else
                obj.data = data_with_mw-data_without_mw;
                obj.data = - obj.data;
            end
            obj.extradata = [mean(abs(data_without_mw_e)),mean(abs(data_with_mw_e))];
            obj.dataready = true;
        end
    end
end