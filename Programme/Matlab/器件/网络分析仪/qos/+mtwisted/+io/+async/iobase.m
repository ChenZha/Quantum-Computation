classdef (Abstract = true) iobase < handle
% async io base class

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        Timeout = 10 % seconds
        InputBufferSize = 1024*10 % bytes
        OutputBufferSize = 1024*10  % bytes
        BytesAvailableFcnMode = 'terminator'   %{'terminator'}, 'bytes';
        BytesAvailableFcnCount % bytes, only used when BytesAvailableFcnMode = 'bytes'
    end
    properties (Dependent = true)
        isopen = false
    end
    properties (SetAccess = protected, GetAccess = protected)
        backend % a icinterface object
        write_busy = false
        read_busy = false
        last_write_deferred
        last_read_deferred
    end

    methods
        function set.Timeout(obj,val)
            obj.backend.Timeout = val;
        end
        function val = get.Timeout(obj)
            val = obj.backend.Timeout;
        end
        function set.InputBufferSize(obj,val)
            obj.backend.InputBufferSize = val;
        end
        function val = get.InputBufferSize(obj)
            val = obj.backend.InputBufferSize;
        end
        function set.OutputBufferSize(obj,val)
            obj.backend.OutputBufferSize = val;
        end
        function val = get.OutputBufferSize(obj)
            val = obj.backend.OutputBufferSize;
        end
        function set.BytesAvailableFcnMode(obj,val)
            obj.backend.BytesAvailableFcnMode = val;
        end
        function val = get.BytesAvailableFcnMode(obj)
            val = obj.backend.BytesAvailableFcnMode;
        end
        function set.BytesAvailableFcnCount(obj,val)
            obj.backend.BytesAvailableFcnCount = val;
        end
        function val = get.BytesAvailableFcnCount(obj)
            val = obj.backend.BytesAvailableFcnCount;
        end

        function val = get.isopen(obj)
            val = obj.backend.Status(1) =='o';
        end
        function d = query(obj,cmd)
            % query response in text format
            disp('query called'); % debug
%             flushinput(obj.backend);
%             flushoutput(obj.backend);
            [~] = fprintf(obj,cmd);
            d = fread(obj);
            function result = cb(result)
                result = char(result);
                disp('    got result, length of result:'); % debug
                disp(length(result)); % debug
%                 flushoutput(obj.backend);
%                 flushinput(obj.backend);
            end
            d.addCallback(@cb);
            obj.last_write_deferred = d; % defer next write operation until this read operation finishes
        end
        function d = fprintf(obj,cmd)
            function result = run_next_deferred(result,d_)
                d_.callback();
            end
            function result = run_next_task(~,cmd_)
                result = obj.fprintf(cmd_);
            end
            if obj.write_busy
                d = mtwisted.defer.Deferred();
                d.addBoth(@(x)run_next_task(x,cmd));
                obj.last_write_deferred.addBoth(@(x)run_next_deferred(x,d));
            else
                d = fprintf_(obj,cmd);
%                 disp(['Cammand send: ', cmd]); % debug
            end
            obj.last_write_deferred = d;
        end
        function d = fwrite(obj, bytes)
            function result = run_next_deferred(result,d_)
                d_.callback();
            end
            function result = run_next_task(~,bytes_)
                result = obj.fwrite(bytes_);
            end
            if obj.write_busy
                d = mtwisted.defer.Deferred();
                d.addBoth(@(x)run_next_task(x,bytes));
                obj.last_write_deferred.addBoth(@(x)run_next_deferred(x,d));
            else
                d = fwrite_(obj,bytes);
            end
            obj.last_write_deferred = d;
        end
        function d = fread(obj,numbytes)
            % read numbytes bytes from input buffer
            % if numbytes not  specified, read all bytes available in
            % input buffer
            % note: fread is the fastest, if speed is a priority, use fread
            % instead of fscanf.
            if nargin < 2
                numbytes = [];
            end
            function result = run_next_deferred(result,d_)
                d_.callback();
            end
            function result = run_next_task(~,numbytes_)
                result = obj.fread(numbytes_);
            end
            if obj.read_busy
                d = mtwisted.defer.Deferred();
                d.addBoth(@(x)run_next_task(x,numbytes));
                obj.last_read_deferred.addBoth(@(x)run_next_deferred(x,d));
            else
                d = fread_(obj,numbytes);
            end
            obj.last_read_deferred = d;
        end
        function flushinput(obj)
            flushinput(obj.backend);
            obj.read_busy = false;
        end
        function flushoutput(obj)
            flushoutput(obj.backend);
            obj.write_busy = false;
        end
        function fopen(obj)
            if obj.backend.Status(1)=='c'
                fopen(obj.backend);
            end
        end
        function fclose(obj)
            if obj.backend.Status(1)=='o'
                fclose(obj.backend);
            end
        end
        function delete(obj)
            fclose(obj.backend);
        end
    end
    methods (Access = protected, Hidden = true)
        function d = fprintf_(obj,cmd)
            % sends out text string
            % note: fwrite is the fastest, if speed is a priority, consider
            % using binary based commands and use fwrite instead of fprintf
            % to transfer
            disp('==== fprintf_ called'); % debug
            obj.write_busy = true;
            d = mtwisted.defer.Deferred();
            function cb1(~,~)
                obj.backend.OutputEmptyFcn = '';
                obj.write_busy = false;
                disp('==== fprintf_ executed'); % debug
                d.callback();
            end
            obj.backend.OutputEmptyFcn = @cb1;
            try
%                 fprintf(igetfield(obj.backend, 'jobject'), cmd, 1);
                fprintf(obj.backend, cmd, 'async');
            catch ME
%                 newExc = MException('mtwisted:io:asyncio:backendFprintf:opfailed', ME.message);
                d.errback(mtwisted.Failure(ME));
            end
            function cb2(d_)
                obj.read_busy = false;
                flushoutput(obj);
                d_.errback(mtwisted.Failure(MException('mtwisted:io:async:iobase:opTimedout','fprintf timed out.')));
            end
            if ~d.called
                d.addTimeout(obj.Timeout,@cb2);
            end
        end
        function d = fwrite_(obj, bytes)
            % sends out bytes 
            % note: fwrite is the fastest, if speed is a priority, use
            % fwrite instead of fprintf.
            obj.write_busy = true;
            d = mtwisted.defer.Deferred();
            function cb1(~,~)
                obj.backend.OutputEmptyFcn = '';
                obj.write_busy = false;
                d.callback();
            end
            obj.backend.OutputEmptyFcn = @cb1;
            try
%                fwrite(igetfield(obj.backend, 'jobject'), bytes, length(bytes), 5, 1, 0);
                fwrite(obj.backend, bytes, 1);
            catch ME
%                 newExc = MException('mtwisted:io:asyncio:backendFwrite:opfailed', ME.message);
                d.errback(mtwisted.Failure(ME));
            end
            function cb2(d_)
                obj.read_busy = false;
                flushinput(obj);
                d_.errback(mtwisted.Failure(MException('mtwisted:io:async:iobase:opTimedout','fwrite timed out.')));
            end
            if ~d.called
                d.addTimeout(obj.Timeout,@cb2);
            end
        end
        function d = fread_(obj,numbytes)
            % read numbytes bytes from input buffer
            % if numbytes not  specified, read all bytes available in
            % input buffer
            % note: fread is the fastest, if speed is a priority, use fread
            % instead of fscanf.
            disp('@@@@ fread_ called');  % debug
            obj.read_busy = true;
            d = mtwisted.defer.Deferred();
            function cb1(~,~)
%                 disp('@@@@ fread_ executed'); % debug
%                 disp('    BytesAvailable:');  % debug
%                 disp(obj.backend.BytesAvailable);  % debug
                obj.backend.BytesAvailableFcn = '';
                if isempty(numbytes)
                    try 
                        data = fread(obj.backend,obj.backend.BytesAvailable);
    %                     out = fread(igetfield(obj.backend, 'jobject'), obj.backend.BytesAvailable, 5, 0);
    %                     data = out(1);
                        d.callback(data);
                    catch ME
                        d.errback(mtwisted.Failure(ME));
                    end
                elseif numbytes <= obj.backend.BytesAvailable
                    try
                        data = fread(obj.backend,numbytes);
    %                     out = fread(igetfield(obj.backend, 'jobject'), numbytes, 5, 0);
    %                     data = out(1);
                        d.callback(data);
                    catch ME
                        d.errback(mtwisted.Failure(ME));
                    end
                else
                    ME = MException('mtwisted:io:asyncio:backendFread:opfailed',...
                        'number of bytes to read exceeding number of bytes available in input buffer.');
                    d.errback(mtwisted.Failure(ME));
                end
                obj.read_busy = false;
            end
            obj.backend.BytesAvailableFcn = @cb1;
            try
%                 readasync(igetfield(obj.backend, 'jobject'), numbytes);
                readasync(obj.backend);
            catch ME
%                 newExc = MException('mtwisted:io:asyncio:backendReadasync:opfailed', ME.message);
                d.errback(mtwisted.Failure(ME));
            end
            function cb2(d_)
                obj.read_busy = false;
                flushinput(obj);
                d_.errback(mtwisted.Failure(MException('mtwisted:io:async:iobase:opTimedout','fread timed out.')));
            end
            if ~d.called
                d.addTimeout(obj.Timeout,@cb2);
            end
        end
        % the counter part of fprintf, fscanf does not have async mode as
        % for as I know, keep a syncronized fscanf for private usage
        function d = fscanf(obj)
            d = fscanf(obj.backend);
        end
    end
end