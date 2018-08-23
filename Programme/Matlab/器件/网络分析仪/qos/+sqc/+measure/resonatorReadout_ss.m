classdef resonatorReadout_ss < sqc.measure.resonatorReadout
    % resonator readout multiple qubits, return probability of a single state
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        state = 1 % 1 to 2^num_qubits
    end
    methods
        function obj = resonatorReadout_ss(qubits, isParallel,iqAsExtraData)
			if ischar(qubits)
				qubits = {qubits};
			end
			if nargin < 2
				if numel(qubits) > 1
					isParallel = true;
				else
					isParallel = false;
                end
                iqAsExtraData = true;
            elseif nargin < 3
                iqAsExtraData = true;
			elseif numel(qubits) > 1 && ~isParallel
				error('illegal arguments');
			end
            obj = obj@sqc.measure.resonatorReadout(qubits,isParallel,iqAsExtraData);
            obj.name = ['P',obj.stateNames{obj.state}];
			if isParallel
				obj.numericscalardata = false;
			else
				obj.numericscalardata = true;
			end
        end
        function set.state(obj,val)
			val = round(val);
            if val < 1 || val > 2^numel(obj.qubits)
                throw(MException('resonatorReadout:invalidState',...
						'state should be an integer between 1 and %d.',2^obj.num_qs));
            end
            obj.state = val;
            obj.name = ['P',obj.stateNames{obj.state}];
        end
        function Run(obj)
			Run@sqc.measure.resonatorReadout(obj);
            obj.data = obj.data(:,obj.state);
        end
    end
end