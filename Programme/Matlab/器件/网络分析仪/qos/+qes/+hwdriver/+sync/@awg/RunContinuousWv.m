function RunContinuousWv(obj,chnl,wvData)
%
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	TYP = lower(obj.drivertype);
	switch TYP
		case {'ustc_da_v1'}
            if ~isnumeric(wvData) % must be a DASequence
                wvData = wvData.samples();
                wvData = uint16(wvData(1,:));
            end
			obj.interfaceobj.StartContinuousRun(chnl,wvData+32768);
		otherwise
			error('AWG:SetRunModeError','Unsupported awg!');
    end
end
