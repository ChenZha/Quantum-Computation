classdef (Abstract = true) hardware < qes.qHandle & dynamicprops
    % base class for all hardware
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties(SetAccess = protected)
		numChnls % number of channels
		chnlMothdNames = {}
		chnlMothds = {}
        chnlProps = {} % numeric types only
        chnlPropSetMothds = {}
        chnlPropGetMothds = {}
    end
    properties(SetAccess = private)
		takenChnls
        clientCount
	end
    methods
        function obj = hardware(name)
            if nargin == 0 || isempty(name)
                throw(MException('Hardware:UnNamedError',...
				'name empty, hardwares object properties are looked up in settings by name, so a hardware must be given a name.'));
            end
            obj = obj@qes.qHandle(name);
            obj.temperory = false;
            qes.hwdriver.hardware.ListHwObj(obj);
        end
        function delete(obj)
            obj.temperory = true; % remove object from pool
        end
		
		function set.chnlProps(obj,chnlProps_)
            obj.chnlProps = chnlProps_;
            if isempty(obj.numChnls)
                return;
            end
            for ii = 1:numel(chnlProps_)
                P = addprop(obj,chnlProps_{ii});
                obj.(chnlProps_{ii}) = NaN*ones(1,obj.numChnls);
                P.GetAccess = 'protected';
                P.SetAccess = 'protected';
            end
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
        
        function ChnlPropSetAll(obj,propName,val)
            [ret,ind] = ismember(propName,obj.chnlProps);
            if iscell(val)
                cellVal = true;
            else
                cellVal = false;
            end
            if ret
                val = qes.util.numericCell2Mat(val);
                if numel(val) ~= obj.numChnls
                    throw(MException('QOS_hardware:propValueSizeError',...
                        sprintf('value size(%d) of the channel property %s not matching the number of channels(%d)',...
                        numel(val), propName,obj.numChnls)));
                else
                    for ii = 1:obj.numChnls
                        if cellVal
                            obj.chnlPropSetMothds{ind}(obj,ii,val{ii});
                        else
                            obj.chnlPropSetMothds{ind}(obj,ii,val(ii));
                        end
                    end
                end
            else
                throw(MException('QOS_hardware:notChnlPropError',...
                        sprintf('%s is not a channel property of class %s',propName,class(obj))));
            end
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
    methods(Static = true)
        function varargout = ListHwObj(varargin)
            persistent objlst % object pool
            if isempty(objlst)
                objlst = {};
            end
            if nargin == 0 % return all registered objects
                varargout{1} = objlst;
            elseif isa(varargin{1},'qes.hwdriver.hardware') % register a object
                ii = 1;
                NumObj = length(objlst);
                while ii <= NumObj
                    if ~isobject(objlst{ii}) || ~isvalid(objlst{ii})
                        objlst(ii) = [];
                        NumObj = NumObj - 1;
                        ii = ii - 1;
                    elseif objlst{ii} == varargin{1}
                        break;
                    end
                    ii = ii +1;
                end
                if ii > NumObj
                    objlst = [objlst, varargin(1)];
                end
            elseif ischar(varargin{1}) % return registered object of a specific name
                NumObj = length(objlst);
                ii = 1;
                theObject = [];
                while ii <= NumObj
                    if ~isvalid(objlst{ii})
                        objlst(ii) = [];
                        NumObj = NumObj - 1;
                        ii = ii - 1;
                    elseif strcmp(objlst{ii}.name,varargin{1})
                        theObject = objlst{ii};
                        break;
                    end
                    ii = ii +1;
                end
                varargout{1} = theObject;
            end
        end
        function hwObject = FindHwByName(name)
            hwObject = qes.hwdriver.hardware.ListHwObj(name);
        end
    end
end