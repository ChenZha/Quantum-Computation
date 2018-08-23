classdef stateTomography < sqc.measure.tomography
    % state tomography
	% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:Z},... ,{q2:Z q1:Z}
% colomn: P|00>,|01>,|10>,|11>
% qubit labeled as: |qubits{2},qubits{1}>
% in case of 2Q data(3,2): {qubits{2}:X qubits{1}:I} P|01> (|qubits{2},qubits{1}>)
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = stateTomography(qubits, isParallel)
			if nargin < 2
				isParallel = false;
			end
            % X, Y, Z
%             obj = obj@sqc.measure.tomography(qubits,{'Y2p','X2m','I'},isParallel); 
            obj = obj@sqc.measure.tomography(qubits,{'Y2m','X2p','I'},isParallel); 
        end
        function Run(obj)
            Run@sqc.measure.tomography(obj);
        end
    end
end