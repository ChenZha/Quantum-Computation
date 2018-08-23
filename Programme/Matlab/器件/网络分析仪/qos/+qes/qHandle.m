classdef (Abstract = true) qHandle < handle
    % base class of all QES classes
    % caveat:
    % all qHandle sub class should avoid 'propty loopping', that is 
    % a qHandle sub class object A has a property p and p is also a qHandle
    % sub class B object, one of B's property or property's property etc.
    % is a class object A.
    % for qHandle sub class with 'propty loopping', ToStruct method is an
    % infinite loop.
    % call qHandle.ListObj() to list all qHandle objects
    % call objs = FindByClass(classname) to find all instances of a class
    % call  objs = FindByProp(PopertyName,PopertyVal) to find objects by
    % property value;
    % call  DeleteByClass(classname) to delete all instances of a class
    % call  DeleteByProp(PopertyName,PopertyVal) to delete objects with a
    % specific property value;
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        id@uint32 % globally unique id
    end
    properties
        name@char = ''
        % temperoy objects are not kept in object pool, non temperay object
        % such as hardware objects, enven if no one's reference to it, it
        % still exists in the qHandle object pool and can be retrieved by
        % find methods sunch as FindByProp and FindByClass. non temperay
        % object can be deleted by call the delete method.
        temperory@logical scalar = true % by default, all objects are temperory 
    end
    methods
        function obj = qHandle(name)
            if nargin
                obj.name = name;
            end
            qes.qHandle.SetId(obj);
            qes.qHandle.ListObj(obj);
        end
        function set.temperory(obj,val)
            obj.temperory = val;
            qes.qHandle.ListObj(obj);
        end
        function bol = eq(obj1,obj2)
            if obj1.id == obj2.id 
                bol = true;
            else
                bol = false;
            end
        end
    end
    methods (Static = true)
        function SetId(obj)
            persistent nextid
            if isempty(nextid)
                % id start from 1: instead of the object handle itself, an object might be reference by id,
                % which is globally unique, 0 is used to indentify a non-set
                % reference, e.g.
                % some property:
                % otherobjreference@unit32 property
                % if ~obj.otherobjreference
                %       disp('property not set');
                % end
                nextid = uint32(1); 
            end
            obj.id = nextid;
            nextid  = nextid + uint32(1);
        end
        function obj = ToObject(s)
            % create a qHandle class object from a struct, for example:
            % s = qes.qHandle.ToStruct(MWSource1); % s is a struct and can be saved.
            % MWSource1.delete(); clear MWSource1; % now the hardware object MWSource1 is gone
            % MWSource1 = qes.qHandle.ToObject(s); % you got the hardware object MWSource1 again
            % In case of recreate a hardware object, qSettings must be ready: user already set

            if ~isstruct(s)
                obj = s;
                return
            end
            if (~isfield(s,'ishardware') || ~s.ishardware) && ~isfield(s,'creationarg') 
                if ~isfield(s,'class')
                    obj = s;
                    return;
                end
                switch s.class
                    case 'qes.qSettings'
                        obj = qes.qSettings.GetInstance(s.settingsdir);
                        try % ok if fails here
                            obj.user = s.user;
                            obj.session = s.session;
                        catch
                        end
                        obj.SetSettings(s.hardware, s.app, s.misc);
                    case 'qes.expParam'
                        expobj = qes.qHandle.ToObject(s.expobj);
                        obj = ExpParam(expobj,s.propertyname);
                    case {'qes.sweep'}
                        paramobjs = qes.qHandle.ToObject(s.paramobjs(1));
                        for ii = 2:length(s.paramobjs)
                            paramobjs = [paramobjs, qes.qHandle.ToObject(s.paramobjs(ii))];
                        end
                        obj = qes.sweep(paramobjs,s.mainparam);
                    otherwise
                        obj = feval(str2func(['@', s.class]));
                end
            elseif isfield(s,'creationarg') 
                if strcmp(s.class,'qSettings')
                    obj = feval(@qes.qSettings.GetInstance, qes.qHandle.ToObject(s.(s.('creationarg')))); % presume s.(creationarg) is a scalar, other cases are not implemeted
                else
                    obj = feval(str2func(['@', s.class]), qes.qHandle.ToObject(s.(s.('creationarg')))); % presume s.(creationarg) is a scalar, other cases are not implemeted
                end
            else
                try
                    QS = qes.qSettings.GetInstance(); % qSettings object must have been created and conditioned in advance, otherwise error here
                catch
                    error('qHandle:ToObjectError','qSettings not created or not conditioned, creat the qSettings object, select user(by using SU) and select session(by using SS) first.');
                end
                s_ = QS.FindDeviceSettings(s.class, s.name);
                if isempty(s_)
                    error('qHandle:ToObjectError','hardware settings for ''%s'' not found, make sure the input struct is correct and check the hardware settings file.', s.name);
                end
                obj = qes.util.hwCreator(s_);
            end

            metadata = metaclass(obj);
            NotSetYetList = {};
            for ii = 1:length(metadata.PropertyList)
                if strcmpi(metadata.PropertyList(ii).SetAccess, 'Public') && isfield(s,metadata.PropertyList(ii).Name) &&...
                        ~metadata.PropertyList(ii).Dependent
                    propval = s.(metadata.PropertyList(ii).Name);
                    if iscell(propval)
                        sz = size(propval);
                        if numel(sz) > 2
                            error('qHandle:ToObjectError','can not handle more than 2 dimensional cell property values in setting ''%s'' of ''%s''', metadata.PropertyList(ii).Name, s.name);
                        end
                        p = cell(sz);
                        for jj = 1:sz(1)
                            for kk = 1:sz(2) % can not handle more than 2 dimensional arrays
                                p{jj,kk} = qes.qHandle.ToObject(propval{jj,kk});
                            end
                        end
                        propval= p;
                    elseif ~ischar(propval)
                        sz = size(propval);
                        if numel(sz) > 2
                            error('qHandle:ToObjectError','can not handle more than 2 dimensional cell property values in setting ''%s'' of ''%s''', metadata.PropertyList(ii).Name, s.name);
                        end
                        if length(propval) == 1
                            p = qes.qHandle.ToObject(propval);
                        else
                            p = [];
                            for jj = 1:sz(1)
                                for kk = 1:sz(2) % can not handle more than 2 dimensional arrays
                                    p(jj,kk) = qes.qHandle.ToObject(propval(jj,kk));
                                end
                            end
                        end
                        propval= p;
                    end
                    try
                        s.(metadata.PropertyList(ii).Name) = propval; % keep it, we may fail this time, see below
                        obj.(metadata.PropertyList(ii).Name) = propval;
                    catch
                        % some properties can only be set after some other
                        % properties are set, so whenever we failed to set some
                        % properties, we will give it another try later.
                        NotSetYetList = [NotSetYetList, {metadata.PropertyList(ii).Name}]; 
                    end
                end
            end
            NNotSet = length(NotSetYetList);
            if NNotSet
                NotSetYetList = fliplr(NotSetYetList);
                for ii = 1:NNotSet
                    propval = s.(NotSetYetList{ii});
                    if isempty(propval) % some times an empty property value indicates a  property inherited from the super class that has became obsolete(no needed)
                        continue;
                    end
                    try
                        obj.(NotSetYetList{ii}) = propval;
                    catch ME
                        % if still failed, we throw a warning instead of an error
                        % since this is ok  sometime, a deleted hardware object
                        % for example, in such cases we can just leave the property
                        % not set and let user to decide what to do.
                        warning('qHandle:ToObjectError','Failed in setting the property ''%s'' : %s', NotSetYetList{ii}, getReport(ME,'basic','hyperlinks','off'));
                    end
                end
            end
            if isa(obj,'Waveform') && ~isempty(obj.awg) && IsValid(obj.awg)
%                 obj.DoAll(); % method removed
            end
        end
        function [valout] = ToStruct(valin,donotparsehardware)
            % Convert object to struct
            % caveat: convert objects with 'propty loopping', that is 
            % a qHandle sub class A has a property p and p is also a qHandle
            % sub class B object, one of B's property or property's property etc.
            % is a class A object, leads to infinite loopping

            valout = struct();
            if nargin == 1
                donotparsehardware = false;
            end
            if isempty(valin) || isnumeric(valin) ||... % types that dose not need to be parsed
                islogical(valin) || ischar(valin) ||...
                isa(valin,'function_handle')
                valout = valin;
            elseif ~isscalar(valin) % array
                sz = size(valin);
                ND = length(sz);
                if ND > 2 % cell more than 2D is not parsed
                    valout = [num2str(ND,'%0.0f'),' dimentional qHandle object array, not parsed'];
                else
                    valout = cell(sz); % qHandle is one category of classes, not one class
                    if iscell(valin)
                        for jj = 1:sz(1)
                            for kk = 1:sz(2)
                                valout{jj,kk} = qes.qHandle.ToStruct(valin{jj,kk});
                            end
                        end
                    else
                        for jj = 1:sz(1)
                            for kk = 1:sz(2)
                                valout{jj,kk} = qes.qHandle.ToStruct(valin(jj,kk));
                            end
                        end
                        valout = cell2mat(valout);
                    end
                end
            elseif iscell(valin)
                valout = {qes.qHandle.ToStruct(valin{1})};
            elseif (isa(valin,'qes.qHandle') || isa(valin,'qes.qSettings')) &&...
                    ~isa(valin,'qes.hwdriver.sync.ustcadda') && ~isa(valin,'qes.hwdriver.async.ustcadda')  % the ustcadda is temperary, might be removed in the future
                if ~isvalid(valin)
                    valout = sprintf('deleted %s class object.', class(valin));
                    return;
                end
                if isa(valin,'qes.hwdriver.hardware')
                    ishardware = true;
                else
                    ishardware = false;
                end
                if ishardware && donotparsehardware
                    % Hardware read may require hardware i/o,
                    % which may be slow or even leads to
                    % excpetion in some cases, so hardware
                    % objects are not parsed.
                    valout = [class(valin),' hardware class object, not parsed'];
                else
                    metadata = metaclass(valin);
                    valout.class = class(valin);
                    % unlike other objects, hardware objected can not be
                    % regenerated just by the struct converted from the original
                    % object, it is regenerated by QSettings by loading the 
                    % hardware settings file and then overwirtten default property
                    % values with the values stored in the struct,
                    % so let the creator know it is a Hardware
                    if isa(valin, 'qes.hwdriver.hardware') 
                        valout.ishardware  = true; 
                    elseif isa(valin, 'qes.measurement.measurement') 
                        valout.creationarg  = 'InstrumentObject'; 
                    elseif isa(valin, 'qes.qSettings') 
                        valout.creationarg  = 'settingsdir'; 
                    end
                    for ii = 1:length(metadata.PropertyList)
                        propname = metadata.PropertyList(ii).Name;
                        if ismember(propname,{'uiinfo','ctrlpanel'})
                            continue;
                        end
                        if strcmpi(metadata.PropertyList(ii).GetAccess, 'Public')
                            try
                                valout.(propname) = qes.qHandle.ToStruct(valin.(propname),donotparsehardware);
                            catch ME
                                if ishardware
                                    valout.(propname) = 'Failed in reading value.';
                                    warning('qHandle:ToStructError','Unable to convert property value ''%s'' due to: ',propname,getReport(ME,'basic'));
                                else
                                    rethrow(ME);
                                end
                            end
                        end
                    end
                    % the following non important fields are dropped to save data saving space:
                    if isa(valin,'qes.measurement.measurement')
                        valout = rmfield(valout,'data');
                        valout = rmfield(valout,'extradata');
                    end
                end
            elseif isgraphics(valin)
                valout = [];
            elseif isobject(valin)
                if ~isvalid(valin)
                    valout = sprintf('deleted %s class object.', class(valin));
                else
                    valout  = [class(valin),' class object, not parsed'];        
                end
            elseif isstruct(valin)
                fname = fieldnames(valin);
                for ii = 1:length(fname)
                    valout.(fname{ii}) = qes.qHandle.ToStruct(valin.(fname{ii}),donotparsehardware);
                end
            else
                valout = 'Unrecognized data type, not parsed';
            end
        end
        function varargout = ListObj(varargin)
            % Examples:
            % objs = qes.qHandle.ListObj(); % get all qHandle class objects
            % objs = qes.qHandle.ListObj('Waveform'); % get all Waveform class
            % objects
            
            persistent objlst % object pool
            if isempty(objlst)
                objlst = {};
            end
            if nargin == 0 % return all registered qHandle class object
                varargout{1} = objlst;
            elseif isa(varargin{1},'qes.qHandle') % register a qHandle class object
                if varargin{1}.temperory % temperoy objects are not kept in object list, if it is already registed, remove it from the registry.
                    % remove if already in is good by rarely needed, temperory
                    % property is only set from true to false and is defined in
                    % class definition, checking at every object creation is no neccessay.
        %             NumObj = length(objlst);
        %             ii = 1;
        %             while ii <= NumObj
        %                 if ~isobject(objlst{ii}) || ~isvalid(objlst{ii})
        %                     objlst(ii) = [];
        %                     NumObj = NumObj - 1;
        %                     ii = ii - 1;
        %                 elseif objlst{ii} == varargin{1}
        %                     objlst(ii) = [];
        %                     break;
        %                 end
        %                 ii = ii +1;
        %             end
                    return;
                end
                ii = 1;
                NumObj = length(objlst);
                while ii <= NumObj
                    if ~isobject(objlst{ii}) || ~isvalid(objlst{ii})
                        objlst(ii) = [];
                        NumObj = NumObj - 1;
                        ii = ii - 1;
                    elseif objlst{ii} == varargin{1}
                        break;
                    end
                    ii = ii +1;
                end
                if ii > NumObj
                    objlst = [objlst, varargin(1)];
                end
            elseif ischar(varargin{1}) % return registered object of a specific class
                NumObj = length(objlst);
                ii = 1;
                Objs = {};
                while ii <= NumObj
                    if ~isvalid(objlst{ii})
                        objlst(ii) = [];
                        NumObj = NumObj - 1;
                        ii = ii - 1;
                    elseif isa(objlst{ii},varargin{1})
                        Objs = [Objs;objlst(ii)];
                    end
                    ii = ii +1;
                end
                varargout{1} = Objs;
            end
        end
        function objs = FindByClass(classname)
            % objs = qes.qHandle.ListObj('Waveform'); % get all Waveform class objects
            if ~ischar(classname)
                error('qHandle:InvalidInput','classname is not a character string');
            end
            objs = qes.qHandle.ListObj(classname);
        end
        function objs = FindByProp(PopertyName,PopertyVal)
            % objs = qes.qHandle.FindByProp('PopertyName',PopertyVal); % find class
            % object obj which satisfy obj.PopertyName == PopertyVal.

            if ~ischar(PopertyName)
                error('qHandle:InvalidInput','classname is not a character string');
            end
            objs = {};
            allobjs = qes.qHandle.ListObj();
            for ii = 1:length(allobjs)
                if isprop(allobjs{ii},PopertyName)
                    if isempty(allobjs{ii}.(PopertyName)) && isempty(PopertyVal)
                        objs = [objs,allobjs(ii)];
                    elseif ischar(allobjs{ii}.(PopertyName)) && strcmp(allobjs{ii}.(PopertyName),PopertyVal)
                        objs = [objs,allobjs(ii)];
                    else % numeric or class objects with eq method
                        try
                            if allobjs{ii}.(PopertyName) == PopertyVal
                                objs = [objs;allobjs(ii)];
                            end
                        catch
                        end
                    end
                end
            end
        end
        function obj = FindByClassProp(ClassName,PopertyName,PopertyVal)
            % find ClassName class object obj which satisfy obj.PopertyName == PopertyVal.

            obj = [];
            if ~ischar(PopertyName)
                error('qHandle:InvalidInput','classname is not a character string');
            end
            switch ClassName
                case 'waveform'
                    ClassName = 'qes.waveform.waveform';
                case 'hardware'
                    ClassName = 'qes.hwdriver.hardware';
            end
            allobj = qes.qHandle.FindByClass(ClassName);
            for ii = 1:length(allobj)
                if isprop(allobj{ii},PopertyName)
                    if isempty(allobj{ii}.(PopertyName)) && isempty(PopertyVal)
                        obj = allobj{ii};
                    elseif ischar(allobj{ii}.(PopertyName)) && strcmp(allobj{ii}.(PopertyName),PopertyVal)
                        obj = allobj{ii};
                    else % numeric or class objects with eq method
                        try
                            if allobj{ii}.(PopertyName) == PopertyVal
                                obj = allobj{ii};
                            end
                        catch
                        end
                    end
                end
            end
			if isempty(obj)
				throw(MException('QOS_hardware:hardwareNotFound',...
					sprintf('%s class hardware with matching %s property not found.',...
					ClassName,PopertyName)));
			end
        end
        function DeleteByClass(classname)
            % objs = qes.qHandle.DeleteByClass('Waveform'); % delete all Waveform class objects
            objs = qes.qHandle.FindByClass(classname);
            for ii = 1:length(objs)
                objs{ii}.delete;
            end
        end
        function DeleteByProp(PopertyName,PopertyVal)
            % objs = qes.qHandle.DeleteByProp('PopertyName',PopertyVal); % delete all class
            % object obj which satisfy obj.PopertyName == PopertyVal.
            objs = qes.qHandle.FindByProp(PopertyName,PopertyVal);
            for ii = 1:length(objs)
                objs{ii}.delete;
            end
        end
    end
end