classdef randBenchMarkingFS < sqc.measure.randBenchMarking
    % randomized benchmarking, run one fixed random gate sequence
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        ridx
    end
    methods
        function obj = randBenchMarkingFS(qubits,numGates,numShots,ridx)
            % the lowest fidelity reference sequence for n random gate: [~,idx] = min(Pref(:,n)); Gates{n,idx,1}
            if nargin < 2
                error('not enough number of input arguments.');
            end
            if nargin < 3
                numShots = 1;
            end
            if nargin > 3
                sz = size(ridx);
                numGates = sz(2);
                numShots = sz(1);
            end
            obj = obj@sqc.measure.randBenchMarking(qubits, [], numGates, numShots, false);
            if nargin < 4
                ridx = NaN(numShots,numGates);
                if numel(qubits) == 1
                    for ii = 1:numShots
                        ridx(ii,:) = randi(24,1,numGates);
                    end
                elseif numel(qubits) == 2
%                     for ii = 1:numShots
%                         ridx(ii,:) = randi(11520,1,numGates);
%                     end
                    ridx = sqc.measure.randBenchMarkingFS.CZRndSeq(numGates,numShots); 
                else
                    error('randBenchMarking on more than 2 qubits is not implemented.');
                end
            end
            obj.ridx = ridx;
            obj.numericscalardata = true;
            obj.name = 'Sequence Error';
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
            data = NaN(1,obj.numShots);
            extradata = NaN(obj.numShots,obj.numGates+1);
            for ii = 1:obj.numShots
                [gs,gf_ref,~,gref_idx,~] = obj.randGates(obj.ridx(ii,:));
                PR = gs{1,1};
                for ww = 2:obj.numGates
                    PR = PR*gs{1,ww};
                end
                PR = PR*gf_ref;
                obj.R.state = 1;
                obj.R.delay = PR.length;
                PR.Run();
                data(ii) = obj.R();
                extradata(ii,:) = gref_idx;
            end
			obj.data = 1 - mean(data);
            obj.extradata = extradata;
            obj.dataready = true;
        end
    end
    methods (Static  = true)
        function rind = CZRndSeq(numGates,numShots)
            % 0 cz: 576
            % 1 cz: 5184
            % 2 cz: 5184
            % 3 cz: 576
            assert(numShots > 1 && 20*round(numShots/20) == numShots,...
                'numShots must be a multiple of 20');
            M = numShots/20;
            N = numGates*M;
            zeroCZGateInds = 1:576;
            rind0 = zeroCZGateInds(randperm(576,N));
            oneCZGateInds = 577:5760;
            rind1 = oneCZGateInds(randperm(5184,9*N));
            twoCZGateInds = 5761:10944;
            rind2 = twoCZGateInds(randperm(5184,9*N));
            threeCZGateInds = 10945:11520;
            rind3 = threeCZGateInds(randperm(576,N));
            rind = [reshape(rind0,M,numGates);...
                    reshape(rind1,9*M,numGates);...
                    reshape(rind2,9*M,numGates);...
                    reshape(rind3,M,numGates)];
           for ii = 1:numGates
               rind(:,ii) = rind(randperm(numShots),ii);
           end
        end
    end
end