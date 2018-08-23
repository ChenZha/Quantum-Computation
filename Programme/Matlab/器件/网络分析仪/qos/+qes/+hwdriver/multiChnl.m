classdef (Abstract = true) multiChnl < handle & dynamicprops 
    % a interface class
    % note: a multiChnl object should not be callable as
    % it is not supportted by instrumentChnl

% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties(SetAccess = protected)
		numChnls % number of channels
        chnlProps % numeric types only
        chnlPropSetMothds
        chnlPropGetMothds
    end
    properties(SetAccess = private)
		takenChnls
        clientCount
	end
    methods
        function set.chnlProps(obj,chnlProps_)
            for ii = 1:numel(chnlProps_)
                P = addprop(obj,chnlProps_{ii});
                if ~isempty(obj.numChnls)
                    obj.(chnlProps_{ii}) = NaN*ones(1,obj.numChnls);
                end
                P.GetAccess = 'protected';
                P.SetAccess = 'protected';
            end
            obj.chnlProps = chnlProps_;
        end
        function set.numChnls(obj,numChnls_)
            if ~isempty(obj.numChnls)
                throw(MException('QOS_multiChnl:reSetnumChnls','numChnls is immutable.'));
            end
            obj.numChnls = numChnls_;
            if ~isempty(obj.chnlProps)
                obj.chnlProps = obj.chnlProps;
            end
        end
        function chnlObj = GetChnl(obj,chnl,exclusive)
            if nargin < 3
                exclusive = false; % by default, not exclusive
            end
            chnlObj = qes.hwdriver.instrumentChnl(obj,chnl,exclusive);
		end
    end
    methods(Hidden = true)
		function TakeChnl(obj,chnl,exclusive_)
            idx = find(obj.takenChnls,chnl);
			if ~isempty(idx)
                if isinf(obj.clientCount(idx))
                    throw(MException('QOS_multiChnl:chnlNotAvailable','channel %0.0f is not available.', chnl));
                elseif exclusive_
                    throw(MException('QOS_multiChnl:chnlNotAvailable',...
                        'channel %0.0f is currently taken by other applications, thus can not be taken exclusively.', chnl));
                else
                    obj.clientCount(idx) = obj.clientCount(idx) + 1;
                end
            else
                obj.takenChnls = [obj.takenChnls, chnl];
                if exclusive_
                    obj.clientCount = [obj.clientCount,Inf];
                else
                    obj.clientCount = [obj.clientCount,1];
                end
            end
		end
		function ReleaseChnl(obj,chnl)
            idx = find(obj.takenChnls,chnl);
            if isempty(idx)
                return;
            end
            if isinf(obj.clientCount(idx))
                obj.takenChnls(idx) = [];
                obj.clientCount(idx) = [];
            else
                obj.clientCount(idx) = max(0,obj.clientCount(idx)-1);
            end
		end
    end
end