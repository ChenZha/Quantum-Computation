classdef Failure < handle
%     A basic abstraction for an error that has occurred.
%     This is necessary because Python's built-in error mechanisms are
%     inconvenient for asynchronous communication.
%     The C{stack} and C{frame} attributes contain frames.  Each frame is a tuple
%     of (funcName, fileName, lineNumber, localsItems, globalsItems), where
%     localsItems and globalsItems are the contents of
%     C{locals().items()}/C{globals().items()} for that frame, or an empty tuple
%     if those details were not captured.
%     @ivar value: The exception instance responsible for this failure.
%     @ivar type: The exception's class.
%     @ivar stack: list of frames, innermost last, excluding C{Failure.__init__}.
%     @ivar frames: list of frames, innermost first.

% 
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        type
        value
        count
    end
    methods
        function self = Failure(exc_value,exc_type,exc_tb)
            if nargin == 0
                error('Matlab can not return the last exception except in prompt, the exception must be given');
%                 exc_value = [];
%                 exc_type = [];
%                 exc_tb = [];
            elseif nargin == 1
                exc_type = [];
                exc_tb = [];
            elseif nargin == 2
                exc_tb = [];
            end
            self.type = [];
            self.value = [];
            tb = [];
            if ischar(exc_value) && isempty(exc_type)
                error('Strings are not supported by Failure');
            end
            stackOffset = 0;
%             if isempty(exc_value)
%                 exc_value = self.findFailure_(); % not implemented
%             end
            if isempty(exc_value) % Matlab can not return the last except except in prompt, exc_value must be specified
%                 last_exc = MException.last();
%                 if isempty(last_exc)
%                     error('NoCurrentExceptionError');
%                 end
                last_exc = MException('','Matlab dose not support MException.last() except in promp.');
                self.type = last_exc.identifier;
                self.value = last_exc.message;
                tb = [];
                stackOffset = 1;
            elseif isempty(exc_type)
                if isa(exc_value, 'MException')
                    self.type = exc_value.identifier;
                else %allow arbitrary objects.
                    self.type = class(exc_value);
                end
                self.value = exc_value;
            else
                self.type = exc_type;
                self.value = exc_value;
            end
            if isa(exc_value,'mtwisted.Failure')
                self = exc_value;
                return;
            end
            if isempty(tb)
                if isempty(exc_tb)
                    tb = exc_tb;
                end
            end
            
%             frames = [];
%             self.frames = [];
%             stack = [];
%             self.stack = [];
%             
%             self.tb = tb;
            
            % more functionalities ommited

        end
        function c = get.count(self) % count is global
            c = Failure.count_();
        end
        function bol = eq(f1,f2)
            bol = false;
            if isa(f2,'mtwisted.Failure') && strcmp(f1.type,f2.type) && f1.value == f2.value
                bol = true;
            end
        end
    end
    methods (Static = true, Access = private)
        function const = count_(add)
            persistent c;
            if isempty(c)
                c = 0;
            end
            if nargin && add
                c = c + 1;
            end
            const = c;
        end
    end
end