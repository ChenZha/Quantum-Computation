classdef visa < mtwisted.io.async.iobase
    % a wrapper of matlab visa with async io
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = immutable)
        vendor
        rsrcname
    end
    methods
        function obj = visa(vendor, rsrcname)
            obj.backend = visa(vendor, rsrcname);
            obj.vendor = vendor;
            obj.rsrcname = rsrcname;
            obj.backend.ReadAsyncMode = 'manual'; 
        end
    end
end