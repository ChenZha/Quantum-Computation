function out = MVisa(arg1, arg2, arg3)
% Matlab visa wrapper for Java

% test code:
% viRscName1 = 'TCPIP0::10.0.0.3::inst0::INSTR';
% MVisa('createInstance','agilent', viRscName1);
% MVisa('open',viRscName1,'null');
% viRscName2 = 'TCPIP0::10.0.0.4::inst0::INSTR';
% MVisa('createInstance','agilent', viRscName2);
% MVisa('open',viRscName2,'null');
% disp(MVisa('query',viRscName1,'*IDN?'));
% MVisa('fprintf',viRscName1,[':SOUR:POWER ',num2str(0,'%0.2f'),'DBM']);
% disp(MVisa('query',viRscName1,':SOUR:POW?'));
% disp(MVisa('query',viRscName2,':SOUR:POW?')); 
% MVisa('close',viRscName1,'null');
% MVisa('close',viRscName2,'null');
% MVisa('delete',viRscName1,'null');
% MVisa('delete',viRscName2,'null');

    out = 'null';

    persistent instanceList;
    persistent visaResourceNamelist;

    if strcmp(arg1,'createInstance')
        if ~ismember(arg2,{'ni','agilent','tek'})
            throw(MException('MVisa:UnsupportedVendorException',sprintf('Unsupported visa vendor %s', arg2)));
        end
        [lia,loc] = ismember(arg3,visaResourceNamelist);
        if lia 
            if isvalid(instanceList{loc})
                return;
                % throw(MException('MVisa:InstanceAlreadyCreatedException',sprintf('Visa instance already created for %s', arg2)));
            end
        else
            loc = length(visaResourceNamelist) + 1;
        end
        instanceList{loc} = visa(arg2,arg3);
        visaResourceNamelist{loc} = arg3;
        return;
    end

    [lia,loc] = ismember(arg2,visaResourceNamelist);
    if ~lia
        throw(MException('MVisa:InstanceNotCreatedException',sprintf('Visa instance not created for %s', arg2)));
    end
    instance = instanceList{loc};
    if ~isvalid(instance)
        throw(MException('MVisa:InstanceNotValidException',...
            sprintf('Visa instance exist but not valid(been deleted in most cases) for %s', arg2)));
    end
    
    switch arg1	
        case {'open'}
            if strcmp(instance.Status,'closed')
                fopen(instance);
            end
            return;
        case {'close'}
            if strcmp(instance.Status,'open')
                fclose(instance);
            end
            return;
        case {'delete'}
            if strcmp(instance.Status,'open')
                fclose(instance);
            end
            delete(instance);
            instanceList(loc) = [];
            visaResourceNamelist(loc) = [];
            return;
    end
    
    if ~strcmp(instance.Status,'open')
        throw(MException('MVisa:ConnectionNotOpenException',sprintf('Connection not open for %s', arg2)));
    end

    switch arg1	
        case {'query'}
            out = query(instance,arg3);
        case {'fprintf'}
            fprintf(instance,arg3);
        case {'fscanf'}
            fscanf(instance);
        case {'fwrite'}
            fwrite(instance,arg3);
        case {'freadFixedBytes'}
            fread(instance,arg3);
        case {'fread'}
            fread(instance);
        otherwise
            throw(MException('MVisa:IllegalArgumentException',sprintf('unrecognized operation %s', arg1)));
    end

end