function resp = iquery(interfaceobj, cmd)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    flushinput(interfaceobj); % query dose not flush input buffer(R2013b)
    resp = query(interfaceobj, cmd);
end