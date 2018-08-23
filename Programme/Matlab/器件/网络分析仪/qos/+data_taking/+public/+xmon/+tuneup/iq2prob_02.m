function varargout = iq2prob_02(varargin)
% iq2prob_02: calibrate iq to qubit state probability, |0> and |1>
%
% <_f_> = iq2prob_02('qubit',_c&o_,'numSamples',_i_,...
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
	
	NUM_SAMPLES_MIN = 5e3;
	
	args = util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
	
    if num_samples < NUM_SAMPLES_MIN
        throw(MException('QOS_iq2prob_02:numSamplesTooSmall',...
			sprintf('num_samples too small, %0.0f minimu.', NUM_SAMPLES_MIN)));
    end

    X = gate.X(q);
    X12 = op.X12(q);
    P = X12*X;
    P.Run();
    R = measure.resonatorReadout(q);
    R.delay = q.qr_xy_piLn;

    num_reps = ceil(num_samples/q.r_avg);
    iq_raw_1 = NaN*ones(num_reps,q.r_avg);
    for ii = 1:num_reps
        R.Run();
        iq_raw_1(ii,:) = R.extradata{1};
    end
    iq_raw_1 = iq_raw_1(:)';

    X.amp = 0;
    X.mw_src{1}.on = false;
    X12.amp = 0;
    P = X12*X;
    P.Run();
    iq_raw_0 = NaN*ones(num_reps,q.r_avg);
    for ii = 1:num_reps
        R.Run();
        iq_raw_0(ii,:) = R.extradata{1};
    end
    iq_raw_0 = iq_raw_0(:)';

    [~, center2] =... 
		data_taking.public.dataproc.iq2prob_centers(iq_raw_0,iq_raw_1,auto);

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
        QS.saveSSettings({q.name,'r_iq2prob_center2'},center2);
    end
	varargout{1} = center2;
end