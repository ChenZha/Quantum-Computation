function StatusChk(obj)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    persistent lastnotificationtime
    if isempty(lastnotificationtime)
        lastnotificationtime = obj.starttime - 0.003472222222222;  % first 5 min, ignore all messages
    end
    persistent lastofflinealerttime
    if isempty(lastofflinealerttime)
        lastofflinealerttime = obj.starttime - 0.003472222222222;  % first 5 min, ignore all messages
    end
    persistent lastofflineemergencytime
    if isempty(lastofflineemergencytime)
        lastofflineemergencytime = 0;
    end
    persistent lastreconnecttime
    if isempty(lastreconnecttime)
        lastreconnecttime = 0;
    end

    FridgeType = class(obj.fridgeobj);
    AlertLvl = 0;
    checkintervalindays = obj.checkinterval/86400;
    persistent lastnonnanidx
    if isempty(lastnonnanidx)
        lastnonnanidx = 1;
    end
    lastnonnanidx = find(~isnan(obj.temperature(lastnonnanidx:obj.dpoint,1)),1,'last')+lastnonnanidx-1;
    
    if isempty(lastnonnanidx) && now - obj.starttime > 0.003472222222222;  % first 5 min, ignore all messages
        if now - lastofflineemergencytime > 1/24
            AlertLvl = 2; % emergency.
            Msg = ['Dilution fridge offline since the start of the monitor!'];
            lastofflineemergencytime = now;
        end
    elseif now - obj.time(lastnonnanidx) > max(2*checkintervalindays, 10/1440) % 10 minutes
        if now - lastofflineemergencytime > 1/24
            AlertLvl = 2; % emergency.
            Msg = ['Dilution fridge offline for more than 10 minutes!'];
            lastofflineemergencytime = now;
        end
    elseif now - obj.time(lastnonnanidx) > max(2*checkintervalindays, 5/1440) % 5 minutes
        if now - lastofflinealerttime > 1/24
            AlertLvl = 1; % alert
            Msg = ['Dilution fridge offline for more than 5 minutes!'];
            lastofflinealerttime = now;
        end
    end
    
    if now - obj.time(lastnonnanidx) > max(2*checkintervalindays, 3/1440) % 3 minutes
        if now - lastreconnecttime > 3/1440 % 3 minutes
            oldinfostr = get(obj.uihandles.InfoDisp,'String');
            oldinfostr = TrimNotes(oldinfostr);
            oldinfostr = oldinfostr(:)';
            str = 'Dilution fridge offline for more than 3 minutes, trying to reconnect...';
            newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,str,10,oldinfostr];
            if length(newinfostr) > 1024;
                newinfostr(1024:end) = [];
            end
            set(obj.uihandles.InfoDisp,'String',newinfostr);
%             warning('OxfordDRMonitor:Offline',...
%                     [datestr(now,'dd mmm HH:MM:SS'),'Dilution fridge offline for more than 3 minutes, trying to reconnect...']);
            disp([datestr(now,'dd mmm HH:MM:SS'),' Dilution fridge offline for more than 3 minutes, trying to reconnect...']);
            try
                obj.fridgeobj.Reconnect();
                oldinfostr = newinfostr;
                str = 'Successful.';
                newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,str,10,oldinfostr];
                disp('Successful.');
            catch
                oldinfostr = newinfostr;
                str = 'Failed, reconnection will be tried again 3 minutes later.';
                newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,str,10,oldinfostr];
                disp( 'Failed, reconnection will be tried again a 3 minutes later.');
            end
            lastreconnecttime = now;
            if length(newinfostr) > 1024;
                newinfostr(1024:end) = [];
            end
            set(obj.uihandles.InfoDisp,'String',newinfostr);
        end
    end

    persistent lastcheckpluginexceptiontime
    if isempty(lastcheckpluginexceptiontime)
        lastcheckpluginexceptiontime = 0;
    end
    if ~AlertLvl && obj.process ~= 5 % obj.process == 5 no alert
        switch FridgeType
            case 'OxfordDR400_55084'
                try % user provided check functions are not guaranted to be bug free
                    [AlertLvl, Msg] = obj.Chk_OxfordDR400_55084();
                catch ME
                    AlertLvl = 0;
                    Msg = '';
                    if now - lastcheckpluginexceptiontime > 1/24
                        AlertLvl = 1;
                        Msg = ['Error at evaluating ''Chk_OxfordDR400_55084''',getReport(ME,'basic')];
                        lastcheckpluginexceptiontime = now;
                    end
                end
        end
    end
    if now - obj.starttime < 0.003472222222222 % first 5 min, ignore all alert messages
        AlertLvl = 0;
        Msg = '';
    end
    if AlertLvl
        if AlertLvl > 1
            Title = [obj.fridgeobj.name,' Emergency!'];
            NotifyMsg = [datestr(now,'dd mmm, HH:MM:SS'),10,Msg];
            NotifyOption = 2;
        else
            Title = [obj.fridgeobj.name,' Important!'];
            NotifyMsg = [datestr(now,'dd mmm, HH:MM:SS'),10,Msg];
            NotifyOption = 1;
        end
        Timestamp = now;
        obj.eventtime(end+1) = now;
        obj.event(end+1) = {['Alert: ', NotifyMsg]};
        obj.m.eventtime = obj.eventtime;
        obj.m.event = obj.event;
        oldinfostr = get(obj.uihandles.InfoDisp,'String');
        oldinfostr = TrimNotes(oldinfostr);
        oldinfostr = oldinfostr(:)';
        newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,Msg,10,oldinfostr];
        if length(newinfostr) > 1024
            newinfostr(1024:end) = [];
        end
        set(obj.uihandles.InfoDisp,'String',newinfostr);
    elseif now - lastnotificationtime >= obj.notifyinterval/1440
        Title = [obj.fridgeobj.name,' Report'];
        str = '=========Status========';
        switch obj.process
            case 1
                str = [str, 10, 'Idle'];
            case 2
                str = [str, 10, 'Base temperature'];
            case 3 
                str = [str, 10, 'Warmming up'];
            case 4
                str = [str, 10, 'Cooling down'];
        end
         
        str = [str, 10, '======Temperature======'];
        for ii =1:obj.numtempchnls
            if obj.temperature(obj.dpoint,ii) >= 1
                str = [str, 10, obj.tempchnlnames{ii},' = ',num2str(obj.temperature(obj.dpoint,ii),'%0.1f'),'K'];
            else
                str = [str, 10, obj.tempchnlnames{ii},' = ',num2str(1e3*obj.temperature(obj.dpoint,ii),'%0.1f'),'mK'];
            end
        end
        str = [str,10, '=====Pressure(mBar)====='];
        for ii =1:obj.npreschls
            str = [str, 10, obj.preschlnames{ii},' = ', num2str(1000*obj.pressure(obj.dpoint,ii),'%0.2e')];
        end
        str = [str,10, '=======Pulse Tube======='];
        str = [str,10, 'Cooling water inlet ', num2str(obj.ptcwit(obj.dpoint),'%0.1f'),'C'];
        str = [str,10, 'Cooling water outlet ', num2str(obj.ptcwot(obj.dpoint),'%0.1f'),'C'];
        
        NotifyOption = -2;
        if obj.dpoint > 0
            Timestamp = obj.time(obj.dpoint);
        else
            Timestamp = now;
        end
        NotifyMsg = [datestr(Timestamp,'dd mmm, HH:MM:SS'),10,str];
        
        oldinfostr = get(obj.uihandles.InfoDisp,'String');
        oldinfostr = TrimNotes(oldinfostr);
        oldinfostr = oldinfostr(:)';
        newinfostr = [datestr(obj.time(obj.dpoint,1),'dd mmm HH:MM:SS'),10,'Send report:',10,str,10,oldinfostr];
        if length(newinfostr) > 1024
            newinfostr(1024:end) = [];
        end
        set(obj.uihandles.InfoDisp,'String',newinfostr);
    else
        return;
    end
    if obj.notify && ~isempty(obj.notifier)
        obj.notifier.title = Title;
        obj.notifier.message = NotifyMsg;
        obj.notifier.priority = NotifyOption;
        obj.notifier.timestamp = [];
%         obj.notifier.timestamp = Timestamp + 4/24; % Beijing time
        [str,status] = obj.notifier.Push();
        if status==0
            warning('OxfordDRMonitor:NotificationFailed',...
                [datestr(now,'dd mmm HH:MM:SS'),' Send notification failed: ',str]);
        elseif ~AlertLvl % emergency alerts should not be counted as routine notifications
            lastnotificationtime = now;
        end
    end
    if AlertLvl % fire alarm
        if AlertLvl > 1 % persistent alarm
            start(obj.alarmobj);
        else % 10 seconds
            start(obj.alarmobj);
            pause(10);
            stop(obj.alarmobj);
        end
    end
end