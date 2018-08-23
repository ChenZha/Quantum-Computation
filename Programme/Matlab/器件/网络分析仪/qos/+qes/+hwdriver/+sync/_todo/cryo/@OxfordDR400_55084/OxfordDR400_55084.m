classdef OxfordDR400_55084 < OxfordDR
    % Oxford dilution fridge driver for
    % DR400(project number 55084), Li Lu's group(Q02), IoP, CAS, China.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods (Access = private,Hidden = true)
        function obj = OxfordDR400_55084(name,interfaceobj,drivertype)
            if nargin < 3
                drivertype = [];
            end
            obj = obj@OxfordDR(name,interfaceobj,drivertype);
            obj.tempuidlst = {'T1','T2','T3','T4','T5','T6','T13'};
            obj.tempnamelst = {'PT1','PT2','Still','100mK','MC RuO2','MC Cernox','Magnet'};
            obj.presuidlst = {'P1','P2','P3','P4','P5','P6'};
            obj.presnamelst = {'Tank','Compressor','Still','P4','P5','OVC'};
        end
    end
    
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
end