classdef dynMwSweepRngBnd < qes.util.dynMwSweepRng
    % Dynamically change the sweeping range of a target Sweep object
    % according to the current step value of a control Sweep object by
    % setting the mask property of the target Sweep object.
    % Type: band

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        centerfunc  % function handle of the band center
        bandwidth  % width of the band
    end
    methods
        function obj = dynMwSweepRngBnd(CtrlSweepObj,TrgtSweepObj)
            % CtrlSweepObj: control sweep
            % TrgtSweepObj: target sweep
            obj = obj@qes.util.dynMwSweepRng(CtrlSweepObj,TrgtSweepObj);
        end
    end
    methods
        function UpdateRng(obj)
            % Update sweep range.
            if obj.ctrlsweepobj.IsDone()
                return;
            end
            cnt = feval(obj.centerfunc, obj.ctrlsweepobj.vals{1}(obj.ctrlsweepobj.idx));
            mask = logical(zeros(1,obj.trgtsweepobj.size));
            mask(obj.trgtsweepobj.vals{1} >= cnt - obj.bandwidth/2 &...
                obj.trgtsweepobj.vals{1} <= cnt + obj.bandwidth/2) = true;
            obj.trgtsweepobj.mask = mask;
        end
    end
end