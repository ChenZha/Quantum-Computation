function DeleteMeasurement(obj, MeasurementName)
    % Delete measurement.
    % if MeasurementName not specified, delete all

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin == 1
        MeasurementName = [];
    end
    if ~isempty(MeasurementName) && ~ischar(MeasurementName)
        error('SParamMeter:InvalidInput','Invalid measurement name.');
    end

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent_n5230c'}
                if isempty(MeasurementName) % delete all
                    fprintf(obj.interfaceobj,':CALCulate:PARameter:DELete:ALL');
                else
                    measurementlist = obj.measurements;
                    if isempty(measurementlist) || ~ismember(MeasurementName,measurementlist)
                        warning('SParamMeter:DeletMeasurement', ['Measurement ', MeasurementName ,' not exist.']);
                    else
                        fprintf(obj.interfaceobj,[':CALCulate:PARameter:DELete:NAME ',MeasurementName]);
                    end
                end
            case {'agilent_e5071c'}
                % nothing to do
            otherwise
                  error('SParamMeter:DeletMeasurement', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('SParamMeter:DeletMeasurement', 'Setting instrument failed.');
    end
    
end