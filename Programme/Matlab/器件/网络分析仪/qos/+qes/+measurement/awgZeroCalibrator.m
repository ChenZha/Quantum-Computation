classdef awgZeroCalibrator < qes.measurement.measurement
	% measure awg zero offset
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        fine@logical scalar = false;
        showProcess@logical scalar = false
    end
    properties (SetAccess = private, GetAccess = private)
        awgChnl
		chnl
        volt
        ax
    end
    methods
        function obj = awgZeroCalibrator(awgChnl,voltM)
            obj = obj@qes.measurement.measurement([]);
			obj.awgChnl = awgChnl;
            obj.chnl = awgChnl.chnl;
            voltM.datafcn = @abs;
            obj.volt = voltM;
            obj.numericscalardata = true;
        end
        function AX = getAx(obj)
            AX = obj.ax;
        end
        function Run(obj)
			Run@qes.measurement.measurement(obj);
            function dcLvl(lvl)
                DASequence = qes.waveform.DASequence(...
                    obj.chnl,qes.waveform.sequence(...
                        qes.waveform.dc(10e3,lvl)));
                obj.awgChnl.StopContinuousWv();
                obj.awgChnl.RunContinuousWv(DASequence);
            end
            p1 = qes.expParam(@dcLvl);
            f = qes.expFcn(p1,obj.volt);
            x = 0;
            if obj.fine
                precision = obj.awgChnl.vpp/200;
            else
                precision = obj.awgChnl.vpp/20;
            end
            stopPrecision = obj.awgChnl.vpp/1e5;
            if obj.showProcess
                h = qes.ui.qosFigure(sprintf('AWG Zeros Offset Calibration | AWG %s, channel %0.0f', obj.awgChnl.name, obj.chnl),true);
                obj.ax = axes('parent',h,'Box','on');
                hl = line(NaN,NaN);
                xlabel(obj.ax,'DC waveform amplitude');
                ylabel(obj.ax,'DAC Output Voltage(mV)');
            end
            x_ = [];
            y_ = [];
            while precision > stopPrecision
                l = f(x-precision);
                c = f(x);
                r = f(x+precision);
                dx = precision*qes.util.minPos(l, c, r);
                if abs(dx) < precision
                    precision = precision/2;
                end
                if obj.showProcess
                    x_ = [x_,x];
                    y_ = [y_,c];
                    try
                        set(hl,'XData',x_,'YData',y_*1e3);
                        drawnow;
                    catch % incase of figure being closed
                    end
                end
                x = x+dx;
            end
            if obj.showProcess
                try
                	title(obj.ax,'Done.')
                catch
                end
            end
			obj.awgChnl.StopContinuousWv();
            obj.data = x;
        end
    end
end