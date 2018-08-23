function val = GetMeasurements(obj)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent_n5230c'}
                str = query(obj.interfaceobj, ':CALCulate:PARameter:CATalog?');
                if length(str) < 2
                    val = [];
                    return;
                end
                str = strrep(str,',','''},{''');
                str = strtrim(strrep(str,'"',''));
                str = eval(['[{''',str,'''}]']);
                val = str(1:2:end);
                if ~isempty(val) && strcmp(val{1},'NO CATALOG')
                    val = [];
                end
            case {'agilent_e5071c'}
                val = [];
            otherwise
                  error('SParamMeter:GetMeasurement', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('SParamMeter:GetMeasurement', 'Query instrument failed.');
    end
    
end