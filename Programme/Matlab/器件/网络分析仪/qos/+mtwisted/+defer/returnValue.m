function returnValue(val)
%     Return val from a L{inlineCallbacks} generator.
%     Note: this is currently implemented by raising an exception
%     derived from L{BaseException}.  You might want to change any
%     'except:' clauses to an 'except Exception:' clause so as not to
%     catch this exception.
%     Also: while this function currently will work when called from
%     within arbitrary functions called from within the generator, do
%     not rely upon this behavior.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    mtwisted.defer.DefGen_Return(val);
end