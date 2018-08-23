classdef GetIQ_ATS < GetIQ
    %

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        n % number of averages
        chnlmap = [1,2]; % [1,2]: chnl 1 for I, chnl 2 for Q, [2,1 ]: chnl 1 for Q, chnl 2 for I
        % raw voltage is truncated to only keep data in range of
        % startidx:endidx, if not specified, no truncation
        % use ShowVoltSignal to show the voltage signal and choose the
        % correct truncation index.
        startidx = 1
        endidx
        freq % demod frequency, Hz
        singlechnl@logical  = true % use single channel or use both I chnl and Q chnl
        
        eps_a = 0 % mixer amplitude correction
        eps_p = 0 % mixer phase correction
    end
	methods
        function obj = GetIQ_ATS(InstrumentObject)
            if ~isa(InstrumentObject,'AlazarATS') || ~isvalid(InstrumentObject)
                error('GetIQ_ATS:InvalidInput','InstrumentObject is not a valid AlazarATS class object!');
            end
            obj = obj@GetIQ(InstrumentObject);
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('GetIQ_ATS:InvalidInput','n should be a positive integer!');
            end
            obj.n = val;
            obj.InstrumentObject.num_records = val;
        end
        function set.startidx(obj,val)
            val = ceil(val);
            if val < 1 || val > obj.InstrumentObject.record_ln || (~isempty(obj.endidx) && val >= obj.endidx)
                error('GetIQ_ATS:InvalidInput','startidx should be an interger greater than 0 and smaller than AD record_ln and endidx!');
            end
            obj.startidx = val;
        end
        function set.endidx(obj,val)
            val = ceil(val);
            if val <= obj.startidx || val > obj.InstrumentObject.record_ln
                error('GetIQ_ATS:InvalidInput','endidx should be an interger greater than startidx and not exceeding AD record_ln!');
            end
            obj.endidx = val;
        end
        function ShowVoltSignal(obj)
            % plot the I Q raw voltage signals, you may need this to
            % choose startidx and endidx
            Volt = obj.InstrumentObject.FetchData();
            NperSeg = obj.InstrumentObject.record_ln;
            VI = Volt(obj.chnlmap(1),1:NperSeg);
            VQ = Volt(obj.chnlmap(2),1:NperSeg);
            figure();
            t = 1e9*(0:length(VI)-1)/obj.InstrumentObject.smplrate;
            plotyy(t,VI,t,VQ);
            xlabel('Time (ns)');
            ylabel('Digitizer Voltage Signal');
            title('Voltage signal of one segament, not trucated, by this plot you should choose the right truncation idexes for the IQ extraction process.');
            legend({'I voltage','Q voltage'});
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.n) 
                error('GetIQ_ATS:RunError','some properties are not set yet!');
            end
            Run@Measurement(obj); % check object and its handle properties are isvalid or not
            Volt = obj.InstrumentObject.FetchData();
            rawdataln = size(Volt,2);
            NperSeg = obj.InstrumentObject.record_ln;
            if NperSeg*obj.n ~= rawdataln
                error('GetIQ_ATS:RunError',...
                    'Digitizer error: the digitizer did not return the expected number of voltage signal sample points:  %0.0f expected, %0.0f returned.', NperSeg*obj.n, rawdataln);
            end
            
            if obj.singlechnl
%                 [I, Q] = Run_SingleChnl_FFT(obj, Volt);
                IQ= obj.Run_SingleChnl(Volt);
            else
                IQ = obj.Run_BothChnl(Volt);
            end
            
            obj.data = mean(IQ);
            obj.extradata = IQ;
            obj.dataready = true;
        end
    end
    methods (Access = private,Hidden = true)
        function  [t,VI,VQ] = GetVoltSignal(obj)
            % plot the I Q raw voltage signals, you may need this to
            % choose startidx and endidx
            Volt = obj.InstrumentObject.FetchData();
            NperSeg = obj.InstrumentObject.record_ln;
            VI = Volt(obj.chnlmap(1),1:NperSeg);
            VQ = Volt(obj.chnlmap(2),1:NperSeg);
            t = 1e9*(0:length(VI)-1)/obj.InstrumentObject.smplrate;
        end
        function [I, Q] = Run_SingleChnl_FFT_New(obj, Volt)
            NperSeg = obj.InstrumentObject.record_ln;
%             I = NaN*zeros(1,obj.n);
%             Q = NaN*zeros(1,obj.n);
%             Amp = NaN*zeros(1,obj.n);
%             Phase = NaN*zeros(1,obj.n);
            dsidx = 1;
            samplingfreq = obj.InstrumentObject.smplrate;
%             npts_per_ifperiod = obj.InstrumentObject.smplrate/obj.freq;
%             N = npts_per_ifperiod*floor((obj.endidx - obj.startidx)/npts_per_ifperiod);
%            idx = 1:N-1;
            L = obj.endidx-obj.startidx+1;
            VI_ = zeros(obj.n,L);
            VQ_ = zeros(obj.n,L);
            for ii = 1:obj.n
                didx = dsidx:dsidx+NperSeg-1;
                VI = Volt(obj.chnlmap(1),didx);
                VQ = Volt(obj.chnlmap(2),didx);
                dsidx = dsidx+NperSeg;
                if isempty(obj.startidx)
                    obj.startidx = 1;
                end
                if isempty(obj.endidx)
                    obj.endidx = length(VI);
                end
                VI_(ii,:) = VI(obj.startidx:obj.endidx);
                VQ_(ii,:) = VQ(obj.startidx:obj.endidx);
            end
            VI_ = sum(VI_,1);
                NFFT = 2^nextpow2(L); % Next power of 2 from length of y
                Y = fft(VI_,NFFT)/ L;
                Frequency = samplingfreq/2*linspace(0,1,NFFT/2+1);
                
%                 figure();plot(Frequency/1e6,abs(Y(1:length(Frequency))));
                
                DF = Frequency(2) - Frequency(1);
                Y = Y(Frequency >= obj.freq - 0.6*DF & Frequency <= obj.freq + 0.6*DF);
                [Amp, idx_]= max(abs(Y));
                Phase = angle(Y(idx_));

            I = Amp*cos(Phase);
            Q = Amp*sin(Phase);
        end
        function [I, Q] = Run_SingleChnl_FFT(obj, Volt)
            NperSeg = obj.InstrumentObject.record_ln;
            I = NaN*zeros(1,obj.n);
            Q = NaN*zeros(1,obj.n);
            Amp = NaN*zeros(1,obj.n);
            Phase = NaN*zeros(1,obj.n);
            dsidx = 1;
            samplingfreq = obj.InstrumentObject.smplrate;
            for ii = 1:obj.n
                didx = dsidx:dsidx+NperSeg-1;
                VI = Volt(obj.chnlmap(1),didx);
                VQ = Volt(obj.chnlmap(2),didx);
                dsidx = dsidx+NperSeg;
                if isempty(obj.startidx)
                    obj.startidx = 1;
                end
                if isempty(obj.endidx)
                    obj.endidx = length(VI);
                end
                VI = VI(obj.startidx:obj.endidx);
                VQ = VQ(obj.startidx:obj.endidx);
                npts_per_ifperiod = obj.InstrumentObject.smplrate/obj.freq;
                N = npts_per_ifperiod*floor((obj.endidx - obj.startidx)/npts_per_ifperiod);
                idx = 1:N-1;
                VI = VI(idx);
                VQ = VQ(idx);
                
                L = length(VI);
                NFFT = 2^nextpow2(L); % Next power of 2 from length of y
                Y = fft(VI,NFFT)/ L;
                Frequency = samplingfreq/2*linspace(0,1,NFFT/2+1);
                
%                 figure();plot(Frequency/1e6,abs(Y(1:length(Frequency))));
                
                DF = Frequency(2) - Frequency(1);
                Y = Y(Frequency >= obj.freq - 0.6*DF & Frequency <= obj.freq + 0.6*DF);
                [Amp_, idx_]= max(abs(Y));
                Amp(ii)  = Amp_;
                Phase(ii) = angle(Y(idx_));
            end
            Amp = mean(Amp);
            Phase = mean(Phase);
            I = Amp*cos(Phase);
            Q = Amp*sin(Phase);
        end
        function IQ = Run_SingleChnl(obj, Volt)
            chnlidx = 1; % 1 for I channel, 2 for Q channel
            
            NperSeg = obj.InstrumentObject.record_ln;
            if isempty(obj.endidx)
                eidx = NperSeg;
            else
                eidx = obj.endidx;
            end
            selectidx = obj.startidx:eidx;
            IQ = NaN*zeros(1,obj.n); 
            dsidx = 1;
            samplingfreq = obj.InstrumentObject.smplrate;
            npts_per_ifperiod = samplingfreq/obj.freq;
            idx = 1:npts_per_ifperiod*floor((eidx - obj.startidx+1)/npts_per_ifperiod);
            t = (idx-1)/samplingfreq;
            kernel = exp(-2j*pi*obj.freq.*t);
            for ii = 1:obj.n
                V = Volt(obj.chnlmap(chnlidx),dsidx:dsidx+NperSeg-1);
                dsidx = dsidx+NperSeg;
                % typically, one need ot remove a few data points at the
                % beginning or at the end of each segament due to trigger
                % and signal are not exactly syncronized in most cases
                V = V(selectidx); 
                IQ(ii) = mean(kernel.*V(idx));
            end
        end
        function IQ = Run_BothChnl(obj,Volt)
            Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2]; % mixer correction matrix
            NperSeg = obj.InstrumentObject.record_ln;
            if isempty(obj.endidx)
                eidx = NperSeg;
            else
                eidx = obj.endidx;
            end
            selectidx = obj.startidx:eidx;
            IQ = NaN*zeros(1,obj.n); 
            dsidx = 1;
            samplingfreq = obj.InstrumentObject.smplrate;
            idx = 1:eidx - obj.startidx+1;
            t = (idx-1)/samplingfreq;
            kernel = exp(-2j*pi*obj.freq.*t);
            for ii = 1:obj.n
                V = Volt(obj.chnlmap,dsidx:dsidx+NperSeg-1);
                dsidx = dsidx+NperSeg;
                % typically, one need ot remove a few data points at the
                % beginning or at the end of each segament due to trigger
                % and signal are not exactly syncronized in most cases
                IQ_ = kernel.*(V(1,selectidx)+1j*V(2,selectidx));
                IQ_ = mean(Mc*[real(IQ_);imag(IQ_)],2); % correct mixer imballance
                IQ(ii) = IQ_(1)+1j*IQ_(2);
            end
        end
    end
    
end