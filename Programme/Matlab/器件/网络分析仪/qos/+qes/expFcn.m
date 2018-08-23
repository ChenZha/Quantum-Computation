classdef expFcn
    % make the already very simple experiment procedure 'setting some
    % parameters and then do some measuremts' even more straightfowrd:
    % suppose the work to do is:
    % 1, set some parameters Param1, Param1,...
    % 2, do some measurements Measurement1, Measurement2,...
    % what you need to do now becomes:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % f = expFcn({Param1, Param1,...},{Measurement1, Measurement2,...});
    % y = f(x1,x2,...);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % just a function call and everything is done!
    % x1, x2,... are values to be set on the parameters, y is the measured
    % data, a cell that stores the results of each measurement.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        fcn % the funciton that is actually being call when calling a expFunc class object
    end
    properties (GetAccess = private, SetAccess = private)
        params
        measurements
        maxevaltries = 3
    end
    methods
        function obj = expFcn(ParamList,MeasurementObj)
            if iscell(ParamList) % ParamList should be an array of ExpParam class objects
                    % there is only one ExpParam class, it is a sealed class,
                    % so here we use matrix, this formality is not imposed one the user
                    % though, we do the conversion in case of cells received.
                ParamList = cell2mat(ParamList,MeasurementObj); 
            end
            if ~isa(ParamList,'qes.expParam')
                throw(MException('QOS_expFcn:InvalidInput','ParamList should be ExpParam class objects.'));
            end
            if ~iscell(MeasurementObj) % Measurement is group of classes, use cell
                MeasurementObj = {MeasurementObj}; % in case of just one, the cell formality can be ignored
            end
            nparam = length(ParamList);
            nmeas = numel(MeasurementObj);
            for nn = 1:nmeas
                if ~isa(MeasurementObj{nn},'qes.measurement.measurement')
                    throw(MException('QOS_expFcn:InvalidInput','at least one of the MeasurementObj is not a Measurement class objects.'));
                end
                if ~MeasurementObj{nn}.numericscalardata && isempty(MeasurementObj{nn}.datafcn)
                    throw(MException('QOS_expFcn:InvalidInput','only handles MeasurementObj that produces numeric scalar data.'));
                end
            end
            obj.params = ParamList;
            obj.measurements = MeasurementObj;
            function varargout = f(varargin)
                if numel(varargin) == nparam
                    for ii = 1:nparam
                        obj.params(ii).val = varargin{ii};
                    end
                else
                    for ii = 1:nparam
                        obj.params(ii).val = varargin{1}(ii);
                    end
                end
                varargout = cell(1,nmeas);
                for ii = 1:nmeas
                    obj.measurements{ii}.Run();
%                     for jj = 1:obj.maxevaltries
%                         if isempty(obj.measurements{ii}.data) || ~isnumeric(obj.measurements{ii}.data)
%                             if jj == obj.maxevaltries
%                                 error('expFcn:FEvalFailed','measurements run failed.');
%                             end
%                         end
%                         varargout{ii} = obj.measurements{ii}.data;
%                     end
                end
                for ii = 1:nmeas
%                     waitfor(obj.measurements{ii},'dataready')
                    if obj.measurements{ii}.dataready
                        varargout{1}=obj.measurements{ii}.data;
                        break;
                    end
                end
            end
            obj.fcn = @f;
        end
    end
    methods (Access = 'public', Hidden=true)
        function varargout = subsref(obj,S)
            switch S(1).type
                case '.'
                    varargout{1} = obj.(S(1).subs);
                case '()'
                    varargout{1} = obj.fcn(S(1).subs{:});
            end
        end
    end
    
end