function new_f = inlineCallbacks(f)
%     inlineCallbacks helps you write L{Deferred}-using code that looks like a
%     regular sequential function. For example::
%         @inlineCallbacks
%         def thingummy():
%             thing = yield makeSomeRequestResultingInDeferred()
%             print(thing)  # the result! hoorj!
%     When you call anything that results in a L{Deferred}, you can simply yield it;
%     your generator will automatically be resumed when the Deferred's result is
%     available. The generator will be sent the result of the L{Deferred} with the
%     'send' method on generators, or if the result was a failure, 'throw'.
%     Things that are not L{Deferred}s may also be yielded, and your generator
%     will be resumed with the same object sent back. This means C{yield}
%     performs an operation roughly equivalent to L{maybeDeferred}.
%     Your inlineCallbacks-enabled generator will return a L{Deferred} object, which
%     will result in the return value of the generator (or will fail with a
%     failure object if your generator raises an unhandled exception). Note that
%     you can't use C{return result} to return a value; use C{returnValue(result)}
%     instead. Falling off the end of the generator, or simply using C{return}
%     will cause the L{Deferred} to have a result of L{None}.
%     Be aware that L{returnValue} will not accept a L{Deferred} as a parameter.
%     If you believe the thing you'd like to return could be a L{Deferred}, do
%     this::
%         result = yield result
%         returnValue(result)
%     The L{Deferred} returned from your deferred generator may errback if your
%     generator raised an exception::
%         @inlineCallbacks
%         def thingummy():
%             thing = yield makeSomeRequestResultingInDeferred()
%             if thing == 'I love Twisted':
%                 # will become the result of the Deferred
%                 returnValue('TWISTED IS GREAT!')
%             else:
%                 # will trigger an errback
%                 raise Exception('DESTROY ALL LIFE')
%     If you are using Python 3.3 or later, it is possible to use the C{return}
%     statement instead of L{returnValue}::
%         @inlineCallbacks
%         def loadData(url):
%             response = yield makeRequest(url)
%             return json.loads(response)

    function d = unwindGenerator(varargin)
        try
            gen = f(varargin);
        catch _DefGen_Return
            error('inlineCallbacks requires %s to produce a generator; instead caught returnValue being used in a non-generator', f);
        end
        if ~isa(gen, 'mtwisted.Generator')
            error('inlineCallbacks requires %s to produce a generator; instead got %r', f, gen);
        end
        d = inlineCallbacks_(None, gen, mtwisted.defer.Deferred());
    end
    new_f =  @unwindGenerator;
end

function deferred = inlineCallbacks_(result, g, deferred)
%     See L{inlineCallbacks}.
%     This function is complicated by the need to prevent unbounded recursion
%     arising from repeatedly yielding immediately ready deferreds.  This while
%     loop and the waiting variable solve that by manually unfolding the
%     recursion.

    waiting = [true,... % waiting for result?
               mtwisted.None]; % result

    while 1
        try
            % Send the last result back as the result of the yield expression.
            if isa(result, 'mtwisted.Failure')
                result = result.throwExceptionIntoGenerator(g); %%%%%%%%%%%%%%%%%%
            else
                result = g.send(result);
            end
        catch ME
            switch ME.identifier
                case 'mtwisted:StopIteration'
                    % fell off the end, or "return" statement
                    deferred.callback(ME.value);
                    return;
                case 'mtwisted:DefGen_Return'
                    % returnValue() was called; time to give a result to the original
                    % Deferred.  First though, let's try to identify the potentially
                    % confusing situation which results when returnValue() is
                    % accidentally invoked from a different function, one that wasn't
                    % decorated with @inlineCallbacks
                    % The traceback starts in this frame (the one for
                    % _inlineCallbacks); the next one down should be the application
                    % code.
                    appCodeTrace = exc_info();
                    appCodeTrace = appCodeTrace(2).tb_next;
                    if isFailure
%                         If we invoked this generator frame by throwing an exception
%                         into it, then throwExceptionIntoGenerator will consume an
%                         additional stack frame itself, so we need to skip that too.
                        appCodeTrace = appCodeTrace.tb_next;
                    end
%                     Now that we've identified the frame being exited by the
%                     exception, let's figure out if returnValue was called from it
%                     directly.  returnValue itself consumes a stack frame, so the
%                     application code will have a tb_next, but it will *not* have a
%                     second tb_next.
                    if appCodeTrace.tb_next.tb_next
%                         If returnValue was invoked non-local to the frame which it is
%                         exiting, identify the frame that ultimately invoked
%                         returnValue so that we can warn the user, as this behavior is
%                         confusing.
                        ultimateTrace = appCodeTrace;
                        while ultimateTrace.tb_next.tb_next
                            ultimateTrace = ultimateTrace.tb_next;
                        end
                        filename = ultimateTrace.tb_frame.f_code.co_filename;
                        lineno = ultimateTrace.tb_lineno;
                        warnings.warn_explicit(...
                            'returnValue() in %s causing %s to exit: returnValue should only be invoked by functions decorated with inlineCallbacks',...
                                ultimateTrace.tb_frame.f_code.co_name, appCodeTrace.tb_frame.f_code.co_name),DeprecationWarning, filename, lineno);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    end
                    deferred.callback(ME.value)
                    return;
                otherwise
                    deferred.errback()
                    return;
            end
        end
        if isa(result, 'mtwisted.defer.Deferred')
            % a deferred was yielded, get the result.
            result.addBoth(@gotResult);
            if waiting(0)
                % Haven't called back yet, set flag so that we get reinvoked
                % and return from the loop
                waiting(0) = false;
                return;
            end
            result = waiting(1);
            % Reset waiting to initial values for next loop.  gotResult uses
            % waiting, but this isn't a problem because gotResult is only
            % executed once, and if it hasn't been executed yet, the return
            % branch above would have been taken.
            waiting(0) = true;
            waiting(1) = mtwisted.defer.None();
        end
    end
    function gotResult(r)
        if waiting(0)
            waiting(0) = false;
            waiting(1) = r;
        else
            inlineCallbacks_(r, g, deferred);
        end
    end
end

        