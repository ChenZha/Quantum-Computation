classdef qSettings < handle
    % setting of QOS

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        user
		hardware
    end
	properties (SetAccess = private)
        root
		session % to switch session, use SS, session is protected from direct asign with reasons, do not change.
		hwCreated = false
	end
	methods (Access = private)
         function obj = qSettings(root)
             if nargin && isdir(root) && exist(root,'dir')
                 obj.root = root;
             else
                 throw(MException('QOS:qSettings:invalidRootPath',...
					sprintf('settings root path %s not found.', root)));
             end
         end
    end
    methods
        function set.user(obj,username)
            if isempty(dir(fullfile(obj.root,username)))
                throw(MException('QOS:qSettings:invalidUser',...
					sprintf('settings for user %s not found.', obj.user)));
            end
            obj.user = username;
			obj.session = [];
        end
        function set.session(obj,sessionname)
			if isempty(obj.user)
				throw(MException('QOS:qSettings:userNotSet',...
                    'user not set.')); % session can only be set after user is set
			end
			if isempty(sessionname)
				obj.session = [];
                return;
			end
            if isempty(dir(fullfile(obj.root,obj.user,sessionname)))
                throw(MException('QOS:qSettings:sessionNotFound',...
					sprintf('session %s not found for user %s .', sessionname, obj.user)));
            end
            data_path = qes.util.loadSettings(obj.root,{obj.user,sessionname,'data_path'});
            if ~isdir(data_path)
                throw(MException('QOS:qSettings:dataPathError',...
					sprintf('session %s has no data_path setting or not a valid path.', sessionname)));
            end
            if isempty(data_path)
                mkdir(data_path);
            end
            old_session = qes.util.loadSettings(obj.root,{obj.user,'selected'});
            if strcmp(old_session,sessionname)
                return;
            end
            movefile(fullfile(obj.root,obj.user,['selected@',old_session,'.key']),...
                fullfile(obj.root,obj.user,['selected@',sessionname,'.key']));
        end
		function set.hardware(obj,hwGroup)
			if isempty(dir(fullfile(obj.root,'hardware',hwGroup)))
                throw(MException('QOS:qSettings:InvalidInput',...
					sprintf('hardware group %s not found.', hwGroup)));
            end
            old_hwGroup = qes.util.loadSettings(obj.root,{'hardware','selected'});
            if strcmp(old_hwGroup,hwGroup)
                return;
            end
            movefile(fullfile(obj.root,'hardware',['selected@',old_hwGroup,'.key']),...
                fullfile(obj.root,'hardware',['selected@',hwGroup,'.key']));
            hwObjs = qes.qHandle.FindByClass('qes.hwdriver.hardware');
            for ii = 1:numel(hwObjs)
                try
                    hwObjs{ii}.delete();
                catch ME
                    warning(getReport(ME));
                end
            end
			obj.hwCreated = false;
		end
        function val = get.session(obj)
            try
                val = qes.util.loadSettings(obj.root,{obj.user,'selected'});
            catch
                val = [];
            end
        end
		function val = get.hardware(obj)
            try
                val = qes.util.loadSettings(obj.root,{'hardware','selected'});
            catch
                val = [];
            end
        end
        function SU(obj,username)
            % switch or set user
            obj.user = username;
        end
        function SS(obj,sessionname)
            % switch or set session
            obj.session = sessionname;
        end
		function SHW(obj,hw)
            % switch or set hardware
            obj.hardware = hw;
        end
        function s = loadSSettings(obj,fields)
            % loads settings in selected session
            % ommit the fields argument to load all
            if isempty(obj.user)
                throw(MException('QOS:qSettings:userNotSet','user not set.'));
            end
            fieldNameGiven = true;
            if nargin < 2
                fieldNameGiven = false;
                fields = qes.util.loadSettings(obj.root,{obj.user,obj.session,'selected'});
                if ~exist(fullfile(obj.root,obj.user,obj.session,'shared'),'file')
                    throw(MException('QOS:qSettings:publicSettingsNotExist',...
						'shared settings not found, each session must have a shared settings group.'));
                end
				for ii = 1:numel(fields)
					if ~exist(fullfile(obj.root,obj.user,obj.session,fields{ii}),'file')
						throw(MException('QOS:qSettings:nonExistentQObjects',...
							'selected qobject %s dose not exist.', fields{ii}));
					end
				end
                fields = [{'shared'},fields];
            end
            if ~iscell(fields)
                fields = {fields};
            end
            numSets = numel(fields);
            % if field name not given, we have to return a struct with the
            % field name as the struct field name, not just the value,
            % otherwise the user will know what field this value
            % corresponds to.
            if fieldNameGiven
                s = qes.util.loadSettings(obj.root,[{obj.user,obj.session},fields]);
            else
                s = struct();
                for ii = 1:numSets
                    s.(fields{ii}) = qes.util.loadSettings(obj.root,[{obj.user,obj.session},fields{ii}]);
                end
            end
%             if numSets == 1 && fieldNameGiven
%                 s = qes.util.loadSettings(obj.root,[{obj.user,obj.session},fields{1}]);
%                 s = struct();
%                 for ii = 1:numSets
%                     s.(fields{ii}) = qes.util.loadSettings(obj.root,[{obj.user,obj.session},fields{ii}]);
%                 end
%             end
            
        end
        function [time,data] = loadSSettingsHis(obj,fields)
            % loads settings in selected session with history data
            if isempty(obj.user)
                throw(MException('QOS:qSettings:userNotSet','user not set.'));
            end
            if nargin < 2
                error('not enough arguments');
            end
            if ~iscell(fields)
                fields = {fields};
            end
            [current_data,his_data,his_time] = qes.util.loadSettings(obj.root,[{obj.user,obj.session},fields]);
            time = [his_time; now];
            data = [his_data; current_data];
        end
        function saveSSettings(obj,field,value)
            % saves settings value of a specific fied in selected session
            if ~iscell(field)
                if ~ischar(field)
                    throw(MException('QOS:qSettings:InvalidInput','invalid field name.'));
                else
                    field = {field};
                end
            end
            qes.util.saveSettings(obj.root,[{obj.user,obj.session},field], value);
        end
        function s = loadHwSettings(obj,fields)
            % loads hardware settings specified by fields or loads all if
            % fields no specified in selected hardware settings groups
            if nargin>1 && ~isempty(fields) && ~iscell(fields)
                fields = {fields};
            end
            selected_hw_settings_group = qes.util.loadSettings(obj.root,{'hardware','selected'});
            if isempty(dir(fullfile(obj.root,'hardware',selected_hw_settings_group)))
                throw(MException('QOS:qSettings:settingsNotFound',...
					sprintf('hardware settings group %s is selected, but no such settings group is found.',...
					selected_hw_settings_group)));
            end
            if nargin>1 && ~isempty(fields)
                s = qes.util.loadSettings(obj.root,[{'hardware',selected_hw_settings_group},fields]);
            else % loads all
                s = qes.util.loadSettings(obj.root,{'hardware',selected_hw_settings_group});
            end
        end
        function saveHwSettings(obj,field,value)
            % saves hardware settings specified by fields
            selected_hw_settings_group = qes.util.loadSettings(obj.root,{'hardware','selected'});
            if isempty(dir(fullfile(obj.root,'hardware',selected_hw_settings_group)))
                throw(MException('QOS:qSettings:settingsNotFound',... 
					sprintf('hardware settings group %s is selected, but no such settings group is found.',...
					selected_hw_settings_group)));
            end
            qes.util.saveSettings(obj.root,[{'hardware',selected_hw_settings_group},field],value);
        end
        function CreateHw(obj)
            %
            selected_hw_settings_group = qes.util.loadSettings(obj.root,{'hardware','selected'});
            if isempty(dir(fullfile(obj.root,'hardware',selected_hw_settings_group)))
                throw(MException('QOS:qSettings:settingsNotFound',...
					sprintf('hardware settings group %s is selected, but no such settings group is found.',...
					selected_hw_settings_group)));
            end
            selected_hw = qes.util.loadSettings(obj.root,{'hardware',selected_hw_settings_group,'selected'});
            if ~iscell(selected_hw) % parseJson returns the elements itself in case of single element list
                selected_hw = {selected_hw};
            end
            for ii = 1:length(selected_hw)
                hw_settings = qes.util.loadSettings(obj.root,{'hardware',selected_hw_settings_group,selected_hw{ii}});
                hw_settings.name = selected_hw{ii};
                [~] = qes.util.hwCreator(hw_settings);
            end
			obj.hwCreated = true;
        end
        function DeleteHw(obj)
            %
            hwObjs = qes.qHandle.FindByClass('qes.hwdriver.hardware');
            for ii = 1:numel(hwObjs)
                try
                    hwObjs{ii}.delete();
                catch ME
                    warning(getReport(ME));
                end
            end
			obj.hwCreated = false;
        end
    end
    methods (Static)
        function obj = GetInstance(root)
            % qSettings is a global setting, if instance already exits, return the existing instance.
            persistent settingsobj;
            if ~isempty(settingsobj) &&  isvalid(settingsobj)
                obj = settingsobj;
                return;
            elseif nargin == 0
                logger = qes.util.log4m.getLogger();
                logger.info('qCloud.startup','start');
				throw(MException('QOS:qSettings:notEnoughInputArguments',...
					'settings object not created, the settings root path must be given.'));
			end
            settingsobj = qes.qSettings(root);
            obj = settingsobj;
        end
    end
end