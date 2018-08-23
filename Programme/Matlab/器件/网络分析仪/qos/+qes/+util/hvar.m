classdef hvar < handle
    % hvar wraps numeric primitives to handle class objects for case when
    % one needs to pass a numeric variable by reference

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        val
    end
    methods
        function obj = hvar(a)
            if nargin == 0
                a = [];
            end
            obj.val = a;
        end
        function obj = plus(a,b)
            obj = hvar(a.val+b.val);
        end
        function obj = minus(a,b)
            obj = hvar(a.val-b.val);
        end
        function obj = uminus(a)
            obj = hvar(-a.val);
        end
        function obj = uplus(a)
            obj = hvar(a.val);
        end
        function obj = times(a,b)
            obj = hvar(a.val.*b.val);
        end
        function obj = mtimes(a,b)
            obj = hvar(a.val*b.val);
        end
        function obj = rdivide(a,b)
            obj = hvar(a.val./b.val);
        end
        function obj = ldivide(a,b)
            obj = hvar(a.val.\b.val);
        end
        function obj = mrdivide(a,b)
            obj = hvar(a.val/b.val);
        end
        function obj = mldivide(a,b)
            obj = hvar(a.val\b.val);
        end
        function obj = power(a,b)
            obj = hvar(a.val.^b.val);
        end
        function obj = mpower(a,b)
            obj = hvar(a.val^b.val);
        end
        function bl = lt(a,b)
            bl = a.val < b.val;
        end
        function bl = gt(a,b)
            bl = a.val > b.val;
        end
        function bl = le(a,b)
            bl = a.val <= b.val;
        end
        function bl = ge(a,b)
            bl = a.val >= b.val;
        end
        function bl = ne(a,b)
            bl = a.val ~= b.val;
        end
        function bl = eq(a,b)
            bl = a.val == b.val;
        end
        function bl = and(a,b)
            bl = a.val & b.val;
        end
        function bl = or(a,b)
            bl = a.val | b.val;
        end
        function bl = not(a)
            bl = ~a.val;
        end
        function obj = ctranspose(a)
            obj = hvar((a.val)');
        end
        function obj = transpose(a)
            obj = hvar((a.val).');
        end
        function obj = horzcat(a,b)
            obj = hvar([a.val,b.val]);
        end
        function obj = vercat(a,b)
            obj = hvar([a.val;b.val]);
        end
        function display(a)
            disp('a =');
            if ~isempty(a.val)
                disp(num2str(a.val));
            else
                disp('[]');
            end
        end
    end
end