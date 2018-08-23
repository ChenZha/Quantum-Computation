classdef (Abstract = true) measurement < qes.qHandle
    % base class of measurement classes, defines the basic features of
    % measurement.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        timeout = Inf;  % seconds, maximun waiting time for dataready, default: Inf 
        % swap data and extra data or not, if set to true, obj.data will
        % return extradata instead of data, this can be useful in some applications.
        swapdata@logical scalar = false;
        % a function to do data tranform or data post process, type: function handle
        % example: @mean, produces mean of data
        datafcn
		preRunFcns
		postRunFcns
    end
	properties (SetAccess = protected)
        % data is numeric scalar or not, default, true, to defined in specific sub classes
        numericscalardata@logical = true; 
        data % single value or matrix, read only
        extradata  % extradata, single value or matrix, read only
    end
    properties (SetAccess = protected)
        instrumentObject % Instrument class objects or measurement class objects,
                         % the later case is complicated measuements built
                         % by using simple measurements.
    end
    properties (SetAccess = protected, SetObservable = true)
        dataready@logical % read only
    end
    properties (Hidden = true, SetAccess = protected, GetAccess = protected)
        data_img
        extradata_img
        abort = false; % abort flag
    end
    events
        DataReady % when data is ready, this event is broadcasted.
    end
	
	methods
        function obj = measurement(instrumentObject)
            % instrumentObject: Instrument/Device class objects or measurement class objects,
            % the later case is complicated measuements built by using
            % simple measurements, IbSearch for example.
            obj = obj@qes.qHandle('');
            obj.instrumentObject = instrumentObject;
            addlistener(obj,'dataready','PostSet',@qes.measurement.measurement.NotifyDataReady);
%             addlistener(obj,'data','PostSet',@measurement.MkDataImg);
        end
        function set.swapdata(obj,val)
            if ~islogical(val)
                error('measurement:InvalidInput','swapdata should be a bolean!');
            end
            obj.swapdata = val;
        end
        function set.datafcn(obj,val)
            if ~isempty(val) && ~isa(val,'function_handle')
                error('measurement:InvalidInput','datafcn should be empty or a function handle!');
            end
            obj.datafcn = val;
        end
		function set.preRunFcns(obj,val)
			if ~isempty(val) && ~iscell(val)
				val = {val};
			end
			for ii = 1:numel(val)
				if ~isa(val{ii},'function_handle')
					error('measurement:InvalidInput',...
						'preRunFcns should be empty or cell array of function handles');
				end
			end
            obj.preRunFcns = val;
        end
		function set.postRunFcns(obj,val)
			if ~isempty(val) && ~iscell(val)
				val = {val};
			end
			for ii = 1:numel(val)
				if ~isa(val{ii},'function_handle')
					error('measurement:InvalidInput',...
						'postRunFcns should be empty or cell array of function handles');
				end
			end
            obj.postRunFcns = val;
        end
        function val = get.numericscalardata(obj)
            if obj.swapdata % in case of swapdata, extradata is returned instead of data while qureying measurement data.
                val = false;
            else
                val = obj.numericscalardata;
            end
        end
        function val = get.data(obj)
            if obj.swapdata
                val = obj.extradata_img;
            else
                val = obj.data_img;
            end
            if ~isempty(obj.datafcn) % return mean of data for example
                val = feval(obj.datafcn,val);
            end
        end
        function set.data(obj,val)
            obj.data = val;
            obj.data_img = val;
        end
        function val = get.extradata(obj)
            if obj.swapdata
                val = obj.data_img;
            else
                val = obj.extradata_img;
            end
        end
        function set.extradata(obj,val)
            obj.extradata = val;
            obj.extradata_img = val;
        end
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            if isobject(obj.instrumentObject) && ~isvalid(obj.instrumentObject) 
                bol = false;
                return;
            end
        end
        function Run(obj)
%             if ~obj.IsValid()
%                 error('measurement:RunError','The object itself not valid or some of its handle class properties not valid.');
%             end
			for ii = 1:numel(obj.preRunFcns)
				feval(obj.preRunFcns{ii});
			end
            obj.data = [];
            obj.extradata = [];
            obj.dataready = false;
            obj.abort = false;
        end
        function Abort(obj)
            obj.abort = true; % post the abort flag
        end
    end
    methods (Access = 'public', Hidden=true)
        function varargout = subsref(obj,S)
            % a call to a measurement object will runs it
            varargout = {};
            switch S(1).type
                case '.'
                    if numel(S) == 1
                        if nargout
                            varargout{1} = obj.(S(1).subs);
                        else
                            obj.(S(1).subs);
                        end
                    else
                        switch S(2).type
                            case '()'
                                if nargout
                                    varargout{1} = obj.(S(1).subs)(S(2).subs{:});
                                else
                                    obj.(S(1).subs)(S(2).subs{:});
                                end
                            case '{}'
                                varargout{1} = obj.(S(1).subs){S(2).subs{:}};
                        end
                    end
                case '()'
                    obj.Run();
                    if nargout
                        varargout{1} = obj.data;
                    end
            end
        end
    end
    methods (Static = true)
        function NotifyDataReady(metaProp,eventData)
            obj = eventData.AffectedObject;
            if obj.dataready
                notify(obj,'DataReady');
				for ii = 1:numel(obj.postRunFcns)
					feval(obj.postRunFcns{ii});
				end
            end
        end
    end
    
end