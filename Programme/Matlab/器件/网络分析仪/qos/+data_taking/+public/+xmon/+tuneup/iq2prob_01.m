function varargout = iq2prob_01(varargin)
% supports multiple qubits parallel calibration
%
% iq2prob_01: calibrate iq to qubit state probability, |0> and |1>
% 
% <[_f_]> = iq2prob_01_multiplexed('qubits',[_c&o_],'numSamples',_i_,...
%       'checkResult',<_b_>,'gui',<_b_>,'save',<_b_>,'logger',<_o_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: objectve
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.
% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*
    import sqc.util.getQSettings
	
	numSamples_MIN = 5e3;
	
	args = util.processArgs(varargin,{'fineTune',false,'gui',false,'save',true,'logger',[]});
	qubits = args.qubits;
	if ~iscell(qubits)
		qubits = {qubits};
    end

    if args.numSamples < numSamples_MIN
        if ~isempty(args.logger)
            args.logger.error('QOS_iq2prob_01:IllegalArgument',sprintf('numSamples too small, %0.0f minimu.', numSamples_MIN));
        end
        throw(MException('QOS_iq2prob_01:numSamplesTooSmall',...
			sprintf('numSamples too small, %0.0f minimu.', numSamples_MIN)));
    end
    
    N = 3000; 
    numQs = numel(qubits);
    for ii = 1:numQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
		qubits{ii}.r_avg = N;
    end

    R = measure.resonatorReadout(qubits);
    RDelay = 0;
    X = cell(1,numQs);
    for ii = 1:numQs
		X{ii} = gate.X(qubits{ii});
		RDelay = max(RDelay,X{ii}.length);
    end
    R.delay = RDelay;

    num_reps = ceil(args.numSamples/N);
    iq_raw_1 = nan(numQs,num_reps*N);
    sInd = 1;
    for ii = 1:num_reps
        for jj = 1:numQs
            X{jj}.Run();
        end
        R.Run();
        iq_raw_1(:,sInd:sInd+N-1) = R.extradata;
        sInd = sInd+N;
    end

    iq_raw_0 = nan(numQs,num_reps*N);
    sInd = 1;
    for ii = 1:num_reps
        R.Run();
        iq_raw_0(:,sInd:sInd+N-1) = R.extradata;
        sInd = sInd+N;
    end

	for ii = 1:numQs
        q = qubits{ii};
        [center0, center1,F00,F11, hf,axs,iqWidth] =... 
            data_taking.public.dataproc.iq2prob_means(iq_raw_0(ii,:),iq_raw_1(ii,:),~args.gui);
%             data_taking.public.dataproc.iq2prob_centers(iq_raw_0(ii,:),iq_raw_1(ii,:),~args.gui);
        r_iq2prob_center0_o = getQSettings('r_iq2prob_center0',q.name);
        r_iq2prob_center1_o = getQSettings('r_iq2prob_center1',q.name);
        if ~isempty(axs)
            try 
                hold(axs(1),'on');
                plot(axs(1),r_iq2prob_center0_o,'+','Color','w','MarkerSize',10,'LineWidth',0.5);
                plot(axs(1),r_iq2prob_center1_o,'+','Color','g','MarkerSize',10,'LineWidth',0.5);
                hold(axs(1),'off');
                set(hf,'Name',[get(hf,'Name'), ' | ',q.name]);
            catch
            end
        end
        if ischar(args.save)
            args.save = false;
            choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%             choice  = questdlg('Update settings?','Save options',...
%                     'Yes','No','No');
            if ~isempty(choice) && strcmp(choice, 'Yes')
                args.save = true;
            end
        end
        if args.save
            QS = qes.qSettings.GetInstance();
            
            if args.fineTune
                D0 = abs(center0 - r_iq2prob_center0_o);
                if ~isempty(q.r_iqWidth) && D0 > q.r_iqWidth
                    if ~isempty(args.logger)
                        args.logger.error('QOS_iq2prob_01:LargeChange',...
                            [q.name,': Large change measured on r_iq2prob_center0, settings not updated.']);
                    end
                    warning('iq2prob_01:LargeChange',...
                        [q.name,': Large change measured on r_iq2prob_center0, settings not updated.']);
%                     throw(exceptions.QRuntimeException('iq2prob_01:LargeChange',...
%                         [q.name,': Large change measured on r_iq2prob_center0']));
                    continue;
                elseif abs(center1 - center0) < 0.5*abs(r_iq2prob_center1_o - r_iq2prob_center0_o)
                    if ~isempty(args.logger)
                        args.logger.error('QOS_iq2prob_01:LargeChange',...
                            [q.name,': Large change measured on center1 center0 distance']);
                    end
                    warning('iq2prob_01:LargeChange',...
                        [q.name,': Large change measured on center1 center0 distance']);
%                     throw(exceptions.QRuntimeException('iq2prob_01:LargeChange',...
%                         [q.name,': Large change measured on center1 center0 distance']));
                    continue;
                end
            end
            QS.saveSSettings({q.name,'r_iq2prob_center0'},center0);
            QS.saveSSettings({q.name,'r_iq2prob_center1'},center1);
            QS.saveSSettings({q.name,'r_iq2prob_fidelity'},...
                sprintf('[%0.3f,%0.3f]',F00,F11));
            QS.saveSSettings({q.name,'r_iqWidth'},iqWidth);
            if ~isempty(hf) && isvalid(hf)
                dataSvName = fullfile(QS.loadSSettings('data_path'),...
                    ['iqRaw_',q.name,'_',datestr(now,'yymmddTHHMMSS'),...
                    num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
                try
                    saveas(hf,dataSvName);
                catch
                    warning('save figure failed.');
                end
            end
        end
	end

	varargout{1} = center0;
	varargout{2} = center1;
    varargout{3} = F11+F00-1;
    varargout{4} = [F00,F11];
end