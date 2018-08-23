classdef (Abstract = true) OxfordDR < Instrument
    % Oxford dilution fridge driver.
    % Abstract class for all Oxford DRs, use sub class for a specific model
    % to create an driver instance.
    % basic properties and functions, for extensive
    % properties and functions, use class OxfordDR_e.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        temperature % 1xN array, temperature of all temperature channels, K
        tempres % 1xN array, resistance of all temperature channels, Ohm
        tempchnl % cell, name of temperature channels to read/set, if empty, read/set all channels
        pressure % 1xM array, presurre of all pressure channels, bar
        preschnl % cell, name of preschnl channels to read or set, if empty, read/set all channels

%         ptcon
%         valve % array
%         compressor %
    end
    properties (SetAccess = private)
        ptcstatus % string, pulse tube compressor status
        ptcwit % pulse tube compressor cooling water inlet termperature
        ptcwot % pulse tube compressor cooling water outlet termperature
    end
    properties (SetAccess = protected) % the following properties are model specific, to be harded coded in sub classes of specific models
        tempnamelst % cell, channel names of all temperature channel UIDs
        presnamelst % cell, channel names of all presurre channel UIDs
    end
    properties (SetAccess = protected, GetAccess = private) % the following properties are model specific, to be harded coded in sub classes of specific models
        tempuidlst % cell, all temperature channel UIDs
        presuidlst % cell, all presurre channel UIDs
    end
    methods
        function obj = OxfordDR(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('OxfordDR:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            if nargin < 3
                drivertype = [];
            end
            interfaceobj.Timeout = 2; % seconds
            obj = obj@Instrument(name,interfaceobj,drivertype);
            obj.active = false; % Oxford dilution fridge dose not support *IDN? query
        end
    end
    methods
        function set.tempchnl(obj,val)
            if isempty(val)
                obj.tempchnl = val;
                return;
            end
            if ischar(val)
                val = {val};
            end
            if ~all(ismember(val,obj.tempnamelst))
                error('OxfordDR:SetError','Unrecognized channel names.');
            end
            obj.tempchnl = val;
        end
        function set.preschnl(obj,val)
            if isempty(val)
                obj.preschnl = val;
                return;
            end
            if ischar(val)
                val = {val};
            end
            if ~all(ismember(val,obj.presnamelst))
                error('OxfordDR:SetError','Unrecognized channel names.');
            end
            obj.preschnl = val;
        end
        function t = get.temperature(obj)
            if isempty(obj.tempchnl)
                chnls = obj.tempnamelst;
            else
                chnls = obj.tempchnl;
            end
            numchnls = length(chnls);
            t = NaN*ones(1,numchnls);
            for ii = 1:numchnls
                idx = find(strcmp(obj.tempnamelst,chnls{ii}));
                try
                    flushinput(obj.interfaceobj); % flush input buffer is important
                    fprintf(obj.interfaceobj,['READ:DEV:',obj.tempuidlst{idx},':TEMP:SIG:TEMP']);
                    str = fscanf(obj.interfaceobj);
                    idx = strfind(str,':');
                    t(ii) = str2double(str(idx(end)+1:end-2));
                catch
                    t(ii) = NaN;
                end
            end
        end
        function set.temperature(obj,val)
            error('set forbidden.');
        end
        function r = get.tempres(obj)
            if isempty(obj.tempchnl)
                chnls = obj.tempnamelst;
            else
                chnls = obj.tempchnl;
            end
            numchnls = length(chnls);
            r = NaN*ones(1,numchnls);
            for ii = 1:numchnls
                idx = find(strcmp(obj.tempnamelst,chnls{ii}));
                try
                    flushinput(obj.interfaceobj); % flush input buffer is important
                    fprintf(obj.interfaceobj,['READ:DEV:',obj.tempuidlst{idx},':TEMP:SIG:RES']);
                    str = fscanf(obj.interfaceobj);
                    idx = strfind(str,':');
                    r(ii) = str2double(str(idx(end)+1:end-4));
                catch
                    r(ii) = NaN;
                end
            end
        end
        function set.tempres(obj,val)
            error('set forbidden.');
        end
        function p = get.pressure(obj)
            if isempty(obj.preschnl)
                chnls = obj.presnamelst;
            else
                chnls = obj.preschnl;
            end
            numchnls = length(chnls);
            p = NaN*ones(1,numchnls);
            for ii = 1:numchnls
                idx = find(strcmp(obj.presnamelst,chnls{ii}));
                try
                    flushinput(obj.interfaceobj); % flush input buffer is important
                    fprintf(obj.interfaceobj,['READ:DEV:',obj.presuidlst{idx},':PRES:SIG:PRES']);
                    str = fscanf(obj.interfaceobj);
                    idx = strfind(str,':');
                    p(ii) = str2double(str(idx(end)+1:end-3));
                catch
                    p(ii) = NaN;
                end
            end
            p = 1e-3*p;
        end
        function set.pressure(obj,val)
            error('set forbidden.');
        end
        function status = get.ptcstatus(obj)
            try
                flushinput(obj.interfaceobj); % flush input buffer is important
                fprintf(obj.interfaceobj,['READ:DEV:C1:PTC:STATUS']); % assume there is only on pulse tube cooler
                str = fscanf(obj.interfaceobj);
                idx = strfind(str,':');
                status = str(idx(end)+1:end-1);
            catch
                status = NaN;
            end
        end
        function t = get.ptcwit(obj)
            try
                flushinput(obj.interfaceobj); % flush input buffer is important
                fprintf(obj.interfaceobj,['READ:DEV:C1:PTC:SIG:WIT']); % assume there is only on pulse tube cooler
                str = fscanf(obj.interfaceobj);
                idx = strfind(str,':');
                t = str2double(str(idx(end)+1:end-2));
            catch
                t = NaN;
            end
        end
        function t = get.ptcwot(obj)
            try
                flushinput(obj.interfaceobj); % flush input buffer is important
                fprintf(obj.interfaceobj,['READ:DEV:C1:PTC:SIG:WOT']); % assume there is only on pulse tube cooler
                str = fscanf(obj.interfaceobj);
                idx = strfind(str,':');
                t = str2double(str(idx(end)+1:end-2));
            catch
                t = NaN;
            end
        end
    end
end