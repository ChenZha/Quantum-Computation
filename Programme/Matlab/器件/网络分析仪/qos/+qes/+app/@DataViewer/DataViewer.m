classdef (Sealed = true)DataViewer < handle
    % QOS data viewer
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % data folder, view all data files in this folder, sub folders are
        % included.
        datadir
        plotfunc = 1; % index of plot function, the plot funciton is one of 'availableplotfcns'
        readonly = false;
    end
    properties (SetAccess = private, GetAccess = private)
        % cell, each cell element is the path of a data file
        datafilepaths
        % cell, each cell element is a file name of a data file with its absolute path,
        % example: 'C:\data\150604\sample1\ICM_150608T10152237_[hi]_.mat'
        datafiles_full 
        % cell, each cell elememet is a file name of a data file,
        % example: 'ICM_150608T10152237_[hi]_.mat
        datafiles
        datatime % time stamp of data
        % 0/1 for each data file, indicating data file being deleted or
        % not. the purpose of setting a filedeleted property is to reduce
        % programming complexity: when the nth file is deleted, only the
        % filedeleted(n) is given a value true to the mark the deletion,
        % datafiles_full, datafiles, datatime, files2show etc. are kept
        % unchanged as changing then accorddingly would bring much
        % programming complexity.
        filedeleted 
        
        % data file index of files to show,
        % the data file name of the nth element is datafiles{files2show(nth)}
        % files2show can only be one of the three list allfiles, unhidden or hilighted
        files2show
        % data file index of the current data file,
        % the data file name is datafiles{files2show(currentfile)}
        currentfile
        % data file index of the preview data files,
        % the data file name of the nth element is datafiles{files2show(previewfiles(nth))}
        previewfiles
        
        % loaded data, has the same length as previewfiles, 
        % loadeddata(n) is the data of data file datafiles{previewfiles(n)}
        loadeddata

        allfiles % data file index of all data file 
        unhidden % data file index of all unhidden data file 
        hilighted % data file index of all hilighted data file 
        
        fullnamesubmarkstr % full filename without datamarkstr
        datamarkstr % data marker string of all data files.
        
        uihandles % handles of ui componenents.
        donotplot = false;
        changed2newlst = false;
		resizable
    end
    properties (Constant = true, GetAccess = private)
        numpreview = 8 % number of preview data files is 2*numpreview+1, do not change.
        % available plot funcions, Default: use the data specified plot
        % function or if no plot funciton specified in data,
        % 'OneMeasReal_Def' is used.
        % available plot fucntions are functions in package '+qes.util.plotfcn'
        availableplotfcns = {'Data specified or default','OneMeas_Def','OneMeasReal_1D_Mkr',...
            'OneMeasReal_2DMap_SubBkgrd_Y','OneMeasReal_2DMap_SubBkgrdMin_Y',...
            'OneMeasReal_2DMap_SubBkgrdMax_Y','OneMeasReal_2DMap_SubBkgrd_X',...
            'OneMeasReal_2DMap_SubBkgrdMin_X','OneMeasReal_2DMap_SubBkgrdMax_X',...
            'OneMeasComplex_1D_Amp','OneMeasComplex_1D_Phase',...
            'OneMeasComplex_2DMap_Amp','OneMeasComplex_2DMap_Amp_X','OneMeasComplex_2DMap_Amp_Y',...
            'OneMeasComplex_2DMap_Amp_dB_X','OneMeasComplex_2DMap_Amp_dB_Y',...
            'OneMeasComplex_2DMap_Phase','OneMeasComplex_2DMap_Phase_X','OneMeasComplex_2DMap_Phase_Y',...
            'sparam.Amplitude','sparam.AmplificationInDB','sparam.Phase','T1'};
        availablefitfcns={'Spectrum','T_1','Ramsey','Rabi','Test'};
    end
    methods
        function obj = DataViewer(datadir, resizable_)
            if nargin && ischar(datadir) && isdir(datadir) && ~isempty(dir(datadir))
                obj.datadir = datadir;
            else
                obj.datadir = pwd;
            end
			if nargin < 2
				resizable_ = true;
			end
			obj.resizable = resizable_;
			if obj.resizable
				obj.CreateGUI_resizable();
			else
				obj.CreateGUI_fixed();
			end
        end
        function set.plotfunc(obj,val)
            val = round(val);
            if val < 1 || val > length(obj.availableplotfcns)
                error('DataViewer:plotfunc','illegal value.');
            end
            obj.plotfunc = val;

            if isempty(obj.uihandles)
                return;
            end
            handles = obj.uihandles;
            if isempty(obj.previewfiles)
                return;
            end
            idx = find(obj.previewfiles == obj.currentfile,1);
            data = obj.loadeddata{idx};
%             if isempty(data)
%                 plot(handles.mainax,NaN,NaN);
%                 XLIM = get(handles.mainax,'XLim');
%                 YLIM = get(handles.mainax,'YLim');
%                 text('Parent',handles.mainax,'Position',[mean(XLIM),mean(YLIM)],'String','Unable to plot.',...
%                         'HorizontalAlignment','center','VerticalAlignment','middle',...
%                         'Color',[1,0,0],'FontSize',25,'FontWeight','bold');
%                 errordlg(['Plot data failed due to: ', data.Config],'Error!','modal'); % errordlg can not parse hyperlinks.
%                 return;
%             end
            if (isfield(data,'Info') && ischar(data.Info)) ||... % old version data
                   (isfield(data,'Config') && ischar(data.Config)) 
                if ~isempty(obj.donotplot) && ~obj.donotplot
                    if isfield(data,'Info')
                        errordlg([data.Info],'Error!','modal'); % errordlg can not parse hyperlinks.
                    else
                        errordlg([data.Config],'Error!','modal'); % errordlg can not parse hyperlinks.
                    end
                end
                return;
            end
            if obj.plotfunc == 1
                if isfield(data,'Info') && isfield(data.Info,'plotfcn') && ~isempty(data.Info.plotfcn) && ischar(data.Info.plotfcn)
                    PlotFcn = str2func(data.Info.plotfcn);
                elseif isfield(data,'Config') && isfield(data.Config,'plotfcn') && ~isempty(data.Config.plotfcn) && ischar(data.Config.plotfcn)
                    PlotFcn = str2func(data.Config.plotfcn);
                else
                    PlotFcn = @qes.util.plotfcn.OneMeas_Def; % default
                end
            else
                PlotFcn = str2func(['qes.util.plotfcn.',obj.availableplotfcns{obj.plotfunc}]);
            end
            handles = obj.uihandles;
            set(handles.xsliceax,'Visible','off');
            set(handles.ysliceax,'Visible','off');
            set(handles.cx,'Visible','off');
            set(handles.cy,'Visible','off');
            set(handles.cz,'Visible','off');
            set(handles.XYTraceBtn,'Value',0);
            set(handles.mainax,'Position',handles.mainaxfullpos);
            set(handles.dataviewwin,'WindowButtonMotionFcn',[]);
            hold(handles.xsliceax,'off');
            hold(handles.ysliceax,'off');
            
            try
                if ~isempty(obj.donotplot) && ~obj.donotplot
                    if isfield(data,'Info')
                        feval(PlotFcn,data.Data, data.SweepVals,data.ParamNames,data.SwpMainParam,data.Info.measurement_names,handles.mainax);
                    else
                        feval(PlotFcn,data.Data, data.SweepVals,data.ParamNames,data.SwpMainParam,data.Config.measurement_names,handles.mainax);
                    end
                end
            catch
                plot(handles.mainax,NaN,NaN);
                XLIM = get(handles.mainax,'XLim');
                YLIM = get(handles.mainax,'YLim');
                text('Parent',handles.mainax,'Position',[mean(XLIM),mean(YLIM)],'String','Unable to plot.',...
                        'HorizontalAlignment','center','VerticalAlignment','middle',...
                        'Color',[1,0,0],'FontSize',25,'FontWeight','bold');
                errordlg(['Plot data failed. In most cases this due to the choosen  plot function can not handle the current data set.'],'Error!','modal'); % errordlg can not parse hyperlinks.
            end
        end
        function set.datadir(obj,val)
            % reset
            obj.datafilepaths = {};
            obj.datafiles_full = {};
            obj.datafiles = {};
            obj.datatime = [];
            obj.filedeleted = [];
            obj.files2show = [];
            obj.previewfiles = [];
            obj.loadeddata = [];
            obj.allfiles = [];
            obj.unhidden = [];
            obj.hilighted = [];
            obj.fullnamesubmarkstr = {};
            obj.datamarkstr = {};
            
            if ~exist(val,'dir')
                error('DataViewer:SetDir','directory not exist.');
            end
            obj.datadir = val;
            [FilePath,FileName] = qes.app.DataViewer.GetAllFiles(val);
            if ~isempty(FileName)
                Filename_full = fullfile(FilePath,FileName);
            else
                Filename_full={};
            end
            NumFilseFound = length(Filename_full);
            matfileidx = zeros(1,NumFilseFound);
            for ii = 1:NumFilseFound
                if length(FileName{ii})>=4 && strcmp(FileName{ii}(end-3:end),'.mat')
                    matfileidx(ii) = 1;
                end
            end
            matfilespath = FilePath(logical(matfileidx));
            matfiles = FileName(logical(matfileidx));
            matfiles_fullname = Filename_full(logical(matfileidx));
            NumMatFilse = length(matfiles);
            idstrs = {};
            for ii = 1:NumMatFilse
                idx = regexpi(matfiles{ii},'_\d{6}T\d{8}[_.]');
                if isempty(idx)
                    % unrecognized filename format
                    continue;
                else
                    datamaskstr = matfiles{ii}(idx+16:end-4);
                    idstrsi = matfiles{ii}(idx+1:idx+15);
                    fullnamesubmarkstri = matfiles_fullname{ii}(1:end-length(matfiles{ii})+idx+15);
                    includefile = true;
                    for ee = 1:length(idstrs)
                        if strcmp(idstrs{ee},idstrsi) % identical name except mark, this happens when someone add marks to a copy of datafile manually.
                            if ~isempty(regexpi(obj.datamarkstr{ee},'\[.*\]')) ||...
                                    (isempty(regexpi(datamaskstr,'\[.*\]')) &&...
                                    (isempty(obj.datamarkstr{ee}) || ~isempty(datamaskstr))) % ignore the current datafile
                                warning(['Datafile', 10, obj.datafiles_full{ee} ,10, 'shadows datafile', 10, matfiles_fullname{ii}]);
                            else % replace the previous found with the current datafile
                                obj.datamarkstr{ee} = datamaskstr;
                                obj.fullnamesubmarkstr{ee} = fullnamesubmarkstri;
                                obj.datafilepaths{ee} = matfilespath{ii};
                                obj.datafiles{ee} = matfiles{ii};
                                obj.datafiles_full{ee} = matfiles_fullname{ii};
                                obj.datatime(ee) = datenum(matfiles{ii}(idx+1:idx+13),'yymmddTHHMMSS');
                                warning(['Datafile', 10, matfiles_fullname{ii} ,10, 'shadows datafile', 10, obj.datafiles_full{ee}]);
                            end
                            includefile = false;
                            break;
                        end
                    end
                    if includefile
                        idstrs = [idstrs,{matfiles{ii}(idx+1:idx+15)}];
                        obj.datamarkstr{end+1} = datamaskstr;
                        obj.fullnamesubmarkstr{end+1} = fullnamesubmarkstri;
                        obj.datafilepaths{end+1} = matfilespath{ii};
                        obj.datafiles{end+1} = matfiles{ii};
                        obj.datafiles_full{end+1} = matfiles_fullname{ii};
                        obj.datatime = [obj.datatime, datenum(matfiles{ii}(idx+1:idx+13),'yymmddTHHMMSS')];
                    end
                end
            end
            [obj.datatime,idx] = sort(obj.datatime);
            obj.datafilepaths = obj.datafilepaths(idx);
            obj.datafiles = obj.datafiles(idx) ;
            obj.datafiles_full = obj.datafiles_full(idx);
            obj.datamarkstr = obj.datamarkstr(idx);
            obj.fullnamesubmarkstr = obj.fullnamesubmarkstr(idx);
            NumDataFiles = length(obj.datafiles);
            obj.filedeleted = false(1,NumDataFiles);
            obj.loadeddata = [];
            
            obj.allfiles = 1:NumDataFiles;
            obj.unhidden = [];
            obj.hilighted = [];
            for ii = 1:NumDataFiles
                if isempty(strfind(obj.datamarkstr{ii},'[ex]'))
                    obj.unhidden = [obj.unhidden,ii];
                elseif ~isempty(regexp(obj.datamarkstr{ii},'\[hi\d{0,1}\]','ONCE'))  % irregular file name, hilighted files should not be hidden
                    obj.datamarkstr{ii} = strrep(obj.datamarkstr{ii},'[ex]','');
                    obj.datafiles{ii} = strrep(obj.datafiles{ii},'[ex]','') ;
                    newfilename = [obj.fullnamesubmarkstr{ii},obj.datamarkstr{ii},'.mat'];
                    movefile(obj.datafiles_full{ii},newfilename);
                    obj.datafiles_full{ii} = newfilename;
                    obj.unhidden = [obj.unhidden,ii];
                    obj.hilighted = [obj.hilighted,ii];
                    continue;
                end
                if ~isempty(regexp(obj.datamarkstr{ii},'\[hi\d{0,1}\]','ONCE'))
                    obj.hilighted = [obj.hilighted,ii];
                end
            end
            obj.files2show = obj.allfiles; % by default, show all unhidden files
            numfiles2show = length(obj.files2show);
            if numfiles2show > 0 
                obj.currentfile = numfiles2show;
            end
            handles = obj.uihandles;
            if isempty(handles)
                return;
            end
            set(handles.SelectData,'value',1); % default: unhidden
        end
        function set.currentfile(obj,val)
            obj.currentfile = val;
            if isempty(val)
                obj.previewfiles = [];
                obj.loadeddata = {};
                return;
            end
            previewfiles_old = obj.previewfiles;
            obj.previewfiles =...
                max(1,obj.currentfile-obj.numpreview):...
                min(length(obj.files2show),obj.currentfile+obj.numpreview);
            loadeddata_old = obj.loadeddata;
            numPreviewFiles = length(obj.previewfiles);
            obj.loadeddata = cell(1,numPreviewFiles);
            % the reson for ii_K8jD28cQ75V0xMw39zL as looping index:
            % the looping index used to be ii, once there was a data set
            % with a variable named ii, leading to confusing results,
            % this took me a very long time to debug!
            for ii_K8jD28cQ75V0xMw39zL = 1:numPreviewFiles
                idx = find(obj.previewfiles(ii_K8jD28cQ75V0xMw39zL)==previewfiles_old,1);
                if (isempty(obj.changed2newlst) || ~obj.changed2newlst) && ~isempty(idx)
                      obj.loadeddata{ii_K8jD28cQ75V0xMw39zL} = loadeddata_old{idx};
                else
                    try
                        load(obj.datafiles_full{obj.files2show(obj.previewfiles(ii_K8jD28cQ75V0xMw39zL))});
                        temp.Data = Data;
                        temp.SweepVals = SweepVals;
                        temp.ParamNames = ParamNames;
                        temp.SwpMainParam = ones(size(SweepVals));
                        if exist('SwpMainParam','var')
                            temp.SwpMainParam = SwpMainParam;
                            clear('SwpMainParam'); % clear SwpMainParam is indespensible!
                        end
                        temp.Notes = Notes;
                        if exist('Info','var') % old version data
                            if isfield(Info,'measurementnames')
                                Info.measurement_names = Info.measurementnames;
                                Info = rmfield(Info,'measurementnames');
                            end
                            temp.Info = Info;
                        else
                            temp.Config = Config;
                            if ~isfield(Config,'user')
                                temp.Config.user = 'Unknown'; % to support old version data
                            end
                        end
                        if exist('SwpData','var')
                            temp.SwpData = SwpData;
                            clear('SwpData');  % clear SwpData is indespensible!
                        end
                        clear('Data','SweepVals','ParamNames','Notes','Info','Config');
                    catch ME
                        temp.Data = [];
                        temp.SweepVals = [];
                        temp.ParamNames = [];
                        temp.Notes = [];
                        temp.Config = ['Unable to load data due to: ', getReport(ME,'basic')];
                    end
                    obj.loadeddata{ii_K8jD28cQ75V0xMw39zL} = temp;
                end
            end
        end
        function NextN(obj,N)
            if isempty(obj.files2show)
                return;
            end
            if N > 0
                obj.currentfile = min(length(obj.files2show),obj.currentfile +N);
            else
                obj.currentfile = max(1,obj.currentfile +N);
            end
            handles = obj.uihandles;
            if isempty(obj.previewfiles)
                return;
            end
            set(handles.PlotFunction,'Value',1);
            obj.donotplot = true;
            obj.plotfunc = 1;
            obj.RefreshGUI();
            obj.donotplot = false;
        end
        function Next(obj)
            obj.NextN(1);
        end
        function Previous(obj)
            obj.NextN(-1);
        end
        function NextPage(obj)
            obj.NextN(2*obj.numpreview +1);
        end
        function PreviousPage(obj)
            obj.NextN(-2*obj.numpreview -1);
        end
        function delete(obj)
            handles = obj.uihandles;
            if ~isempty(handles) && ishghandle(handles.basepanel)
                delete(handles.basepanel);
            end
        end
        SelectData(obj,choice)
        RefreshGUI_fixed(obj)
        RefreshGUI_resizable(obj)
        DeleteFile(obj)
        HideFile(obj)
        HilightFile(obj,option)
        Save(obj)
        ExportData(obj)
        ExtractLine(obj)
    end
    methods (Access = private)
        CreateGUI(obj)
    end
    methods (Static)
        [FilePaths,  FileNames] = GetAllFiles(DIR)
        [out1,out2,out3] = Ginput(arg1)
        table_data = Config2TableData(Config);
    end
end