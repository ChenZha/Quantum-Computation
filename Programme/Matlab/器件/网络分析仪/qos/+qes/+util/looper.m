classdef looper < qes.util.looper_
    % a simple wrapper of looper_ with varargin input arguments
    % example:
	% >>lo = looper([1,2,3,4],{'a','b'});
	% >>ai = lo()
	%	ai = {1,'a'}
	% >>ai = lo()
	%	ai = {1,'b'}
	% >>ai = lo()
	%	ai = {2,'a'}
	% ...

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	methods
		function obj = looper(varargin)
			obj = obj@qes.util.looper_(varargin);
		end
    end
end