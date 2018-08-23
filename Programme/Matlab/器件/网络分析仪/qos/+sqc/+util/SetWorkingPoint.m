function SetWorkingPoint(q,f01,giveWarning)
% set qubit q working point to f01
% warning:
%          1, SetWorkingPoint assumes that the current zdc_amp in
%            registry corresponds to f01 in the registry and zdc_amp2f01
%            is correct up to a zero point shift, if these condition are
%            not satisfied, it will set the working point wrong.
%          2, setting the working point too far away from the current 
%            working point by using SetWorkingPoint is not recommended.
%          3, changing the working point is an dangerous action, make sure you
%            konw what you are doing.
%           

% Copyright 2018 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 3
        giveWarning = true;
    end
    if giveWarning
        str = ['1, SetWorkingPoint assumes that the current zdc_amp in registry corresponds to f01 in the registry and zdc_amp2f01 is correct up to a zero point shift, if these condition are not satisfied, it will set the working point wrong.', char(13), char(10),...
                    '2, setting the working point too far away from the current working point by using SetWorkingPoint is not recommended.', char(13), char(10),...
                    '3, changing the working point is an dangerous action, make sure you konw what you are doing.'];
            choice  = questdlg(str,'Make sure you know the following: ',...
                    'I''m fully informed','Changed my mind','Changed my mind');
        if isempty(choice) || strcmp(choice, 'Changed my mind')
            return;
        end
    end
    if ischar(q)
        q = sqc.util.qName2Obj(q);
    end
    DZamp = sqc.util.detune2zdc(q.name,f01 - q.f01);
    
    QS = qes.qSettings.GetInstance();
    QS.saveSSettings({q.name,'f01'},f01);
    QS.saveSSettings({q.name,'zdc_amp'},q.zdc_amp + DZamp);
    data_taking.public.util.setZDC(q.name);
end