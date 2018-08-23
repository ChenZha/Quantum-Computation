function obj = GetInstance(FridgeObj)
    % if called without input arguments, the first valid instance is
    % returned, if 'name' is not empty, the instance that matches 'name'
    % is returned if exits, if not exit, a new instance is created(in this
    % case all input arguments should be specified)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    persistent objlst;
    if isempty(objlst)
        if nargin == 0
            error('OxfordDRMonitor:GetInstanceError',...
                'No existing instance, all input paramenters should be specified!');
        end
        obj = OxfordDRMonitor(FridgeObj);
        objlst = obj;
    else
        nexistingobj = numel(objlst);
        ii = 1;
        while ii <= nexistingobj
            if isvalid(objlst(ii))
                if nargin == 0 
                    obj = objlst(ii);
                    return;
                end
                if objlst(ii).fridgeobj == FridgeObj % instance exit already, return the handle
                    obj = objlst(ii);
                    break;
                end
            else
                objlst(ii) = [];  % remove invalid handles(handles of delete objects)
                nexistingobj = nexistingobj -1;
                ii = ii - 1;
            end
            if ii >= nexistingobj  % instance not exit, create one
                if nargin == 0
                    error('OxfordDRMonitor:GetInstanceError',...
                        'No existing instance, all input paramenter should be specified!');
                end
                obj = OxfordDRMonitor(FridgeObj);
                objlst(end+1) = obj;
            end
            ii = ii + 1;
        end
    end
end