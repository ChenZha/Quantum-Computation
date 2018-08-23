function Run(obj)
    % Start an acquisition
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if obj.running
        return;
    end

    obj.acquisition = get(obj.deviceobj, 'Acquisition');
    % Fetch_Relative_To 477 Fetches relative to the first pretrigger point requested with 
    % Fetch_Relative_To 481 Fetch data at the last sample acquired.
    % Fetch_Relative_To 482 Fetch data starting at the first point sampled by the digitizer
    % Fetch_Relative_To 483 Fetch at the first posttrigger sample
    % Fetch_Relative_To 388 The read pointer is set to zero when a new acquisition is initiated.
    % After every fetch the read pointer is incremented to be the sample after the last sample retrieved.
    % Therefore, you can repeatedly fetch relative to the read pointer for a continuous acquisition program. 
    if obj.workmode == 2 % triggered mode
%         obj.acquisition.Fetch_Relative_To = 388;
%         obj.acquisition.Fetch_Relative_To = 483;
%         obj.acquisition.Fetch_Offset = 0;
    elseif obj.workmode == 1 % continues mode, should always fetch the latest data!
        % set the position to start fetching within one record to:
        % NISCOPE_VAL_READ_POINTER (388)¡ªThe read pointer is set to zero when a new acquisition is initiated.
        % After every fetch the read pointer is incremented to be the sample after the last sample retrieved.
        % Therefore, you can repeatedly fetch relative to the read pointer for a continuous acquisition program. 
        % Indispensible enven if only one fetch is needed.
        if isempty(obj.numsamples)
             error('NIDAQUSB5132:RunError', 'numsample points not set!');
        end
        obj.acquisition.Fetch_Relative_To = 481; % the last sample acquired
        obj.acquisition.Fetch_Offset = -obj.numsamples;
    end
    % initiate acquisition
    invoke(obj.acquisition, 'initiateacquisition');
    obj.running = true;
end