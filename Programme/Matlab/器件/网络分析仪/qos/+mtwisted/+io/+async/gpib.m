classdef gpib < mtwisted.io.async.iobase
    % a wrapper of matlab gpib with async io
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = immutable)
        vendor
        boardindex
        primaryaddress
    end
    methods
        function obj = gpib(vendor, boardindex, primaryaddress)
            obj.backend = gpib(vendor, boardindex, primaryaddress);
            obj.vendor = vendor;
            obj.boardindex = boardindex;
            obj.primaryaddress = primaryaddress;
            obj.backend.ReadAsyncMode = 'manual'; 
        end
    end
end