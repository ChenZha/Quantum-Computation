classdef (Sealed = true) rect_cos < qes.waveform.waveform
    % Rectangular pulse with cosine shaped rise/fall edges and
    % drawback/overshoot calibration before/after edges

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1
        rise_time = 1
        beta = 0; % beta is a small calibration parameter, beta >= 0
        % tcut = []; % 
    end
    methods
        function obj = rect_cos(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
            % obj.tcut = obj.t0 + ln;
        end
        function set.rise_time(obj,val)
            if val < 1
                throw(MException('QOS_rect_cos:invalidArgument','rise_time < 1.'));
            end
            obj.rise_time = val;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            tmin = obj.t0;
            trise = obj.t0+obj.rise_time;
            tfall = obj.t0+obj.length-obj.rise_time;
            tmax = obj.t0+obj.length;
            flattime = obj.length-2*obj.rise_time;
            
            v = (obj.amp/2*(1-(1+obj.beta)*cos(pi*(t-obj.t0)/obj.rise_time)+...
                obj.beta*cos(3*pi*(t-obj.t0)/obj.rise_time)).*(t>=tmin).*(t<trise)+...
                obj.amp*(t>=trise).*(t<tfall)+...
                obj.amp/2*(1-(1+obj.beta)*cos(pi*(t-flattime-obj.t0)/obj.rise_time)+...
                obj.beta*cos(3*pi*(t-flattime-obj.t0)/obj.rise_time)).*(t>=tfall).*(t<tmax));  % .*(t<=obj.tcut+obj.t0);
        end
        function v = FreqFcn(obj,f)
            v = qes.waveform.fcns.FFT(obj,f);
        end
    end
end