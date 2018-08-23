classdef iq_ustc_ad < qes.measurement.iq
    % data(m): IQ mean of demod frequency freq(m)
    % extradata(num_demod_freq,n), n: num stats
    % extradata(m,k), IQ of kth shot of demod frequency freq(m)

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        n = 100 % number of averages
        % raw voltage is truncated to only keep data in range of
        % startidx:endidx, if not specified, no truncation
        % use ShowVoltSignal to show the voltage signal and choose the
        % correct truncation index.
        startidx
        endidx
        freq % demod frequency, Hz
%         singlechnl@logical  = true % use single channel or use both I chnl and Q chnl
        
        eps_a = 0 % mixer amplitude correction
        eps_p = 0 % mixer phase correction

%        upSampleNum = 1 % upsample to match DA sampling rate
        iqWeight
		
		T1
    end
    properties (SetAccess = private, GetAccess = private)
        % Cached variables
        Mc = [];
        % Mc = [1, 0; 0, 1]          % mixer correction matrix
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
            calcCachedVar(obj);
        end
        function set.freq(obj,val)
			if ~isempty(obj.T1) && length(obj.T1) ~= length(val)
				error('number of freq not matching number of T1s');
			end
            obj.freq = val;
            numFreqs = numel(obj.freq);
			obj.T1 = Inf*ones(1,numFreqs);
            obj.iqWeight = cell(1,numFreqs);
            obj.selectidx = cell(1,numFreqs);
            if ~isempty(obj.startidx)
                assert(numel(obj.startidx) == numFreqs);
            end
			if obj.adI.demodMode
				obj.adI.demodFreq = obj.freq;
				obj.adQ.demodFreq = obj.freq;
			else
				if ~isempty(obj.n)
					obj.IQ = NaN*zeros(numel(obj.freq),obj.n);
				end
				calcCachedVar(obj);
            end
            
        end
		function set.T1(obj,val)
			if ~isempty(obj.freq) && length(obj.freq) ~= length(val)
				error('number of freq not matching number of T1s');
			end
			obj.T1 = val;
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
            obj.adI.window_start = obj.startidx;
            if ~isempty(obj.endidx)
                assert(numel(obj.startidx) == numel(obj.endidx));
            end
            calcCachedVar(obj);
        end
        function set.endidx(obj,val)
%             val = ceil(val);
%             if val <= obj.startidx || val > obj.instrumentObject.recordLength
%                 throw(MException('iq_ustc_ad:InvalidInput',...
%                     'endidx should be an interger greater than startidx and not exceeding AD recordLength!'));
%             end
            obj.endidx = val;
            obj.adI.window_width = obj.endidx-obj.startidx+1;
            if ~isempty(obj.endidx)
                assert(numel(obj.startidx) == numel(obj.endidx));
            end
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
%               obj.adI.demodMode=1;
            QS = qes.qSettings.GetInstance();
            obj.adI.demodMode = QS.loadSSettings({'shared','isDemod'});
			if obj.adI.demodMode
				% TODO...
				[I,Q]= obj.adI.Run(obj.n);
% 				figure(12); plot(mean(I),mean(Q),'*');hold on
				obj.IQ = (I+1j.*Q);
            else
                %%%
                % constant overhead: 0.167 sec.
                % relative overhead: 12%,
                % blows up around obj.n = 1.5e4;
                % tested on LD system with 150us repetition time on 2018-01-06 
% 				tic
                [Vi,Vq] = obj.adI.Run(obj.n);
%                 ShowVoltSignal(obj)
%                 figure;plot(mean(Vi));hold on;plot(mean(Vq));
%              toc
				Vi = double(Vi) -127;
				Vq = double(Vq) -127;
                
                obj.demod(Vi,Vq);
				
			end           
               % toc 
            obj.data = mean(obj.IQ,2);
            obj.extradata = obj.IQ;
            
            obj.dataready = true;
        end
    end
    methods (Access = private,Hidden = true)
        function calcCachedVar(obj)
            if isempty(obj.freq) || isempty(obj.startidx)
                return;
            end
            numFreqs = numel(obj.freq);
            recordLn = obj.adI.recordLength;
            if isempty(obj.endidx)
                eidx = recordLn*ones(1,numFreqs);
            else
                eidx = obj.endidx;
            end
            adSamplingRate = obj.adI.samplingRate;
            t_ = (1:obj.adI.recordLength)/adSamplingRate;
            obj.kernel = cell(1,numFreqs);
            for ii = 1:numFreqs
                % in most cases one needs to remove a few data points at the
                % beginning or at the end of each segament due to trigger
                % and signal may not be exactly syncronized.
                if obj.startidx(ii) > 1 ||...
                        eidx(ii) < recordLn
                    obj.selectidx{ii} = obj.startidx(ii):eidx(ii);
                    t = (obj.selectidx{ii}-obj.startidx(ii))/adSamplingRate;
                else
                    t = t_;
                end
                
                t = t.';

                % obj.selectidx = obj.startidx:obj.upSampleNum:eidx;
                % t = (obj.selectidx-obj.startidx)/...
                %     (obj.adI.samplingRate*obj.upSampleNum);
                obj.kernel{ii} = exp(-2j*pi*obj.freq(ii).*t);
%                 obj.kernel{ii} = exp(-t/obj.T1(ii)-2j*pi*obj.freq(ii).*t);
            end
        end
        
%         function IQ = demod(obj,Vi, Vq)
        function demod(obj, Vi, Vq)
		  % iq_ustc_ad used to suporrted the minimum delay step of one DA point, for that we need to
		  % interpolate the raw data, but interpolation is expensive, thus removed in later versions
            % Vi = qes.util.upsample_c(Vi,obj.upSampleNum);
            % Vq = qes.util.upsample_c(Vq,obj.upSampleNum);

            v = Vi+1j*Vq;

            for ii = 1:numel(obj.freq)
                if ~isempty(obj.selectidx{ii})
                    v_ = v(:,obj.selectidx{ii});
                else
                    v_ = v;
                end
                if isempty(obj.iqWeight{ii})
                    IQ_ = (v_*obj.kernel{ii})/numel(obj.selectidx{ii});
                    IQ_ = IQ_.';
%                     figure(13);
%                     plot(real(mean(IQ_)),imag(mean(IQ_)),'*g');hold on
                    if ~isempty(obj.Mc)
                        IQ_ = obj.Mc*[real(IQ_);imag(IQ_)];
                    end
                    obj.IQ(ii,:) = IQ_;
                else
                    error('to be implemented');
                end
            end
            
        end
        function Amp = Amp(obj, Vi, Vq)
            Amp = sum(abs(Vi(:)))+ sum(abs(Vq(:)));
        end
    end
    
end