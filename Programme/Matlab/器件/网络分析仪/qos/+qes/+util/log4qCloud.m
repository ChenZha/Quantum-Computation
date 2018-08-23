classdef log4qCloud < qes.util.log4m
    properties (SetAccess = private, GetAccess = private)
        tag
        funcName
        message
        timeStamp
        
        notifier
        
        logCount = 0;
        maxLogPerFile = 2e4;
    end
    methods (Static)
        function obj = getLogger( logPath )
            %GETLOGGER Returns instance unique logger object.
            %   PARAMS:
            %       logPath - Relative or absolute path to desired logfile.
            %   OUTPUT:
            %       obj - Reference to signular logger object.
            %
            
            if(nargin == 0)
                logPath = 'log4qos.log';
            elseif(nargin > 1)
                error('getLogger only accepts one parameter input');
            end
            
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = qes.util.log4qCloud(logPath);
            end
            obj = localObj;
        end
    end
    methods(Access = private)
        function self = log4qCloud(fullpath_passed)
            self = self@qes.util.log4m(fullpath_passed);
        end
    end
    methods
        function setNotifier(self, apiKey, receiver)
            self.notifier = qes.util.pushover();
            self.notifier.apptoken = apiKey;
            self.notifier.receiver = receiver;
        end
        function notify(self)
            if ~isempty(self.notifier) && ~isempty(self.tag) && ~isempty(self.message)
                self.notifier.title = self.tag;
                self.notifier.message = self.message;
                switch self.tag
                    case {'FATAL'}
                        self.notifier.priority = 2;
                    case {'ERROR'}
                        self.notifier.priority = 1;
                    case {'WARN'}
                        self.notifier.priority = 0;
                    otherwise
                        self.notifier.priority = -1;
                end
                try
                    self.notifier.Push();
                catch ME
                    warning('QOS:pushover:sendNotificationFailure',ME.message);
                end
            else
                warning('QOS:pushover','notifier not set.');
            end
        end
        function trace(self, funcName, message)
            trace@qes.util.log4m(self, funcName, message)
            self.tag = 'TRACE';
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        
        function debug(self, funcName, message)
            self.tag = 'DEBUG';
            debug@qes.util.log4m(self, funcName, message)
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        
 
        function info(self, funcName, message)
            self.tag = 'INFO';
            info@qes.util.log4m(self, funcName, message)
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        

        function warn(self, funcName, message)
            self.tag = 'WARN';
            warn@qes.util.log4m(self, funcName, message)
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        

        function error(self, funcName, message)
            self.tag = 'ERROR';
            error@qes.util.log4m(self, funcName, message)
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        

        function fatal(self, funcName, message)
            self.tag = 'FATAL';
            fatal@qes.util.log4m(self, funcName, message)
            self.funcName = funcName;
            self.message = message;
            self.timeStamp = datestr(now,'yyyy-mm-dd HH:MM:SS,FFF');
            self.logCount = self.logCount + 1;
            if self.logCount > self.maxLogPerFile
                self.newLogFile();
            end
        end
        
    end
end