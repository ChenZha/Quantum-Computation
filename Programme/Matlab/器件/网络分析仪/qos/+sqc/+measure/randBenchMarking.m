classdef randBenchMarking < qes.measurement.measurement
    % randomized benchmarking
    % for two qubits: CZ based
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        process
        qubits % qubit objects or qubit names
        numGates
        numShots
    end
    properties (SetAccess = protected,GetAccess = protected)
        R
    end
    properties (GetAccess = private, SetAccess = private)
        processIdx
        C1
        C1m
        C2
        C2m
        numQs
		noReference@logical scalar
    end
    methods
        function obj = randBenchMarking(qubits, process, numGates, numShots, noReference,processClassName)
			if nargin < 5
				noReference = false;
			end
			
			if ~isempty(process) && ~isa(process,'sqc.op.physical.operator')
				throw(MException('QOS_randBenchMarking:invalidInput',...
						'the input is not a valid quantum operator.'));
			end
			import sqc.op.physical.gate.*
			if ~iscell(qubits)
                qubits = {qubits};
            end
            numQs = numel(qubits);
            if numQs > 2
				throw(MException('QOS_randBenchMarking:invalidInput',...
						'randBenchMarking on more than 2 qubits is not implemented.'));
			end
            for ii = 1:numQs
                if ischar(qubits{ii})
                    qs = sqc.util.loadQubits();
                    qubits{ii} = qs{qes.util.find(qubits{ii},qs)};
                end
				qubits{ii} = qubits{ii};
                % qubits{ii} = Copy(qubits{ii}); % copy is important for CZ based two-qubit RB 
            end
            obj = obj@qes.measurement.measurement([]);
            obj.noReference = noReference;
            obj.process = process;
			obj.qubits = qubits;
            obj.numericscalardata = false;
            obj.numGates = numGates;
            obj.numShots = numShots;
            if nargin < 6
                if ~isempty(process)
                    processClassName = class(process);
                    processClassName = strsplit(processClassName,'.');
                    processClassName = processClassName{end};
                else
                    processClassName = 'NULL';
                end
            end
            switch processClassName
				case 'NULL' % case which only measures the reference
					obj.processIdx = 0;
                case 'I'
                    obj.processIdx = 1;
                case {'X','X_'}
                    obj.processIdx = 2;
                case {'Y','Y_'}
                    obj.processIdx = 3;
                case 'X2p'
                    obj.processIdx = 13;
                case 'X2m'
                    obj.processIdx = 14;
                case 'Y2p'
                    obj.processIdx = 15;
                case 'Y2m'
                    obj.processIdx = 16;
                case 'Z'
                    obj.processIdx = 4;
                case {'CZ','ACZ'}
                    obj.processIdx = 4035;
                case 'CNOT'  % CNOT with qubit{1} as control
                    throw(MException('QOS_randBenchMarking:notImplemeted',...
						'Not implemented error'));
                    % obj.processIdx = ;
                case 'iCNOT' % CNOT with qubit{2} as control
                    throw(MException('QOS_randBenchMarking:notImplemeted',...
						'Not implemented error'));
                case 'iSwap' 
                    throw(MException('QOS_randBenchMarking:notImplemeted',...
						'Not implemented error'));
                otherwise % other cases are assumed to be I, X2p*X2m, CZ*CZ for example
                    obj.processIdx = 1;
                   % error('Process not one of NULL, I, X, Y, X2p, X2m, Y2p, Y2m, CZ, CNOT, iCNOT, iSwap.');
            end
            
            obj.R = sqc.measure.resonatorReadout_ss(obj.qubits);
            obj.R.state = 1;
            if numQs == 1
                obj.C1 = sqc.measure.randBenchMarking.C1Gates();
                obj.C1m = sqc.measure.randBenchMarking.C1matrix();
            elseif numQs == 2
                obj.C2 = sqc.measure.randBenchMarking.C2Gates();
                obj.C2m = sqc.measure.randBenchMarking.C2matrix();
            end
            obj.numQs = numQs;
        end
        function changeProcessTo(obj,process)
            assert(obj.processIdx == 1 && isa(process,'sqc.op.physical.operator'));
            obj.process = process;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
            obj.data = NaN(obj.numShots,2);
            obj.extradata = cell(obj.numShots,2);
            for nn = 1:obj.numShots
                [gs,gf_ref,gf_i,gref_idx,gint_idx] = obj.randGates();
				if obj.noReference
					pa = NaN;
                else 
					PR = gs{1,1};
                    
                    
%                     for ii = 2:obj.numGates
%                         PR = PR*gs{1,ii};
%                     end
%                     PR = PR*gf_ref;
 
%                     PR.logSequenceSamples = true;
%                     PR.Run();
%                     sqc.op.physical.sequenceSampleLogger.plot();

                    if obj.numQs == 1
                        for ii = 2:obj.numGates
                            PR = PR.noCopyPlus(gs{1,ii});
                        end
                        PR = PR.noCopyPlus(gf_ref);
                    else
                        for ii = 2:obj.numGates
                            PR = PR.noCopyTimes(gs{1,ii});
                        end
                        PR = PR.noCopyTimes(gf_ref);
                    end
				
					obj.R.state = 1;
					obj.R.delay = PR.length;

					PR.Run();
					pa = obj.R();
                end

				if obj.processIdx > 0 
					Pi = gs{2,1};
% 					for ii = 2:obj.numGates
% 						Pi = Pi*obj.process*gs{2,ii};
% 					end
% 					Pi = Pi*obj.process*gf_i;
                    if obj.numQs == 1
                        for ii = 2:obj.numGates
                            Pi_ = Pi*obj.process;
                            Pi = Pi_.noCopyPlus(gs{2,ii});
                        end
                        Pi = Pi*obj.process*gf_i;
                    else
                        for ii = 2:obj.numGates
                            Pi_ = Pi*obj.process;
                            Pi = Pi_.noCopyTimes(gs{2,ii});
                        end
                        Pi = Pi*obj.process*gf_i;
                    end
                    
					obj.R.delay = Pi.length;
					Pi.Run();
					pb = obj.R();
				else
					pb = NaN;
				end
                obj.data(nn,:) = [pa, pb];
                obj.extradata(nn,:) = {gref_idx,gint_idx};
                obj.dataready = true;
            end
        end
    end
	methods (Access = protected)
		function [g,gf_ref,gf_i,gref_idx,gint_idx] = randGates(obj,ridx)
			switch obj.numQs
                case 1
                    g = cell(2,obj.numGates);
                    if nargin < 2
                        ridx = randi(24,1,obj.numGates);
                    end
                    for ii = 1:obj.numGates
                        g{1,ii} = sqc.measure.randBenchMarking.generate1Qgates(obj.C1{ridx(ii)},obj.qubits{1});
                        g{2,ii} = Copy(g{1,ii});
                    end
                case 2
                    g = cell(2,obj.numGates);
                    if nargin < 2
                        ridx = randi(11520,1,obj.numGates);
                    end
                    for ii = 1:obj.numGates
                        [g_] = sqc.measure.randBenchMarking.generate2Qgates(...
                                obj.C2{ridx(ii)},obj.qubits{1},obj.qubits{2});
                         g{1,ii} = g_;
                         g{2,ii} = Copy(g_);
                    end
                otherwise
                    error('more than 2 qubits RB is not supported.');
            end
            [gf_ref, gf_idx] = obj.finalGate(ridx);
			gref_idx = [ridx,gf_idx];
			if obj.processIdx > 0
				iidx = reshape([ridx; obj.processIdx*ones(1,obj.numGates)],1,[]);
				[gf_i, gf_i_idx] = obj.finalGate(iidx);
				gint_idx = [iidx,gf_i_idx];
			else
				gf_i = [];
				gint_idx = [];
			end
        end
    end
    methods (Access = private)
		function [g, gidx] = finalGate(obj,gidx)
            if obj.numQs == 1
                gm = obj.C1m(gidx);
                gm_ = gm{1};
                for ii = 2:numel(gm)
                    gm_ = gm{ii}*gm_;
                end
                for ii = 1:24
                    mi = obj.C1m{ii}*gm_;
                    if abs(mi(1,2)) + abs(mi(2,1)) < 0.001 &&...
                            (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.001 ||...
                            abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.001)
                        break;
                    end
                    if ii == 24
                        error('final gate not found error.');
                    end
                end
                g = sqc.measure.randBenchMarking.generate1Qgates(obj.C1{ii},obj.qubits{1});   
            elseif obj.numQs == 2
                gm = obj.C2m(gidx);
                gm_ = gm{1};
                for ii = 2:numel(gm)
                    gm_ = gm{ii}*gm_;
                end
                for ii = 1:11520
                    mi = obj.C2m{ii}*gm_;   
                    if abs(abs(mi(1,1)) + abs(mi(2,2)) + abs(mi(3,3)) + abs(mi(4,4)) - 4) < 0.0001 &&...
                            (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.0001 ||...
                            abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.0001) &&...
                            (abs(angle(mi(1,1)) - angle(mi(3,3))) < 0.0001 ||...
                            abs(abs(angle(mi(1,1)) - angle(mi(3,3)))- 2*pi) < 0.0001) &&...
                            (abs(angle(mi(1,1)) - angle(mi(4,4))) < 0.0001 ||...
                            abs(abs(angle(mi(1,1)) - angle(mi(4,4)))- 2*pi) < 0.0001)
                        break;
                    end
                    if ii == 11520
                        error('final gate not found error.');
                    end
                end
                g = sqc.measure.randBenchMarking.generate2Qgates(...
                    obj.C2{ii},obj.qubits{1},obj.qubits{2});
            end
            gidx = ii;
        end
    end
    methods(Static = true)
        function g = generate1Qgates(gn,q)
            % g = feval(str2func(['@(q)sqc.op.physical.gate.',gn{1},'(q)']),q);
            g = sqc.op.physical.operator.empty;
            for ii = 1:numel(gn)
                % g = g*feval(str2func(['@(q)sqc.op.physical.gate.',gn{ii},'(q)']),q);
                g = g.noCopyPlus(feval(str2func(['@(q)sqc.op.physical.gate.',gn{ii},'(q)']),q));
            end
        end
        function [g] = generate2Qgates(gn,q1,q2)
            g = [];
            for ii = 1:numel(gn) %
                if ~iscell(gn{ii})
                    % temp
                    % CZ, the only two qubit gate is supported
                    g_ = feval(str2func(['@(q1,q2)sqc.op.physical.gate.',gn{ii},'(q1,q2)']),q1,q2);
                else
                    g_ = sqc.measure.randBenchMarking.generate1Qgates(gn{ii}{1},q1);
                    g_ = g_.*sqc.measure.randBenchMarking.generate1Qgates(gn{ii}{2},q2);
                end
       
                if isempty(g)
                    g = g_;
                else
%                     g = g*g_;
                    g = g.noCopyTimes(g_);
                end

            end
        end
        function gates = C1Gates()
            persistent C1;
            if isempty(C1)
                C1 = {{'I'},{'X'},{'Y'},{'Y','X'},...
                            {'X2p','Y2p'},{'X2p','Y2m'},{'X2m','Y2p'},{'X2m','Y2m'},...
                            {'Y2p','X2p'},{'Y2p','X2m'},{'Y2m','X2p'},{'Y2m','X2m'},...
                            {'X2p'},{'X2m'},{'Y2p'},{'Y2m'},...
                            {'X2m','Y2p','X2p'},{'X2m','Y2m','X2p'},...
                            {'X','Y2p'},{'X','Y2m'},{'Y','X2p'},{'Y','X2m'},...
                            {'X2p','Y2p','X2p'},{'X2m','Y2p','X2m'}};
            end
            % numC1Gates = 24;
            gates = C1;
        end
        function gm = C1matrix()
            persistent C1;
            if isempty(C1)
                I = [1,0;0,1];
                X = [0,1;1,0];
                Y = [0,-1i;1i,0];

                X2p = expm(-1j*(pi/2)*X/2);
                X2m = expm(-1j*(-pi/2)*X/2);

                Y2p = expm(-1j*(pi/2)*Y/2);
                Y2m = expm(-1j*(-pi/2)*Y/2);

                C1 = {I, X, Y, X*Y,...
                        Y2p*X2p, Y2m*X2p, Y2p*X2m, Y2m*X2m,...
                        X2p*Y2p, X2m*Y2p, X2p*Y2m, X2m*Y2m,...
                        X2p, X2m, Y2p, Y2m,...
                        X2p*Y2p*X2m, X2p*Y2m*X2m,...
                        Y2p*X, Y2m*X, X2p*Y, X2m*Y,...
                        X2p*Y2p*X2p, X2m*Y2p*X2m};
            end
            gm = C1;
        end
        function gates = C2Gates()
            persistent C2;
            persistent s1Gates;
            persistent s1X2pGates;
            persistent s1Y2pGates;
            if isempty(C2)
                C2 = cell(1,11520);
                C1 = sqc.measure.randBenchMarking.C1Gates();
                numC1Gates = 24;
                if isempty(s1Gates)
                    s1Gates = {{'I'},{'Y2p','X2p'},{'X2m','Y2m'}};
                end
                numS1Gates = 3;
                if isempty(s1X2pGates)
                    s1X2pGates = {{'X2p'},{'X2p','Y2p','X2p'},{'Y2m'}};
                end
                numS1X2pGates = 3;
                if isempty(s1Y2pGates)
                    s1Y2pGates = {{'Y2p'},{'Y','X2p'},{'X2m','Y2m','X2p'}};
                end
                numS1Y2pGates = 3;

                n = 1;
                for ii = 1:numC1Gates
                    for jj = 1:numC1Gates
                        C2{n} = {{C1{ii},C1{jj}}};
                        n = n+1;
                    end
                end
                NC1C1 = n-1;
                
                for ii = 1:NC1C1
                    for jj = 1:numS1Gates
                        for kk = 1:numS1Y2pGates
                            if n == 4035
                                C2{n} = {'CZ'};
                            else
                                C2{n} = {C2{ii}{1},'CZ',{s1Y2pGates{kk},s1Gates{jj}}};
                            end
                            n = n +1;
                        end
                    end
                end
                
                for ii = 1:NC1C1
                    for jj = 1:numS1Y2pGates
                        for kk = 1:numS1X2pGates
                            C2{n} = {C2{ii}{1}, 'CZ', {{'X2m'},{'Y2p'}}, 'CZ', {s1X2pGates{kk},s1Y2pGates{jj}}};
                            n = n +1;
                        end
                    end
                end
                
                for ii = 1:NC1C1
                    C2{n} = {C2{ii}{1}, 'CZ', {{'Y2p'},{'Y2m'}}, 'CZ', {{'Y2m'},{'Y2p'}}, 'CZ', {{'Y2p'},{'I'}}};
                    n = n +1;
                end
                
            end
            gates = C2;
        end
        function gm = C2matrix()
            % 0 cz: 576
            % 1 cz: 5184
            % 2 cz: 5184
            % 3 cz: 576
            persistent C2;
            if isempty(C2)
                C1 = sqc.measure.randBenchMarking.C1matrix();
                
                I = [1,0;0,1];
                X = [0,1;1,0];
                Y = [0,-1i;1i,0];

                X2p = expm(-1j*(pi/2)*X/2);
                X2m = expm(-1j*(-pi/2)*X/2);

                Y2p = expm(-1j*(pi/2)*Y/2);
                Y2m = expm(-1j*(-pi/2)*Y/2);
                
                S1 = {I, X2p*Y2p, Y2m*X2m};
                S1x2p = {X2p, X2p*Y2p*X2p, Y2m};
                S1y2p = {Y2p, X2p*Y, X2p*Y2m*X2m};
                
                numC1Gates = 24;
                numS1Gates = 3;
                numS1x2pGates = 3;
                numS1y2pGates = 3;
                
                C2 = cell(1,11520);
                n = 1;
                for ii = 1:numC1Gates
                    for jj = 1:numC1Gates
                        C2{n} = kron(C1{ii},C1{jj});
                        n = n+1;
                    end
                end
                NC1C1 = n-1;
                
                CZ = [1,0,0,0;
                      0,1,0,0;
                      0,0,1,0;
                      0,0,0,-1];
                  
                for ii = 1:NC1C1
                    for jj = 1:numS1Gates
                        for kk = 1:numS1y2pGates
                            C2{n} = kron(S1y2p{kk},S1{jj})*CZ*C2{ii};
                            n = n +1;
                        end
                    end
                end

                for ii = 1:NC1C1
                    for jj = 1:numS1y2pGates
                        for kk = 1:numS1x2pGates
                            C2{n} = kron(S1x2p{kk},S1y2p{jj})*CZ*kron(X2m,Y2p)*CZ*C2{ii};
                            n = n +1;
                        end
                    end
                end

                for ii = 1:NC1C1
                    C2{n} = kron(Y2p,[1,0;0,1])*CZ*kron(Y2m,Y2p)*CZ*kron(Y2p,Y2m)*CZ*C2{ii};
                    n = n +1;
                end
                numC2Gates = 11520;
                assert(numC2Gates == n-1);  
            end
            gm = C2;
        end
    end
end
