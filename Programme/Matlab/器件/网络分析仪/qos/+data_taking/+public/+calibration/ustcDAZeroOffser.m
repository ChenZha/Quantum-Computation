function varargout = ustcDAZeroOffser(varargin)
    % run this function to calibrate USTC DA zero offset
    % 
    % awgZero('awgName',_c_,'chnl',_i_,'voltMeterName',_c_,...
    %       'gui',<_b_>,'save',<_b_>);
	% awgName: name of the awg to calibrate
	% chnl: channel to calibrate

% Yulin Wu, 2017

    args = qes.util.processArgs(varargin,{'fineCallibration',false,'avgnum',1,'gui',false});
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_awgZero:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    
    awgChnlMap = QS.loadHwSettings({args.awgName,'interface','chnlMap'});
    backendChnlMap = QS.loadHwSettings({'ustcadda','da_chnl_map'});
    boardIndChnlInd = strsplit(regexprep(backendChnlMap{awgChnlMap(args.chnl)},'\s+',''),',');
    fieldNameList = {'ustcadda',...
        sprintf('da_boards{%s}',boardIndChnlInd{1}),...
        sprintf('offsetCorr{%s}',boardIndChnlInd{2})};
    
    Calibrator = qes.measurement.awgZeroCalibrator.empty;
    numAvg = 1;
    function offsetCorr_ = Run()
        awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg','name',args.awgName);
        awgChnl = awgObj.GetChnl(args.chnl);
        voltMeter = qes.qHandle.FindByClassProp('qes.hwdriver.sync.voltMeter','name',args.voltMeterName);
        voltMeterChnl = voltMeter.GetChnl(1);
        voltMeterChnl.numAvg = numAvg;
        voltMeterChnl.range = 0.1;
        vm = qes.measurement.dcVoltage(voltMeterChnl);

        Calibrator = qes.measurement.awgZeroCalibrator(awgChnl,vm);
        if args.gui
            Calibrator.showProcess = true;
        end
        offsetCorr_ = Calibrator();
    end
    
    offsetCorr = Run();
    if args.fineCallibration
        AX = Calibrator.getAx();
        if ishghandle(AX)
           title(AX,'Coarse callibration done, proceed to fine callibration.');
           drawnow;
        end
    end
    
    da_boards = QS.loadHwSettings({'ustcadda','da_boards'});
    offsetCorr_old = da_boards{str2double(boardIndChnlInd{1})}.offsetCorr(str2double(boardIndChnlInd{2}));
    QS.saveHwSettings(fieldNameList,num2str(offsetCorr_old+offsetCorr,'%0.0f'));

    QS.DeleteHw();
    QS.CreateHw();
    if args.fineCallibration
        Calibrator.fine = true;
        numAvg = 10;
        offsetCorr_fine = Run();

        da_boards = QS.loadHwSettings({'ustcadda','da_boards'});
        offsetCorr_old = da_boards{str2double(boardIndChnlInd{1})}.offsetCorr(str2double(boardIndChnlInd{2}));
        QS.saveHwSettings(fieldNameList,num2str(offsetCorr_old+offsetCorr_fine,'%0.0f'));

        offsetCorr = offsetCorr + offsetCorr_fine;
    end
        
    varargout{1} = [];
end