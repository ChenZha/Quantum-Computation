function varargout = DRAGAlpha(varargin)
% finds the optimal DRAGAlpha by APE
%
% <[_f_]> = DRAGAlpha('qubit',_c&o_,...
%       'numI',<_i_>,'gui',<_b_>,'save',<_b_>)
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
    
    % Yulin Wu, 2017/4/2
    
    error('obsolete, use DRAGAlphaAPE');
	
    import data_taking.public.xmon.tuneup.APE
	import data_taking.public.util.getQubits
	
	MINIMUMVISIBILITY1 = 0.35;
	MINIMUMVISIBILITY2 = 0.25;
	
    args = qes.util.processArgs(varargin,{'numI',10,'gui',false,'save',true});
	q = getQubits(args,{'qubit'});
	if ~q.qr_xy_dragPulse
		q.qr_xy_dragPulse = true;
	end
	q.qr_xy_dragAlpha = 0.5;

	phase = [-pi/2:pi/40:pi/2];
	e = APE('qubit',q,'phase',phase,'numI',0);
	P0 = e.data{1};
	visibility = range(P0);
	if visibility < MINIMUMVISIBILITY1
		throw(MException('QOS_DRAGAlpha:visibilityTooLow',...
			'visibility(%0.2f) too low, run DRAGAlpha at low visibility might produce wrong result, thus not supported.', P0));
	end
	function f__ = fitFcn(param_,x_)
		f__ = param_(1)+param_(2)*cos(x_-param_(3));
	end
	warning('off');
    [param,~,residual,~,~,~,~] = lsqcurvefit(@fitFcn,[],phase,P0);
    warning('on');
	if mean(abs(residual)) > range(P0)/10
		throw(MException('QOS_DRAGAlpha:fittingFailed','fitting failed.'));
	end
	
	e = APE('qubit',q,'numI',args.numI);
	PN = e.data{1};
	visibility = range(PN);
	if visibility < MINIMUMVISIBILITY2
		throw(MException('QOS_DRAGAlpha:visibilityTooLow',...
				'visibility(%0.2f) too low, run DRAGAlpha at low visibility might produce wrong result, thus not supported.', PN));
    end

    if ischar(args.save)
        args.save = false;
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
%     if args.save
%         QS.saveSSettings({q.name,'zdc_amp2f01'},param);
%     end
% 	
% 	varargout{1} = q.zdc_amp2f01;
end