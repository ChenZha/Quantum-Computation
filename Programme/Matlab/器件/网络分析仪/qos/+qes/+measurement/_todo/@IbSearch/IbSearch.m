classdef IbSearch < Measurement
    % flux qubit SQUID Readout
    % 'IbSearch' performs the following function:
    % Given a switching probability P (0<P<1), 'IbSearch' finds the
    % amplitude of the measurement pulse(Ib) which gives the switching
    % probability P
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        P = 0.5;   % target probabilty, default 0.5
        Ib_est; % estimation of the amplitude of the measurement pulse
        CloseSearch = false; % Ib_est is already close to the real value, search starts at a small initial searching step, default: false
        MaxSteps = 19; % maximum search steps, default 19
        ShowProcess@logical scalar = true;    % plot searching process, default: true
        PlotAxes            % axes to plot the searching process, defaut: create one if not specified
    end
    properties (Hidden = true, SetAccess = private, GetAccess = private)
        ReadoutPulseObj
    end
    properties (Hidden = true, SetAccess = private, GetAccess = private, Dependent = true)
        N
    end
    properties (Hidden = true, Constant = true)
        SearchPrecision = 2e4;          % Minimum search step£ºIc_est/SearchPrecision;
                                % The value of this limit is set to be
                                % approximately the maximum resolution of
                                % the AWG.
                                % Searching will stop if the 'search-step'
                                % reaches this limit.
                                % In most cases, this limit will not be
                                % reached.
    end
    methods (Access = private)
        function GenPlotAxes(obj)
            % Generate the axes for plot if it is not already generated
            if isempty(obj.PlotAxes) || ~ishghandle(obj.PlotAxes)
                scrsz = get(0,'ScreenSize');
                FigPos = [850, 50, 561, 420];
                FigPos(1) = (scrsz(3) - FigPos(3))/2;
                FigPos(2) = (scrsz(4) - FigPos(4))/2;
                FigName = ['Searching Ib for P(Ib) = ',num2str(obj.P,'%0.2f')];
                SearchDisplayFig = figure('Name',FigName,'NumberTitle','off',...
                    'Color',[1,1,1],'Toolbar','none','MenuBar','none','Position',FigPos,...
                    'tag','IbSearchPlotFigure');
                obj.PlotAxes = axes('parent',SearchDisplayFig);
                set(SearchDisplayFig,'UserData',obj.PlotAxes);
            end
        end
    end
	methods
        function obj = IbSearch(InstrumentObject,ReadoutPulseObj)
            if ~isa(InstrumentObject,'GetP') || ~isvalid(InstrumentObject)
                error('IbSearch:InvalidInput','InstrumentObject is not a valid GetP class object!');
            end
            if ~isa(ReadoutPulseObj,'Waveform') || ~isvalid(ReadoutPulseObj)
                error('IbSearch:InvalidInput','ReadoutPulseObj is not a valid Waveform class object!');
            end
            obj = obj@Measurement(InstrumentObject);
            obj.numericscalardata = true;
            obj.ReadoutPulseObj = ReadoutPulseObj;
            obj.timeout = 180; % default timeout 180 seconds.
        end
        function set.P(obj,val)
            if isempty(val)
                return;
            end
            if isempty(val) || val >=1 || val <=0
                error('IbSearch:InvalidInput','P>=1 or P <=0!');
            end
            obj.P = val;
        end
        function set.Ib_est(obj,val)
            if isempty(val) || val <=0
                error('IbSearch:InvalidInput','Ib should be positive!');
            end
            obj.Ib_est = val;
        end
        function set.CloseSearch(obj,val)
            if isempty(val) || ~islogical(val)
                error('IbSearch:InvalidInput','CloseSearch should be bolean!');
            end
            obj.CloseSearch = val;
        end
        function set.MaxSteps(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('IbSearch:InvalidInput','MaxSteps should be a positive integer!');
            end
            obj.MaxSteps = val;
        end
        function set.ShowProcess(obj,val)
            if isempty(val) || ~islogical(val)
                error('IbSearch:InvalidInput','ShowProcess should be bolean!');
            end
            obj.ShowProcess = val;
        end
        function val = get.N(obj)
            val = obj.InstrumentObject.N;
        end
        Run(obj)
    end
end