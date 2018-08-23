classdef (Abstract = true) dynMwSweepRng < handle
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
        function obj = dynMwSweepRng(CtrlSweepObj,TrgtSweepObj)
            if ~isa(CtrlSweepObj,'qes.sweep')
                error('CtrlSweepObj is not a Sweep class object.');
            end
            if ~isa(TrgtSweepObj,'qes.sweep')
                error('TrgtSweepObj is not a Sweep class object.');
            end
            CtrlSweepObj.poststepcallbacks = @(x)obj.UpdateRng();
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