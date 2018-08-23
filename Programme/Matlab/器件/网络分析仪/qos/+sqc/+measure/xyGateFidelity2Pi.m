classdef xyGateFidelity2Pi < qes.measurement
	% measure xy gate fidelity.
	% simple, fast and coarse, if fine fidelity result is needed, use QPT or RB.
    % method: build a multiple 2 pi rotation by the given xy gate and
	% measure the |0> state probability

    % Copyright 2017 Yulin Wu, University of Science and Technology of China
    % mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		num2Pi = 1  % number of 2 pi rotations, 2 pi(if possible) by default
	end
    properties (GetAccess = private, SetAccess = private)
        gate
    end
	properties (Constant = true)
		supportedGates = {'X','X2m','X2p','X4m','X4p','Y','Y2m','Y2p','Y4m','Y4p',...
			'XY_4m','XY_4p',...
			'XY','XY2m','XY2p'};
	end
    methods
        function obj = xyGateFidelity2Pi(g, n)
			gClass = strsplit(class(g),'.');
			gClass = gClass{end};
			if ~ismember(gClass,supportedGates);
				throw(MException('QOS_xyGateFidelity2Pi:inValidInput',...
					sprintf('the input gate %s is not one of the supported gates.',gClass)));
			end
			obj.gate = g;
            if nargin == 1
				obj.num2Pi = 1;
			end
			obj.gate = g;
            obj.numericscalardata = true;
            obj.name = 'Fidelity';
        end
        function Run(obj)
%             obj.drive_mw_src.on = true;
            Run@sqc.measure.resonatorReadout_ss(obj);
            data_with_mw = obj.data;
            data_with_mw_e = mean(obj.extradata);
%             obj.drive_mw_src.on = false;
            Run@sqc.measure.resonatorReadout_ss(obj);
            data_without_mw = obj.data;
            data_without_mw_e = mean(obj.extradata);
            if obj.keep_bkgrnd
                obj.data = [data_without_mw,data_with_mw];
            else
                obj.data = data_with_mw-data_without_mw;
                obj.data = - obj.data;
            end
            obj.extradata = [mean(abs(data_without_mw_e)),mean(abs(data_with_mw_e))];
            obj.dataready = true;
        end
    end
end