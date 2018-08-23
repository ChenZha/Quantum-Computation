function VoltSignal = FetchData(obj)
% fetch data from digitizer buffer
% at each trigger event, aquire a data segament record_ln long and
% returns num_records data segament.
% VoltSignal is 1 by num_record*record_ln array if only one channel is enabled,
% 2 by num_records*record_ln if both channnels are enabled, the first row is the
% voltage signal data of the first channel, the second row, the second
% channel.
% VoltSignal(1,:) chnl 1
% VoltSignal(2,:) chnl 2

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

persistent ApiSuccess;
persistent ADMA_FIFO_ONLY_STREAMING;
persistent ADMA_EXTERNAL_STARTCAPTURE;
persistent ADMA_NPT;
persistent ApiWaitTimeout;
ApiSuccess                  =	int32(512);
ApiWaitTimeout              =	int32(579);
ADMA_FIFO_ONLY_STREAMING    =   hex2dec('00000800');
ADMA_EXTERNAL_STARTCAPTURE  =   hex2dec('00000001');
ADMA_NPT                    =   hex2dec('00000200');


%%%%%%%%%%%%%%%%%%%%%%%%%%
if obj.clocksource == 2; % external
    scode = obj.samplerate_codes(end);
else
    scode = obj.samplerate_codes(obj.smplrate==obj.samplerate_options);
end
if obj.clocksource == 2; % external
    retCode = ...
        calllib('ATSApi', 'AlazarSetCaptureClock', ...
        obj.deviceobj,		...	% HANDLE -- board handle
        2,		...	% U32 -- clock source id
        scode,...	% U32 -- sample rate id
        0,	...	% U32 -- clock edge id
        0					...	% U32 -- clock decimation
        );
elseif obj.clocksource == 1; % internal
       retCode = ...
        calllib('ATSApi', 'AlazarSetCaptureClock', ...
        obj.deviceobj,		...	% HANDLE -- board handle
        1,		...	% U32 -- clock source id
        scode,...	% U32 -- sample rate id
        0,	...	% U32 -- clock edge id
        0					...	% U32 -- clock decimation
        );
end
if retCode ~= int32(512)
    error('Error: AlazarSetCaptureClock failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

% buffer timeout
% This is the amount of time to wait for for each buffer to be filled
bufferTimeout_ms = 300000;
% number of records per channel per DMA buffer
% obj.num_records = 2000;

% which channels to capture (A, B, or both)
% channelMask = CHANNEL_A + CHANNEL_B;
% channelMask = CHANNEL_A;
if obj.chnl1enabled && obj.chnl2enabled
    channelMask = 3;
elseif obj.chnl1enabled
    channelMask = 1;
elseif obj.chnl2enabled
    channelMask = 2;
end

% Calculate the number of enabled channels from the channel mask
channelCount = 0;
channelsPerBoard = 2;
for channel = 0:channelsPerBoard - 1
    channelId = 2^channel;
    if bitand(channelId, channelMask)
        channelCount = channelCount + 1;
    end
end
if (channelCount < 1) || (channelCount > channelsPerBoard)
    error('Error: Invalid channel mask %08X\n', channelMask);
end

% Get the sample and memory size
[retCode, obj.deviceobj, maxSamplesPerRecord, bitsPerSample] = calllib('ATSApi', 'AlazarGetChannelInfo', obj.deviceobj, 0, 0);
if retCode ~= ApiSuccess
    error('Error: AlazarGetChannelInfo failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end

preTriggerSamples = 0;
postTriggerSamples = obj.record_ln;
samplesPerRecord = preTriggerSamples + postTriggerSamples;
if (maxSamplesPerRecord > 0) && (samplesPerRecord > maxSamplesPerRecord)
    error('Error: Too many samples per record %u max %u\n', samplesPerRecord, maxSamplesPerRecord);
end

% except in acquiring very larg data set, we need to do multiple
% acquisitions to fill the amount of data required, 
% in most applications, one acquisition is enough, so here we fix 
% buffersPerAcquisition = 1, and we can always call FetchData()
% multiple times for large acquisitions, so fix buffersPerAcquisition to 1
% is not a problem.
% total number of buffers to capture
buffersPerAcquisition = 1;
% Calculate the size of each buffer in bytes
bytesPerSample = floor((double(bitsPerSample) + 7) / 8);
samplesPerBuffer = samplesPerRecord * obj.num_records * channelCount;
bytesPerBuffer = bytesPerSample * samplesPerBuffer;

% TODO: Select the number of DMA buffers to allocate.
% The number of DMA buffers must be greater than 2 to allow a board to DMA into
% one buffer while, at the same time, your application processes another buffer.
bufferCount = uint32(16);

% Create an array of DMA buffers
buffers = cell(1, bufferCount);
for j = 1 : bufferCount
    pbuffer = calllib('ATSApi', 'AlazarAllocBufferU16', obj.deviceobj, samplesPerBuffer);
    if pbuffer == 0
        error('Error: AlazarAllocBufferU16 %u samples failed\n', samplesPerBuffer);
    end
    buffers(1, j) = { pbuffer };
end


% Set the record size
retCode = calllib('ATSApi', 'AlazarSetRecordSize', obj.deviceobj, preTriggerSamples, postTriggerSamples);
if retCode ~= ApiSuccess
    error('Error: AlazarBeforeAsyncRead failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end
% Data Acquisition

% TODO: Select AutoDMA flags as required
% ADMA_NPT - Acquire multiple records with no-pretrigger samples
% ADMA_EXTERNAL_STARTCAPTURE - call AlazarStartCapture to begin the acquisition
% ADMA_FIFO_ONLY_STREAMING - disable on-board memory
admaFlags = ADMA_EXTERNAL_STARTCAPTURE + ADMA_NPT + ADMA_FIFO_ONLY_STREAMING;

% Configure the board to make an AutoDMA acquisition
recordsPerAcquisition = buffersPerAcquisition * obj.num_records;
retCode = calllib('ATSApi', 'AlazarBeforeAsyncRead', obj.deviceobj, channelMask, -int32(preTriggerSamples), samplesPerRecord, obj.num_records, recordsPerAcquisition, admaFlags);
if retCode ~= ApiSuccess
    error('Error: AlazarBeforeAsyncRead failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end

% Post the buffers to the board
for bufferIndex = 1 : bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', obj.deviceobj, pbuffer, bytesPerBuffer);
    if retCode ~= ApiSuccess
        error('Error: AlazarPostAsyncBuffer failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
    end
end

% Arm the board system to wait for triggers
retCode = calllib('ATSApi', 'AlazarStartCapture', obj.deviceobj);
if retCode ~= ApiSuccess
    error('Error: AlazarStartCapture failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end


rawdata = cell(1,bufferCount);

% Wait for sufficient data to arrive to fill a buffer, process the buffer,
% and repeat until the acquisition is complete
buffersCompleted = 0;
captureDone = false;
success = false;

while ~captureDone
    
    bufferIndex = mod(buffersCompleted, bufferCount) + 1;
    pbuffer = buffers{1, bufferIndex};
    
    % Wait for the first available buffer to be filled by the board
    [retCode, obj.deviceobj, bufferOut] = ...
        calllib('ATSApi', 'AlazarWaitAsyncBufferComplete', obj.deviceobj, pbuffer, bufferTimeout_ms);
    if retCode == ApiSuccess
        % This buffer is full
        bufferFull = true;
        captureDone = false;
    elseif retCode == ApiWaitTimeout
        % The wait timeout expired before this buffer was filled.
        % The board may not be triggering, or the timeout period may be too short.
        bufferFull = false;
        captureDone = true;
        error('Error: AlazarWaitAsyncBufferComplete timeout -- Verify trigger!\n');
    else
        % The acquisition failed
        bufferFull = false;
        captureDone = true;
        error('Error: AlazarWaitAsyncBufferComplete failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
    end
    
    if bufferFull
        % TODO: Process sample data in this buffer.
        %
        % NOTE:
        % While you are processing this buffer, the board is already
        % filling the next available DMA buffer.
        %
        % You must finish processing this buffer before the board fills
        % all of its available DMA buffers and on-board memory.
        %
        % Records are arranged in the buffer as follows:
        % R0A, R1A, R2A ... RnA, R0B, R1B, R2B ...
        %
        % Samples values are arranged contiguously in each record.
        % A 12-bit sample code is stored in the most significant bits of each 16-bit sample value.
        %
        % Sample codes are unsigned by default where:
        % - 0x000 represents a negative full scale input signal;
        % - 0x800 represents a 0V signal;
        % - 0xfff represents a positive full scale input signal.
        
        setdatatype(bufferOut, 'uint16Ptr', 1, samplesPerBuffer);
        
        
        
        % temperory store the data into cell
        rawdata{1,bufferIndex} = bufferOut.Value;
        
        % Make the buffer available to be filled again by the board
        retCode = calllib('ATSApi', 'AlazarPostAsyncBuffer', obj.deviceobj, pbuffer, bytesPerBuffer);
        if retCode ~= ApiSuccess
            captureDone = true;
            error('Error: AlazarPostAsyncBuffer failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
        end
        
        % Update progress
        buffersCompleted = buffersCompleted + 1;
        if buffersCompleted >= buffersPerAcquisition
            captureDone = true;
            success = true;
        end
        
    end % if bufferFull
    
end % while ~captureDone

if channelMask == 3;
    finalrawdata = zeros(1,2*obj.record_ln*obj.num_records*buffersPerAcquisition);
    for ig = 1:buffersPerAcquisition;
        finalrawdata(((ig-1)*2*obj.record_ln*obj.num_records+1):(2*ig*obj.record_ln*obj.num_records)) = rawdata{1,ig};
    end
    finalrawdataA = finalrawdata(1:2:end);
    finalrawdataB = finalrawdata(2:2:end);
elseif channelMask == 1;
    finalrawdataA = zeros(1,obj.record_ln*obj.num_records*buffersPerAcquisition);
    finalrawdataB = zeros(1,obj.record_ln*obj.num_records*buffersPerAcquisition);
    for ig = 1:buffersPerAcquisition;
        finalrawdataA(((ig-1)*obj.record_ln*obj.num_records+1):(ig*obj.record_ln*obj.num_records)) = rawdata{1,ig};
    end
elseif channelMask == 2;
    finalrawdataA = zeros(1,obj.record_ln*obj.num_records*buffersPerAcquisition);
    finalrawdataB = zeros(1,obj.record_ln*obj.num_records*buffersPerAcquisition);
    for ig = 1:buffersPerAcquisition;
        finalrawdataB(((ig-1)*obj.record_ln*obj.num_records+1):(ig*obj.record_ln*obj.num_records)) = rawdata{1,ig};
    end
end

voltA=obj.chnl1range*(double(finalrawdataA/16)-ones(1,length(finalrawdataA))*(2048))/2048;
voltB=obj.chnl2range*(double(finalrawdataB/16)-ones(1,length(finalrawdataB))*(2048))/2048;

VoltSignal = [voltA;voltB];

%% Abort the acquisition

retCode = calllib('ATSApi', 'AlazarAbortAsyncRead', obj.deviceobj);
if retCode ~= ApiSuccess
    error('Error: AlazarAbortAsyncRead failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
end

% Release the buffers
for bufferIndex = 1:bufferCount
    pbuffer = buffers{1, bufferIndex};
    retCode = calllib('ATSApi', 'AlazarFreeBufferU16', obj.deviceobj, pbuffer);
    if retCode ~= ApiSuccess
        error('Error: AlazarFreeBufferU16 failed -- %s\n', qes.hwdriver.sync.alazarATS.errorToText(retCode));
    end
end



end