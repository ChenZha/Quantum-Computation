classdef generator < handle
	% implements generator in MATLAB
	% example:
	% >>ag = generator([1,2,3,4]); % cell also ok
	% >>ai = ag()
	%	ai = 1
	% >>ai = ag()
	%	ai = 2
	% >>ai = ag()
	%	ai = 3
	% ...
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties (SetAccess = private)
		numElements
		isDone = false;
		nextIdx
	end
	properties(SetAccess = private, GetAccess = private)
		cellElements = false;
		elements
	end
	methods
		function obj = generator(elements)
			obj.numElements = numel(elements);
			if iscell(elements)
				obj.cellElements = true;
			end
			obj.elements = elements;
			obj.nextIdx = 1;
			if obj.nextIdx > obj.numElements
				obj.isDone = true;
			end
		end
		function Reset(obj)
			obj.nextIdx = 1;
            obj.isDone = false;
			if obj.nextIdx > obj.numElements
				obj.isDone = true;
			end
		end
		function g = copy(obj)
			g = qes.util.generator(obj.elements);
		end
    end
    methods (Access = private)
		function val = next(obj)
			if ~obj.isDone
				if obj.cellElements
					val = obj.elements{obj.nextIdx};
				else
					val = obj.elements(obj.nextIdx);
				end
				obj.nextIdx = obj.nextIdx + 1;
				if obj.nextIdx > obj.numElements
					obj.isDone = true;
				end
			else
				throw(MException('qes_util_generator:noMoreElements','no more elements'));
			end
        end
    end
	methods (Hidden = true)
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