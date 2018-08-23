function CreateMeasurement(obj, MeasurementName, SIdx)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

if ~ischar(MeasurementName)
    error('SParamMeter:InvalidInput','Invalid measurement name');
end
if ~isreal(SIdx) || length(SIdx)~=2 || round(SIdx(1)) ~= SIdx(1) ||...
        round(SIdx(2)) ~= SIdx(2) || any(SIdx) < 1 || any(SIdx>obj.numports)
    error('SParamMeter:InvalidInput','Invalid SIdx');
end
if isempty(obj.swpstartfreq) || isempty(obj.swpstopfreq) || isempty(obj.swppoints)||...
        isempty(obj.bandwidth)
    error('SParamMeter:InvalidInput','Some parameters are not set.');
end
if length(obj.swpstartfreq) ~= length(obj.swpstopfreq) ||...
        length(obj.swpstartfreq) ~= length(obj.swppoints) ||...
        length(obj.swpstartfreq) ~= length(obj.bandwidth)
    error('SParamMeter:InvalidInput','swpstartfreq, swpstopfreq, swppoints and bandwidth are not of the same size.');
end

TYP = lower(obj.drivertype);
switch TYP
    case {'agilent_n5230c'}
        if any(obj.swpstartfreq >= obj.swpstopfreq)
            error('swpstartfreq >= swpstopfreq');
        end
        if any(obj.swppoints < 2) || sum(obj.swppoints) > 20001
            error('swppoints out of range.');
        end
        cmd = [':CALCulate:PARameter:DEFine:EXTended ',MeasurementName,',S',num2str(SIdx(1)),num2str(SIdx(2))];
        fprintf(obj.interfaceobj,cmd);
        NSeg = length(obj.swpstartfreq);
        obj.numsegments = NSeg;
        try
            if length(obj.swpstartfreq) > 1
                fprintf(obj.interfaceobj,'SENS:SEGM:DEL:ALL');
                fprintf(obj.interfaceobj,'SENS:SEGM:ARB ON');
                fprintf(obj.interfaceobj,'SENS:SEGM:BWID:CONT ON');
                fprintf(obj.interfaceobj,'SENS:SEGM:POW:CONT OFF');
                for ii = 1:NSeg
                    fprintf(obj.interfaceobj,sprintf('SENS:SEGM%d:ADD',ii));
                    fprintf(obj.interfaceobj,sprintf('SENS:SEGM%d:FREQ:START %d',ii,obj.swpstartfreq(ii)));
                    fprintf(obj.interfaceobj,sprintf('SENS:SEGM%d:FREQ:STOP %d',ii,obj.swpstopfreq(ii)));
                    fprintf(obj.interfaceobj,sprintf('SENS:SEGM%d:SWE:POIN %d',ii,obj.swppoints(ii)));
                    if obj.bandwidth(ii) < 1e3
                        fprintf(obj.interfaceobj,['SENS:BWID ', num2str(obj.bandwidth(ii),'%0.1fHz')]);
                    else
                        fprintf(obj.interfaceobj,['SENS:BWID ', num2str(obj.bandwidth(ii)/1e3,'%0.1fKHz')]);
                    end
                    fprintf(obj.interfaceobj,sprintf('SENS:SEGM%d ON',ii));
                end
                fprintf(obj.interfaceobj,'SENS:SWE:TYPE SEGM');
            else
                if obj.bandwidth(1) < 1e3
                    fprintf(obj.interfaceobj,['SENS:BWID ', num2str(obj.bandwidth(1),'%0.1Hz')]);
                else
                    fprintf(obj.interfaceobj,['SENS:BWID ', num2str(obj.bandwidth(1)/1e3,'%0.1fKHz')]);
                end
                fprintf(obj.interfaceobj,[':SENSe:FREQuency:STARt ',num2str(obj.swpstartfreq)]);
                fprintf(obj.interfaceobj,[':SENSe:FREQuency:STOP ',num2str(obj.swpstopfreq)]);
                fprintf(obj.interfaceobj,[':SENSe:SWEep:POINts ', num2str(obj.swppoints)]);
                fprintf(obj.interfaceobj,'SENS:SWE:TYPE LIN');
            end
        catch
            error('SParamMeter:CreateMeasurement', 'Setting instrument failed.');
        end
    case {'agilent_e5071c'}
        if any(obj.swpstartfreq >= obj.swpstopfreq)
            error('swpstartfreq >= swpstopfreq');
        end
        if any(obj.swppoints < 2) || sum(obj.swppoints) > 20001
            error('swppoints out of range.');
        end
        NSeg = length(obj.swpstartfreq);
        obj.numsegments = NSeg;
        
        try
            if length(obj.swpstartfreq) > 1
                if NSeg>1
                    error('Segment sweeping not supported right now. Consider to develop in the future.')
                end
            else
                fprintf(obj.interfaceobj,[':SENS1:BAND ', num2str(obj.bandwidth(1))]);
                fprintf(obj.interfaceobj,[':SENSe1:FREQuency:STARt ',num2str(obj.swpstartfreq)]);
                fprintf(obj.interfaceobj,[':SENSe1:FREQuency:STOP ',num2str(obj.swpstopfreq)]);
                fprintf(obj.interfaceobj,[':SENSe1:SWEep:POINts ', num2str(obj.swppoints)]);
                fprintf(obj.interfaceobj,'SENS1:SWE:TYPE LIN');
                
                % setup measurement type: S21
                fprintf(obj.interfaceobj,':CALC1:PAR1:SEL');
                fprintf(obj.interfaceobj,':CALC1:PAR1:DEF S21');
            end
        catch
            error('SParamMeter:CreateMeasurement', 'Setting instrument failed.');
        end
    otherwise
        error('SParamMeter:CreateMeasurement', ['Unsupported instrument: ',TYP]);
end

end