function copySession(source,destination)
% 

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
	
    if ~isvarname(destination)
        throw(MException('QOS:copySession:invalidDestinationName',...
			sprintf('invalid destination name: %s', destination)));
    end
	try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS:copySession:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
	if isempty(QS.user)
		throw(MException('QOS:copySession:userNotSet',...
			'user not set: create the qSettings object, set user and select session first.'));
	end
	if isempty(source)
		source = QS.session;
	end
	s = fullfile(QS.root,QS.user, source);
	if ~exist(s,'file')
		throw(MException('QOS:copySession:sourceSessionNotExist',...
			sprintf('the given source session %s not exist', s)));
	end
	d = fullfile(QS.root,QS.user, destination);
	if exist(d,'file')
		throw(MException('QOS:copySession:destinationSessionAllreadyExist',...
			sprintf('destination %s allready exist', destination)));
	end
	[status,msg,msgID] = copyfile(s,d);
	if ~status
		throw(MException('QOS:copySession:copyFailure',msg));
    end
    
end