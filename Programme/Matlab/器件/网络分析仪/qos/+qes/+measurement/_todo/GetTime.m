classdef GetTime < Measurement
    % measure time in days, either absolute or relative to a reference,
    % the default refernce time is the object creation time, it can be set
    % by ResetRef(), which sets the it to the current time, or by
    % ResetRef(anytime) which sets it to 'anytime'.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        absolute = true; % absolut time or relative time
    end
    properties (SetAccess = private)
        % reference time, if measure relative time, measured time is relative to
        % this time. days
        ref
    end
	methods
        function obj = GetTime()
            obj = obj@Measurement([]);
            obj.ref = now;
        end
        function Run(obj)
            Run@Measurement(obj);
            if ~obj.absolute
                obj.data = now;
            else
                obj.data = now - obj.ref;
            end
            obj.extradata = obj.ref;
            obj.dataready = true;
        end
        function ResetRef(obj, newref)
            % Reset time reference, defult, reset to the current time.
            if nargin == 1
                obj.ref = now;
            else
                obj.ref = newref;
            end
        end
    end
end