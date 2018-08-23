classdef pushover < handle
    % pushover sends push notifications to IOS or Android devices.
    % Notifications are sent from an application(any kind of program) to
    % a client(an app installed on an IOS or Android device).
    % To start, follow these steps:
    % step 1, install the app pushover on the device to receive push
    % notifications and register to get a user key, pushover is available
    % on Apple App Store and Google Play.
    % step2, obtain an api key for you specific application from
    % https://pushover.net.
    % step3, now you are ready to use pushover, for example:
    % notifier = qes.util.pushover;
    % notifier.apptoken = api key; % char
    % notifier.receiver = user key; % char
    % notifier.title = 'A Test';
    % notifier.message = 'Hi there, ''pushover'' is now working.';
    % notifier.Push;
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % API token/key, sender of notifications
        apptoken
        % user key or group key, receiver or a group of receivers of the
        % notifications.
        receiver
        % device of the receiver, if not specified, the notification is
        % pushed to all enabled devices or receivers.
        % character string, eg, 'My_iPhone'. optional
        device@char
        title % title of notification, optional
        message % notification message 
        % Optional settings
        % notification alert sound, must be one of the availablesounds:
%         'pushover'(default),'bike','bugle','cashregister','classical',...
%         'cosmic','falling','gamelan','incoming','intermission',...
%         'magic','mechanical','pianobar','siren','spacealarm','tugboat',...
%         'alien',...% (long)
%         'climb',...% (long)
%         'persistent ',...% (long)
%         'echo',...% (long)
%         'updown',... % (long)
%         'none'  % (silent)
        alertsound@char = 'pushover';
        url@char % a url can be added to the message, optional
        url_title@char % optional, optional
        % priority, send as -2 to generate no notification/alert, -1 to
        % always send as a quiet notification, 1 to display as 
        % high-priority and bypass the user's quiet hours, or 2 to also
        % require confirmation from the user
        % default is 0, a regular notification
        priority
        % resend every 'retryinterval' seconds in case or emergency notificaion(priority = 2)
        retryinterval = 60; 
        % stop resend after 'expiretime' seconds in case or emergency notificaion(priority = 2)
        expiretime = 3600;
        % time stamp, by default, time of the notification being receivered
        % by the server is used as timestamp, yet the user can specify any
        % time can be as timestamp if needed.
        % matlab numeric time, datenum('2015-10-04
        % 19:37:00'), now etc. optional
        timestamp
    end
    properties (Constant = true)
        apiurl='https://api.pushover.net/1/messages.json'
        email='api.pushover.net'
        soundurl='https://api.pushover.net/1/sounds.json'
    end
    properties (SetAccess = private)
        availablesounds =...
            {'pushover','bike','bugle','cashregister','classical',...
            'cosmic','falling','gamelan','incoming','intermission',...
            'magic','mechanical','pianobar','siren','spacealarm','tugboat',...
            'alien',...% (long)
            'climb',...% (long)
            'persistent ',...% (long)
            'echo',...% (long)
            'updown',... % (long)
            'none'};  % (silent)
    end
    methods
        function set.apptoken(obj,val)
            if isempty(val)
                return;
            end
            if ~ischar(val) && length(val) ~= 30
                error('pushover:SetError','apptoken should a cell array of char string of 30 characters.');
            end
            obj.apptoken = val;
        end
        function set.receiver(obj,val)
            if isempty(val)
                return;
            end
            if ~ischar(val) && length(val) ~= 30
                error('pushover:SetError','receiver should a cell array of char string of 30 characters.');
            end
            obj.receiver = val;
        end
        function set.title(obj,val)
            if isempty(val)
                return;
            end
            if ~ischar(val)
                error('pushover:SetError','title should a char string.');
            end
            obj.title = val(1:min(length(val),32));
        end
        function set.message(obj,val)
            if isempty(val)
                return;
            end
            if ~ischar(val)
                error('pushover:SetError','mesage should a char string.');
            end
            obj.message = val(1:min(length(val),512));
        end
        function set.alertsound(obj,val)
            if any(strcmpi(val, obj.availablesounds(:)))
                obj.alertsound = val;
            else
                error('pushover:SetError','unrecognized sound, sound can only be one of availablesounds.');
            end
        end
        function set.priority(obj,val)
            switch val
                case {'2',2}  % bypass quiet hours, need confirmation
                    obj.priority='2';
                case {'1',1} % bypass quiet hours
                    obj.priority='1';
                case {'0',0} % normal
                    obj.priority='0';
                case {'-1',-1} % display alert but silent
                    obj.priority='-1';
                case {'-2',-2} % no display and silent(notification can only be seem within the app)
                    obj.priority='-2';
                otherwise
                    error('pushover:SetError','unsupported priority option.');
            end
        end
        function set.retryinterval(obj,val)
            if isempty(val)
                return;
            end
            if ~isreal(val) || val < 30
                error('pushover:SetError','retryinterval should be a positive integer >= 30.');
            end
            obj.retryinterval = round(val);
        end
        function set.expiretime(obj,val)
            if isempty(val)
                return;
            end
            if ~isreal(val) || val < 30 || val > 86400
                error('pushover:SetError','expiretime should be a positive integer >= 30 and <= 86400.');
            end
            obj.expiretime = round(val);
        end
        function set.timestamp(obj,val)
            if isempty(val)
                obj.timestamp=[];
                return;
            end
            if ischar(val)
                val = datenum(val);
            end
            if val <= 0
                error('pushover:SetError','illegal timestamp value.');
            end
            % Convert Matlab serial date to Unix timestamp.
            temp=int32(floor(86400*(val-datenum('01-Jan-1970'))));
            obj.timestamp=temp;
        end
        function [varargout] = Push(obj)
            if isempty(obj.apptoken)
                error('pushover:Failed','apptoken not set.');
            end
            if isempty(obj.receiver)
                error('pushover:Failed','receiver not set.');
            end
            Post = obj.PostContents();
            [str,status]=urlread(obj.apiurl,'post',Post,'Timeout',10);
%             if status==0
%                 warning('pushover:Failed',['Post failed: ', str]);
%             end
            switch nargout
                case 1
                    varargout{1}=str;
                case 2
                    varargout{1}=str;
                    varargout{2}=status;
                otherwise
            end
        end
        function GetSounds(obj)
            if isempty(obj.apptoken)
                return;
            end
            [JStr,status]=urlread([obj.soundurl,'?token=',obj.apptoken],'Timeout',10);
            if status==1
                data=pushover.ParseJson(JStr);
                if isempty(data{1})
                    return;
                end
                sound=fieldnames(data{1}.sounds);
                soundFull=struct2cell(data{1}.sounds);
                obj.availablesounds=[soundFull sound]';
            end
        end
    end
    methods (Access = private)
        function Post = PostContents(obj)
            Post = {'token',obj.apptoken,'user',obj.receiver};
            if ~isempty(obj.device)
                Post = [Post,{'device',obj.device}];
            end
            if ~isempty(obj.message)
                Post = [Post,{'message',obj.message}];
            else
                error('pushover:Failed','message is empty.');
            end
            if ~isempty(obj.title)
                Post = [Post,{'title',obj.title}];
            end
            if ~isempty(obj.title)
                Post = [Post,{'sound',obj.alertsound}];
            end
            if ~isempty(obj.url)
                Post = [Post,{'url',obj.url}];
                if ~isempty(obj.url_title)
                    Post = [Post,{'url_title',obj.url_title}];
                end
            end
            if ~isempty(obj.priority)
                Post = [Post,{'priority',obj.priority}];
                if strcmp(obj.priority,'2')
                    if ~isempty(obj.retryinterval) && ~isempty(obj.expiretime)
                        Post = [Post,{'retry',num2str(obj.retryinterval,'%0.0f')},...
                            {'expire',num2str(obj.expiretime,'%0.0f')}];
                    end
                end
            end
            if ~isempty(obj.timestamp)
                Post = [Post,{'timestamp',num2str(obj.timestamp,'%0.0f')}];
            end
        end
    end
    methods (Static = true)
        [data, json] = ParseJson(json)
    end
end