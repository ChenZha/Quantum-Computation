function [IRF,noiseSTD] = DAImpulseResponse(awg,chnl,scope,data_ln)
	% measure da impulse response function

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	IRF = NaN*ones(data_ln,2);

    wv  = qes.waveform.numeric();
    wvdata = zeros(1,128);
    wv.awg = awg;
    wv.awgchnl = chnl;
	awg.StopContinuousRun(); % implement a continues run/stop
    wv.SendWave();
	TrigInterval = wv.lenght
    awg.StartContinuousRun(TrigInterval); % implement a continues run/stop
	
	numAvg = 1e4;
	scope.record_ln = data_ln;
	scope.num_records = numAvg;
	
	background = mean(reshape(scope.FetchData(),record_ln,numAvg),2); % to be implemented
	
	wvdata(1) = awg.vpp;
    wv.wvdata = wvdata;
	awg.StopContinuousRun();
	wv.SendWave();
    awg.StartContinuousRun(TrigInterval); % implement a continues run
	
    IRF(:,2) = mean(reshape(scope.FetchData(),record_ln,numAvg),2) - background; % to be implemented
	IRF(:,1) = (0:record_ln-1)'/scope.smplrate;
    
	awg.StopContinuousRun();
	
	noiseSTD = std(background);
end