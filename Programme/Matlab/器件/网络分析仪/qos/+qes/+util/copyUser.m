function copyUser(source,destination)
% 

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
	% TODO...
	try
        S = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_copyUser:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
	s = fullfile(s.root,source);
	d = fullfile(s.root,destination);
	[status,msg,msgID] = copyfile(s,d);
	if ~status
		throw(MException('QOS_copyUser:copyError',msg));
	end
end