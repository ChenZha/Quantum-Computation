classdef QState
    % quantum state, Z basis, basis state mapping:
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
	% usage:
	% qsobj = QState('0.55|1000>+0.86603|0101>');
    % qsobj = QState([0,1,i,0]);
	% outstate = U*instate; here U is QOperator class object(a quantum gate),
    % instate, outstate are QState class objects(quantum states)
    % normalization is not neccessary, QState will do it
    % qsobj.PlotReal(); qsobj.PlotImag(); plots the real/imaginary part of
    % qsobj's density matrix
    % qsobj.DMatrix() returns the density matrix
    % mulplication (*):
    % |q2>|q1> <=> q2*q1

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        v % the quantum state as a vector in basis {|00...00>, |00...01>,...,|11...11>}
        s % the quantum state as a human readable string 'a1|00...00>+a2|00...01>+...+an|11...11>'
    end
    methods
        function obj = QState(strorv)
            if ischar(strorv)
                str = strorv;
                str = regexprep(str,'[^-ij\d.\|>+\(\)]','');
                [sidx_,~] = regexp(str,'\|\d+>');
                [sidx,eidx] = regexp(str,'\|[01]+>');
                if isempty(sidx_) || numel(sidx_) ~= numel(sidx)
                    error('Illegal state string.');
                end
                if ~unique(sidx-eidx) || eidx(1)-sidx(1) < 2
                    error('Illegal state string.');
                end
                N = length(sidx);
                coef = NaN*ones(1,N);
                stidx = NaN*ones(1,N);
                DDD = 1;
                for ii = 1:N
                    if ii == 1
                        coefstr = str(1:sidx(ii)-1);
                    else
                        if str(eidx(ii-1)+1)~= '+' && str(eidx(ii-1)+1)~= '-'
                            error('Illegal state string.');
                        end
                        coefstr = str(eidx(ii-1)+1:sidx(ii)-1);
                    end
                    basissatestr = str(sidx(ii)+1:eidx(ii)-1);
                    if ii == 1
                        DDD = length(basissatestr);
                    elseif length(basissatestr) ~= DDD
                        error('Illegal state string.');
                    end
                    [idxs,idxe] = regexp(coefstr,'\(.*\)');
                    if ~isempty(idxs)
                        if coefstr(1) == '-'
                            coefstr([1;idxs(:);idxe(:)])=[];
                            if isempty(coefstr)
                                coefstr = '1';
                            else
                                coefstr = num2str(-str2double(coefstr));
                            end
                        else
                            coefstr([1;idxs(:);idxe(:)])=[];
                        end
                    end
                    if length(coefstr) == 1
                        if coefstr == '+'
                            coefstr = '1';
                        elseif coefstr == '-'
                            coefstr = '-1';
                        end
                    end
                    if isempty(coefstr)
                        coef(ii) = 1;
                    else
                        coef(ii) = str2double(coefstr);
                        if isnan(coef(ii))
                            error('Illegal state string.');
                        end
                    end
                    stidx(ii) = bin2dec(basissatestr)+1;
                end
                obj.v =  zeros(2^DDD,1);
                for ii = 1:numel(coef)
                    obj.v(stidx(ii)) = obj.v(stidx(ii)) + coef(ii);
                end
                obj.v = obj.v/norm(obj.v);
            elseif isnumeric(strorv)
                sz = size(strorv);
                if numel(sz) ~= 2 || all(sz) > 1
                    error('Invalid input');
                end
                DDD = log(numel(strorv))/log(2);
                if round(DDD) ~= DDD
                    error('Input is not a valid qubit state vector.');
                end
                obj.v = strorv/norm(strorv);
            else
                error('Invalid input');
            end
            zerostate = char(48*ones(1,DDD));
            statestr = [];
            for ii = 1:length(obj.v)
                if abs(obj.v(ii)) > 0
                    basissate = zerostate;
                    str = dec2bin(ii-1);
                    basissate(DDD-length(str)+1:end) = str;
                    if isreal(obj.v(ii))
                        if obj.v(ii) >=0
                            statestr = [statestr,'+',num2str(obj.v(ii)),'|',basissate,'>'];
                        else
                            statestr = [statestr,'-',num2str(-obj.v(ii)),'|',basissate,'>'];
                        end
                    elseif real(obj.v(ii)) == 0
                        if imag(obj.v(ii)) >=0
                            statestr = [statestr,'+',num2str(imag(obj.v(ii))),'i|',basissate,'>'];
                        else
                            statestr = [statestr,'-',num2str(-imag(obj.v(ii))),'i|',basissate,'>'];
                        end
                    elseif real(obj.v(ii)) > 0
                        statestr = [statestr,'+(',num2str(obj.v(ii)),')|',basissate,'>'];
                    elseif real(obj.v(ii)) < 0 && imag(obj.v(ii)) < 0
                        statestr = [statestr,'-(',num2str(-obj.v(ii)),')|',basissate,'>'];
                    else
                        statestr = [statestr,'+(',num2str(obj.v(ii)),')|',basissate,'>'];
                    end
                end
            end
            if statestr(1) == '+'
                statestr = statestr(2:end); 
            end
            idx = strfind(statestr,'|');
            idx = idx(1);
            if statestr(1) == '-' && statestr(2) == '1' && idx == 3
                statestr(2) = [];
            elseif idx == 2 && statestr(1) == '1'
                statestr(1) = [];
            end
            obj.s = statestr;
        end
        function W = mtimes(U,V) % implement * as Kronecker tensor product
            if isa(V,'sqc.op.logical.QState')
                W = sqc.op.logical.QState(kron(U.v,V.v));
            else
                error('V not a QState');
            end
        end
        function W = DMatrix(obj)
            % convert quantum state(QState) to density matrix
            % output is QOperator class object
            W = QOperator(kron(obj.v',obj.v));
        end
        function PlotReal(obj,ax,FaceAlpha)
            if nargin == 1 || ~ishghandle(axes) || isempty(ax)
                ax = [];
            end
            if nargin < 3
                FaceAlpha= 1;
            end
            W = DMatrix(obj);
            W.PlotReal(ax,FaceAlpha);
        end
        function PlotImag(obj,ax,FaceAlpha)
            if nargin == 1 || ~ishghandle(axes) || isempty(ax)
                ax = [];
            end
            if nargin < 3
                FaceAlpha= 1;
            end
            W = DMatrix(obj);
            W.PlotImag(ax,FaceAlpha);
        end
    end
end