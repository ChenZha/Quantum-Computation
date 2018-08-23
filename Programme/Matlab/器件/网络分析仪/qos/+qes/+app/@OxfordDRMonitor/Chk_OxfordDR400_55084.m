function [AlertLvl, Msg] = Chk_OxfordDR400_55084(obj)
    % Trtion 400(Prj. No. 55084) in Q02, IoP, CAS. 
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    persistent lastidle1emergencytime
    if isempty(lastidle1emergencytime)
        lastidle1emergencytime = 0;
    end
    persistent lastbasetemp1emergencytime
    if isempty(lastbasetemp1emergencytime)
        lastbasetemp1emergencytime = 0;
    end
    persistent lastbasetemp2emergencytime
    if isempty(lastbasetemp2emergencytime)
        lastbasetemp2emergencytime = 0;
    end
    persistent lastbasetemp3emergencytime
    if isempty(lastbasetemp3emergencytime)
        lastbasetemp3emergencytime = 0;
    end
    persistent lastwarmup1emergencytime
    if isempty(lastwarmup1emergencytime)
        lastwarmup1emergencytime = 0;
    end
    persistent mixturecollected
    if isempty(mixturecollected)
        mixturecollected = false;
    end
    
    persistent lastcoolingdwn1emergencytime
    if isempty(lastcoolingdwn1emergencytime)
        lastcoolingdwn1emergencytime = 0;
    end
    persistent lastcoolingdwn2emergencytime
    if isempty(lastcoolingdwn2emergencytime)
        lastcoolingdwn2emergencytime = 0;
    end
    persistent lastcoolingdwn3emergencytime
    if isempty(lastcoolingdwn3emergencytime)
        lastcoolingdwn3emergencytime = 0;
    end
    
    AlertLvl = 0;
    Msg = '';
    if obj.dpoint == 0 
        return;
    end
    switch obj.process
        case 1 % idle
            if obj.pressure(obj.dpoint,1) < obj.mintankpres
                if now - lastidle1emergencytime > 1/24
                    AlertLvl = 2;
                    Msg = ['Possible tank leakage, tank pressure dropped to ', num2str(obj.pressure(obj.dpoint,1),'%0.2f'),'Bar!'];
                    lastidle1emergencytime = now;
                end
            end
        case 2 % base temperature
            Msg = [];
            if obj.temperature(obj.dpoint,5) > obj.maxbasetemp
                if now - lastbasetemp1emergencytime > 1/24
                    AlertLvl = 2;
                    Msg = ['Temperature rising to ', num2str(1000*obj.temperature(obj.dpoint,5),'%0.1f'),'mK!'];
                    lastbasetemp1emergencytime = now;
                end
            end
            if obj.ptcwit(obj.dpoint) > obj.maxptcwitemp
                if now - lastbasetemp2emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'Pulse tube cooling water too hot: ', num2str(obj.ptcwit(obj.dpoint),'%0.1f'),'C at inlet!'];
                    lastbasetemp2emergencytime = now;
                end
            end
            if obj.ptcwot(obj.dpoint) > obj.maxptcwotemp
                if now - lastbasetemp2emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'Pulse tube cooling water too hot: ', num2str(obj.ptcwot(obj.dpoint),'%0.1f'),'C at outlet!'];
                    lastbasetemp2emergencytime = now;
                end
            end
            idx = find(obj.time(1:obj.dpoint)<=now-1/24,1,'last');
            if ~isempty(idx) &&...
                    (obj.pressure(idx,6) > 1e-2 && obj.pressure(obj.dpoint,6) > 1.5*obj.pressure(idx,6)) ||...
                    (obj.pressure(idx,6) <= 1e-2 && obj.pressure(obj.dpoint,6) > max(2*obj.pressure(idx,6),5e-3))
                if now - lastbasetemp3emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'OVC vacuum rising, possible OVC leakage!'];
                    lastbasetemp3emergencytime = now;
                end
            end
        case 3 % warming up
%              if obj.temperature(obj.dpoint,5) > 273
%                  if now - lastwarmup1emergencytime > 1/24
%                     AlertLvl = 0;
%                     Msg = ['System warmed up to room temperature. '];
%                     lastwarmup1emergencytime = now;
%                  end
%              end
            
            if obj.pressure(obj.dpoint,1) >= obj.mintankpres
                mixturecollected = true;
            end
            if mixturecollected && obj.pressure(obj.dpoint,1) < 0.9*obj.mintankpres
                if now - lastwarmup1emergencytime > 1/24
                    AlertLvl = 2;
                    Msg = ['Possible tank leakage, tank pressure dropped to ', num2str(obj.pressure(obj.dpoint,1),'%0.2f'),'Bar!'];
                    lastwarmup1emergencytime = now;
                end
            end
        case 4 % cooling down
            idx = find(obj.time(1:obj.dpoint)<=now-1/24,1,'last');
            if ~isempty(idx) && obj.temperature(obj.dpoint,2) > obj.temperature(idx,2) + 5
                if now - lastcoolingdwn1emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'PT2 stage temperature rising!'];
                    lastcoolingdwn1emergencytime = now;
                end
            end
            if ~isempty(idx) &&...
                    (obj.pressure(idx,6) > 1e-2 && obj.pressure(obj.dpoint,6) > 1.5*obj.pressure(idx,6)) ||...
                    (obj.pressure(idx,6) <= 1e-2 && obj.pressure(obj.dpoint,6) > max(2*obj.pressure(idx,6),5e-3))
                if now - lastcoolingdwn2emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'OVC vacuum rising, possible OVC leakage!'];
                    lastcoolingdwn2emergencytime = now;
                end
            end
            if obj.ptcwit(obj.dpoint) > obj.maxptcwitemp
                if now - lastcoolingdwn3emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'Pulse tube cooling water temperature too high: ', num2str(obj.ptcwit(obj.dpoint),'%0.1f'),'C at inlet!'];
                    lastcoolingdwn3emergencytime = now;
                end
            end
            if obj.ptcwot(obj.dpoint) > obj.maxptcwotemp
                if now - lastcoolingdwn3emergencytime > 1/24
                    AlertLvl = 2;
                    if ~isempty(Msg)
                        Msg = [Msg, 10];
                    end
                    Msg = [Msg, 'Pulse tube cooling water temperature too high: ', num2str(obj.ptcwot(obj.dpoint),'%0.1f'),'C at outlet!'];
                    lastcoolingdwn3emergencytime = now;
                end
            end
    end
end