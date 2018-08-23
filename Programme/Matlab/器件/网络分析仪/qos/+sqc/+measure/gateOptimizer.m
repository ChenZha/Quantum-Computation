classdef gateOptimizer < qes.measurement.measurement
	% gate optimization
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	methods(Static = true)
		function xyGateOptWithDrag(qubit,numGates,numShots,rAvg,maxIter)
            if nargin < 5
                maxIter = 20;
            end
            maxFEval = maxIter;

			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if ~qubit.qr_xy_dragPulse
				error('DRAG disabled, can not do DRAG optimization, checking qubit settings.');
            end
			qubit.r_avg = rAvg;
            
            R = sqc.measure.randBenchMarkingFS(qubit,numGates,numShots);
% 			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numShots);
			
			detune = qes.expParam(qubit,'f01');
			detune.offset = qubit.f01;
			
			XY2_amp = qes.expParam(qubit,'g_XY2_amp');
			XY2_amp.offset = qubit.g_XY2_amp;
			
			XY_amp = qes.expParam(qubit,'g_XY_amp');
			XY_amp.offset = qubit.g_XY_amp;
			
			alpha = qes.expParam(qubit,'qr_xy_dragAlpha');
			alpha.offset = 0.5;
            
            QS = qes.qSettings.GetInstance();

			% opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			if isempty(qubit.g_XY_impl) || strcmp(qubit.g_XY_impl,'pi')
				f = qes.expFcn([detune,XY2_amp,XY_amp,alpha],R);

                x0 = [0,-0.05*qubit.g_XY2_amp,-0.05*qubit.g_XY_amp,-0.25;...
                    -0.5e6,-0.05*qubit.g_XY2_amp,-0.05*qubit.g_XY_amp,0.25;...
                    -0.5e6,-0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp,0.25;...
                    -0.5e6,0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp,0.25;...
                    0.5e6,0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp,0.25];
                tolX = [1e4,qubit.g_XY2_amp/1e4,qubit.g_XY_amp/1e4, 0.005];
                tolY = [5e-4];

                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s', qubits.name),false);
                axs(1) = subplot(4,1,4,'Parent',h);
                axs(2) = subplot(4,1,3);
                axs(3) = subplot(4,1,2);
                axs(4) = subplot(4,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                
%                 x0 = [0,0,0,0];
%                 fval0 = f(x0);
% 				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
% 					x0,...
% 					[-2e6,-qubit.g_XY2_amp*0.05,-qubit.g_XY_amp*0.05,-0.25],...
% 					[2e6,qubit.g_XY2_amp*0.05,qubit.g_XY_amp*0.05,0.25],...
% 					opts);

                
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01);
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp);
                QS.saveSSettings({qubit.name,'g_XY_amp'},qubit.g_XY_amp);
                QS.saveSSettings({qubit.name,'qr_xy_dragAlpha'},qubit.qr_xy_dragAlpha);
			elseif strcmp(qubit.g_XY_impl,'hPi')
				f = qes.expFcn([detune,XY2_amp,alpha],R);
                
                x0 = [0,-0.05*qubit.g_XY2_amp,-0.25;...
                    -0.5e6,-0.05*qubit.g_XY2_amp,0.25;...
                    -0.5e6,0.05*qubit.g_XY2_amp,0.25;...
                    0.5e6,0.05*qubit.g_XY2_amp,0.25];
                tolX = [1e4,qubit.g_XY2_amp/1e4, 0.005];
                tolY = [5e-4];

                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s', qubit.name),false);
                axs(1) = subplot(4,1,4,'Parent',h);
                axs(2) = subplot(4,1,3);
                axs(3) = subplot(4,1,2);
                axs(4) = subplot(4,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                
%                 x0 = [0,0,0];
%                 fval0 = f(x0);
% 				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
% 					x0,...
% 					[-2e6,-qubit.g_XY2_amp*0.05,-0.25],...
% 					[2e6,qubit.g_XY2_amp*0.05,0.25],...
% 					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01);
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp);
                QS.saveSSettings({qubit.name,'qr_xy_dragAlpha'},qubit.qr_xy_dragAlpha);
			else
				error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
					qubit.g_XY_typ);
            end
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['XYGateOpt_',TimeStamp,'.mat'];
			figFileName = ['XYGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'xyGateOptWithDrag';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
		end
		function xyGateOptNoDrag(qubit,numGates,numShots,rAvg,maxIter)
            if nargin < 4
                maxIter = 20;
            end
 
			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if qubit.qr_xy_dragPulse
				error('DRAG enable, can not do no DRAG optimization, checking qubit settings.');
			end
			qubit.r_avg = rAvg;
			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numShots);
			
			detune = qes.expParam(qubit,'f01');
			detune.offset = qubit.f01;
			
			XY2_amp = qes.expParam(qubit,'g_XY2_amp');
			XY2_amp.offset = qubit.g_XY2_amp;
			
			XY_amp = qes.expParam(qubit,'g_XY_amp');
			XY_amp.offset = qubit.g_XY_amp;
            
            QS = qes.qSettings.GetInstance();

			opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
			if isempty(qubit.g_XY_typ) || strcmp(qubit.g_XY_typ,'pi')
				f = qes.expFcn([detune,XY2_amp,XY_amp],R);
                
                x0 = [0,-0.05*qubit.g_XY2_amp,-0.05*qubit.g_XY_amp;...
                    -0.5e6,-0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp;...
                    -0.5e6,0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp;...
                    0.5e6,0.05*qubit.g_XY2_amp,0.05*qubit.g_XY_amp];
                tolX = [1e4,qubit.g_XY2_amp/1e4, qubit.g_XY_amp/1e4];
                tolY = [5e-4];

                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s', qubits.name),false);
                axs(1) = subplot(4,1,4,'Parent',h);
                axs(2) = subplot(4,1,3);
                axs(3) = subplot(4,1,2);
                axs(4) = subplot(4,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                
%                 x0 = [0,0,0];
%                 fval0 = f(x0);
% 				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
% 					x0,...
% 					[-2e6,-qubit.g_XY2_amp*0.05,-qubit.g_XY_amp*0.05],...
% 					[2e6,qubit.g_XY2_amp*0.05,qubit.g_XY_amp*0.05],...
% 					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01);
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp);
                QS.saveSSettings({qubit.name,'g_XY_amp'},qubit.g_XY_amp);
			elseif strcmp(qubit.g_XY_typ,'hPi')
				f = qes.expFcn([detune,XY2_amp,alpha],R);
                
                x0 = [-0.5e6,-0.05*qubit.g_XY2_amp;...
                    -0.5e6,0.05*qubit.g_XY2_amp;...
                    0.5e6,0.05*qubit.g_XY2_amp];
                tolX = [1e4,qubit.g_XY2_amp/1e4];
                tolY = [5e-4];

                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s', qubits.name),false);
                axs(1) = subplot(4,1,4,'Parent',h);
                axs(2) = subplot(4,1,3);
                axs(3) = subplot(4,1,2);
                axs(4) = subplot(4,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                
%                 x0 = [0,0];
%                 fval0 = f(x0);
% 				[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
% 					x0,...
% 					[-2e6,-qubit.g_XY2_amp*0.05],...
% 					[2e6,qubit.g_XY2_amp*0.05],...
% 					opts);
                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                QS.saveSSettings({qubit.name,'f01'},qubit.f01);
                QS.saveSSettings({qubit.name,'g_XY2_amp'},qubit.g_XY2_amp);
			else
				error('unrecognized X gate type: %s, available x gate options are: pi and hPi',...
					qubit.g_XY_typ);
            end
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['XYGateOpt_',TimeStamp,'.mat'];
			figFileName = ['XYGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'xyGateOptNoDrag';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','hwSettings','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
        end
		
		function zGateOpt(qubit,numGates,numShots,rAvg,maxIter)
            if nargin < 4
                maxIter = 20;
            end
 
			import sqc.op.physical.*
			if ischar(qubit)
				qubit = sqc.util.qName2Obj(qubit);
			end
			if ~strcmp(qubit.g_Z_typ,'z')
				error('zGateOpt perform Z gate optimization by tunning pulse callibration paraeters, it is applicable only when Z gate is implemented by z pulse, check Z gate settings.');
			end
			qubit.r_avg = rAvg;
			Z = sqc.op.physical.gate.Z(qubit);
			R = sqc.measure.randBenchMarking4Opt(qubit,numGates,numShots,Z);
            
            QS = qes.qSettings.GetInstance();
			
			Z_amp = qes.expParam(Z,'amp');
			Z_amp.offset = qubit.g_Z_z_amp;
			
 			da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                         'name',qubit.channels.z_pulse.instru);
            z_daChnl = da.GetChnl(qubit.channels.z_pulse.chnl);
%             
%             xfrFuncSettings = QS.loadHwSettings({'obj.qubit.channels.z_pulse.instru',...
%                 'xfrFunc'});
%             xfrFunc = xfrFuncSettings{obj.qubit.channels.z_pulse.chnl};
%            xfrFuncSetting = struct('lowPassFilters','xfrFuncs');
%            xfrFuncSetting.lowPassFilters = {struct('type','function',...
%                'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
%                'bandWidth','0.130')};
%            xfrFuncSetting.xfrFuncs = {struct('type','function',...
%                'funcName','qes.waveform.xfrFunc.gaussianExp',...
%                'bandWidth',0.25,...
%                'rAmp',[0.0155],...
%                'td',[800])};
				
			lowPassFilterSettings0 = struct('type','function',...
					'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
					'bandWidth',0.130);
            xfrFuncsSettings0 = struct('type','function',...
                'funcName','qes.waveform.xfrFunc.gaussianExp',...
                'bandWidth',0.25,...
                'rAmp',[0.0155],...
                'td',[800]);
			
			rAmp = qes.util.hvar(xfrFuncsSettings0.rAmp(1));
			td = qes.util.hvar(xfrFuncsSettings0.td(1));
			function setXfrFunc()
				lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
				xfrFunc_ = qes.util.xfrFuncBuilder(...
					struct('type','function',...
					'funcName','qes.waveform.xfrFunc.gaussianExp',...
					'bandWidth',0.25,...
					'rAmp',[rAmp.val],...
					'td',[td.val]));
				xfrFunc = lowPassFilter.add(xfrFunc_.inv());
				z_daChnl.xfrFunc = xfrFunc;
			end
            
			p_rAmp = qes.expParam(rAmp,'val');
			p_rAmp.offset = rAmp.val;
            p_rAmp.callbacks = {@(x)setXfrFunc()};
            setXfrFunc()
			
			p_td = qes.expParam(td,'val');
            p_td.callbacks = {@(x)setXfrFunc()};
			p_td.offset = td.val;

            
            f = qes.expFcn([Z_amp,p_rAmp,p_td],R);
            
            
            x0 = [-1e6,-0.05*qubit.g_XY2_amp;...
                    -1e6,0.05*qubit.g_XY2_amp;...
                    1e6,0.05*qubit.g_XY2_amp];
            tolX = [1e4,qubit.g_XY2_amp/1e4];
            tolY = [5e-4];

            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s', qubits.name),false);
            axs(1) = subplot(4,1,4,'Parent',h);
            axs(2) = subplot(4,1,3);
            axs(3) = subplot(4,1,2);
            axs(4) = subplot(4,1,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);
            
%             x0 = [0,0,0];
%             fval0 = f(x0);
%             opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
%             [optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
%                 x0,...
%                 [-qubit.g_Z_z_amp*0.05,-0.03,100],...
%                 [qubit.g_Z_z_amp*0.05,0.03,1500],...
%                 opts);
                
                
            if fval > fval0
                error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
                
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['ZGateOpt_',TimeStamp,'.mat'];
			figFileName = ['ZGateOpt_',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'ZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings',...
				'hwSettings','lowPassFilterSettings0','xfrFuncsSettings0','notes');
			try
				saveas(gcf,figFileName);
			catch
			end
        end
        
        function czOptPulseCal_oneDecay(qubits,isACZQ,numGates,numShots,rAvg,maxIter,...
                useFminsearch,fixedSequence)
            maxFEval = maxIter;
 
			import sqc.op.physical.*
            for ii = 1:numel(qubits)
                if ischar(qubits{ii})
                    qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
			
            if fixedSequence
                R = sqc.measure.randBenchMarkingFS(qubits,numGates);
            else
                R = sqc.measure.randBenchMarking4Opt(qubits,numGates,numShots);
            end

            QS = qes.qSettings.GetInstance();

            if isACZQ
                calQInd = 1;
            else
                calQInd = 2;
            end
 			da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                         'name',qubits{calQInd}.channels.z_pulse.instru);
            z_daChnl = da.GetChnl(qubits{calQInd}.channels.z_pulse.chnl);

			lowPassFilterSettings0 = struct('type','function',...
					'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
					'bandWidth',0.130);
            xfrFuncsSettings0 = struct('type','function',...
                'funcName','qes.waveform.xfrFunc.gaussianExp',...
                'bandWidth',0.25,...
                'rAmp',[0.0155],...
                'td',[800]);
			
			rAmp = qes.util.hvar(xfrFuncsSettings0.rAmp(1));
			td = qes.util.hvar(xfrFuncsSettings0.td(1));
            rAmp_his = [];
            td_his = [];
            
            if useFminsearch
                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ pls cal', qubits{1}.name, qubits{2}.name),false);
                axs(1) = subplot(2,1,2,'Parent',h);
                axs(2) = subplot(2,1,1);
            end
            
			function setXfrFunc()
				lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
				xfrFunc_ = qes.util.xfrFuncBuilder(...
					struct('type','function',...
					'funcName','qes.waveform.xfrFunc.gaussianExp',...
					'bandWidth',0.25,...
					'rAmp',[rAmp.val],...
					'td',[td.val]));
				xfrFunc = lowPassFilter.add(xfrFunc_.inv());
				z_daChnl.xfrFunc = xfrFunc;
                rAmp_his = [rAmp_his,rAmp.val];
                td_his = [td_his,td.val];
                if useFminsearch
                    try
                        plot(axs(1),rAmp_his);
                        plot(axs(2),td_his);
                    catch
                    end
                end
			end
            
			p_rAmp = qes.expParam(rAmp,'val');
			% p_rAmp.offset = rAmp.val;
            p_rAmp.callbacks = {@(x)setXfrFunc()};
            setXfrFunc();
			
			p_td = qes.expParam(td,'val');
            p_td.callbacks = {@(x)setXfrFunc()};
			% p_td.offset = td.val;
            
			f = qes.expFcn([p_rAmp,p_td],R);
		
            if useFminsearch
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.005,'PlotFcns',{@optimplotfval});	
                x0 = [0,200];
                fval0 = f(x0);
                [optParams,fval,exitflag,output] = fminsearch(f.fcn,x0,opts);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                x0 = [-0.05,200;...
                        -0.05,1000;...
                        0.05,1000];
                tolX = [0.0005,1];
                tolY = 0.001;
                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ pls cal', qubits{1}.name, qubits{2}.name),false);
                axs(1) = subplot(3,1,3,'Parent',h);
                axs(2) = subplot(3,1,2);
                axs(3) = subplot(3,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
                
                
            if fval > fval0
                error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
                
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['czOptPlsCal_',qubits{1}.name,qubits{2}.name,TimeStamp,'.mat'];
			figFileName = ['czOptPlsCal_',qubits{1}.name,qubits{2}.name,TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
            if isACZQ
                notes = ['cz Optimization: z pulse callibration ', qubits{1}.name];
            else
                notes = ['cz Optimization: z pulse callibration ', qubits{2}.name];
            end
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','rAmp_his','td_his',...
				'hwSettings','lowPassFilterSettings0','xfrFuncsSettings0','notes');
			try
				saveas(gcf,fullfile(dataPath,figFileName));
			catch
			end
        end
        
        function czOptPulseCal_2Decay(qubits,isACZQ,numGates,numShots,rAvg,maxIter,useFminsearc)
            maxFEval = maxIter;
 
			import sqc.op.physical.*
            for ii = 1:numel(qubits)
                if ischar(qubits{ii})
                    qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
			
			R = sqc.measure.randBenchMarking4Opt(qubits,numGates,numShots);
            
            QS = qes.qSettings.GetInstance();

            if isACZQ
                calQInd = 1;
            else
                calQInd = 2;
            end
 			da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                         'name',qubits{calQInd}.channels.z_pulse.instru);
            z_daChnl = da.GetChnl(qubits{calQInd}.channels.z_pulse.chnl);

			lowPassFilterSettings0 = struct('type','function',...
					'funcName','com.qos.waveform.XfrFuncFastGaussianFilter',...
					'bandWidth',0.130);
			
			rAmp1 = qes.util.hvar(0);
			td1 = qes.util.hvar(50);
            rAmp1_his = [];
            td1_his = [];
            
            rAmp2 = qes.util.hvar(0);
			td2 = qes.util.hvar(500);
            rAmp2_his = [];
            td2_his = [];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ pls cal', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(4,1,1,'Parent',h);
            axs(2) = subplot(4,1,2);
            axs(3) = subplot(4,1,3);
            axs(4) = subplot(4,1,4);
            
			function setXfrFunc()
				lowPassFilter = qes.util.xfrFuncBuilder(lowPassFilterSettings0);
				xfrFunc_ = qes.util.xfrFuncBuilder(...
					struct('type','function',...
					'funcName','qes.waveform.xfrFunc.gaussianExp',...
					'bandWidth',0.25,...
					'rAmp',[rAmp1.val,rAmp2.val],...
					'td',[td1.val,td2.val]));
				xfrFunc = lowPassFilter.add(xfrFunc_.inv());
				z_daChnl.xfrFunc = xfrFunc;
                rAmp1_his = [rAmp1_his,rAmp1.val];
                td1_his = [td1_his,td1.val];
                rAmp2_his = [rAmp2_his,rAmp2.val];
                td2_his = [td2_his,td2.val];
                if useFminsearch
                    try
                        plot(axs(1),rAmp1_his);
                        plot(axs(2),td1_his);
                        plot(axs(3),rAmp2_his);
                        plot(axs(4),td2_his);
                    catch

                    end
                end
			end
            
			p_rAmp1 = qes.expParam(rAmp1,'val');
            p_rAmp1.callbacks = {@(x)setXfrFunc()};
    
			p_td1 = qes.expParam(td1,'val');
            p_td1.callbacks = {@(x)setXfrFunc()};
            
            p_rAmp2 = qes.expParam(rAmp2,'val');
            p_rAmp2.callbacks = {@(x)setXfrFunc()};
    
			p_td2 = qes.expParam(td2,'val');
            p_td2.callbacks = {@(x)setXfrFunc()};
            
			f = qes.expFcn([p_rAmp1,p_td1,p_rAmp2,p_td2],R);
		
            if useFminsearch
                %%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%
                opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.005,'PlotFcns',{@optimplotfval});	
                x0 = [0.015,30,0.015,800];
                fval0 = f(x0);
                [optParams,fval,exitflag,output] = fminsearch(f.fcn,x0,opts);

                if fval > fval0
                    error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%
            else
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                x0 = [-0.5,50,-0.05,200;...
                      -0.5,50,-0.05,1500;...
                      -0.5,50,0.05,1500;...
                      -0.5,200,0.05,1500;...
                      0.5,200,0.05,1500];
                tolX = [0.0005,1,0.0005,1];
                tolY = 0.001;
                h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ pls cal', qubits{1}.name, qubits{2}.name),false);
                axs(1) = subplot(3,1,3,'Parent',h);
                axs(2) = subplot(3,1,2);
                axs(3) = subplot(3,1,1);
                [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
                fval = y_trace(end);
                fval0 = y_trace(1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
                
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['czOptPlsCal_',qubits{1}.name,qubits{2}.name,TimeStamp,'.mat'];
			figFileName = ['czOptPlsCal_',qubits{1}.name,qubits{2}.name,TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
            if isACZQ
                notes = ['cz Optimization: z pulse callibration ', qubits{1}.name];
            else
                notes = ['cz Optimization: z pulse callibration ', qubits{2}.name];
            end
            save(fullfile(dataPath,dataFileName),'optParams','sessionSettings','rAmp1_his','td1_his','rAmp1_his','td1_his',...
				'hwSettings','lowPassFilterSettings0','xfrFuncsSettings0','notes');
			try
				saveas(gcf,fullfile(dataPath,figFileName));
			catch
			end
        end

        % function czOptPhase(qubits,numGates,numShots, rAvg, maxFEval)
        function czOptPhase(qubits,numGates, numShots, rAvg, maxFEval)
            if nargin < 5
                maxFEval = 100;
            end
			
			import sqc.op.physical.*
			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end

			aczSettings = sqc.qobj.aczSettings(sprintf('%s_%s',qubits{1}.name,qubits{2}.name));
            aczSettings.load();
			qubits{1}.aczSettings = aczSettings;
			
			% R = sqc.measure.randBenchMarking4Opt(qubits,numGates,numShots);

            R = sqc.measure.randBenchMarkingFS(qubits,numGates,numShots);
			
			phase1 = qes.expParam(aczSettings,'dynamicPhase(1)');
			
			phase2 = qes.expParam(aczSettings,'dynamicPhase(2)');
            
			f = qes.expFcn([phase1,phase2],R);
            
% 			x0 = [0,0];
% 			fval0 = f(x0);
%             opts = optimset('Display','none','MaxIter',maxIter,'TolX',0.0001,'TolFun',0.01,'PlotFcns',{@optimplotfval});
% 			[optParams,fval,exitflag,output] = qes.util.fminsearchbnd(f.fcn,...
%                     x0,...
% 					[-pi,-pi],...
% 					[pi,pi],...
% 					opts);

%             x0 = [-pi,-pi;...
%                     -pi,pi;...
%                     0,pi]/3;

            x0 = [scz.dynamicPhase(1),scz.dynamicPhase(2)-pi/4;...
                    scz.dynamicPhase(1)-pi/4,scz.dynamicPhase(2)+pi/4;...
                    scz.dynamicPhase(1)+pi/4,scz.dynamicPhase(2)+pi/4];
            tolX = [pi,pi]/1e3;
            tolY = [5e-4];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(3,1,3,'Parent',h);
            axs(2) = subplot(3,1,2);
            axs(3) = subplot(3,1,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);

			if fval > fval0
               error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
            
            QS = qes.qSettings.GetInstance();
            
            % note: aczSettings is a handle class
            aczSettings.dynamicPhase = aczSettings.dynamicPhase - 2*pi*floor(aczSettings.dynamicPhase/(2*pi));
			QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								aczSettings.dynamicPhase);
			
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
        
        % function czOptPhaseAmp(qubits,numGates, rAvg, maxFEval)
        function czOptPhaseAmp(qubits,numGates, numShots,rAvg, maxFEval)
            if nargin < 5
                maxFEval = 100;
            end
			
			import sqc.op.physical.*
			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end

			aczSettings = sqc.qobj.aczSettings(sprintf('%s_%s',qubits{1}.name,qubits{2}.name));
            aczSettings.load();
			qubits{1}.aczSettings = aczSettings;
			
			% R = sqc.measure.randBenchMarking4Opt(qubits,numGates,numShots);
            R = sqc.measure.randBenchMarkingFS(qubits,numGates,numShots);
			
			phase1 = qes.expParam(aczSettings,'dynamicPhase(1)');
			phase2 = qes.expParam(aczSettings,'dynamicPhase(2)');
            
            amplitude = qes.expParam(aczSettings,'amp');
			amplitude.offset = aczSettings.amp;
            
			f = qes.expFcn([phase1,phase2,amplitude],R);

            x0 = [-0.5,-0.5,-0.05*aczSettings.amp;...
                    -0.5,-0.5,0.05*aczSettings.amp;...
                    -0.5,0.5,0.05*aczSettings.amp;...
                    0.5,0.5,0.05*aczSettings.amp];
            tolX = [pi/1e3,pi/1e3,1];
            tolY = [1e-3];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(4,1,4,'Parent',h);
            axs(2) = subplot(4,1,3);
            axs(3) = subplot(4,1,2);
            axs(4) = subplot(4,1,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);

			if fval > fval0
               error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
            
            QS = qes.qSettings.GetInstance();
            % note: aczSettings is a handle class
            aczSettings.dynamicPhase = aczSettings.dynamicPhase - 2*pi*floor(aczSettings.dynamicPhase/(2*pi));
			QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								aczSettings.dynamicPhase);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'amp'},...
								aczSettings.amp);
			
			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
        
        function czOptLeakage(qubits,numGates, rAvg, maxFEval)
            import sqc.op.physical.*
            if nargin < 4
                maxFEval = 100;
            end

			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
            aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
			aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
            aczSettings.load();
            
            nG1 = numGates;
            if nG1 < 3
                nG2 = 3;
            else
                nG2 = ceil(nG1*2/3);
            end

            function leakage = measureLeakage()
                qubits{1}.aczSettings = aczSettings;
                X1 = sqc.op.physical.gate.X(qubits{1});
                X2 = sqc.op.physical.gate.X(qubits{2});
                CZ = sqc.op.physical.gate.CZ(qubits{1},qubits{2});
                R = sqc.measure.resonatorReadout_ss(qubits{2}); 
                R.state = 1;
                proc = (X1.*X2)*CZ^nG1;
                proc.Run();
                R.delay = proc.length;
                leakage = R();
                proc = (X1.*X2)*CZ^nG2;
                proc.Run();
                R.delay = proc.length;
                leakage = leakage + R();
            end
            m = qes.measurement.measureByFunction(@measureLeakage);

            lam2 = qes.expParam(aczSettings,'lam2');
			lam2.offset = aczSettings.lam2;
            lam3 = qes.expParam(aczSettings,'lam3');
			lam3.offset = aczSettings.lam3;
            
			f = qes.expFcn([lam2,lam3],m);
            x0 = [-0.3,-0.1;...
                  -0.3,0.1;...
                  -0.05,0.1];
            
            tolX = [1e-4,1e-4];
            tolY = [1e-4];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(2,2,4,'Parent',h);
            axs(2) = subplot(2,2,3);
            axs(3) = subplot(2,2,2);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);
            
%              [~,ind] = min(y_trace);
%              aczSettings.thf = x_trace(ind,1);
%              aczSettings.lam2 = x_trace(ind,3);
%              aczSettings.lam3 = x_trace(ind,4);

% 			if fval > fval0
%                error('Optimization failed: no convergence, registry not updated.');
%             end
            
            QS = qes.qSettings.GetInstance();
            % note: aczSettings is a handle class
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam2'},aczSettings.lam2);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam3'},aczSettings.lam3);

			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateLeakageOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
        
        function czOptLeakage__(qubits,numGates, rAvg, maxFEval)
            import sqc.op.physical.*
            if nargin < 4
                maxFEval = 100;
            end

			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
            aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
			aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
            aczSettings.load();
            
            nG1 = numGates;
            if nG1 < 3
                nG2 = 3;
            else
                nG2 = ceil(nG1*2/3);
            end
            R1 = sqc.measure.resonatorReadout_ss(qubits{2}); 
            R1.state = 1;
            R2 = sqc.measure.phase(qubits{2}); 

            X1 = gate.X(qubits{1});
            I1 = gate.I(qubits{1});
            I1.ln = X1.length;
            X2 = sqc.op.physical.gate.X(qubits{2});
            I2 = gate.I(qubits{2});
            I2.ln = X1.length;
            Y2m = gate.Y2m(qubits{2});
            
            function Err = measureLeakage()
                qubits{1}.aczSettings = aczSettings;
                CZ = sqc.op.physical.gate.CZ(qubits{1},qubits{2});
                proc = (X1.*X2)*CZ^nG1;
                proc.Run();
                R1.delay = proc.length;
                leakage = R1();
%                 proc = (X1.*X2)*CZ^nG2;
%                 proc.Run();
%                 Rl.delay = proc.length;
%                 leakage = leakage + Rl();

                proc = Y2m*CZ;
                R2.setProcess(proc);
                phase0 = R2();
                proc = ((X1.*I2)*Y2m)*CZ;
                R2.setProcess(proc);
                phase1 = R2();
                phaseDiff = abs(rem(phase1 - phase0,2*pi));
                Err = leakage + abs(pi - phaseDiff)/pi;
            end
            m = qes.measurement.measureByFunction(@measureLeakage);
            amp = qes.expParam(aczSettings,'amp');
            amp.offset = aczSettings.amp;
            lam2 = qes.expParam(aczSettings,'lam2');
			lam2.offset = aczSettings.lam2;
            lam3 = qes.expParam(aczSettings,'lam3');
			lam3.offset = aczSettings.lam3;
            
			f = qes.expFcn([amp,lam2,lam3],m);
            amp0 = aczSettings.amp;
            x0 = [0.97*amp0, -0.3,-0.1;...
                  0.97*amp0, -0.3,0.1;...
                  0.97*amp0, -0.05,0.1;...
                  1.03*amp0, -0.05,0.1];
            
            tolX = [1e-4,1e-4,1e-4];
            tolY = [1e-4];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(2,2,4,'Parent',h);
            axs(2) = subplot(2,2,3);
            axs(3) = subplot(2,2,2);
            axs(4) = subplot(2,2,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);
            
%              [~,ind] = min(y_trace);
%              aczSettings.thf = x_trace(ind,1);
%              aczSettings.lam2 = x_trace(ind,3);
%              aczSettings.lam3 = x_trace(ind,4);

% 			if fval > fval0
%                error('Optimization failed: no convergence, registry not updated.');
%             end
            
            QS = qes.qSettings.GetInstance();
            % note: aczSettings is a handle class
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam2'},aczSettings.lam2);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam3'},aczSettings.lam3);

			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateLeakageOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
        
        function czOptLeakage_(qubits,numGates, rAvg, maxFEval)
            import sqc.op.physical.*
            if nargin < 4
                maxFEval = 100;
            end

			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
            aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
			aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
            aczSettings.load();
            
            nG1 = numGates;
            if nG1 < 3
                nG2 = 3;
            else
                nG2 = ceil(nG1*2/3);
            end

            function leakage = measureLeakage()
                qubits{1}.aczSettings = aczSettings;
                X1 = sqc.op.physical.gate.X(qubits{1});
                X2 = sqc.op.physical.gate.X(qubits{2});
                CZ = sqc.op.physical.gate.CZ(qubits{1},qubits{2});
                R = sqc.measure.resonatorReadout_ss(qubits{2}); 
                R.state = 1;
                proc = (X1.*X2)*CZ^nG1;
                proc.Run();
                R.delay = proc.length;
                leakage = R();
%                 proc = (X1.*X2)*CZ^nG2;
%                 proc.Run();
%                 R.delay = proc.length;
%                 leakage = leakage + R();
            end
            m = qes.measurement.measureByFunction(@measureLeakage);
            
            thf = qes.expParam(aczSettings,'thf');
			thf.offset = aczSettings.thf;
            lam2 = qes.expParam(aczSettings,'lam2');
			lam2.offset = aczSettings.lam2;
            lam3 = qes.expParam(aczSettings,'lam3');
			lam3.offset = aczSettings.lam3;
            
			f = qes.expFcn([thf,lam2,lam3],m);
            x0 = [0.45*pi/2,-0.4,-0.1;...
                  0.45*pi/2,-0.4,0.1;...
                  0.45*pi/2,0,0.1;...
                  0.65*pi/2,0,0.1];
            
            tolX = [1e-4,1e-4,1e-4];
            tolY = [1e-4];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(2,2,4,'Parent',h);
            axs(2) = subplot(2,2,3);
            axs(3) = subplot(2,2,2);
            axs(4) = subplot(2,2,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);
            
%              [~,ind] = min(y_trace);
%              aczSettings.thf = x_trace(ind,1);
%              aczSettings.lam2 = x_trace(ind,3);
%              aczSettings.lam3 = x_trace(ind,4);

% 			if fval > fval0
%                error('Optimization failed: no convergence, registry not updated.');
%             end
            
            QS = qes.qSettings.GetInstance();
            % note: aczSettings is a handle class
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'thf'},aczSettings.thf);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam2'},aczSettings.lam2);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam3'},aczSettings.lam3);

			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateLeakageOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
		
		function czOpt(qubits,numGates, rAvg, maxFEval)
            if nargin < 5
                maxFEval = 100;
            end
			
			import sqc.op.physical.*
			if ~iscell(qubits) || numel(qubits) ~= 2
				error('qubits not a cell of 2.');
			end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Obj(qubits{ii});
                end
                qubits{ii}.r_avg = rAvg;
            end
            aczSettingsKey = sprintf('%s_%s',qubits{1}.name,qubits{2}.name);
			aczSettings = sqc.qobj.aczSettings(aczSettingsKey);
            aczSettings.load();
			qubits{1}.aczSettings = aczSettings;
			
			% R = sqc.measure.randBenchMarking4Opt(qubits,numGates,10);
            R = sqc.measure.randBenchMarkingFS(qubits,numGates,numShots);
			
			phase1 = qes.expParam(aczSettings,'dynamicPhase(1)');
			phase1.offset = aczSettings.dynamicPhase(1);
			
			phase2 = qes.expParam(aczSettings,'dynamicPhase(2)');
			phase2.offset = aczSettings.dynamicPhase(2);
            
            amplitude = qes.expParam(aczSettings,'amp');
			amplitude.offset = aczSettings.amp;
            
            thf = qes.expParam(aczSettings,'thf');
			thf.offset = aczSettings.thf;
            
            thi = qes.expParam(aczSettings,'thi');
			thi.offset = aczSettings.thi;
            
            lam2 = qes.expParam(aczSettings,'lam2');
			lam2.offset = aczSettings.lam2;
            
            lam3 = qes.expParam(aczSettings,'lam3');
			lam3.offset = aczSettings.lam3;
            
			f = qes.expFcn([phase1,phase2,amplitude,thf,thi,lam2,lam3],R);

            x0 = [-0.1,-0.1,-0.02*aczSettings.amp,-0.2,-0.2,-0.2,-0.2;...
                    -0.1,-0.1,-0.02*aczSettings.amp,-0.2,-0.2,-0.2,0.2;...
                    -0.1,-0.1,-0.02*aczSettings.amp,-0.2,-0.2,0.2,0.2;...
                    -0.1,-0.1,-0.02*aczSettings.amp,-0.2,0.2,0.2,0.2;...
                    -0.1,-0.1,-0.02*aczSettings.amp,0.2,0.2,0.2,0.2;...
                    -0.1,-0.1,0.02*aczSettings.amp,0.2,0.2,0.2,0.2;...
                    -0.1,0.1,0.02*aczSettings.amp,0.2,0.2,0.2,0.2;...
                    0.1,0.1,0.02*aczSettings.amp,0.2,0.2,0.2,0.2];
            
            tolX = [pi/5e4,pi/5e4,1,1e-4,1e-4,1e-4,1e-4];
            tolY = [1e-4];
            
            h = qes.ui.qosFigure(sprintf('Gate Optimizer | %s%s CZ', qubits{1}.name, qubits{2}.name),false);
            axs(1) = subplot(4,2,8,'Parent',h);
            axs(2) = subplot(4,2,7);
            axs(3) = subplot(4,2,6);
            axs(4) = subplot(4,2,5);
            axs(5) = subplot(4,2,4);
            axs(6) = subplot(4,2,3);
            axs(7) = subplot(4,2,2);
            axs(8) = subplot(4,2,1);
            [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
            fval = y_trace(end);
            fval0 = y_trace(1);

			if fval > fval0
               error('Optimization failed: final fidelity worse than initial fidelity, registry not updated.');
            end
            
            QS = qes.qSettings.GetInstance();
            % note: aczSettings is a handle class
            aczSettings.dynamicPhase = aczSettings.dynamicPhase - 2*pi*floor(aczSettings.dynamicPhase/(2*pi));
			QS.saveSSettings({'shared','g_cz',aczSettingsKey,'dynamicPhase'},...
								aczSettings.dynamicPhase);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'amp'},aczSettings.amp);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'thf'},aczSettings.thf);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'thi'},aczSettings.thi);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam2'},aczSettings.lam2);
            QS.saveSSettings({'shared','g_cz',aczSettingsKey,'lam3'},aczSettings.lam3);

			dataPath = QS.loadSSettings('data_path');
			TimeStamp = datestr(now,'_yymmddTHHMMSS_');
			dataFileName = ['CZGateOpt',TimeStamp,'.mat'];
			figFileName = ['CZGateOpt',TimeStamp,'.fig'];
			sessionSettings = QS.loadSSettings;
			hwSettings = QS.loadHwSettings;
			notes = 'CZGateOpt';
            save(fullfile(dataPath,dataFileName),'optParams','x_trace','y_trace','sessionSettings','hwSettings','notes');
			try
				saveas(h,fullfile(dataPath,figFileName));
			catch
			end
        end
        
    end
end