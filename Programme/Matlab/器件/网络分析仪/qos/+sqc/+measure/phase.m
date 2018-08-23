classdef phase < sqc.measure.phaseTomography
    % measure single qubit state phase
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = phase(qubits, isParallel)
			if ~iscell(qubits)
				qubits = {qubits};
			end
			if nargin < 2
				if numel(qubits) > 1
					isParallel = true;
				else
					isParallel = false;
				end
			elseif numel(qubits) > 1 && ~isParallel
				error('illegal arguments');
			end
            obj = obj@sqc.measure.phaseTomography(qubits,isParallel);
			if isParallel
				obj.numericscalardata = false;
				obj.name = ['phase(rad)'];
			else
				obj.numericscalardata = true;
				obj.name = [qubits{1}.name,' phase(rad)'];
            end
        end
        function Run(obj)
            Run@sqc.measure.phaseTomography(obj);
            % by define |0>-|1>, |0>-1j|1> and |0>, as x, y and z zero
            % phase point
			if obj.isParallel
				numQs = numel(obj.qubits);
				data_ = nan(1,numQs);
				for ii = 1:numQs
					data__ = 1 - 2*obj.data(ii,2,:);  % 1-2*P|1> or 2*P|0> - 1
					data__ = angle(data__(1)+1j*data__(2));
                    
					data_(ii) = data__;
				end
				obj.data = data_;
			else
				obj.data = 1 - 2*obj.data(:,2);  % 1-2*P|1> or 2*P|0> - 1
                disp(abs(obj.data(1)+1j*obj.data(2)))
				obj.data  = angle(obj.data(1)+1j*obj.data(2));
			end
        end
    end
end