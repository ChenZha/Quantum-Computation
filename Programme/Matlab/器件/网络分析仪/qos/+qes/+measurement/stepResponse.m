classdef iqMixerCalibrator < qes.measurement.measurement
	% measure da step response function

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
    end
	properties (SetAccess = private, GetAccess = private)
	end
    methods
        function obj = stepResponse(awg,chnl,wv_ln,scope,data_ln,numAvg)
			if ~isa(awgObj,'qes.hwdriver.sync.awg') ||...
				~isa(awgObj,'qes.hwdriver.async.awg') ||...
				~isa(spcAmpObj,'qes.measurement.specAmp') ||...
				~isa(loSource,'qes.measurement.sync.mwSource') ||...
				~isa(loSource,'qes.measurement.async.mwSource') ||...
				numel(awgchnls) ~= 2;
				throw(MException('QOS_stepResponse:InvalidInput','Invalud input arguments.'));
			end
            obj = obj@qes.measurement.measurement([]);
			obj.awg = awgObj;
			obj.i_chnl = awgchnls(1);
			obj.q_chnl = awgchnls(2);
			obj.spc_amp_obj = spcAmpObj;
			obj.lo_source = loSource;
            obj.numericscalardata = false;
        end
        function Run(obj)
            if isempty(obj.q_delay) || isempty(obj.lo_freq) ||...
                    isempty(obj.lo_power) || isempty(obj.sbfreq)
                throw(MException('QOS_stepResponse:propertyNotSet',...
					'some properties are not set.'));
            end
			Run@qes.measurement.measurement(obj);
			obj.lo_source.frequency = obj.lo_freq;
			obj.lo_source.frequency = obj.lo_power;
            [iZero, qZero] = obj.CalibrateZero();
            sbCompensation = CalibrateSideband(obj);
			obj.data = struct('iZeros',iZero,'qZero',qZero,...
				'sbCompensation',sbCompensation);
			obj.dataready = true;
        end
    end
    methods(Access = private)
        function [x, y] = CalibrateZero(obj)
            I = qes.waveform.dc(obj.pulseln);
            I.awg = obj.awg;
            I.awgchnl = obj.i_chnl;
            Q = copy(I);
            Q.awg = obj.awg;
            Q.awgchnl = obj.q_chnl;
            p1 = qes.expParam(I,'dcval');
            p2 = qes.expParam(Q,'dcval');
            p1.callbacks = {@(x_) x_.expobj.awg.StopContinousRun(), @(x_) x_.expobj.SendWave(),...
					@(x_) x_.expobj.awg.StartContinousRun()};
            p2.callbacks = p1.callbacks;
            
            obj.spc_amp_obj.freq = obj.lo_freq;
            f = qes.expFcn([p1, p2],obj.spc_amp_obj);
            maxAmp = obj.awg.vpp/2;
            x = 0;
            y = 0;
            precision = obj.awg.vpp/4;
            stopPrecision = obj.awg.vpp/1e6;
            while precision <= stopPrecision
                l = f(x-precision,y);
                c = f(x,y);
                r = f(x+precision,y);
                dx = precision*qes.util.minPos(l, c, r);
                x = x+dx;
                
                l = f(x,y-precision);
                c = f(x,y);
                r = f(x,y+precision);
                dy = precision*qes.util.minPos(l, c, r);
                y = x+dy;
                precision = min(precision/2, 2*max(abs(dx), abs(dy)));
            end
			
			%%%%%%%%%% debug
			f(0,0);
			instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
			spcAnalyzerObj = instr{1};
			
			startfreq_backup = spcAnalyzerObj.startfreq;
			stopfreq_backup = spcAnalyzerObj.stopfreq;
			bandwidth_backup = spcAnalyzerObj.bandwidth;
			numpts_backup = spcAnalyzerObj.numpts;
			
			spcAnalyzerObj.startfreq = obj.lo_source - 10e6
			spcAnalyzerObj.stopfreq = obj.lo_source + 10e6
			spcAnalyzerObj.bandwidth = 50e3;
			spcAnalyzerObj.numpts = 401;
			spcAmpBeforeCal = spcAnalyzerObj.get_trace();
			
			f(x,y);
			spcAmpAfterCal = spcAnalyzerObj.get_trace();
			freq4plot = linspace(spcAnalyzerObj.startfreq,...
				spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9;
			figure();
			plot(freq4plot,spcAmpBeforeCal,freq4plot,spcAmpAfterCal);
			xlabel('Frequency(GHz)');
			ylabel('Amplitude');
			legend({'before calibration','after calibration'});
			
			spcAnalyzerObj.startfreq = startfreq_backup;
			spcAnalyzerObj.stopfreq = stopfreq_backup;
			spcAnalyzerObj.bandwidth = bandwidth_backup;
			spcAnalyzerObj.numpts = numpts_backup;
			%%%%%%%%%% enddebug
			
			obj.awg.StopContinousRun();
        end
        function x = CalibrateSideband(obj)
			% todo: correct mixer zero with the calibration
			% result of the previous step.
			
			awg_ = obj.awg;
			awgchnl_ = [obj.i_chnl, obj.q_chnl];
            IQ = qes.waveform.dc(obj.pulseln);
            IQ.amp = obj.awg.vpp/2;
            IQ.awg = awg_;
            IQ.awgchnl = awgchnl_;
            IQ.df = obj.sbfreq;
            IQ.q_delay = obj.q_delay;
			IQ_op = copy(IQ);
			IQ_op.df = -obj.sbfreq;

            function wv = calWv(comp_)
				wv = IQ + comp_*IQ_op;
				wv.awg = awg_;
				wv.awgchnl = awgchnl_;
			end
			
			p = qes.expParam(@calWv);
			p.callbacks ={@(x_) x_.expobj.awg.StopContinousRun(),...
						@(x_) x_.expobj.awg.SendWave(),...
						@(x_) x_.expobj.awg.StartContinousRun()};
            
            obj.spc_amp_obj.freq = obj.lo_freq;
            f = qes.expFcn(p1,obj.spc_amp_obj);

            precision = 1;
			x = 0*1j;
            while precision > 1e-6
                l = f(x-precision);
                c = f(x);
                r = f(x+precision);
                dr = precision*qes.util.minPos(l, c, r);
                x = x+dr;
                
                l = f(x-1j*precision);
                c = f(x);
                r = f(x+1j*precision);
                di = precision*qes.util.minPos(l, c, r);
                x = x+1j*di;
                precision = min(precision/2, 2*max(abs(dr), abs(di)));
            end
			
			%%%%%%%%%% debug
			f(0);
			instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
			spcAnalyzerObj = instr{1};
			
			startfreq_backup = spcAnalyzerObj.startfreq;
			stopfreq_backup = spcAnalyzerObj.stopfreq;
			bandwidth_backup = spcAnalyzerObj.bandwidth;
			numpts_backup = spcAnalyzerObj.numpts;
			
			spcAnalyzerObj.startfreq = obj.lo_source - obj.sbfreq - 10e6;
			spcAnalyzerObj.stopfreq = obj.lo_source - obj.sbfreq + 10e6;
			spcAnalyzerObj.bandwidth = 50e3;
			spcAnalyzerObj.numpts = 401;
			spcAmpBeforeCal_neg = spcAnalyzerObj.get_trace();
			freq4plot = linspace(spcAnalyzerObj.startfreq,...
				spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9;
			
			spcAnalyzerObj.startfreq = obj.lo_source + obj.sbfreq - 10e6;
			spcAnalyzerObj.stopfreq = obj.lo_source + obj.sbfreq + 10e6;
			spcAnalyzerObj.bandwidth = 50e3;
			spcAnalyzerObj.numpts = 401;
			spcAmpBeforeCal_pos = spcAnalyzerObj.get_trace();
			freq4plot = [freq4plot, linspace(spcAnalyzerObj.startfreq,...
				spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9];
			
			spcAmpBeforeCal = [spcAmpBeforeCal_neg, spcAmpBeforeCal_pos];
			
			f(x);
			spcAmpAfterCal_pos = spcAnalyzerObj.get_trace();
			
			spcAnalyzerObj.startfreq = obj.lo_source - obj.sbfreq - 10e6;
			spcAnalyzerObj.stopfreq = obj.lo_source - obj.sbfreq + 10e6;
			spcAnalyzerObj.bandwidth = 50e3;
			spcAnalyzerObj.numpts = 401;
			spcAmpAfterCal_neg = spcAnalyzerObj.get_trace();

			figure();
			plot(freq4plot,spcAmpBeforeCal,freq4plot,spcAmpAfterCal);
			xlabel('Frequency(GHz)');
			ylabel('Amplitude');
			legend({'before calibration','after calibration'});
			
			spcAnalyzerObj.startfreq = startfreq_backup;
			spcAnalyzerObj.stopfreq = stopfreq_backup;
			spcAnalyzerObj.bandwidth = bandwidth_backup;
			spcAnalyzerObj.numpts = numpts_backup;
			%%%%%%%%%% enddebug
			
			obj.awg.StopContinousRun();
        end
    end


end