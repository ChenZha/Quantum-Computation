classdef logclass < handle

    
    properties 
        model
        logs
    end
        
    methods(Static)
        function func=replace(replacestr)
            persistent refunc;
            if nargin
                if ~strcmp(replacestr,'getreplacefunc')
                    eval(['refunc=@' replacestr ';'])  
                end
            end
            if isempty(refunc)
                error('replace empty')
            end
            func = @qes.logclass;
            if nargin
                if strcmp(replacestr,'getreplacefunc')
                    func = refunc;
                end
            end
        end
        
        function newobj=runlogs(logs)
            [~,n]=size(logs);
            timestr=logs{1,1};
            tlate=timestr2second(timestr);
            newobj=[];
            for index = 1:n
                timestr=logs{1,index};
                tnow=timestr2second(timestr);
                pause(tnow-tlate);
                tlate=tnow;
                if strcmp(logs{2,index},'create')
                    if isempty(logs{4,index})
                        newobj=qes.logclass();
                    else
                        newobj=qes.logclass(logs{4,index});
                    end
                else
                    s=logs{4,index};
                    if strcmp(logs{2,index},'get')
                        sref=subsref(newobj,s);
                    elseif strcmp(logs{2,index},'set')
                        newobj=subsasgn(newobj,s,logs{3,index});
                    end
                end
            end
            
            function fsecond=timestr2second(timestr)
                s0=str2double(timestr(16:end));
                m0=str2double(timestr(13:14));
                h0=str2double(timestr(10:11));
                d0=str2double(timestr(7:8));
                % mm0=str2double(timestr(5:6));
                % y0=str2double(timestr(1:4));
                fsecond=((d0*24+h0)*60+m0)*60+s0;
            end
        end     
    end
    
    methods
        function obj=logclass(varargin)
            func=qes.logclass.replace('getreplacefunc');          
            if nargin
                obj.logs={obj.time();'create';char(func);varargin};
                obj.model=func(varargin{:});
            else
                obj.logs={obj.time();'create';char(func)};
                obj.model=func();
            end
        end
        
 
        function timestr=time(obj) %#ok<MANU>
            timestr=datestr(now,'yyyymmdd_HH:MM:SS.FFF');
        end

        function disp(obj)
            disp(obj.model)
        end
        
        function obj=subsasgn(obj,s,val)
            obj.logs(1,end+1)={obj.time()};
            obj.logs(2,end)={'set'};
            obj.logs(3,end)={val};
            obj.logs(4,end)={s};
            tempindex=5;
            for i=s
                obj.logs(tempindex,end)={i.type};
                tempindex=tempindex+1;
                obj.logs(tempindex,end)={i.subs};
                tempindex=tempindex+1;
            end
            %
            obj.model=subsasgn(obj.model,s,val);
        end
        function sref=subsref(obj,s)
            if strcmp(s(1).subs,'logs')
                sref=obj.logs;
                return
            end
            if strcmp(s(1).subs,'model')
                sref=obj.model;
                return
            end
            obj.logs(1,end+1)={obj.time()};
            obj.logs(2,end)={'get'};
            obj.logs(4,end)={s};
            tempindex=5;
            for i=s
                obj.logs(tempindex,end)={i.type};
                tempindex=tempindex+1;
                obj.logs(tempindex,end)={i.subs};
                tempindex=tempindex+1;
            end
            %
            sref=[];
            try
                sref=subsref(obj.model,s);
            catch
                builtin('subsref',obj.model,s);%无返回值时会跳到这里
            end
            %
            obj.logs(3,end)={sref};
        end
    end
end
