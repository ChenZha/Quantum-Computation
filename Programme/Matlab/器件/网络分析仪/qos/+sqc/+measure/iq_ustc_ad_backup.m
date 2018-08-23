classdef iq_ustc_ad < qes.measurement.iq
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

%        upSampleNum = 1 % upsample to match DA sampling rate
        iqWeight
        
        iqRaw@logical scalar = false;
    end
    properties (SetAccess = private, GetAccess = private)
        % Cached variables
        Mc = [1, 0; 0, 1]          % mixer correction matrix
        IQ          % IQ = NaN*zeros(numFreq,obj.n); % numFreq = numel(obj.freq);

        selectidx   % selectidx = obj.startidx:obj.eidx;
        kernel      % kernel = exp(-2j*pi*obj.freq(ii).*t);
		
		adI
		adQ
    end
	methods
        function obj = iq_ustc_ad(adI,adQ)
			% the following checks are not neccessary as these properties are not implemented as channel properties in the hw driver
            assert(adI.recordLength == adQ.recordLength);
			assert(adI.demodMode == adQ.demodMode);
			assert(adI.samplingRate == adQ.samplingRate);
			assert(adI.delayStep == adQ.delayStep);
            obj = obj@qes.measurement.iq(adI);
			obj.adI = adI;
			obj.adQ = adQ;
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                throw(MException('iq_ustc_ad:InvalidInput','n should be a positive integer!'));
            end
            obj.n = val;
            if ~isempty(obj.freq)
                obj.IQ = NaN*zeros(numel(obj.freq),obj.n);
            end
        end
        function set.freq(obj,val)
            obj.freq = val;
			if obj.adI.demodMode
				obj.adI.demodFreq = obj.freq;
				obj.adQ.demodFreq = obj.freq;
			else
				if ~isempty(obj.n)
					obj.IQ = NaN*zeros(numel(obj.freq),obj.n);
				end
				calcCachedVar(obj);
            end
            obj.iqWeight = cell(1,numel(obj.freq));
        end
%        function set.upSampleNum(obj,val)
%            if isempty(val)
%                throw(MException('QOS_iq_ustc_ad:emptyUnpSampleNum','upSampleNum can not be empty.'));
%            end
%            if round(val) ~= val || val < 1
%                throw(MException('QOS_iq_ustc_ad:nonIntegerUnpSampleNum',...
%                    sprintf('upSampleNum must be a positive integer, %0.2f given.',val)));
%            end
%            obj.upSampleNum = val;
%            calcCachedVar(obj);
%        end
        function set.startidx(obj,val)
%             val = ceil(val);
%             if val < 1 || val > obj.instrumentObject.recordLength || (~isempty(obj.endidx) && val >= obj.endidx)
%                 throw(MException('iq_ustc_ad:InvalidInput',...
%                     'startidx should be an interger greater than 0 and smaller than AD recordLength and endidx!'));
%             end
            obj.startidx = val;
            calcCachedVar(obj);
        end
        function set.endidx(obj,val)
%             val = ceil(val);
%             if val <= obj.startidx || val > obj.instrumentObject.recordLength
%                 throw(MException('iq_ustc_ad:InvalidInput',...
%                     'endidx should be an interger greater than startidx and not exceeding AD recordLength!'));
%             end
            obj.endidx = val;
            calcCachedVar(obj);
        end
        function set.eps_a(obj,val)
            obj.eps_a = val;
            obj.Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2]; 
        end
        function set.eps_p(obj,val)
            obj.eps_p = val;
            obj.Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2];
        end
        function ShowVoltSignal(obj,ax)
            % plot the I Q raw voltage signals, you may need this to
            % choose startidx and endidx
			
			% TODO...
            [VI,VQ] = obj.adI.Run(1);
			
            t_ = 1e9*(0:length(VI)-1)/obj.adI.samplingRate;
%             plotyy(t,VI,t,VQ);
            if nargin < 2
                hf = qes.ui.qosFigure('AD Voltage Signal',true);
                ax = axes('Parent',hf);
                hold(ax,'on');
            end
            plot(ax,t_,VI,t_,VQ);
            drawnow;
            xlabel('Time (1/sampling rate)');
            ylabel('Digitizer Voltage Signal');
            title('Voltage signal of one segament, not trucated, by this plot you should choose the right truncation idexes for the IQ extraction process.');
            legend({'I voltage','Q voltage'});
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.n)
                throw(MException('iq_ustc_ad:RunError','some properties are not set yet!'));
            end
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
%             disp('===========');
%             tic

			if obj.adI.demodMode
				% TODO...
				[I, Q]= obj.adI.Run(obj.n);
				
				obj.IQ = (I+1j*Q).';
			else
				% tic
				[Vi,Vq] = obj.adI.Run(obj.n);
             % toc
				Vi = double(Vi) -127;
				Vq = double(Vq) -127;
                
                if obj.iqRaw
                    obj.data = obj.demod_rawIQ(Vi,Vq);
                    obj.dataready = true;
                    return;
                else
                    obj.demod(Vi,Vq);
                end
				
			end           
               % toc 
            obj.data = mean(obj.IQ);
            obj.extradata = obj.IQ;
            
            obj.dataready = true;
        end
    end
    methods (Access = private,Hidden = true)
        function calcCachedVar(obj)
            if ~isempty(obj.startidx) && ~isempty(obj.freq)
                NperSeg = obj.adI.recordLength;
                if isempty(obj.endidx)
					eidx = NperSeg;
                    % eidx = obj.upSampleNum*NperSeg;
                else
                    eidx = obj.endidx;
                end
                % typically, one needs to remove a few data points at the
                % beginning or at the end of each segament due to trigger
                % and signal may not be exactly syncronized.
				obj.selectidx = obj.startidx:1:eidx;
                % obj.selectidx = obj.startidx:obj.upSampleNum:eidx;
                % t = (obj.selectidx-obj.startidx)/...
                %     (obj.adI.samplingRate*obj.upSampleNum);
				t = (obj.selectidx-obj.startidx)/...
                    (obj.adI.samplingRate);
                obj.kernel = zeros(numel(obj.freq),numel(t));
                for ii = 1:numel(obj.freq)
                    obj.kernel(ii,:) = exp(-2j*pi*obj.freq(ii).*t);
                end
            end
        end
%         function IQ = demod(obj,Vi, Vq)
        function demod(obj, Vi, Vq)
		  % iq_ustc_ad used to suporrted the minimum delay step of one DA point, for that we need to
		  % interpolate the raw data, but interpolation is expensive, thus removed in later versions
            % Vi = qes.util.upsample_c(Vi,obj.upSampleNum);
            % Vq = qes.util.upsample_c(Vq,obj.upSampleNum);
            Vi = Vi(:,obj.selectidx);
            Vq = Vq(:,obj.selectidx);

            for ii = 1:numel(obj.freq)
                if isempty(obj.iqWeight{ii})
                    for jj = 1:obj.n
                        IQ_ = obj.kernel(ii,:).*(Vi(jj,:)+1j*Vq(jj,:));
                        IQ_ = mean(obj.Mc*[real(IQ_);imag(IQ_)],2); % correct mixer imballance
                        obj.IQ(ii,jj) = IQ_(1)+1j*IQ_(2);
                    end
                else
                    for jj = 1:obj.n
                        IQ_ = obj.kernel(ii,:).*(Vi(jj,:)+1j*Vq(jj,:));
                        IQ_ = mean(obj.Mc*[real(IQ_)*obj.iqWeight{ii}(1,:);...
                            imag(IQ_)*obj.iqWeight{ii}(2,:)],2); % correct mixer imballance
                        obj.IQ(ii,jj) = IQ_(1)+1j*IQ_(2);
                    end
                end
            end
        end
        function iqraw = demod_rawIQ(obj, Vi, Vq)
            Vi = Vi(:,obj.selectidx);
            Vq = Vq(:,obj.selectidx);
            iqraw = zeros(numel(obj.freq),size(obj.kernel,2));
            for ii = 1:numel(obj.freq)
                for jj = 1:obj.n
                    IQ_ = obj.kernel(ii,:).*(Vi(jj,:)+1j*Vq(jj,:));
                    IQ_ = obj.Mc*[real(IQ_);imag(IQ_)]; % correct mixer imballance
                    obj.IQ(ii,jj) = IQ_(1)+1j*IQ_(2);
                    iqraw(ii,:) = iqraw(ii,:) + IQ_(1,:)+1j*IQ_(2,:);
                end
            end
            iqraw = iqraw/obj.n;
        end
        function Amp = Amp(obj, Vi, Vq)
            Amp = sum(abs(Vi(:)))+ sum(abs(Vq(:)));
        end
    end
    
end