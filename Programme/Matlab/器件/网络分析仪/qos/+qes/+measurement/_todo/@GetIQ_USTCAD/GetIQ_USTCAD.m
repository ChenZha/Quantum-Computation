classdef GetIQ_USTCAD < GetIQ
    %

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        n % number of averages
        % raw voltage is truncated to only keep data in range of
        % startidx:endidx, if not specified, no truncation
        % use ShowVoltSignal to show the voltage signal and choose the
        % correct truncation index.
        startidx = 1
        endidx
        freq % demod frequency, Hz
%         singlechnl@logical  = true % use single channel or use both I chnl and Q chnl
        
        eps_a = 0 % mixer amplitude correction
        eps_p = 0 % mixer phase correction
    end
	methods
        function obj = GetIQ_USTCAD(InstrumentObject)
            if ~isa(InstrumentObject,'USTCADDA') || ~isvalid(InstrumentObject)
                error('GetIQ_USTCAD:InvalidInput','InstrumentObject is not a valid AWG class object!');
            end
            obj = obj@GetIQ(InstrumentObject);
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetIQ_USTCAD:InvalidInput','n should be a positive integer!');
            end
            obj.n = val;
        end
        function set.startidx(obj,val)
            val = ceil(val);
            if val < 1 || val > obj.InstrumentObject.record_ln || (~isempty(obj.endidx) && val >= obj.endidx)
                error('GetIQ_USTCAD:InvalidInput','startidx should be an interger greater than 0 and smaller than AD record_ln and endidx!');
            end
            obj.startidx = val;
        end
        function set.endidx(obj,val)
            val = ceil(val);
            if val <= obj.startidx || val > obj.InstrumentObject.record_ln
                error('GetIQ_USTCAD:InvalidInput','endidx should be an interger greater than startidx and not exceeding AD record_ln!');
            end
            obj.endidx = val;
        end
        function ShowVoltSignal(obj,ax)
            % plot the I Q raw voltage signals, you may need this to
            % choose startidx and endidx
            [VI,VQ] = obj.InstrumentObject.Run(1);
            t = 1e9*(0:length(VI)-1)/obj.InstrumentObject.smplrate;
%             plotyy(t,VI,t,VQ);
            if nargin < 2
                figure();
                ax = axes();
                hold(ax,'on');
            end
            plot(ax,t,VI,t,VQ);
            drawnow;
            xlabel('Time (1/sampling rate)');
            ylabel('Digitizer Voltage Signal');
            title('Voltage signal of one segament, not trucated, by this plot you should choose the right truncation idexes for the IQ extraction process.');
            legend({'I voltage','Q voltage'});
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.n)
                error('GetIQ_USTCAD:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            [Vi,Vq] = obj.InstrumentObject.Run(obj.n);
            Vi = double(Vi) -127;
            Vq = double(Vq) -127;

            IQ = obj.Run_BothChnl(Vi,Vq);
            
%             Amp = obj.Amp(Vi, Vq);
%             obj.data = Amp;
            
            obj.data = mean(IQ);
            obj.extradata = IQ;
            obj.dataready = true;
        end
    end
    methods (Access = private,Hidden = true)
        function IQ = Run_BothChnl(obj,Vi, Vq)
            Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2]; % mixer correction matrix
            NperSeg = obj.InstrumentObject.record_ln;
            if isempty(obj.endidx)
                eidx = NperSeg;
            else
                eidx = obj.endidx;
            end
            % typically, one need ot remove a few data points at the
            % beginning or at the end of each segament due to trigger
            % and signal are not exactly syncronized in most cases
            selectidx = obj.startidx:eidx;
            Vi = Vi(:,selectidx);
            Vq = Vq(:,selectidx);
            IQ = NaN*zeros(1,obj.n); 
            idx = 1:eidx - obj.startidx+1;
            t = (idx-1)/obj.InstrumentObject.smplrate;
            kernel = exp(-2j*pi*obj.freq.*t);
            for ii = 1:obj.n
                IQ_ = kernel.*(Vi(ii,:)+1j*Vq(ii,:));
                IQ_ = mean(Mc*[real(IQ_);imag(IQ_)],2); % correct mixer imballance
                IQ(ii) = IQ_(1)+1j*IQ_(2);
            end
        end
        function Amp = Amp(obj,Vi, Vq)
            Amp = sum(abs(Vi(:)))+ sum(abs(Vq(:)));
        end
    end
    
end