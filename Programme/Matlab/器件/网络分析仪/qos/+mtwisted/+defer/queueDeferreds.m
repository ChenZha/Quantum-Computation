function queueDeferreds(varargin)
    % queueDeferreds(d1,d2,d3,d4,...) links d1,d2,d3,d4,...together, the
    % returned deferred is juts d1.
    % fire of d1 fires d2 if not already fired, fire of d2 fires d3
    % if not already fired,...
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    function r = cb(r,d_)
        d_.callback();
    end
    for ii = 1:length(varargin)-1
        varargin{ii}.addBoth(@(x)cb(x,varargin{ii+1}));
    end
end