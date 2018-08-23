classdef randBenchMarking4Opt < sqc.measure.randBenchMarking
    % a wrapper of randBenchMarking as a measure for gate optimization
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties(SetAccess = private, GetAccess = private)
		isReference = true;
	end
    methods
        function obj = randBenchMarking4Opt(qubits,numGates,numShots,process)
			if nargin < 4 || isempty(process)
				process = [];
				notReference = false;
			else
				notReference = true;
			end
			obj@sqc.measure.randBenchMarking(qubits,process,numGates,numShots,notReference);
            obj.isReference = ~notReference;
            obj.numericscalardata = true;
            obj.name = 'Sequence Error';
        end
        function Run(obj)
            Run@sqc.measure.randBenchMarking(obj);
			if obj.isReference
				obj.data = 1-mean(obj.data(:,1));
			else
				obj.data = 1-mean(obj.data(:,2));
			end
            obj.dataready = true;
        end
    end
end
