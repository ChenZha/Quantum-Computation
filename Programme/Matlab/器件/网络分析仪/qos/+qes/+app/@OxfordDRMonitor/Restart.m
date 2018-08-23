function Restart(hObject,eventdata,obj)
    % a private method

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    persistent lastrestarttime
    if isempty(lastrestarttime)
        lastrestarttime = 0;
    end
    if now - lastrestarttime > 2/24; % 2 hours
        obj.restartcount = 0;
    end
    if obj.restartcount > 50, % timer fire 20 seconds later, that's about 15 minutes' trying.
        if ~isempty(obj.notifier)
            obj.notifier.title = [obj.fridgeobj.name,' Important!'];
            obj.notifier.message = [datestr(now,'dd mmm, HH:MM:SS'),10,'Monitor encountered some problem and stopped!'];
            obj.notifier.priority = 1;
            obj.notifier.timestamp = [];
            obj.notifier.Push();
        end
        obj.eventtime(end+1) = now;
        obj.event(end+1) = {['Alert: ', 'Monitor encountered some problem and stopped.']};
        obj.m.eventtime = obj.eventtime;
        obj.m.event = obj.event;
        sound(sounds.siren);
        start(obj.alarmobj);
        pause(10);
        stop(obj.alarmobj);
        return;
    end
    stop(obj.timerobj);
    delete(obj.timerobj);
    obj.timerobj = timer('ExecutionMode','fixedRate','BusyMode','drop',...
                'Period',obj.checkinterval,'TimerFcn',{@OxfordDRMonitor.DRRead,obj},...
                'ErrorFcn',{@OxfordDRMonitor.Restart,obj},'ObjectVisibility','off');
    % start 20 seconds later to avoid constantly calling restart in case of
    % restart also fails, which is the most possible if restart
    % immediately because the cause of timer stop only disappear after a
    % while in most cases.
    startat(obj.timerobj,now+20/3600/24); % fire timer 20 seconds later.
    obj.restartcount = obj.restartcount + 1;
end