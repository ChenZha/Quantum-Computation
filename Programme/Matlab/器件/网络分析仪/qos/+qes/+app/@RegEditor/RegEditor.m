classdef (Sealed = true)RegEditor < handle
    % Registry editor
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        qs
        nodeParent
        nodeName
        userList
        hwList
        sessionList
        guiHandles
        
        tblRefreshTmr
        
        keyAnnotation
        bigScreen = false
        winSize
        leftPanelWidth
    end
    properties (Constant = true, GetAccess = private)
        tblRefreshPeriond = 30
    end
    methods
        function obj = RegEditor()
            try
                obj.qs = qes.qSettings.GetInstance();
            catch
                qsRootDir = uigetdir(pwd,'Select the registry directory:');
                if ~ischar(qsRootDir)
                    return;
                end
                try
                    obj.qs = qes.qSettings.GetInstance(qsRootDir);
                catch ME
                    qes.ui.msgbox(['qSettings object can not be created due to:',...
                        getReport(ME,'extended','hyperlinks','off')],'Error!');
                    return;
                end
            end
            try
                obj.bigScreen = qes.util.loadSettings(obj.qs.root,{'misc','registryEditor','bigScreen'});
            catch
                obj.bigScreen = false;
            end
            if obj.bigScreen
                obj.winSize = [0,0,150,65];
                obj.leftPanelWidth = 50.5;
            else
                obj.winSize = [0,0,100,40];
                obj.leftPanelWidth = 45.5;
            end
            userList_ = {'_Not set_'};
            fInfo = dir(fullfile(obj.qs.root));
            for ii = 1:numel(fInfo)
                if fInfo(ii).isdir &&...
                        ~ismember(fInfo(ii).name,{'.','..','calibration','hardware'}) &&...
                        ~qes.util.startsWith(fInfo(ii).name,'_')
                    userList_ = [userList_,{fInfo(ii).name}];
                end
            end
            obj.userList = userList_;
            hwList_ = {'_Not set_'};
            fInfo = dir(fullfile(obj.qs.root,'hardware'));
            for ii = 1:numel(fInfo)
                if fInfo(ii).isdir && ~ismember(fInfo(ii).name,{'.','..'})
                    hwList_ = [hwList_,{fInfo(ii).name}];
                end
            end
            obj.hwList = hwList_;
            if ~isempty(obj.qs.user)
                fInfo = dir(fullfile(obj.qs.root,obj.qs.user));
                sessionList_ = {'_Not set_'};
                for ii = 1:numel(fInfo)
                    if fInfo(ii).isdir &&...
                            ~ismember(fInfo(ii).name,{'.','..'}) &&...
                            ~qes.util.startsWith(fInfo(ii).name,'_')
                        sessionList_ = [sessionList_,{fInfo(ii).name}];
                    end
                end
                obj.sessionList = sessionList_;
            end
            
            anno = struct();
            % load Q object key annotation
            anno.qobject = [];
            finfo = dir(fullfile(obj.qs.root,'_annotation','qobject'));
            for ii = 1:numel(finfo)
                if strcmp(finfo(ii).name,'.') || strcmp(finfo(ii).name,'..')...
                        || ~finfo(ii).isdir
                    continue;
                end
                try
                    finfo_ = dir(fullfile(obj.qs.root,'_annotation','qobject',finfo(ii).name));
                    for jj =  1:numel(finfo_)
                        if finfo_(jj).isdir || ~qes.util.endsWith(finfo_(jj).name,'.key')
                            continue;
                        end
                        s = qes.util.loadSettings(...
                            fullfile(obj.qs.root,'_annotation','qobject',finfo(ii).name),finfo_(jj).name(1:end-4));
                        if isempty(s)
                            continue;
                        else
                            anno.qobject.(finfo(ii).name).(finfo_(jj).name(1:end-4)) = s;
                        end
                    end
                catch ME
                    warning(getReport(ME));
                end
            end
            % load hardware key annotation
            anno.hardware = [];
            finfo = dir(fullfile(obj.qs.root,'_annotation','hardware'));
            for ii = 1:numel(finfo)
                if strcmp(finfo(ii).name,'.') || strcmp(finfo(ii).name,'..') ||...
                       finfo(ii).isdir || ~qes.util.endsWith(finfo(ii).name,'.key')
                    continue;
                end
                try
                    s = qes.util.loadSettings(...
                        fullfile(obj.qs.root,'_annotation','hardware'),finfo(ii).name(1:end-4));
                    if isempty(s)
                        continue;
                    else
                        anno.hardware.(finfo(ii).name(1:end-4)) = s;
                    end
                catch ME
                    warning(getReport(ME));
                end
            end
            obj.keyAnnotation = anno;
            
            CreateGUI(obj);
%             %%% to deal with a bug in MATLAB 2016b
%             close(obj.guiHandles.reWin);
%             CreateGUI(obj);
%             %%%
        end
        function createUITree(obj)
            warning('off');
            fInfo = dir(fullfile(obj.qs.root,obj.qs.user,obj.qs.session));
            SSGroups = {};
            for ii = 1:numel(fInfo)
                if ~fInfo(ii).isdir || strcmp(fInfo(ii).name,'.')||...
                        strcmp(fInfo(ii).name,'..') ||...
                        qes.util.startsWith(fInfo(ii).name,'_')
                    continue;
                end
                SSGroups = [SSGroups, {fInfo(ii).name}];
            end
            selectedSSGroups = ['shared',obj.qs.loadSSettings('selected')];
            ss = uitreenode('v0', 'session settings', [obj.qs.user, '-',obj.qs.session], '.NULL', false);
            ss.setIcon(im2java(qes.app.RegEditor.ico_user()));
            for ii = 1:numel(SSGroups)
                node = uitreenode('v0', SSGroups{ii},  SSGroups{ii},  [], true);
                if qes.util.ismember(SSGroups{ii},selectedSSGroups) ||...
                        strcmp(SSGroups{ii},'public')
                    node.setIcon(im2java(qes.app.RegEditor.ico_qobject()));
                else
                    ico = qes.app.RegEditor.ico_qobject();
                    r = 0.4;
                    ico = (1-r)+r*ico;
                    node.setIcon(im2java(ico));
                end
                ss.add(node);
            end
            fInfo = dir(fullfile(obj.qs.root,'hardware',...
                qes.util.loadSettings(obj.qs.root,{'hardware','selected'})));
            HwSGroups = {};
            for ii = 1:numel(fInfo)
                if ~fInfo(ii).isdir || strcmp(fInfo(ii).name,'.')||...
                        strcmp(fInfo(ii).name,'..') ||...
                        qes.util.startsWith(fInfo(ii).name,'_')
                    continue;
                end
                HwSGroups = [HwSGroups, {fInfo(ii).name}];
            end
            selectedHwSGroups = obj.qs.loadHwSettings('selected');
            hws = uitreenode('v0', 'hardware settings', 'hardware', '.NULL', false);
            hws.setIcon(im2java(qes.app.RegEditor.ico_hardware_pci()));
            for ii = 1:numel(HwSGroups)
                node = uitreenode('v0', HwSGroups{ii},  HwSGroups{ii},  [], true);
                if qes.util.ismember(HwSGroups{ii},selectedHwSGroups)
                    node.setIcon(im2java(qes.app.RegEditor.ico_hardwave_chip()));
                else
                    ico = qes.app.RegEditor.ico_hardwave_chip();
                    r = 0.4;
                    ico = (1-r)+r*ico;
                    node.setIcon(im2java(ico));
                end
                hws.add(node);
            end

            % Root node
            rootNode = uitreenode('v0', 'registry', 'registry', [], false);
            rootNode.setIcon(im2java(qes.app.RegEditor.ico_settings()));
            rootNode.add(hws);
            rootNode.add(ss);
            
            OPSYSTEM = lower(system_dependent('getos'));
            if any([strfind(OPSYSTEM, 'microsoft windows xp'),...
                    strfind(OPSYSTEM, 'microsoft windows Vista'),...
                    strfind(OPSYSTEM, 'microsoft windows 7'),...
                    strfind(OPSYSTEM, 'microsoft windows server 2008'),...
                    strfind(OPSYSTEM, 'microsoft windows server 2003')])
                isWin10 = false;
            elseif any([strfind(OPSYSTEM, 'microsoft windows 10'),...
                    strfind(OPSYSTEM, 'microsoft windows server 10'),...
                    strfind(OPSYSTEM, 'microsoft windows server 2012')])
                isWin10 = true;
            else
                isWin10 = false;
            end
        
            if obj.bigScreen
                if isWin10
                    Pos = [5,5,255,750];
                else
                    Pos = [5,5,250,750];
                end
            else
                if isWin10
                    Pos = [5,5,230,430];
                else
                    Pos = [5,5,225,430];
                end
            end
            obj.guiHandles.mtree = uitree('v0', 'Root', rootNode,...
                'Parent',obj.guiHandles.reWin,'Position',Pos);
            set(obj.guiHandles.mtree,'NodeSelectedCallback', @SelectFcn);
            obj.guiHandles.mtree.expand(rootNode);
            obj.guiHandles.mtree.expand(ss);
            obj.guiHandles.mtree.expand(hws);

            function SelectFcn(tree,~)
                nodes = tree.SelectedNodes;
                if isempty(nodes) || ~nodes(1).isLeaf
                    return;
                end
                node = nodes(1);
                name = get(node,'Name');
                parentName = get(get(node,'Parent'),'Value');
                obj.nodeName = name;
                obj.nodeParent = parentName;
                set(obj.guiHandles.regTable,'Data',obj.TableData(name,parentName));
            end
            warning('on');
        end
        
        function delete(obj)
            if ~isempty(obj.guiHandles) &&...
                    isfield(obj.guiHandles,'reWin') &&...
                    ishghandle(obj.guiHandles.reWin)
                close(obj.guiHandles.reWin);
            end
            if ~isempty(obj.tblRefreshTmr)
                stop(obj.tblRefreshTmr);
                delete(obj.tblRefreshTmr);
            end
        end
    end
    methods (Access = private)
        CreateGUI(obj)
        t = CreateUITree(obj)
        table_data = TableData(obj,name,parentName)
    end
    methods (Static)
		cm = ico_settings()
		cm = ico_user()
		cm = ico_hardware_pci()
		cm = ico_hardwave_chip()
		cm = ico_qobject()
    end
end