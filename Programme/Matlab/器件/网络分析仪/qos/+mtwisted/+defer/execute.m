function d = execute(fcn,varargin)
    % call a synchronous funciton call and wrap the result into a deferred,
    % this is usefull when it is necessay to code synchronous functions
    % in a asynchronous way.
    % execute is the counter part of wrap.
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    try
        result = fcn(varargin);
    catch
        d = mtwisted.defer.fail();
        return;
    end
    d = mtwisted.defer.succeed(result);
end