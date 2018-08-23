function varargout = iq2prob_01(varargin)
% iq2prob_01: calibrate iq to qubit state probability, |0> and |1>
% 
% <[_f_]> = iq2prob_01('qubit',_c&o_,'numSamples',_i_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*
	
	numSamples_MIN = 1e4;
	
	args = util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
	
    if args.numSamples < numSamples_MIN
        throw(MException('QOS_iq2prob_01:numSamplesTooSmall',...
			sprintf('numSamples too small, %0.0f minimu.', numSamples_MIN)));
    end

    X = gate.X(q);
    R = measure.resonatorReadout(q);
    R.delay = X.length; 

    num_reps = ceil(args.numSamples/q.r_avg);
    iq_raw_1 = NaN*ones(num_reps,q.r_avg);
    for ii = 1:num_reps
        X.Run();
        R.Run();
        iq_raw_1(ii,:) = R.extradata;
    end
    iq_raw_1 = iq_raw_1(:).';

    iq_raw_0 = NaN*ones(num_reps,q.r_avg);
    for ii = 1:num_reps
        R.Run();
        iq_raw_0(ii,:) = R.extradata;
    end
    iq_raw_0 = iq_raw_0(:).';

    [center0, center1,F00,F11, hf] =... 
		data_taking.public.dataproc.iq2prob_centers(iq_raw_0,iq_raw_1,~args.gui);

    if ischar(args.save)
        args.save = false;
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
    if args.save
        QS = qes.qSettings.GetInstance();
		QS.saveSSettings({q.name,'r_iq2prob_center0'},center0);
        QS.saveSSettings({q.name,'r_iq2prob_center1'},center1);
		QS.saveSSettings({q.name,'r_iq2prob_fidelity'},...
			sprintf('[%0.3f,%0.3f]',F00,F11));
        % QS.saveSSettings({q.name,'r_iq2prob_01rPoint'},rPoint);
        % QS.saveSSettings({q.name,'r_iq2prob_01angle'},ang);
        % QS.saveSSettings({q.name,'r_iq2prob_01threshold'},threshold);
        % QS.saveSSettings({q.name,'r_iq2prob_01polarity'},num2str(polarity,'%0.0f'));
        if ~isempty(hf) && isvalid(hf)
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                ['iqRaw_',q.name,'_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            saveas(hf,dataSvName);
        end
    end

	varargout{1} = center0;
	varargout{1} = center1;
end