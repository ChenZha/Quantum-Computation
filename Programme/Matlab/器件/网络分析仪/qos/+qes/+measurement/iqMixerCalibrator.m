classdef iqMixerCalibrator < qes.measurement.measurement
	% do IQ Mixer calibration
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
%         q_delay = 0
        lo_freq      % Hz, carrier frequency
        lo_power
        sb_freq % Hz, side band frequency
        pulse_ln = 25000
%         chnls
        
        showProcess@logical scalar = false
    end
	properties (SetAccess = private, GetAccess = private)
		awg
		i_chnl
        q_chnl
		lo_source
		spc_amp_obj
        iqAmp
        
        iqCalDataSetIdx
        
        iZero
        qZero
        
        loFreqs
        iZeros
        qZeros
        sbFreqs
        sbCompensations
        
        SPC_AMP_MIN = -130
        MAX_ITER_NUM = 25;
	end
    methods
        function obj = iqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource)
			if (~isa(awgObj,'qes.hwdriver.sync.awg') &&...
				~isa(awgObj,'qes.hwdriver.async.awg')) ||...
				~isa(spcAmpObj,'qes.measurement.specAmp') ||...
				~isa(loSource,'qes.hwdriver.instrumentChnl') ||...
				numel(awgchnls) ~= 2
				throw(MException('QOS_iqMixerCalibrator:InvalidInput','Invalud input arguments.'));
			end
            obj = obj@qes.measurement.measurement([]);
			obj.awg = awgObj;
			obj.i_chnl = awgchnls(1);
			obj.q_chnl = awgchnls(2);
%             obj.chnls = awgchnls;
			obj.spc_amp_obj = spcAmpObj;
			obj.lo_source = loSource;
            obj.numericscalardata = false;
            
            obj.awg.iqCalDataSet = []; % clear loaded iqCalDataSet is important!

            numIQCalDataSet = numel(obj.awg.iqCalDataSet);
            if numIQCalDataSet==0
                obj.awg.iqCalDataSet = struct(...
                        'chnls',[],'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]); % loPower is import but not needed by the awg, thus not included
                obj.iqCalDataSetIdx = numIQCalDataSet+1;
            end
            for ii = 1:numIQCalDataSet
                if all(obj.awg.iqCalDataSet(ii).chnls == [obj.i_chnl,obj.q_chnl])
                    obj.iqCalDataSetIdx = ii;
                    break;
                elseif ii == numIQCalDataSet
                    obj.awg.iqCalDataSet(end+1) = struct(...
                        'chnls',[],'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]); % loPower is import but not needed by the awg, thus not included
                    obj.iqCalDataSetIdx = numIQCalDataSet+1;
                end
            end
        end
        function set.lo_freq(obj,val)
            obj.iZero = [];
            obj.qZero = [];
            obj.lo_freq = val;
        end
        function Run(obj)
            if isempty(obj.lo_freq) ||...
                    isempty(obj.lo_power) || isempty(obj.sb_freq)
                throw(MException('QOS_iqMixerCalibrator:propertyNotSet',...
					'some properties are not set.'));
            end
%             if isempty(obj.q_delay) || isempty(obj.lo_freq) ||...
%                     isempty(obj.lo_power) || isempty(obj.sb_freq)
%                 throw(MException('QOS_iqMixerCalibrator:propertyNotSet',...
% 					'some properties are not set.'));
%             end
			Run@qes.measurement.measurement(obj);
            obj.iqAmp = obj.awg.vpp/4;
			obj.lo_source.frequency = obj.lo_freq;
			obj.lo_source.power = obj.lo_power;
            obj.lo_source.on = true;
            [obj.iZero, obj.qZero] = obj.CalibrateZero();
            
            obj.loFreqs = [obj.loFreqs,obj.lo_freq];
            obj.iZeros = [obj.iZeros, obj.iZero];
            obj.qZeros = [obj.qZeros, obj.qZero];
            % obj.sbCompensations = [obj.sbCompensations,];
            [loFreqs_,idx] = unique(obj.loFreqs);
            iZeros_ = obj.iZeros(idx);
            qZeros_ = obj.qZeros(idx);
            
            [loFreqs_,idx] = sort(loFreqs_,'ascend');
            iZeros_ = iZeros_(idx);
            qZeros_ = qZeros_(idx);

            obj.awg.iqCalDataSet(obj.iqCalDataSetIdx) =...
                struct('chnls',[obj.i_chnl, obj.q_chnl],...
                'loFreq',loFreqs_,...
                'iZero',iZeros_,'qZero',qZeros_,...
                'sbFreq',[],'sbCompensation',[]);
            
            sbCompensation = CalibrateSideband(obj);
			
            obj.data = struct('iZeros',obj.iZero,'qZeros',obj.qZero,'chnls',[obj.i_chnl, obj.q_chnl],...
				'sbCompensation',sbCompensation,...
                'iqAmp',obj.iqAmp,'loPower',obj.lo_power);
            
            obj.sbFreqs = [obj.sbFreqs,obj.sb_freq];
            obj.sbCompensations = [obj.sbCompensations,sbCompensation];
			obj.dataready = true;
        end
    end
    methods(Access = private)
        function [x, y] = CalibrateZero(obj)
            if ~isempty(obj.iZero) && ~isempty(obj.qZero)
                x = obj.iZero;
                y = obj.qZero;
                return;
            end
            I = qes.waveform.dc(obj.pulse_ln);
            I.awg = obj.awg;
            I.awgchnl = obj.i_chnl;
            Q = copy(I);
            Q.awg = obj.awg;
            Q.awgchnl = obj.q_chnl;
            p1 = qes.expParam(I,'dcval');
            p2 = qes.expParam(Q,'dcval');
            p1.callbacks = {@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
            p2.callbacks = p1.callbacks;
            obj.spc_amp_obj.freq = obj.lo_freq;
            f = qes.expFcn([p1, p2],obj.spc_amp_obj);
            
            % search method 1
            opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.2,'TolFun',0.1,'PlotFcns',{@optimplotfval});%,'PlotFcns',''); % current value and history
            lb = [-obj.awg.vpp/10, -obj.awg.vpp/10];
            ub = [obj.awg.vpp/10, obj.awg.vpp/10];
            xsol = qes.util.fminsearchbnd(f.fcn,[0,0],lb,ub,opts);
            x = xsol(1);
            y = xsol(2);

            % search method 2
%             precision = obj.awg.vpp/50;
%             stopPrecision = obj.awg.vpp/1e5;
%             if obj.showProcess
%                 h = qes.ui.qosFigure(sprintf('IQ Calibration | DAC %s, I channel %0.0f, Q channel %0.0f',...
%                     obj.awg.name, obj.i_chnl, obj.q_chnl),true);
%                 ax1 = axes('Parent',h,'Box','on');
%                 ax2 = axes('Parent',h,'Box','on','Color','none','YAxisLocation','right');
%                 hl1 = line(NaN,NaN,'LineStyle','-','Color',[1,0,0],'parent',ax1);
%                 hl2 = line(NaN,NaN,'LineStyle',':','Color',[0,1,0],'parent',ax2);
%                 hold(ax2,'on');
%                 hl3 = line(NaN,NaN,'LineStyle',':','Color',[0,0,1],'parent',ax2);
%                 hold(ax2,'off');
%                 xlabel(ax1,'Number of steps')
%                 ylabel(ax1,'Lo leakage(dBm)');
%                 ylabel(ax2,'IQ amplitude');
%                 linkaxes([ax1, ax2], 'x');
%                 set(ax1,'XLim',[1,20]);
%             end
%             n_ = 0;
%             a_ = NaN;
%             x_ = 0;
%             y_ = 0;
%             x = 0;
%             y = 0;
%             while precision > stopPrecision
%                 lx = f([x-precision, y]);
%                 cx = f([x,y]);
%                 rx = f([x+precision,y]);
%                 dx = precision*qes.util.minPos(lx, cx, rx);
%                 x = x+dx;
%                 
%                 ly = f([x-precision, y]);
%                 cy = f([x,y]);
%                 ry = f([x+precision,y]);
%                 dy = precision*qes.util.minPos(ly, cy, ry);
%                 y = y+dx;
%                 
%                 if cx < obj.SPC_AMP_MIN && cy < obj.SPC_AMP_MIN
%                     break;
%                 end
%                 
%                 if abs(dx) < precision && abs(dy) < precision
%                     precision = precision/2;
%                 end
%                 if obj.showProcess
%                     n_ = [n_,n_(end)+1];
%                     a_ = [a_,cy];
%                     x_ = [x_,x];
%                     y_ = [y_,y];
%                     try
%                         set(hl1,'XData',n_,'YData',a_);
%                         set(hl2,'XData',n_,'YData',x_);
%                         set(hl3,'XData',n_,'YData',y_);
%                         drawnow;
%                     catch % incase of figure being closed
%                     end
%                 end
%             end
%             if obj.showProcess
%                 try
%                 	title(ax,'Done.')
%                 catch
%                 end
%             end
            
			if obj.showProcess
                f([0,0]);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                bp=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                b0=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                bm=obj.spc_amp_obj.data;
                
                f([x,y]);
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                am=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                ap=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                a0=obj.spc_amp_obj.data;
                
                freq4plot=[obj.lo_freq-obj.sb_freq, obj.lo_freq, obj.lo_freq+obj.sb_freq];

                hf = qes.ui.qosFigure('IQ Mixer Calibration | DC',true);
				ax = axes('Parent',hf);
                plot(ax, freq4plot,[bm,b0,bp],'-o',freq4plot,[am,a0,ap],'-*');
                xlabel(ax, 'Frequency(GHz)');
                ylabel(ax, 'Amplitude');
                legend(ax, {'before calibration','after calibration'});

                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(I);
            obj.awg.StopContinuousWv(Q);
        end
        function z = CalibrateSideband(obj)
			% todo: correct mixer zero with the calibration
			% result of the previous step.
            if obj.sb_freq < 5e6 % in practice, sb_freq are  several tens of MHz at least
                z = 0;
                return;
            end
			
            pulse_ln = qes.util.best_fit_count(abs(obj.sb_freq));
            
			awg_ = obj.awg;
			awgchnl_ = [obj.i_chnl, obj.q_chnl];
            IQ = qes.waveform.dc(pulse_ln);
            IQ.dcval = obj.iqAmp;
            IQ.df = obj.sb_freq/obj.awg.samplingRate;
            IQ.fc = obj.lo_freq;

            IQ.awg = awg_;
            IQ.awgchnl = awgchnl_;     
            
%% Complex component method.            
			IQ_op = copy(IQ);
			IQ_op.df = -obj.sb_freq/obj.awg.samplingRate;
            
            function wv = calWv(comp_)
				wv = IQ + comp_(1)*IQ_op+comp_(2)*1j*IQ_op;
				wv.awg = awg_;
				wv.awgchnl = awgchnl_;
                wv.fc=IQ.fc;
			end
			
			p = qes.expParam(@calWv);
			p.callbacks ={@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
            
            obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
            f = qes.expFcn(p,obj.spc_amp_obj);
            
%             function res=f2(a)
%                 res=f(a(1)+1j*a(2));
%             end
            
            opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.01,'TolFun',0.1,'PlotFcns',{@optimplotfval});
            z1 = qes.util.fminsearchbnd(f.fcn,[0,0],[-0.5,-0.5],[0.5,0.5],opts);
            z=z1(1)+1j*z1(2);
            
            depress=f([0,0])-f(z1);
            
            if depress<0
                z1 = qes.util.fminsearchbnd(f.fcn,[0,0],[-0.5,-0.5],[0.5,0.5],opts);
                z=z1(1)+1j*z1(2);
                
                depress=f([0,0])-f(z1);
                
                if depress<0
                    z=0;
                    disp(['WARNING: Phase calibration failed, lo = ' num2str(obj.lo_freq) ', sb = ' num2str(obj.sb_freq)])
                end
            end
            
%% Another method
%             precisionx = 0.1; %balance
%             precisiony = 0.1; %phase
% 			x = 0*1j;
%             dx_=0;
%             dy_=0;
%             while abs(precisionx) > 1e-3 || abs(precisiony) > 1e-3 
%                 l = f(x-precisionx);
%                 c = f(x);
%                 r = f(x+precisionx);
%                 dx = precisionx*qes.util.minPos(l, c, r);
%                 x = x + dx;
%                 if sign(dx*dx_)<=0
%                     precisionx=precisionx/2;
%                 end
%                 dx_=dx;
%                 
%                 l = f(x-1j*precisiony);
%                 c = f(x);
%                 r = f(x+1j*precisiony);
%                 dy = precisiony*qes.util.minPos(l, c, r);
%                 x = x + 1j*dy
%                 if sign(dy*dy_)<=0
%                     precisiony=precisiony/2;
%                 end
%                 dy_=dy;
%             end
%             
%             z = x
%% IQ balance method       
%             p=qes.expParam(IQ,'balance');
%             p.callbacks ={@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
%             
%             obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
%             f = qes.expFcn(p,obj.spc_amp_obj);
%             
%             opts = optimset('Display','none','MaxIter',20,'TolX',0.01,'TolFun',0.1,'PlotFcns',{@optimplotfval});
%             z = qes.util.fminsearchbnd(f.fcn,1.2,0.5,1.5,opts)
%             
%             IQ.balance=z;
            

%% Not necessary maybe.            
%             p1=qes.expParam(IQ,'sb_comp');
%             p1.callbacks ={@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
%             
%             obj.spc_amp_obj.freq = obj.lo_freq;
%             f1 = qes.expFcn(p1,obj.spc_amp_obj);
%             
%             precisionx = 100;
%             precisiony = 100;
% 			x = obj.iZero;
%             y = obj.qZero;
%             dx_=0;
%             dy_=0;
%             while abs(precisionx) > 2 || abs(precisiony) > 2
%                 l = f1([x+precisionx,y]);
%                 c = f1([x,y]);
%                 r = f1([x-precisionx,y]);
%                 dx = precisionx*qes.util.minPos(l, c, r);
%                 x = x - dx;
%                 
%                 l = f1([x,y+precisiony]);
%                 c = f1([x,y]);
%                 r = f1([x,y-precisiony]);
%                 dy = precisiony*qes.util.minPos(l, c, r);
%                 y = y - dy;
%                 
%                 if sign(dx*dx_)<=0
%                     precisionx=round(precisionx*0.5)
%                 end
%                 if sign(dy*dy_)<=0
%                     precisiony=round(precisiony*0.5)
%                 end
%                 
%                 dx_=dx;
%                 dy_=dy;
%             end
%             
%             f1([x,y])
%             
%             i0=round(x)
%             q0=round(y)
%             
%             obj.iZero=i0;
%             obj.qZero=q0;            
%%			
			if obj.showProcess
                f([0,0]);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                bp=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                b0=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                bm=obj.spc_amp_obj.data;
                
                f(z1);
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                am=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                ap=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                a0=obj.spc_amp_obj.data;
                
                freq4plot=[obj.lo_freq-obj.sb_freq, obj.lo_freq, obj.lo_freq+obj.sb_freq];

                hf = qes.ui.qosFigure('IQ Mixer Calibration | DC',true);
				ax = axes('Parent',hf);
                plot(ax,freq4plot,[bm,b0,bp],'-o',freq4plot,[am,a0,ap],'-*');
                xlabel(ax,'Frequency(GHz)');
                ylabel(ax,'Amplitude');
                legend(ax,{'after calibration zero','after calibration phase'});
                if am-bm>0
                    title(ax,'BAD!','color','r')
                else
                    title(ax,'GOOD!','color','g')
                end
                
%                 spcAnalyzerObj.startfreq = obj.lo_freq-abs(obj.sb_freq) - 1e6;
%                 spcAnalyzerObj.stopfreq = obj.lo_freq+abs(obj.sb_freq) + 1e6;
%                 spcAnalyzerObj.bandwidth = 5e3;
%                 spcAnalyzerObj.numpts = 4001;
%                 spcAmpAfterCal = spcAnalyzerObj.get_trace();
%                 
%                 figure(43)
%                 plot(linspace(spcAnalyzerObj.startfreq,spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts),spcAmpAfterCal);
                
                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(IQ);
        end
    end


end