classdef (Sealed = true)sweep < qes.qHandle
    % sweep an array of values for one or multiple
    % ExpParam(experimental parameter) class objects or functions.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % values of paramobjs to sweep, if paramobjs is a
        % array(muti ExpParam objects), vals should be a cell array of the
        % same length, the ith cell is the values of the ith ExpParam
        % object in paramobjs to sweep, and the sweep values for all the
        % ExpParam object should have the same length.
        vals
        % sweep mask, mask is empty or a bolean array with length equal to the sweep size,
        % it is used to relize non rectangular sweeps: circular, band etc.
        % mask(nth) = false: the nth sweep point will be skipped;
        % mask(nth) = true: the nth sweep point will be sweeped;
        % if empty(default), all sweep points are sweeped.
        mask
        % cell array of function handles, before setting of val, these
        % functions are executed in order. all callbacks takes the object
        % as argument
        prestepcallbacks
        % cell array of function handles, after setting of val, these
        % functions are executed in order. all callbacks takes the object
        % as argument
        poststepcallbacks
        % auxilary parameter, typically a object to implement some function
        % by callbacks, for example:
        % auxpara = DynMwSweepRngObj; prestepcallbacks = {@(x) x.auxpara.UpdateRng()};
%        auxpara  
%        % a measurement object,  added to implement a special functionanilty
        swpdatasrc
        swpdata
    end

	properties (SetAccess = immutable)
		% ExpParam class objects or a function to sweep, if paramobjs is a
        % array(muti ExpParam class objects), vals should be a cell array
        % of the same length, each cell containning the sweeping values
        % for the corresponding ExpParam object.
        paramobjs
        % main parameter object, positive integer, default 1
        mainparam = 1
    end
    
    properties (SetAccess = private)
        idx = 1; % next sweep step idx
    end
    properties (Dependent = true)
		size    % number of sweep steps
        paramnames; % name of parameter objects
    end
	methods
        function obj = sweep(ExpParamObjs,MainParam)
            % note: you can create a null sweeper by sweep([]) or sweep(),
            % use numerical values as sweeping values, the length of
            % sweep valuse decides the sweep size, the values are not used.
            % for example, to create a sweep which simply pauses 10 seconds
            % at each step:
            % SwpWait10sec = sweep();
            % SwpWait10sec.callbacks = {@(x) pause(10)};
            % SwpWait10sec.vals = {ones(1,50)}; % sweep size will be 50.
            % this is not sweep time because unlike other physical propeties
            % such as voltage, current, power etc., TIME CAN NOT BE SET.
            obj = obj@qes.qHandle('');
            if nargin == 0
                ExpParamObjs = [];
            end
            NumParams = numel(ExpParamObjs);
            if iscell(ExpParamObjs) % convert cell to matrix
                ExpParamObjs_ = ExpParamObjs{1};
                for ii = 2:NumParams
                    ExpParamObjs_ = [ExpParamObjs_, ExpParamObjs{ii}];
                end
                ExpParamObjs = ExpParamObjs_;
            end
            for ii = 1:NumParams
                if ~isa(ExpParamObjs(ii),'qes.expParam') || ~isvalid(ExpParamObjs(ii))
                    error('sweep:InvalidInput',...
                        'paramobjs should be valid ExpParam class objects!');
                end
            end
            obj.paramobjs = ExpParamObjs(:);
            if nargin == 1
                obj.mainparam = 1;
            else
                if MainParam < 0 || round(MainParam) ~= MainParam
                    error('sweep:InvalidInput',...
                        'mainparam should be a positive interger!');
                end
                if MainParam > NumParams
                    error('sweep:InvalidInput',...
                        'mainparam bigger than the number of parameter objects!');
                end
                obj.mainparam = MainParam;
            end
        end
        function set.vals(obj, ParamVals)
            % sweep size is the number of rows*, each column is taken
            % as a sweep value, one row: scalar value sweep,
            % multiple rows: vector value sweep, property or function that
            % takes a vector as value/argument
            if isempty(obj.paramobjs)
                return;
            end
            if ~iscell(ParamVals)
                ParamVals = {ParamVals};
            end
            NumParams = numel(obj.paramobjs);
            if numel(ParamVals) ~= NumParams
                error('sweep:InvalidInput',...
                        'vals not of the same length as number of paramobjs.');
            end
            sz = zeros(1,NumParams);
            for ii = 1:NumParams
                sz_ = size(ParamVals{ii});
				if length(sz_) > 2
					error('sweep:InvalidInput',...
                            '3D or higher dimension matrix as ParamVals is not supported');
                end
                sz(ii) = sz_(2);
            end
            if numel(unique(sz)) > 1
                error('sweep:InvalidInput',...
                    'sweep values are not of the same length.');
            end
            obj.vals = ParamVals;
        end
        function set.mask(obj,val)
            if isempty(val)
                obj.mask = val;
                return;
            end
            if isempty(obj.vals)
                error('sweep:SetMask','vals not set yet, set vals before set mask.');
            end
            if length(val) ~= obj.size
                error('sweep:SetMask','sweep size and mask size mismatch.');
            end
            if ~all(islogical(val))
                error('sweep:SetMask','mask should be bolean.');
            end
            obj.mask = val;
        end
        function set.prestepcallbacks(obj, val)
            if ~iscell(val)
                val = {val};
            end
            for ii = 1:length(val)
                if ~isa(val{ii}, 'function_handle')
                    error('sweep:InvalidInput',...
                    'some callbacks are not valid funcion handles.');
                end
            end
            obj.prestepcallbacks = val;
        end
        function set.poststepcallbacks(obj, val)
            if ~iscell(val)
                val = {val};
            end
            for ii = 1:length(val)
                if ~isa(val{ii}, 'function_handle')
                    error('sweep:InvalidInput',...
                    'some callbacks are not valid funcion handles.');
                end
            end
            obj.poststepcallbacks = val;
        end
        function set.swpdatasrc(obj, src)
            if isempty(src)
                obj.swpdatasrc = src;
                obj.swpdata = [];
            end
            if ~isa(src,'Measurement') || ~IsValid(src)
                error('sweep:InvalidInput',...
                    'swpdatasrc is not a valid Measurement class object.');
            end
            obj.swpdatasrc = src;
            if obj.swpdatasrc.numericscalardata
                obj.swpdata = NaN*ones(1,numel(obj.vals{1}));
            else
                obj.swpdata = cell(1,numel(obj.vals{1}));
            end
        end
        function sz = get.size(obj)
            if isempty(obj.vals)
                sz = 0;
                return;
            end
            sz = size(obj.vals{1});
            sz = sz(2);
        end
        function Step(obj)
            if obj.idx <= obj.size
                for ii = 1:numel(obj.prestepcallbacks)
                    % do not use cellfun, cellfun function does not perform
                    % the calls in a specific order(cellfun doc).
                    % here execution order is important.
                    feval(obj.prestepcallbacks{ii},obj);
                end
                for ii = 1:numel(obj.paramobjs)
					obj.paramobjs(ii).val = obj.vals{ii}(:,obj.idx);
                end
                for ii = 1:numel(obj.poststepcallbacks)
                    % do not use cellfun, cellfun function does not perform
                    % the calls in a specific order(cellfun doc).
                    % here execution order is important.
                    feval(obj.poststepcallbacks{ii},obj);
                end
                if ~isempty(obj.swpdatasrc)
                    if iscell(obj.swpdata)
                        obj.swpdata{obj.idx} = obj.swpdatasrc.data;
                    else
                        obj.swpdata(obj.idx) = obj.swpdatasrc.data;
                    end
                end
                obj.idx = obj.idx + 1;
                while 1
                    if isempty(obj.mask) || obj.mask(obj.idx) || obj.IsDone()
                        break;
                    end
                    obj.Skip();
                end
            end
        end
        function Skip(obj, numskipsteps)
            % skip one(default) or multi sweep steps(specify number of steps to skip)
            if nargin > 1
                obj.idx = obj.idx + numskipsteps;
            else
                obj.idx = obj.idx + 1;
            end
        end
        function bol = IsDone(obj)
            % Check sweep is done or not
            bol = false;
            if obj.idx > obj.size
                bol = true;
            end
        end
        function Reset(obj)
            % Reset the sweep to the first sweep step
            obj.idx = 1;
        end
        function obj = plus(obj1,obj2)
            % add two sweeps together, order is important: the first sweep is executed first. 
            % the two added sweeps should have the same size.
            if obj1.size ~= obj2.size
                error('sweep:Add','the two added sweeps should have the size.');
            end
            obj = sweep([obj1.paramobjs;obj2.paramobjs]);
            obj.vals = [obj1.vals;obj2.vals];
        end
        function names = get.paramnames(obj)
            NumParams = length(obj.paramobjs);
            names = cell(1,NumParams);
            for ii = 1:NumParams
                names{ii} = obj.paramobjs.name;
            end
        end
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            for ii = 1:length(obj.paramobjs)
                if ~IsValid(obj.paramobjs(ii)) 
                    bol = false;
                    break;
                end
            end
        end
    end
end