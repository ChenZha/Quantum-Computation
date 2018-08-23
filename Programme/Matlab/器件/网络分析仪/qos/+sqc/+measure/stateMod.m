classdef stateMod < sqc.measure.stateTomography
    % measure single qubit state modulus
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = stateMod(qubits, isParallel)
			if ischar(qubits)
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
            obj = obj@sqc.measure.stateTomography(qubits,isParallel);
			if isParallel
				obj.numericscalardata = false;
				obj.name = ['state modulus'];
			else
				obj.numericscalardata = true;
				obj.name = [qubits{1}.name,' state modulus'];
			end
        end
        function Run(obj)
            Run@sqc.measure.stateTomography(obj);
			if isParallel
				numQs = numel(obj.qubits);
				data_ = nan(1,numQs);
				for ii = 1:numQs
					data__ = 1 - 2*obj.data(ii,2,:);  % 1-2*P|1> or 2*P|0> - 1
					data__ = abs(data__(1)+1j*data__(2));
					data_(ii) = data__;
				end
				obj.data = data_;
			else
				obj.data = 1 - 2*obj.data(:,2);  % 1-2*P|1> or 2*P|0> - 1
				obj.data  = abs(obj.data(1)+1j*obj.data(2));
			end
        end
    end
end