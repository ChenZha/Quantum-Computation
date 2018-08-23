classdef operator
    % quantum operator base class, Z basis, basis state mapping:
    % matrix row/column idx from left to right and top to bottom, 
    % qubit labeled in fashion:|qN,...,q2,q1>
    % ==================================================================
    % row/column idx	<=>	Ket vector	<=>     numeric vector
    % 1                 <=>	|00...00>	<=>     [1;0;0;...;0;0]
    % 2                 <=> |00...01>	<=>     [0;1;0;...;0;0]
    % 3                 <=> |00...10>	<=>     [0;0;1;...;0;0]
    % ...
    % 2^N               <=>	|11...11>	<=>     [0;0;...;0;0;1]
    % ==================================================================
    % qgobj.PlotReal(); qgobj.PlotImag(); plots the real/imaginary part
    %
    % about mutiplication('*' and '.*'):
    % 1, QOperatorObj*S£ºis the application of a quantum gates/operators
    %   QOperatorObj on quantum state S, the result is a quantum state.
    % 2, QOperatorObj2*QOperatorObj1: successive application of two quantum
    %   operators: apply QOperatorObj1 first and then apply QOperatorObj2,
    %   the result is a new quantum operator
    % 3, QOperatorObj2.*QOperatorObj1: tensor product of two quantum
    %   operators QOperatorObj1 (of qubit |q1>) and QOperatorObj2 (of qubit
    %   |q2>), the result is a new quantum gate/operator U of |q2,q1>
    % 
    % U2U1|q2>|q1> <=> (U2.*U1)*(q2*q1) or (U2*q2)*(U1*q1), here U1(U2)
    % are quantum operators (operator (sub)class objects) on q1(q2), 
    % q1 and q2 are quantum states (QState (sub)class objects).

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        dim
    end
    properties (SetAccess = protected)
        m
    end
    methods
        function obj = operator(m_)
            sz = size(m_);
			dim_ = log(sz(1))/log(2);
			assert(numel(sz) == 2 & sz(1) == sz(2) &...
				round(dim_) == dim_ & dim_ >= 1);
			obj.m = m_;
            obj.dim = dim_;
%             if nargin > 0
%                 obj.m = m;
%             else
%                 obj.m = [1,0;0,1];
%             end
        end
% 		function set.m(obj,val)
% 			sz = size(val);
% 			dim_ = log(sz(1))/log(2);
% 			assert(numel(sz) == 2 & sz(1) == sz(2) &...
% 				round(dim_) == dim_ & dim_ >= 1);
% 			obj.m = val;
% 		end
        function W = SpanOver(U,V)
            % span double/multiple qubit gate over single qubit gate/gate array V
            % CX = sqc.op.logical.gate.CX;
            % CIX = CX.SpanOver(I) % the firt qubit is control the third
            %                      % qubit is target, the cnot spans over 
            %                      % the second qubit, witch is idle(I)
            % CXHX = CX.SpanOver({X,H}) % the firt qubit is control the
            %                      % fourth qubit is target, the cnot spans 
            %                      % over the second and the third qubit, 
            %                      % witch performs single qubit gates X
            %                      % and H respectively.
            % the resulting  CXHX is a gate on |CX_control_bit, X_bit, H_bit, CX_target_bit>
            % CXHX = CX.SpanOver({X,H}) is equivalent to:
            % CXX = CX.SpanOver(X); CXHX = CXX.SpanOver(H);
            
            if ~iscell(V)
                V = {V};
            end
            W = U;
            for jj = 1:numel(V)
                assert(V{jj}.dim == 1,'V not a one bit operator cell array.');
                W = W.*V{jj};
                for ii = 1:4:size(W.m,1)
                    W.m([ii+1,ii+2],:) = W.m([ii+2,ii+1],:);
                    W.m(:,[ii+1,ii+2]) = W.m(:,[ii+2,ii+1]);
                end
            end
        end
        function W = Permute(U,order)
            % permute order of qubits
            if U.dim == 1
                W = copy(U);
                return;
            end
            m_ = U.m;
            error('todo...'); % permute
        end
        function bol  = isHermitian(U)
            bol = U' == U;
        end
        function bol  = isUnitary(U)
            bol = U'*U == sqc.op.logical.operator([1,0;0,1]);
        end
        function W = exp(U)
            W = sqc.op.logical.operator(expm(U.m));
        end
        function W = log(U)
            W = sqc.op.logical.operator(logm(U.m));
        end
        function W = sqrt(U)
            W = sqc.op.logical.operator(sqrtm(U.m));
        end
        function W = inv(U)  % implements inverse gate
            W = sqc.op.logical.operator(inv(U.m));
        end
    end
    methods (Hidden = true)
        function W = mtimes(U,V)  % implement regular matrix, scalar multiplication and gate operation on a quantum state
            % W is also a operator object if both U an V are operator objects,
            % otherwise W is a matrix or a scalar
            if isa(U,'sqc.op.logical.operator') && isa(V,'sqc.op.logical.operator')
                W = sqc.op.logical.operator(U.m*V.m);
            elseif isa(U,'sqc.op.logical.operator') && isa(V,'sqc.qs.state')
                W = sqc.qs.state(U.m*V.v);
            elseif isa(U,'sqc.op.logical.operator')
                if length(V) == size(U.m)
                    W = sqc.qs.state(U.m*V(:));
                elseif isscalar(V)
                    W = sqc.op.logical.operator(U.m*V);
                else
                    error('invalid input.');
                end
            elseif isa(V,'sqc.op.logical.operator')
                if length(U) == size(V.m)
                    W = sqc.qs.state(U(:)'*V.m);
                elseif isscalar(U)
                    W = sqc.op.logical.operator(U*V.m);
                else
                    error('invalid input.');
                end
            end
        end
        function W = times(U,V)  % implements .* as Kronecker tensor product
            assert(isa(U,'sqc.op.logical.operator') && isa(V,'sqc.op.logical.operator'),'at least one of U,V is not a sqc.op.logical.operator class object.');
            W = sqc.op.logical.operator(kron(U.m,V.m));
        end
         function W = mrdivide(U, V)
            if isa(U,'sqc.op.logical.operator') && isa(V,'sqc.op.logical.operator')
                W = sqc.op.logical.operator(mrdivide(U.m,V.m));
            elseif isa(U,'sqc.op.logical.operator')
                W = sqc.op.logical.operator((1/V)*U.m);
            elseif isa(V,'sqc.op.logical.operator')
                W = sqc.op.logical.operator((1/U)*V.m);
            end
        end
		function W = plus(U,V)
            assert(isa(U,'sqc.op.logical.operator') && isa(V,'sqc.op.logical.operator'),'at least one of U,V is not a sqc.op.logical.operator class object.');
			W = sqc.op.logical.operator(U.m+V.m);
		end
		function W = uplus(U) 
			W = sqc.op.logical.operator(U.m);
		end
		function W = minus(U,V)
			assert(isa(U,'sqc.op.logical.operator') && isa(V,'sqc.op.logical.operator'),'at least one of U,V is not a sqc.op.logical.operator class object.');
			W = sqc.op.logical.operator(U.m-V.m);
		end
		function W = uminus(U) 
			W = sqc.op.logical.operator(-U.m);
        end
		function W = copy(U) 
			W = sqc.op.logical.operator(U.m);
        end
        function W = power(U,V)
           if isa(V,'sqc.op.logical.operator')
                W = sqc.op.logical.operator(mpower(U.m,V.m));
           else
               W = sqc.op.logical.operator(power(U.m,V));
           end
        end
		function W = horzcat(U,V) % implements commutator [U, V]
			W = U*V - V*U;
		end
		function W = ctranspose(U)  % implements ' as hermitian conjugate
            W = sqc.op.logical.operator((U.m)');
        end
		function bol = eq(U,V)
			bol = false;
			if ~isa(U,'sqc.op.logical.operator') ||...
				~isa(V,'sqc.op.logical.operator') ||...
				U.dim ~= V.dim
				return;
			end
			bol = all(all(U.m - V.m < 1e-6));
        end
    end
    methods (Static = true)
        function PlotReal(obj,ax,FaceAlpha)
            % plot the real part of the operator matrix
            if nargin == 1 ||  isempty(ax) || ~ishghandle(ax)
                h = figure();
                ax = axes('parent',h);
            end
            if nargin < 3
                FaceAlpha= 1;
            end
            if isa(obj.m,'sym')
                M = real(eval(obj.m));
            else
                M = real(obj.m);
            end
%             h = bar3(ax, M);
            h = bar3(ax,M);
            for k = 1:length(h)
                zdata = h(k).ZData;
                h(k).CData = zdata;
                h(k).FaceColor = 'interp';
                h(k).FaceAlpha = FaceAlpha;
                h(k).EdgeAlpha = 1;
            end
            xlabel('|x\rangle');
            ylabel('\langley|');
            zlabel('Re(\langley|U|x\rangle_{ij})');
            sz = size(M);
            switch obj.dim
                case 1
                    set(ax,'XTick',[1,2],'XTickLabel',{'|0\rangle','|1\rangle'},...
                        'YTick',[1,2],'YTickLabel',{'\langle0|','\langle1|'});
                case 2
                    set(ax,'XTick',[1,2,3,4],'XTickLabel',{'|00\rangle','|01\rangle','|10\rangle','|11\rangle'},...
                        'YTick',[1,2,3,4],'YTickLabel',{'\langle00|','\langle01|','\langle10|','\langle11|'});
                case 3
                    set(ax,'XTick',[1,2,3,4,5,6,7,8],'XTickLabel',{'|000\rangle','|001\rangle','|010\rangle','|011\rangle','|100\rangle','|101\rangle','|110\rangle','|111\rangle'},...
                        'YTick',[1,2,3,4,5,6,7,8],'YTickLabel',{'\langle000|','\langle001|','\langle010|','\langle011|','\langle100|','\langle101|','\langle110|','\langle111|'});
                otherwise
                    set(ax,'XTick',[1,sz(1)],'XTickLabel',{'|0...00\rangle','|1...11\rangle'},...
                        'YTick',[1,sz(1)],'YTickLabel',{'\langle0...00|','\langle1...11|'});
                    xlabel('|x\rangle: |0...00\rangle,|0...01\rangle,|0...10\rangle \rightarrow |1...11\rangle');
                    ylabel('\langley|: \langle1...11| \rightarrow \langle0...10|,\langle0...01|,\langle0...00|');
                    set(gcf,'Position',[20   20   1000   650]);
            end
            grid(gca,'off');
%             colormap(lbblue)
            colorbar;
%             set(ax,'CameraPosition',[-10   -10   10],'Projection','perspective');
            set(ax,'Projection','perspective');
            set(ax,'Projection','perspective','Color',get(gcf,'Color'),'YDir','reverse');
        end
        function PlotImag(obj,ax)
            % plot the imaginary part of the operator matrix
            if nargin == 1 ||  isempty(ax) || ~ishghandle(ax)
                h = figure();
                ax = axes('parent',h);
            end
            if nargin < 3
                FaceAlpha= 1;
            end
            if isa(obj.m,'sym')
                M = imag(eval(obj.m));
            else
                M = imag(obj.m);
            end
            h = bar3(ax,M);
            for k = 1:length(h)
                zdata = h(k).ZData;
                h(k).CData = zdata;
                h(k).FaceColor = 'interp';
                h(k).FaceAlpha = FaceAlpha;
                h(k).EdgeAlpha = 1;
            end
            xlabel('|x\rangle');
            ylabel('\langley|');
            zlabel('Im(\langley|U|x\rangle_{ij})');
            switch obj.dim
                case 1
                    set(ax,'XTick',[1,2],'XTickLabel',{'|0\rangle','|1\rangle'},...
                        'YTick',[1,2],'YTickLabel',{'\langle0|','\langle1|'});
                case 2
                    set(ax,'XTick',[1,2,3,4],'XTickLabel',{'|00\rangle','|01\rangle','|10\rangle','|11\rangle'},...
                        'YTick',[1,2,3,4],'YTickLabel',{'\langle00|','\langle01|','\langle10|','\langle11|'});
                case 3
                    set(ax,'XTick',[1,2,3,4,5,6,7,8],'XTickLabel',{'|000\rangle','|001\rangle','|010\rangle','|011\rangle','|100\rangle','|101\rangle','|110\rangle','|111\rangle'},...
                        'YTick',[1,2,3,4,5,6,7,8],'YTickLabel',{'\langle000|','\langle001|','\langle010|','\langle011|','\langle100|','\langle101|','\langle110|','\langle111|'});
                otherwise
                    set(ax,'XTick',[1,sz(1)],'XTickLabel',{'|0...00\rangle','|1...11\rangle'},...
                        'YTick',[1,sz(1)],'YTickLabel',{'\langle0...00|','\langle1...11|'});
                    xlabel('|x\rangle: |0...00\rangle,|0...01\rangle,|0...10\rangle \rightarrow |1...11\rangle');
                    ylabel('\langley|: \langle1...11| \rightarrow \langle0...10|,\langle0...01|,\langle0...00|');
                    set(gcf,'Position',[20   20   1000   650]);
            end
            grid(gca,'off');
%             colormap(lbblue)
            colorbar;
%             set(ax,'CameraPosition',[-10   -10   10],'Projection','perspective');
            set(ax,'Projection','perspective');
            set(ax,'Projection','perspective','Color',get(gcf,'Color'),'YDir','reverse');
        end
    end
end