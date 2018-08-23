function varargout = zdc2f01(varargin)
% map out z dc bias amplitude to qubit frequency f01. 
%
% <[_f_]> = zdc2f01('qubit',_c&o_,...
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
    
    % Yulin Wu, 2017/1/8

    import data_taking.public.xmon.spectroscopy1_zdc
    import data_taking.public.xmon.bringup.iq2prob_01
	import data_taking.public.xmon.bringup.xyGateAmpTuner
	import data_taking.public.util.getQubits
	
	RECAL_FREQRANGE = 20e6;
	IQ2PROB_NUMSAMPLES = 2e4;
	PITUNNER_NUMSAMPLES = 2e3;
	RESTOL = 10e6;
	
	freqUnit = 1e9; % dc val can be several micro Amper, that's ~15 orders from frequency in Hz, polyfit fails easily,
					% thus we transfer frequency unit to GHz to reduce the order difference.
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(getQubits(args,{'qubit'})); % we need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.

	if isempty(q.zdc_amp2f01)
		throw(MException('QOS_zdc2f01:invalidInitialValue',...
		'zdc_amp2f01 empty, zdc_amp2f01(1) is taken as the initial value for M(1/M is the modulation cycle of f01 in dc bias)'));
	if q.zdc_amp2f01(1) == 0
		throw(MException('QOS_zdc2f01:invalidInitialValue',...
		'invalid initial value for M(1/M is the modulation cycle of f01 in dc bias), value of M can not be zero.'));
	end
	if q.zdc_amp2fFreqRng < 200e6 || q.zdc_amp2fFreqRng > 2e9
		throw(MException('QOS_zdc2f01:invalidAmp2fFreqRng',...
			'zdc_amp2fFreqRng out of supported range:[200e6, 2e9]'));
	end
	
	% standard qubit tuneup proceedure:
	% n, ...
	% n+1, measure f01(S21) at zdc_amp = 0;
	% n+2, power rabi(S21) to find pi pulse;
	% n+3, with pi pulse, find the optimal readout frequency;
	% n+4, find the iq raw data to probablity centers;
	% n+5, fine calibrate pi pulse with power rabi(|1> probability) or ignore this step if pi pulse already good enough.
	% n+6, measure zdc2f01
	% ...
	% so here if q.zdc_amp ~= 0, you might be using incorrect qubit settings, copy and paste another qubit's
	% settings without changing the values of some crutial entries for example, or you might be doing things
	% in a non standard way and is responsible for possible risks.
	if q.zdc_amp ~= 0
		warning('q.zdc_amp ~= 0.');
	end
	
	M = q.zdc_amp2f01(1); % initial guess of the modulation period(1/M) of qubit spectrum in dc bias
%	offset = 0; % initial guess of the dc value of the optimal point, zero or close to zero
%	fmax = q.f01; % use the qubit frequency at the optimal point as the initial guess
%	fc = 0; % just use zero as the initial guess
	addprop(q,'amp2f_poly__');
	% addprop(q,'amp2f__');
	% addprop(q,'f2amp__');
	q.amp2f_poly__ = q.f01*[2*M,1];
	% q.amp2f__ = @(x) fmax*sqrt(abs(cos(pi*M*abs(x-offset))))+fc*(sqrt(abs(cos(pi*M*abs(x-offset))))-1);
	% q.f2amp__  = {@(x)M*acos((x+fc)^2/(fc+fmax)^2)/pi+offset,...
	%			@(x)-acos((x+fc)^2/(fc+fmax)^2)/(M*pi)+offset};
				
	f01_ini = q.f01;
    function f_ = sweepFreq(bias_)
        f01_est = freqUnit*polyval(q.amp2f_poly__,bias_);
        f_ = q.t_zdc2freqFreqStep*floor((f01_est-q.t_zdc2freqFreqSrchRng/2)/q.t_zdc2freqFreqStep):...
            q.t_zdc2freqFreqStep:...
            q.t_zdc2freqFreqStep*ceil((f01_est+q.t_zdc2freqFreqSrchRng/2)/q.t_zdc2freqFreqStep);
    end

	r_iq2prob_center0_backup = q.r_iq2prob_center0;
	r_iq2prob_center0_backup = q.r_iq2prob_center1;
    last_cal_freq = f01_ini;
    QS = qes.qSettings.GetInstance();

    bias = [];
    f01 = [];
    P = {};
    Frequency = {};
	meanRes = 0;
	currentRes = Inf;
    while true
        if isempty(bias)
            bias = 0;
            f = sweepFreq(bias);
            e0 = spectroscopy1_zdc('qubit',qName,'bias',bias(end),'driveFreq',f,'save',false,'gui',false);
            P = e0.data;
            Frequency = {f};
            [~,midx] = max(P{end});
            f01 = f(midx);
            continue;
        end
        stopBiasForward = false;
        stopBiasBackward = false;
        if f01(1) > f01(end)
            stopBiasForward = true;
        elseif f01(1) < f01(end)
            stopBiasBackward = true;
        end
        if numel(bias) < 10
            df = q.t_zdc2freqFreqSrchRng/10;
        else
            df = q.t_zdc2freqFreqSrchRng/5;
        end
        if ~stopBiasForward
            zdc_amp2f01_ = q.amp2f_poly__;
            if numel(f01) <= 3
                zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/freqUnit;
                r = roots(zdc_amp2f01_);
                db  = min(abs([r -  bias(1),r -  bias(end)]));
				db  = min(abs([r -  bias(1),r -  bias(end)]));
            else
                if polyval(zdc_amp2f01_,bias(end)) >=  polyval(zdc_amp2f01_,bias(end-1))
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(end) + df)/freqUnit;
                else
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(end) - df)/freqUnit;
                end
                r = roots(zdc_amp2f01_)*q.zdc_amp2f_dcUnit;
                db = sort(r(isreal(r))) - bias(end);
                db = db(db>0);
                if isempty(db)
                    db = dbForward;
                else
                    db = db(1);
                    if db > 1.5*dbForward % avoid blow up
                        db = 1.5*dbForward;
                    end
                end
            end
            bias = [bias,bias(end)+db];
            f = sweepFreq(bias(end));
            e = spectroscopy1_zdc('qubit',q,'bias',bias(end),'driveFreq',f,'save',false,'gui',false);
            P = [P, e.data];
            Frequency = [Frequency,{f}];
            [~,midx] = max(P{end});
            f01 = [f01,f(midx)];
            dbForward = db;
            q.f01 = f01(end);
			lastIdx = numel(f01);
        end
        if ~stopBiasBackward
            zdc_amp2f01_ = q.amp2f_poly__;
            if numel(f01) <= 3
                zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/freqUnit;
                r = roots(zdc_amp2f01_);
                db  = -min(abs([r -  bias(1),r -  bias(end)]));
            else
                if polyval(zdc_amp2f01_,bias(1)) >=  polyval(zdc_amp2f01_,bias(2))
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) + df)/freqUnit;
                else
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/freqUnit;
                end
                r = roots(zdc_amp2f01_)*q.zdc_amp2f_dcUnit;
                db = sort(r(isreal(r))) - bias(1);
                db = db(db<0);
                if isempty(db)
                    db = dbBackward;
                else
                    db = db(end);
                    if db < 1.5*dbBackward % avoid blow up
                        db = 1.5*dbBackward;
                    end
                end
            end
            bias = [bias(1)+db, bias];
            f = sweepFreq(bias(1));
            e = spectroscopy1_zdc('qubit',q,'bias',bias(1),'driveFreq',f,'save',false,'gui',false);
            P = [e.data, P];
            Frequency = [{f}, Frequency];
            [~,midx] = max(P{1});
            f01 = [f(midx),f01];
            dbBackward = db;
            q.f01 = f01(1);
            lastIdx = 1;
        end
        try
            zdc_amp2f01_backup = q.amp2f_poly__;
            num_data_points = numel(bias);
            if range(f01) > 0.2e6  && num_data_points > 20
                pf = polyfit(bias,f01/freqUnit,4);
            elseif num_data_points > 10
                pf = polyfit(bias,f01/freqUnit,2);
            else
                pf = polyfit(bias,f01/freqUnit,1);
				if pf(1) < q.zdc_amp2f01(1)/5
					% this might happen when zdc_amp = 0 is very close to the optimal point,
					% here we assume the initial guess of M is resonable: not absurdly large
					pf(1) = q.zdc_amp2f01(1)/5;
				end
            end
            q.amp2f_poly__ = pf;
			meanRes = mean(abs(polyval(pf,bias) - f01));
			currentRes = abs(polyval(pf,bias(lastIdx)) - f01(lastIdx));
        catch
            q.amp2f_poly__ = zdc_amp2f01_backup;
        end
		if abs(last_cal_freq - q.f01) > RECAL_FREQRANGE &&...
				currentRes < 2*meanRes % make sure we don't do recalibration at possible avoided crossing
			piAmp = xyGateAmpTuner('qubit',q,'gateTyp','X','gui',false,'save',false);
            q.g_X_amp = piAmp;
            [iq_center0,iq_center1] =...
                iq2prob_01('qubit',q,'numSamples',IQ2PROB_NUMSAMPLES,'gui',false,'save',false);
            q.r_iq2prob_center0 = iq_center0;
            q.r_iq2prob_center1 = iq_center1;
            last_cal_freq = f01(end);
        end
        plotAndSave(bias,Frequency,P,f01);
        if abs(f01_ini - f01(end)) > q.zdc_amp2fFreqRng && abs(f01_ini - f01(1)) > q.zdc_amp2fFreqRng
            break;
        end
    end
    function plotAndSave(bias_,Frequency_,P_,f01_)
        persistent ax
        if isempty(ax) || ~isvalid(ax)
            hf = qes.ui.qosFigure(sprintf('Z DC -> f01 | %s', q.name),true,60*30);
            ax = axes('parent',hf);
        end
        num_biases = numel(bias);
        all_freq = cell2mat(Frequency_);
        f_ = min(all_freq):q.t_zdc2freqFreqStep:max(all_freq);
        num_freq = numel(f_);
        prob = NaN*ones(num_biases,num_freq);
        for ww = 1:num_biases
            for hh = 1:numel(Frequency_{ww})
                prob(ww,f_ == Frequency_{ww}(hh)) = P_{ww}(hh);
            end
        end
        h = pcolor(bias_,f_,prob','parent',ax);
        set(h,'EdgeColor', 'none');
        hold(ax,'on');
        bi = linspace(bias_(1),bias_(end),200);
        plot(ax,bi,freqUnit*polyval(q.amp2f_poly__,bi),'--','color',[1,1,1],'LineWidth',2);
        plot(ax,bias_,f01_,'o','MarkerEdgeColor',[0,0,0],'MarkerFaceColor',[1,1,1],'MarkerSize',6,'LineWidth',1);
        xlabel(ax,'z dc bias amplitude');
        ylabel(ax,'frequency (Hz)');
        hold(ax,'off');
        colormap(ax,jet(128));
        colorbar('peer',ax);
        drawnow;
        e0.data{1} = prob;
        e0.sweepvals{1}{1} = bias_;
        e0.sweepvals{2}{1} = f_;
        e0.addSettings({'dc_bias','f01'},{bias_,f01_});
        e0.SaveData();
%         % temp, save for demo;
%         saveas(h,['F:\data\matlab\20161221\zdc2f01\',datestr(now,'mmddHHMMSS'),'.png']);
    end
	
	function f__ = amp2f01__(param_,x_)
		f__ = param_(3)*sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))+...
			param_(4)*(sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))-1);
	end

    warning('off');
    [param,~,residual,~,~,~,~] = lsqcurvefit(@amp2f01__,[q.zdc_amp2f01(1),0,q.f01,0],bias,f01);
    warning('on');
	if mean(abs(residual)) > RESTOL
		throw(MException('QOS_zdc2f01:fittingFailed','fitting failed.'));
	end

    if ischar(args.save)
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            QS.saveSSettings({q.name,'zdc_amp2f01'},param);
        end
    elseif args.save
        QS.saveSSettings({q.name,'zdc_amp2f01'},param);
    end
	
	varargout{1} = q.zdc_amp2f01;
end