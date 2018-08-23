function InitializeInstr(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    if ~strcmp(obj.interfaceobj.Status,'closed')
         fclose(obj.interfaceobj); 
    end
    TYP = lower(obj.drivertype);
    switch TYP
        case {'ustc_da_v1'}
            obj.numChnls = obj.interfaceobj.numChnls;
            obj.vpp = 65536*ones(1,obj.numChnls);
			obj.samplingRate = obj.interfaceobj.samplingRate*ones(1,obj.numChnls);
            obj.dynamicReserve = zeros(1,obj.numChnls);
            obj.xfrFunc = cell(1,obj.numChnls);
        otherwise
            error('AWG:SetInterfaceObj','Unsupported awg: ''%s''', TYP);
    end
    fopen(obj.interfaceobj);
end