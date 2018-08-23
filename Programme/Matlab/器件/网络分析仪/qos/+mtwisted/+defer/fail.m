function d = fail(result)
    % wrap somthing into a deferred with errback called.
    % by this you can make synchronous code looks like asynchronous code
    
    %
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    d = mtwisted.defer.Deferred();
    d.errback(result);