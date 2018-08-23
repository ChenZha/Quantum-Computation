classdef Deferred < handle
    % a callback chain which will be called in order at some event
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        % Deffered fired or not, if not, result is not known yet, one
        % still have to wait
        called = false
        % Deffered paused or not
        paused = false
        % result of the Deferred
        result = mtwisted.defer.NO_RESULT
    end
    properties (SetAccess = private, GetAccess = private)
        callbacks_ = {}
        canceller_ = {}
        timeouttimer = [];
        timedout = false;
        cancelled = false;
        % when cancelling a uncalled deferred, the canceller will call the
        % deferred, making it called, thus when the underlying event loop
        % triggers the deferred, a already called exception will be raised,
        % to avoid this we set suppressAlreadyCalled_ flag to tell the
        % startRunCallbacks_ method not to raise this exception and return
        % directly without actually running any callbacks.
        suppressAlreadyCalled_ = false 
        runningCallbacks_ = false
        chainedTo_ = []
    end
    methods
        function self = Deferred(canceller)
%             canceller: a function handle used to stop the pending operation
%             scheduled by this Deferred when Deferred.cancel is
%             invoked. The canceller will be passed the deferred whose
%             cancelation is requested (i.e., self).

%             If a canceller is not given, or does not invoke its argument's
%             callback or errback method, Deferred.cancel will
%             invoke Deferred.errback with a CancelledError.
%             Note that if a canceller is not given, callback or
%             errback may still be invoked exactly once, even though
%             errback has been invoked already, as described
%             above.  This allows clients of code which returns a Deferred
%             to cancel it without requiring the Deferred instantiator to
%             provide any specific implementation support for cancellation.

%             canceller: a 1-argument function handle which takes a Deferred. The
%             return result is ignored.

            if nargin == 0
                canceller = @(d)d.errback(mtwisted.Failure(MException('mtwisted:Deferred:Cancelled',...
                        'deferred cancelled.')));
            end
            assert(isempty(canceller) || isa(canceller,'function_handle'));
            self.canceller_ = canceller;
        end
        function self = addCallbacks(self, callback, errback)
            % callbacks only accept one input argument, the deferred result,...
            % if other input arguents are needed, bound them to the
            % callback function
            % Add a pair of callbacks (success and error)
            assert(isempty(callback) || isa(callback,'function_handle'));
            assert( isempty(errback) || isa(errback,'function_handle'));
            self.callbacks_{end+1} = {callback,errback};
            if self.called
                self.runCallbacks();
            end
        end
        function self = addCallback(self, callback)
            % Convenience method for adding just a callback.
            self = addCallbacks(self, callback, []);
        end
        function self = addErrback(self, errback)
            % Convenience method for adding just an errback.
            self = addCallbacks(self, [], errback);
        end
        function self = addBoth(self, callback)
            % Convenience method for adding a single callable as both a callback.
            self = addCallbacks(self, callback, callback);
        end

        function self = addTimeout(self, timeout, onTimedOut)
            % cancel deferred are time timeout if stilled not been called
            % back
            if nargin < 3 || isempty(onTimedOut)
                onTimedOut = @(d)d.errback(mtwisted.Failure(MException('mtwisted:Deferred:Timedout',...
                        'deferred Timedout.')));
            end
            assert(isa(onTimedOut,'function_handle'));
            function timeItOut(~,~)
                self.timedout = true;
                stop(self.timeouttimer);
                delete(self.timeouttimer);
                self.timeouttimer = [];
                if ~self.called
                    onTimedOut(self);
                elseif isa(self.result, 'mtwisted.defer.Deferred')
                    self.result.addTimeout(0);
                end
            end
            self.timeouttimer = timer('BusyMode','queue','ErrorFcn','',...
                'ExecutionMode','singleShot','ObjectVisibility','off',...
                'StartDelay',timeout,'TimerFcn',@timeItOut);
            start(self.timeouttimer);
        end
        
        function chainDeferred(self, d)
%             Chain another L{Deferred} to this L{Deferred}.
%             This method adds callbacks to this L{Deferred} to call C{d}'s callback
%             or errback, as appropriate. It is merely a shorthand way of performing
%             the following::
%                 self.addCallbacks(d.callback, d.errback)
%             When you chain a deferred d2 to another deferred d1 with
%             d1.chainDeferred(d2), you are making d2 participate in the callback
%             chain of d1. Thus any event that fires d1 will also fire d2.
%             However, the converse is B{not} true; if d2 is fired d1 will not be
%             affected.
%             Note that unlike the case where chaining is caused by a L{Deferred}
%             being returned from a callback, it is possible to cause the call
%             stack size limit to be exceeded by chaining many L{Deferred}s
%             together with C{chainDeferred}.
%             @return: C{self}.
%             @rtype: a L{Deferred}
            d.chainedTo_ = self;
            self.addCallbacks(@d.callback, @d.errback);
        end
        
        function callback(self, result)
%             Run all success callbacks that have been added to this L{Deferred}.
%             Each callback will have its result passed as the first argument to
%             the next; this way, the callbacks act as a 'processing chain'.  If
%             the success-callback returns a L{Failure} or raises an L{Exception},
%             processing will continue on the *error* callback chain.  If a
%             callback (or errback) returns another L{Deferred}, this L{Deferred}
%             will be chained to it (and further callbacks will not run until that
%             L{Deferred} has a result).
%             An instance of L{Deferred} may only have either L{callback} or
%             L{errback} called on it, and only once.
%             @param result: The object which will be passed to the first callback
%                 added to this L{Deferred} (via L{addCallback}).
%             @raise AlreadyCalledError: If L{callback} or L{errback} has already been
%                 called on this L{Deferred}.
            if nargin > 1
                assert(~isa(result,'mtwisted.defer.Deferred'));
                self.startRunCallbacks(result);
            else
                self.startRunCallbacks();
            end
        end
        
        function errback(self, fail)
%             Run all error callbacks that have been added to this L{Deferred}.
%             Each callback will have its result passed as the first
%             argument to the next; this way, the callbacks act as a
%             'processing chain'. Also, if the error-callback returns a non-Failure
%             or doesn't raise an L{Exception}, processing will continue on the
%             *success*-callback chain.
%             If the argument that's passed to me is not a L{failure.Failure} instance,
%             it will be embedded in one. If no argument is passed, a
%             L{failure.Failure} instance will be created based on the current
%             traceback stack.
%             Passing a string as `fail' is deprecated, and will be punished with
%             a warning message.
%             An instance of L{Deferred} may only have either L{callback} or
%             L{errback} called on it, and only once.
%             @param fail: The L{Failure} object which will be passed to the first
%                 errback added to this L{Deferred} (via L{addErrback}).
%                 Alternatively, a L{Exception} instance from which a L{Failure} will
%                 be constructed (with no traceback) or L{None} to create a L{Failure}
%                 instance from the current exception state (with a traceback).
%             @raise AlreadyCalledError: If L{callback} or L{errback} has already been
%                 called on this L{Deferred}.
%             @raise NoCurrentExceptionError: If C{fail} is L{None} but there is
%                 no current exception state.
            if nargin < 2
                fail = [];
            end
            if isempty(fail)
                fail = mtwisted.Failure(MException('mtwisted:defer:Deferred:errback','errback')); 
            elseif ~isa(fail, 'mtwisted.Failure')
                fail = mtwisted.Failure(fail);
            end
            self.startRunCallbacks(fail);
        end
        
        function pause(self)
%             Stop processing on a L{Deferred} until L{unpause}() is called.
            self.paused = self.paused + 1;
        end
        function unpause(self)
%             Process all callbacks made since L{pause}() was called.
            self.paused = self.paused - 1;
            if self.paused
                return;
            end
            if self.called
                self.runCallbacks();
            end
        end
        function cancel(self)
%             Cancel this L{Deferred}.
%             If the L{Deferred} has not yet had its C{errback} or C{callback} method
%             invoked, call the canceller function provided to the constructor. If
%             that function does not invoke C{callback} or C{errback}, or if no
%             canceller function was provided, errback with L{CancelledError}.
%             If this L{Deferred} is waiting on another L{Deferred}, forward the
%             cancellation to the other L{Deferred}.
            if ~self.called
                self.cancelled = true;
                canceller = self.canceller_;
                if ~isempty(canceller)
                    canceller(self);
                else
                    % Arrange to eat the callback that will eventually be fired
                    % since there was no real canceller.
                    self.suppressAlreadyCalled_ = true;
                end
                if ~self.called
                    % There was no canceller, or the canceller didn't call
                    % callback or errback.
                    self.errback(mtwisted.Failure(MException('mtwisted:Deferred:CancelledError',...
                        'no canceller or the canceller didn''t call callback or errback')));
                end
            elseif isa(self.result, 'mtwisted.defer.Deferred')
                % Waiting for another deferred -- cancel it instead.
                self.result.cancel();
            end
        end
    end
    methods (Access = private)
        function startRunCallbacks(self, result)
            if self.cancelled || self.timedout
                self.called = true;
                self.result = result;
                return;
            end
            
            if self.called
                if self.suppressAlreadyCalled_
                    self.suppressAlreadyCalled_ = false;
                    return;
                end
                error('Deferred:AlreadyCalledError','This deferred has been called already.');
            end
            self.called = true;
            if nargin == 2
                self.result = result;
            end
            self.runCallbacks();
        end
        runCallbacks(self)
    end
%     methods(Static = true)
% 
%     end
end