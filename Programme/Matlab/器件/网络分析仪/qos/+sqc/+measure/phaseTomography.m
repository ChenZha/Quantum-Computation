classdef phaseTomography < sqc.measure.tomography
    % phase tomography
	% data: 2 by 2
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = phaseTomography(qubits, isParallel)
			if nargin < 2
				isParallel = false;
			end
            % obj = obj@sqc.measure.tomography(qubits,{'X2p','X2m','Y2p','Y2m'});
%             obj = obj@sqc.measure.tomography(qubits,{'Y2p','X2m'},isParallel);
            obj = obj@sqc.measure.tomography(qubits,{'Y2m','X2p'},isParallel);
        end
    end
end