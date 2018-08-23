classdef (Abstract = true)icinterface_compatible < handle
% a MATLAB icinterface class compatible
% this file
% usage:
% interfaceobj = qes.hwdriver.sync.ustcadda('1.0.0.200',4001);
% fopen(interfaceobj);
% ret = query(interfaceobj,'*IDN?')
% fprintf(interfaceobj,'*IDN?')
% ret = fscanf(interfaceobj)
% interfaceobj.WriteWave(...)
% interfaceobj.StartStop(...)
% ... ...
% fclose(interfaceobj)


% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (SetAccess = private)
        timeout = 10 % seconds
		Timeout
    end
    properties (SetAccess = private)
        Status = 'closed' % to be compatible with MATLAB icinterface class
        isopen = false;
    end
    properties (SetAccess = private, GetAccess = private)
        ibuffer % input buffer
        obuffer % output buffer
        % errorstatus = false
    end
    properties (SetAccess = protected, GetAccess = private)
        cmdList
        ansList
        fcnList % cell array of callables
    end

    methods
		function set(obj,properName,val)
            obj.(properName) = val;
        end
        function set.timeout(obj,val)
            if ~(val > 0)
               error('icinterface_compatible:InvalidValue','time out should be a positive value.'); 
            end
            obj.timeout = val;
        end

        function flushinput(obj)
            obj.ibuffer = [];
        end
        function flushoutput(obj)
            obj.obuffer = [];
        end
        function response = query(obj,cmd)
            obj.HandleCmd(cmd);
            response = obj.ibuffer;
            obj.ibuffer = [];
        end
        function fprintf(obj,cmd)
            obj.HandleCmd(cmd);
        end
        function response = fscanf(obj)
            tic
            while 1
                if ~isempty(obj.ibuffer)
                    response = obj.ibuffer;
                    obj.ibuffer = [];
                    return;
                elseif toc >= obj.timeout
                    error('icinterface_compatible:TimeoutError','Timeout.');
                end
            end
        end
        function fopen(obj)
            obj.Open();
        end
        function fclose(obj)
            obj.Close();
        end
        function close(obj)
            obj.Close();
        end
        function Open(obj)
            if ~obj.isopen
                obj.Status = 'open';
                obj.isopen = true;
            end
        end
        function Close(obj)
            if obj.isopen
                obj.Status = 'closed';
                obj.isopen = false;
            end
        end
        function delete(obj)
            obj.Close();
        end
    end
    methods (Access = private)
        function HandleCmd(obj, cmd)
            cmd = upper(cmd);
            [~, idx] = ismember(cmd,obj.cmdList);
            if isempty(idx)
                throw(MException('icinterface_compatible:UnrecognizedCmd',...
                    sprintf('Unrecognized command: %s', cmd)));
            end
            obj.ibuffer = obj.ansList{idx};
            if ~isempty(obj.fcnList{idx})
                feval(obj.fcnList{idx},obj);
            end
        end
    end
end