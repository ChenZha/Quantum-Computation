function ResaveData(hobj,src,datafilefullname)
    % load and resave to reduce datafile volume
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    fileinfo = dir(datafilefullname);
    if fileinfo.bytes > 10485760 % 10 maga bytes
        load(datafilefullname);
        save(datafilefullname,'fridgename','time','temperature','tempchnl','tempres','pressure',...
                        'preschnl','ptcstatus','ptcwit','ptcwot','dpoint','eventtime','event','-v7.3');
    end
end