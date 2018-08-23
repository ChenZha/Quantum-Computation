function DRRead(hObject,eventdata,obj)
    % a private method

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
        obj.fridgeobj.tempchnl = []; % all channels
        obj.fridgeobj.preschnl = []; % all channels

        if obj.dpoint+1 > obj.dlen
            obj.EnlargeDataCapacity();
        end
        obj.dpoint = obj.dpoint+1;
        time_new = now;
        obj.time(obj.dpoint,1) = time_new;

        temperature_new = obj.fridgeobj.temperature;
        obj.temperature(obj.dpoint,:) = temperature_new;

        tempres_new = obj.fridgeobj.tempres;
        obj.tempres(obj.dpoint,:) = tempres_new;

        pressure_new = obj.fridgeobj.pressure;
        obj.pressure(obj.dpoint,:) = pressure_new;

        status = obj.fridgeobj.ptcstatus;
        switch status
            case {'OK','Ok','ok',1}
                ptcstatus_new = true;
            otherwise 
                ptcstatus_new = false;
        end
        obj.ptcstatus(obj.dpoint,1) = ptcstatus_new;

        ptcwit_new = obj.fridgeobj.ptcwit;
        obj.ptcwit(obj.dpoint,1) = ptcwit_new;

        ptcwot_new = obj.fridgeobj.ptcwot;
        obj.ptcwot(obj.dpoint,1) =  ptcwot_new;

        try
            obj.m.dpoint = obj.dpoint;
            obj.m.time(obj.dpoint,1) = time_new;
            obj.m.temperature(obj.dpoint,:) = temperature_new;
            obj.m.tempres(obj.dpoint,:) = tempres_new;
            obj.m.pressure(obj.dpoint,:) = pressure_new;
            obj.m.ptcstatus(obj.dpoint,1) = ptcstatus_new;
            obj.m.ptcwit(obj.dpoint,1) = ptcwit_new;
            obj.m.ptcwot(obj.dpoint,1) = ptcwot_new;
        catch
            % this happens when some other program(a backup program for example) is accessing the datafile,
            % it is not a problem if it dose not happen constantly.
            
            oldinfostr = get(obj.uihandles.InfoDisp,'String');
            oldinfostr = TrimNotes(oldinfostr);
            oldinfostr = oldinfostr(:)';
            newinfostr = [datestr(now,'dd mmm HH:MM:SS'),10,'Uable to write new data to datafile.'];
            warning('OxfordDRMonitor:SaveDataFail',newinfostr);
            newinfostr = [newinfostr,10,oldinfostr];
            if length(newinfostr) > 1024;
                newinfostr(1024:end) = [];
            end
            set(obj.uihandles.InfoDisp,'String',newinfostr);
        end

        if isempty(obj.parent) || ~ishghandle(obj.parent)
            obj.CreateGUI();
        end
        obj.Chart();
        obj.StatusChk();
    end