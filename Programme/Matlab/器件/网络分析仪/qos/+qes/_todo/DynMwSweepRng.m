classdef (Abstract = true) DynMwSweepRng < handle
    % Dynamically change the sweeping range of a target Sweep object
    % according to the current step value of a control Sweep object by
    % setting the mask property of the target Sweep object.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = protected)
        ctrlsweepobj
        trgtsweepobj
    end
    methods
        function obj = DynMwSweepRng(CtrlSweepObj,TrgtSweepObj)
            if ~isa(CtrlSweepObj,'Sweep')
                error('CtrlSweepObj is not a Sweep class object.');
            end
            if ~isa(TrgtSweepObj,'Sweep')
                error('TrgtSweepObj is not a Sweep class object.');
            end
            obj.ctrlsweepobj = CtrlSweepObj;
            obj.trgtsweepobj = TrgtSweepObj;
        end
    end
%     methods (Abstract = true)
%         function UpdateRng(obj)
%             % Update sweep range.
%         end
%     end
end