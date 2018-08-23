classdef looper_ < handle
    % looper_ of arrays or generators
    % example:
	% >>lo = looper_({[1,2,3,4],{'a','b'}});
	% >>ai = lo()
	%	ai = {1,'a'}
	% >>ai = lo()
	%	ai = {1,'b'}
	% >>ai = lo()
	%	ai = {2,'a'}
	% ...

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	properties (SetAccess = private)
		isDone
	end
	properties(SetAccess = private, GetAccess = private)
		generators
		numGenerators
		gidx
		stepidx
        currentElements
    end
	methods
		function obj = looper_(arrays)
			% arrays: cell array of generators or arrays
			obj.numGenerators = numel(arrays);
			for ii = 1:obj.numGenerators
				if ~isa(arrays{ii},'qes.util.generator')
					arrays{ii} = qes.util.generator(arrays{ii});
				end
				if arrays{ii}.numElements == 0
					throw(MException('qes_util_looper_:emptyGenerator',...
						'empty generators are not allowed.'));
				end
            end
			obj.generators = arrays;
			obj.gidx = 1;
            obj.stepidx = zeros(1,obj.numGenerators);
            obj.currentElements = cell(1,obj.numGenerators);
			obj.isDone = false;
		end
	end
	methods(Access = private)
		function vals = next(obj)
			while obj.gidx > 0
				if obj.generators{obj.gidx}.isDone
					obj.generators{obj.gidx}.Reset();
% 					obj.stepidx(obj.gidx) = obj.generators{obj.gidx}.nextIdx;
					obj.gidx = obj.gidx - 1;
					continue;
				end
% 				obj.stepidx(obj.gidx) =  obj.generators{obj.gidx}.nextIdx;
				obj.currentElements{obj.gidx} = obj.generators{obj.gidx}();
				if obj.gidx < obj.numGenerators
					obj.gidx = obj.gidx + 1;
					continue;
                end
                break;
            end
            if obj.gidx == 0
				obj.isDone = true;
                vals = [];
            else
                vals = obj.currentElements;
            end
		end
	end
	methods (Hidden = true)
		function gs = getGenerators(lpr)
			gs = lpr.generators;
		end
		function nl = plus(lpr1,lpr2)
			gs2 = lpr2.getGenerators();
			ngs2 = length(gs2);
			gArray2 = {};
			for ii = 1:ngs2
				gArray2{end+1} = gs2{ii}.copy();
			end
			nl = qes.util.looper_([lpr1.generators,gArray2]);
		end
		function varargout = subsref(obj,S)
			varargout = cell(1,nargout);
			switch S(1).type
				case '.'
					if numel(S) == 1
						if nargout
							varargout{:} = obj.(S(1).subs);
						else
							obj.(S(1).subs);
						end
					else
						switch S(2).type
							case '()'
								if nargout
									if numel(S) == 2
										varargout{:} = obj.(S(1).subs)(S(2).subs{:});
									else
										varargout{:} = subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
									end
								else
									if numel(S) == 2
										obj.(S(1).subs)(S(2).subs{:});
									else
										subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
									end
								end
							case '{}' 
								if numel(S) == 2
									varargout{:} = obj.(S(1).subs){S(2).subs{:}};
								else
									varargout{:} = subsref(obj.(S(1).subs){S(2).subs{:}},S(3:end));
								end
						end
					end
				case '()'
					if numel(S(1).subs) == 0
						varargout{1} = obj.next();
					else
						error('unrecognized function signiture.');
					end
			end
		end
	end

end