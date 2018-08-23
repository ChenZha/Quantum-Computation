function runCallbacks(self)
%             Run the chain of callbacks once a result is available.
%             This consists of a simple loop over all of the callbacks, calling each
%             with the current result and making the current result equal to the
%             return value (or raised exception) of that call.
%             If L{_runningCallbacks} is true, this loop won't run at all, since
%             it is already running above us on the call stack.  If C{self.paused} is
%             true, the loop also won't run, because that's what it means to be
%             paused.
%             The loop will terminate before processing all of the callbacks if a
%             L{Deferred} without a result is encountered.
%             If a L{Deferred} I{with} a result is encountered, that result is taken
%             and the loop proceeds.
%             @note: The implementation is complicated slightly by the fact that
%                 chaining (associating two L{Deferred}s with each other such that one
%                 will wait for the result of the other, as happens when a Deferred is
%                 returned from a callback on another L{Deferred}) is supported
%                 iteratively rather than recursively, to avoid running out of stack
%                 frames when processing long chains.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

            if self.runningCallbacks_
                % Don't recursively run callbacks
                return;
            end

            % Keep track of all the Deferreds encountered while propagating results
            % up a chain.  The way a Deferred gets onto this stack is by having
            % added its _continuation() to the callbacks list of a second Deferred
            % and then that second Deferred being fired.  ie, if ever had _chainedTo
            % set to something other than None, you might end up on this stack.
            chain = self;
            while ~isempty(chain)
                current = chain(end);
                if current.paused
                    % This Deferred isn't going to produce a result at all.  All the
                    % Deferreds up the chain waiting on it will just have to...
                    % wait.
                    return;
                end
                finished = true;
                current.chainedTo_ = [];
                while ~isempty(current.callbacks_)
                    item = current.callbacks_{1};
                    current.callbacks_(1) = [];
                    if isa(current.result,'mtwisted.Failure')
                        callbackfcn = item{2};
                    else
                        callbackfcn = item{1};
                    end
                    if isempty(callbackfcn)
                        continue;
                    end
                    % Avoid recursion if we can.
                    if isa(callbackfcn,'mtwisted.defer.CONTINUE')
                        % Give the waiting Deferred our current result and then
                        % forget about that result ourselves.
                        chainee = callbackfcn.d;
                        chainee.result = current.result;
                        current.result = [];
                        chainee.paused = chainee.paused - 1;
                        chain(end+1) = chainee;
                        % Delay cleaning this Deferred and popping it from the chain
                        % until after we've dealt with chainee.
                        finished = false;
                        break;
                    end
                    try
                        current.runningCallbacks_ = true;
                        current.result = callbackfcn(current.result);
                        if isa(current.result,'mtwisted.defer.Deferred') && current.result == current
                            error('Callback returned the Deferred it was attached to; this breaks the callback chain');
                        end
                    catch ME
                        % Including full frame information in the Failure is quite
                        % expensive, so we avoid it.
                        current.result = mtwisted.Failure(ME);
                    end
                    current.runningCallbacks_ = false;
                    if isa(current.result,'mtwisted.defer.Deferred')
                        % The result is another Deferred.  If it has a result,
                        % we can take it and keep going.
                        resultResult = current.result.result;
                        if isa(resultResult,'mtwisted.defer.NO_RESULT') || isa(resultResult, 'mtwisted.defer.Deferred') || current.result.paused
                            % Nope, it didn't.  Pause and chain.
                            current.pause();
                            current.chainedTo_ = current.result;
                            % Note: current.result has no result, so it's not
                            % running its callbacks right now.  Therefore we can
                            % append to the callbacks list directly instead of
                            % using addCallbacks.
                            continue_maker = mtwisted.defer.CONTINUE(current);
                            current.result.callbacks_{end+1} = {continue_maker,continue_maker};
                            break;
                        else
                            % Yep, it did. Steal it.
                            current.result.result = [];
                            current.result = resultResult;
                        end
                    end
                end
%                 if finished % to be implemented in the future
%                     % As much of the callback chain - perhaps all of it - as can be
%                     % processed right now has been.  The current Deferred is waiting on
%                     % another Deferred or for more callbacks.  Before finishing with it,
%                     % make sure its _debugInfo is in the proper state.
%                     if isa(current.result, 'mtwisted.Failure')
%                         % Stash the Failure in the _debugInfo for unhandled error
%                         % reporting.
%                         current.result.cleanFailure();
%                     end
%                 end

                    % This Deferred is done, pop it from the chain and move back up
                    % to the Deferred which supplied us with our result.
                chain(1) = [];
            end
        end