function varargout = zpls2f01(varargin)
% map out z pulse bias amplitude to qubit frequency f01. 
%
% <[_f_]> = zpls2f01('qubit',_c&o_,'maxBias',mb...
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

    import data_taking.public.xmon.spectroscopy1_zpa
	import data_taking.public.util.getQubits
	
	RECAL_FREQRANGE = 20e6;
	IQ2PROB_NUMSAMPLES = 2e4;
	PITUNNER_NUMSAMPLES = 2e3;
	RESTOL = 10e6;
	
	freqUnit = 1e9; % dc val can be several micro Amper, that's ~15 orders from frequency in Hz, polyfit fails easily,
					% thus we transfer frequency unit to GHz to reduce the order difference.
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = getQubits(args,{'qubit'}); 

	if isempty(q.zpls_amp2f01)
		throw(MException('QOS_zpls2f01:invalidInitialValue',...
		'zpls_amp2f01 empty, zpls_amp2f01(1) is taken as the initial value for M(1/M is the modulation cycle of f01 in z bias)'));
    end
	if q.zpls_amp2f01(1) == 0
		throw(MException('QOS_zpls2f01:invalidInitialValue',...
		'invalid initial value for M(1/M is the modulation cycle of f01 in z bias), value of M can not be zero.'));
	end
	if q.zpls_amp2fFreqRng < 100e6 || q.zpls_amp2fFreqRng > 2e9
		throw(MException('QOS_zpls2f01:invalidAmp2fFreqRng',...
			'zpls_amp2fFreqRng out of supported range:[100e6, 2e9]'));
	end

	if q.zdc_amp ~= 0
		warning('q.zdc_amp ~= 0.');
	end
	
	M = q.zpls_amp2f01(1); % initial guess of the modulation period(1/M) of qubit spectrum in dc bias
%	offset = 0; % initial guess of the dc value of the optimal point, zero or close to zero
%	fmax = q.f01; % use the qubit frequency at the optimal point as the initial guess
%	fc = 0; % just use zero as the initial guess
	addprop(q,'amp2f_poly__');
	% addprop(q,'amp2f__');
	% addprop(q,'f2amp__');
	q.amp2f_poly__ = q.f01*[2*M,1]/freqUnit;
	% q.amp2f__ = @(x) fmax*sqrt(abs(cos(pi*M*abs(x-offset))))+fc*(sqrt(abs(cos(pi*M*abs(x-offset))))-1);
	% q.f2amp__  = {@(x)M*acos((x+fc)^2/(fc+fmax)^2)/pi+offset,...
	%			@(x)-acos((x+fc)^2/(fc+fmax)^2)/(M*pi)+offset};
				
	f01_ini = q.f01;
    function f_ = sweepFreq(bias_)
        f01_est = freqUnit*polyval(q.amp2f_poly__,bias_);
        f_ = q.t_zAmp2freqFreqStep*floor((f01_est-q.t_zAmp2freqFreqSrchRng/2)/q.t_zAmp2freqFreqStep):...
            q.t_zAmp2freqFreqStep:...
            q.t_zAmp2freqFreqStep*ceil((f01_est+q.t_zAmp2freqFreqSrchRng/2)/q.t_zAmp2freqFreqStep);
    end

    QS = qes.qSettings.GetInstance();

    bias = [];
    f01 = [];
    P = {};
    Frequency = {};
    dbForward = [];
    dbBackward = [];
    FwdPkWdth = [];
    FwdPkProminence = [];
    BkwdPkWdth = [];
    BkwdPkProminence = [];
    while true
        if isempty(bias)
            bias = 0;
            f = sweepFreq(bias);
            e0 = spectroscopy1_zpa('qubit',q,'biasAmp',bias(end),'driveFreq',f,'save',false,'gui',false);
            P = e0.data;
            Frequency = {f};
%             [~,midx] = max(P{end});
%             f01 = f(midx);
            [~,midx] = max(P{end}(2:end));
            f01 = f(midx+1);
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
            df = q.t_zAmp2freqFreqSrchRng/10;
        else
            df = q.t_zAmp2freqFreqSrchRng/5;
        end
        if ~stopBiasForward
            zpls_amp2f01_ = q.amp2f_poly__;
            if numel(f01) <= 3
                zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(1) - df)/freqUnit;
                r = roots(zpls_amp2f01_);
				db  = min(abs([r -  bias(1),r -  bias(end)]));
            else
                if numel(f01) > 15
                    kkk = 1;
                end
                if polyval(zpls_amp2f01_,bias(end)) >=  polyval(zpls_amp2f01_,bias(end-1))
                    zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(end) + df)/freqUnit;
                else
                    zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(end) - df)/freqUnit;
                end
                r = roots(zpls_amp2f01_);
                ridx = [];
                for qq = 1:numel(r)
                    if isreal(r(qq))
                        ridx = [ridx,qq];
                    end
                end
                db = sort(r(ridx)) - bias(end);
                db = db(db>0);
                if isempty(db)
                    db = dbForward;
                else
                    db = db(1);
                end
            end
            if ~isempty(dbForward) && db > 1.5*dbForward % avoid blow up
                db = 1.5*dbForward;
            end
            bias = [bias,bias(end)+db];
            f = sweepFreq(bias(end));
            e = spectroscopy1_zpa('qubit',q,'biasAmp',bias(end),'driveFreq',f,'save',false,'gui',false);
            P = [P, e.data];
            Frequency = [Frequency,{f}];
%             [~,midx] = max(P{end});
%             f01 = [f01,f(midx)];
            % [~,midx] = max(P{end}(2:end));
            rP = range(P{end}(2:end));
            [pks,locs,w,p] = findpeaks(P{end}(2:end),'SortStr','descend','MinPeakHeight',rP/2,...
                'MinPeakProminence',rP/2,'MinPeakDistance',numel(P{end})/5,...
                'WidthReference','halfprom');
            if numel(pks)
                [~,idx_] = sort(abs(locs - (numel(P{end})-1)/2),'descend');
                [~,rnk_locs] = sort(idx_,'ascend');
                if numel(FwdPkWdth) >= 5
                    [~,idx_] = sort(abs(w - mean(FwdPkWdth(max(1,numel(FwdPkWdth)-10):end))),'descend');
                else
                    [~,idx_] = sort(w,'descend');
                end
                [~,rnk_w] = sort(idx_,'ascend');
                if numel(FwdPkWdth) >= 5
                    [~,idx_] = sort(abs(p - mean(FwdPkProminence(max(1,numel(FwdPkProminence)-10):end))),'descend');
                else
                    [~,idx_] = sort(p,'descend');
                end
                [~,rnk_p] = sort(idx_,'ascend');
                [~,pkIdx] = max(rnk_locs+0.5*rnk_w+rnk_p);
                FwdPkWdth = [FwdPkWdth,w(pkIdx)];
                FwdPkProminence = [FwdPkProminence,p(pkIdx)];
                f01 = [f01,f(locs(pkIdx)+1)];
            else
                f01 = [f01,f(round(numel(P{end})/2))];
            end
            dbForward = db;
            q.f01 = f01(end);
        end
        if ~stopBiasBackward
            zpls_amp2f01_ = q.amp2f_poly__;
            if numel(f01) <= 3
                zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(1) - df)/freqUnit;
                r = roots(zpls_amp2f01_);
                db  = -min(abs([r -  bias(1),r -  bias(end)]));
            else
                if polyval(zpls_amp2f01_,bias(1)) >=  polyval(zpls_amp2f01_,bias(2))
                    zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(1) + df)/freqUnit;
                else
                    zpls_amp2f01_(end) = zpls_amp2f01_(end) - (f01(1) - df)/freqUnit;
                end
                r = roots(zpls_amp2f01_);
                ridx = [];
                for qq = 1:numel(r)
                    if isreal(r(qq))
                        ridx = [ridx,qq];
                    end
                end
                db = sort(r(ridx)) - bias(1);
                db = db(db<0);
                if isempty(db)
                    db = dbBackward;
                else
                    db = db(end);
                end
            end
            if ~isempty(dbBackward) && db < 1.5*dbBackward % avoid blow up
                db = 1.5*dbBackward;
            end
            bias = [bias(1)+db, bias];
            f = sweepFreq(bias(1));
            e = spectroscopy1_zpa('qubit',q,'biasAmp',bias(1),'driveFreq',f,'save',false,'gui',false);
            P = [e.data, P];
            Frequency = [{f}, Frequency];
%             [~,midx] = max(P{1});
%             f01 = [f(midx),f01];
%             [~,midx] = max(P{1}(2:end));

            rP = range(P{end}(2:end));
            [pks,locs,w,p] = findpeaks(P{end}(2:end),'SortStr','descend','MinPeakHeight',rP/2,...
                'MinPeakProminence',rP/2,'MinPeakDistance',numel(P{end})/5,...
                'WidthReference','halfprom');
            if numel(pks)
                [~,idx_] = sort(abs(locs - (numel(P{end})-1)/2),'descend');
                [~,rnk_locs] = sort(idx_,'ascend');
                if numel(BkwdPkWdth) >= 5
                    [~,idx_] = sort(abs(w - mean(BkwdPkWdth(max(1,numel(BkwdPkWdth)-10):end))),'descend');
                else
                    [~,idx_] = sort(w,'descend');
                end
                [~,rnk_w] = sort(idx_,'ascend');
                if numel(BkwdPkWdth) >= 5
                    [~,idx_] = sort(abs(p - mean(BkwdPkProminence(max(1,numel(BkwdPkProminence)-10):end))),'descend');
                else
                    [~,idx_] = sort(p,'descend');
                end
                [~,rnk_p] = sort(idx_,'ascend');
                [~,pkIdx] = max(rnk_locs+0.5*rnk_w+rnk_p);
                BkwdPkWdth = [BkwdPkWdth,w(pkIdx)];
                BkwdPkProminence = [BkwdPkProminence,p(pkIdx)];
                f01 = [f(locs(pkIdx)+1),f01];
            else
                f01 = [f(round(numel(P{end})/2)),f01];
            end
            dbBackward = db;
            q.f01 = f01(1);
        end
        try
            zpls_amp2f01_backup = q.amp2f_poly__;
            num_data_points = numel(bias);
            if range(f01) > 300e6  && num_data_points > 20
                pf = poyfit(bias,f01/freqUnit,4);
            elseif range(f01) > q.t_zAmp2freqFreqSrchRng/4 && num_data_points >= 6
                pf = polyfit(bias,f01/freqUnit,2);
            else
                pf = polyfit(bias,f01/freqUnit,1);
				if abs(pf(1)) < abs(q.zpls_amp2f01(1)/10)
					% this might happen when zdc_amp = 0 is very close to the optimal point,
					% here we assume the initial guess of M is resonable: not absurdly large
					pf(1) = sign(pf(1))*abs(q.zpls_amp2f01(1)/10);
				end
            end
            q.amp2f_poly__ = pf;
        catch
            q.amp2f_poly__ = zpls_amp2f01_backup;
        end
        plotAndSave(bias,Frequency,P,f01);
        if max(abs(bias)) >= args.maxBias && abs(f01_ini - f01(end)) > q.zpls_amp2fFreqRng && abs(f01_ini - f01(1)) > q.zpls_amp2fFreqRng
            break;
        end
    end
    function plotAndSave(bias_,Frequency_,P_,f01_)
        persistent ax
        if isempty(ax) || ~isvalid(ax)
            hf = figure('NumberTitle','off','Name','z dc bias to f01','HandleVisibility','callback');
            ax = axes('parent',hf);
        end
        num_biases = numel(bias);
        all_freq = cell2mat(Frequency_);
        f_ = min(all_freq):q.t_zAmp2freqFreqStep:max(all_freq);
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
        xlabel(ax,'z pulse amplitude');
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
%         saveas(h,['F:\data\matlab\20161221\zpls2f01\',datestr(now,'mmddHHMMSS'),'.png']);
    end
	
	function f__ = amp2f01__(param_,x_)
		f__ = param_(3)*sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))+...
			param_(4)*(sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))-1);
	end

    warning('off');
    [param,~,residual,~,~,~,~] = lsqcurvefit(@amp2f01__,[q.zpls_amp2f01(1),0,q.f01,0],bias,f01);
    warning('on');
	if mean(abs(residual)) > RESTOL
		throw(MException('QOS_zpls2f01:fittingFailed','fitting failed.'));
	end

    if ischar(args.save)
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            QS.saveSSettings({q.name,'zpls_amp2f01'},param);
        end
    elseif args.save
        QS.saveSSettings({q.name,'zpls_amp2f01'},param);
    end
	
	varargout{1} = q.zpls_amp2f01;
end