classdef rReadout4S21_01 < sqc.measure.resonatorReadout
    % a wrapper of resonatorReadout to: 
    % measure state |1> probabilty with pi pulse and without pi pulse,
    % used only in T1 measurement

    % Copyright 2017 Yulin Wu, University of Science and Technology of China
    % mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (GetAccess = private, SetAccess = private)
        drive_mw_src
    end
    methods
        function obj = rReadout4S21_01(qubit)
            if numel(qubit) ~= 1
                throw(MException('QOS_rReadout4S21_01:illegalNumQubits',...
                    'rReadout4S21_01 only applicable to one qubit, %0.0f given', numel(qubit)));
            end
            obj = obj@sqc.measure.resonatorReadout(qubit,false,true);
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@sqc.measure.resonatorReadout(obj);
            data1 = obj.extradata;
            Run@sqc.measure.resonatorReadout(obj);
            data0 = obj.extradata;
            obj.data = [mean(data0),mean(data1)];
            obj.extradata = [data0;data1];
            obj.dataready = true;
        end
    end
end