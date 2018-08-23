function [SRF,noiseSTD] = DAImpulseResponse(awg,chnl,wv_ln,scope,data_ln,numAvg)
	% measure da step response function

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	SRF = NaN*ones(data_ln,2);

    wv  = qes.waveform.numeric();
    wvdata = zeros(1,wv_ln);
    wv.awg = awg;
    wv.awgchnl = chnl;
	awg.StopContinuousRun(); % implement a continues run/stop
    wv.SendWave();
	TrigInterval = wv.lenght
    awg.StartContinuousRun(TrigInterval); % implement a continues run/stop
	
	scope.record_ln = data_ln;
	scope.num_records = numAvg;
	
	background = mean(reshape(scope.FetchData(),record_ln,numAvg),2); % to be implemented
	
	wvdata = awg.vpp*ones(1,wv_ln);
	wvdata(1) = 0;
    wv.wvdata = wvdata;
	awg.StopContinuousRun();
	wv.SendWave();
    awg.StartContinuousRun(TrigInterval); % implement a continues run
	
    SRF(:,2) = mean(reshape(scope.FetchData(),record_ln,numAvg),2) - background; % to be implemented
	SRF(:,1) = (0:record_ln-1)'/scope.smplrate;
    
	awg.StopContinuousRun();
	
	noiseSTD = std(background);
end