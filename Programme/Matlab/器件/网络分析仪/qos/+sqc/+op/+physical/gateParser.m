classdef gateParser
    % parse quantum circuit as gate name matrix:
    % qubits = {'q1','q2','q3'};
    % gateMat = {'Y2p','Y2m','I';
    %             'CZ','CZ','I';
    %             'I','Y2p','I';
    %             'I','I','Y2m';
    %             'I','CZ','CZ';
    %             'I','I','Y2p'};
    % p = gateParser.parse(qubits,gateMat);
    % p.Run; % creates a 3-Q GHZ state

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods (Static  = true)
        function gateMat = shiftConcurrentCZ(gateMat)
            matSz = size(gateMat);
            for ii = 1:matSz(1)
                jj = 1;
                CZCount = 0;
                while jj <= matSz(2)
                    if isempty(gateMat{ii,jj}) || strcmp(gateMat{ii,jj},'I') ||...
                         ~strcmp(gateMat{ii,jj},'CZ')   
                        jj = jj+1;
                        continue;
                    end
                    CZCount = CZCount + 1;
                    if CZCount > 1
                        gateMat = [gateMat(1:ii,:);gateMat(ii,:);gateMat(ii+1:end,:)];
                        gateMat(ii,jj:end) = {'I'};
                        gateMat(ii+1,1:jj-1) = {'I'};
                        gateMat = sqc.op.physical.gateParser.shiftConcurrentCZ(gateMat);
                        return;
                    end
                    jj = jj +2;
                end
            end
        end
        function g = parse(qubits,gateMat,noConcurrentCZ)
            if nargin < 3
                noConcurrentCZ = false;
            end
            if noConcurrentCZ
                gateMat = sqc.op.physical.gateParser.shiftConcurrentCZ(gateMat);
            end
            if ~iscell(qubits)
                qubits = {qubits};
            end
            numQs = numel(qubits);
            matSz = size(gateMat);
            assert(numQs == matSz(2),'lenght of the second dimmension of gateMat not equal to the number of qubits');
            for ii = 1:numQs
                if ischar(qubits{ii})
                    qubits{ii} = sqc.util.qName2Obj(qubits{ii});
				end
            end
            supportedGates = sqc.op.physical.gateParser.supportedGates();
            g = sqc.op.physical.gate.ZArbPhase(qubits{1},0);
            for ii = 1:matSz(1)
                g_ = [];
                jj = 1;
                while jj <= numQs
                    if isempty(gateMat{ii,jj}) || strcmp(gateMat{ii,jj},'I')
                        jj = jj+1;
                        continue;
                    end
                    if strcmp(gateMat{ii,jj},'CZ')
                        if jj == numQs || ~strcmp(gateMat{ii,jj+1},'CZ')
                            error('invalid gateMat: at least one CZ without a neibouring CZ');
                        end
                        try
                            g__ = sqc.op.physical.gate.CZ(qubits{jj},qubits{jj+1});
                        catch
                            g__ = sqc.op.physical.gate.CZ(qubits{jj+1},qubits{jj});
                        end
                        jj = jj + 1;
                    else
						parts = strsplit(gateMat{ii,jj},'(');
						if ~ismember(parts{1},supportedGates)
                            error(['unsupported gate: ', gateMat{ii,jj}]);
						elseif length(parts) > 2
							error(['illegal gate format: ', gateMat{ii,jj}]);
						end
						if length(parts) > 1 % with parameters
							if ~strcmp(parts{2}(end),')') || length(parts{2}) == 1
								error(['illegal gate format: ', gateMat{ii,jj}]);
                            end
							pParts = strsplit(parts{2}(1:end-1),',');
							numParams = numel(pParts);
							if numParams > 2
								error(['illegal gate format: ', gateMat{ii,jj}]);
							elseif numParams == 1
								param1 = str2double(pParts{1});
								g__ = feval(str2func(['@(q,p)sqc.op.physical.gate.',parts{1},'(q,p)']),qubits{jj},param1);
							else
								param1 = str2double(pParts{1});
								param2 = str2double(pParts{2});
								g__ = feval(str2func(['@(q,p1,p2)sqc.op.physical.gate.',parts{1},'(q,p1,p2)']),qubits{jj},param1,param2);
							end
%                             if startInd == 1 && endInd == strLn
%                                 [startInd, endInd] = regexp(gateMat{ii,jj},'\(.+\)');
%                                 if isempty(startInd)
%                                     error(['unsupported gate: ', gateMat{ii,jj}]);
%                                 else
%                                     zphase = str2double(gateMat{ii,jj}(startInd+1:endInd-1));
%                                     g__ = feval(str2func('@(q,p)sqc.op.physical.op.Z_arbPhase(q,p)'),qubits{jj},zphase);
%                                 end
%                             else
%                                 error(['unsupported gate: ', gateMat{ii,jj}]);
%                             end
                        else
                            g__ = feval(str2func(['@(q)sqc.op.physical.gate.',parts{1},'(q)']),qubits{jj});
                        end
                    end
                    if isempty(g_)
                        g_ = g__;
                    else
                        g_ = g_.*g__;
                    end
                    jj = jj + 1;
                end
                if ~isempty(g_)
                    g = g*g_;
                end
            end
        end
        function gates = supportedGates()
            gates = {'I','H',...
                'X','X2p','X2m',...
                'Y','Y2p','Y2m',...
				'Rx','Ry','Rz','Rxy',...
                'Z','Z2p','Z2m','Z4p','Z4m','S','Sd','T','Td',...
                'CZ'
                };
        end
        function g = parseLogical(gateMat)
            % note qubit ordering: |q1,q2,...,qn> different from qubit
            % ordering convention taken elsewhere
            
            gateMat = flipud(gateMat);
            I = [1,0;0,1];
            X = [0,1;1,0];
            Y = [0,-1i;1i,0];
            Z = [1,0;0,-1];
            X2p = [1, -1i;...
                -1i   1]*sqrt(2)/2;
            X2m = [1, 1i;...
                1i, 1]*sqrt(2)/2;
            Y2p =[1  -1;
                  1   1]*sqrt(2)/2;
            Y2m =[1  1;
                  -1   1]*sqrt(2)/2;

            Z2p = [1,0;0,1i];
            S = [1,0;0,1i];
            Z2m = [1,0;0,1i];
            Sd = [1,0;0,-1i];
            
            T = [1,0;0,(1+1i)*sqrt(2)/2];
            Td = [1,0;0,(1-1i)*sqrt(2)/2];
            
            function m = Rx(theta)
                a = theta/2;
                m = [cos(a),-1j*sin(a);-1j*sin(a),cos(a)];
            end
            function m = Ry(theta)
                a = theta/2;
                m = [cos(a),-sin(a);sin(a),cos(a)];
            end
            function m = Rz(theta)
                m = [1,0;0,exp(1j*theta)];
            end
            
            function m = Rxy(phi,theta)
                a = theta/2;
                m = cos(a)*I - 1j*sin(a)*(cos(phi)*X+sin(phi)*Y);
            end

            H = [1,1;1,-1]/sqrt(2);

            CNOT = [1,0,0,0;0,1,0,0;0,0,0,1;0,0,1,0];
            CZ = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,-1];
            
            matSz = size(gateMat);
            numQs = matSz(2);
            supportedGates = sqc.op.physical.gateParser.supportedGates();
            g = [];
            for ii = 1:matSz(1)
                jj = 1;
                g_ = [];
                while jj <= numQs
                    if isempty(gateMat{ii,jj}) || strcmp(gateMat{ii,jj},'I')
                        g__ = I;
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                        jj = jj + 1;
                        continue;
                    end
                    supportedGates = sqc.op.physical.gateParser.supportedGates();
                    if strcmp(gateMat{ii,jj},'CZ')
                        if jj == numQs || ~strcmp(gateMat{ii,jj+1},'CZ')
                            error('invalid gateMat: at least one CZ without a neibouring CZ');
                        end
                        g__ = CZ;
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                        jj = jj + 1;
                    else
                        switch gateMat{ii,jj}
                            case 'X'
                                g__ = X;
                            case 'X2p'
                                g__ = X2p;
                            case 'X2m'
                                g__ = X2m;
                            case 'Y'
                                g__ = Y;
                            case 'Y2p'
                                g__ = Y2p;
                            case 'Y2m'
                                g__ = Y2m;
                            case 'Z'
                                g__ = Z;
                            case 'Z2p'
                                g__ = Z2p;
                            case 'Z2m'
                                g__ = Z2m;
                            case 'H'
                                g__ = H;
                            case 'CZ'
                                g__ = CZ;
                            otherwise
                                parts = strsplit(gateMat{ii,jj},'(');
                                if length(parts) == 1 || ~ismember(parts{1},supportedGates)
                                    error(['unsupported gate: ', gateMat{ii,jj}]);
                                elseif length(parts) > 2 || ~strcmp(parts{2}(end),')') || length(parts{2}) == 1
                                    error(['illegal gate format: ', gateMat{ii,jj}]);
                                end
                                pParts = strsplit(parts{2}(1:end-1),',');
                                numParams = numel(pParts);
                                if numParams > 2
                                    error(['illegal gate format: ', gateMat{ii,jj}]);
                                elseif numParams == 1
                                    param1 = str2double(pParts{1});
                                    switch parts{1}
                                        case 'Rx'
                                            g__ = Rx(param1);
                                        case 'Ry'
                                            g__ = Ry(param1);
                                        case 'Rz'
                                            g__ = Rz(param1);
                                        otherwise
                                            error(['unsupported gate: ', gateMat{ii,jj}]);
                                    end
                                else
                                    param1 = str2double(pParts{1});
                                    param2 = str2double(pParts{2});
                                    switch parts{1}
                                        case 'Rxy'
                                            g__ = Rxy(param1,param2);
                                        otherwise
                                            error(['unsupported gate: ', gateMat{ii,jj}]);
                                    end
                                end
                        end
                        if jj == 1
                            g_ = g__;
                        else
                            g_ = kron(g_,g__);
                        end
                    end
                    jj = jj + 1;
                end
                if ii == 1
                    g = g_;
                else
                    g = g*g_;
                end
            end
        end
        function p = parseLogicalProb(gateMat)
            % GHZ sate example
%             gateMat = {'Y2p','Y2m','I',  'I',  'I';
%             'CZ','CZ',  'I',  'I',  'I';
%             'I','Y2p','Y2m',  'I',  'I';
%             'I','CZ',  'CZ',  'I', 'I';
%             'I','I',  'Y2p','Y2m', 'I';
%             'I','I',  'CZ',  'CZ', 'I';
%             'I','I',  'I',  'Y2p','Y2m';
%             'I','I',  'I',   'CZ','CZ';
%             'I','I',  'I',    'I','Y2p'};
%             p = sqc.op.physical.gateParser.parseLogicalProb(gateMat);
%             figure();bar(p);

            g = sqc.op.physical.gateParser.parseLogical(gateMat);
            v = zeros(2^size(gateMat,2),1);
            v(1) = 1;
            f = (g*v).';
            p = real(f).^2+imag(f).^2;
        end
    end
    
end