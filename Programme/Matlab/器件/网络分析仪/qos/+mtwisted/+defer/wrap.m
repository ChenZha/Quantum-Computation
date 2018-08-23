function d = wrap(fcn,varargin)
    % wrap a funciton that returns a deferred into a deferred, this is
    % usefull when it is necessay to code asynchronous functions in a
    % synchronous way.
    % wrap is the counter part of execute.
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    d = mtwisted.defer.Deferred();
    d.addBoth(@cb);
    function d_ = cb(~)
        disp('wraped deferred called');
        d_ = fcn(varargin);
    end
end