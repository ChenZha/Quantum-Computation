classdef ustc_ad_v1 < qes.hwdriver.hardware
    % wrap ustcadda as ad
    
% Copyright 2016 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        chnlMap
        ustcaddaObj
    end
    methods (Access = private)
        function obj = ustc_ad_v1(name,chnlMap_)
            if iscell(chnlMap_) % for chnlMap_ data loaded from registry saved as json array
                chnlMap_ = cell2mat(chnlMap_);
            end
            obj = obj@qes.hwdriver.hardware(name);
            obj.ustcaddaObj = qes.hwdriver.sync.ustcadda_v1.GetInstance();
            obj.ustcaddaObj.Open(); % in case not openned already
            
            if numel(unique(chnlMap_)) ~= numel(chnlMap_)
                throw(MException('QOS_ustc_ad:duplicateChnls','bad chnlMap settings: duplicate channels found.'));
            end
            if ~all(chnlMap_<=obj.ustcaddaObj.numADChnls)
                throw(MException('QOS_ustc_da:nonExistChnls','chnlMap contains non-exist channels on AD.'));
            end
            assert(all(round(chnlMap_) == chnlMap_) & all(chnlMap_>0),'invalidInput');
       
			obj.ustcaddaObj.TakeADChnls(chnlMap_);
            obj.chnlMap = chnlMap_;
			obj.numChnls = numel(chnlMap_);
			
			% obj.samplingRate = obj.ustcaddaObj.GetADChnlSamplingRate(obj.chnlMap);
			
			obj.chnlMothdNames = {'Run'};
			obj.chnlMothds = {@(obj,chnl,N)Run(obj,chnl,N)};
			obj.chnlProps = {'recordLength','range','demodFreq','samplingRate','demodMode','delayStep',...
                             'window_start','window_width'};
            obj.chnlPropSetMothds = {@(obj,chnl,v)SetRecordLength(obj,chnl,v),...
                                      [],... % read only
									  @(obj,chnl,v)SetDemodFreq(obj,chnl,v),...
									  [],... % read only
									  @(obj,chnl,v)SetDemodMode(obj,chnl,v),... 
                                      [],...
                                      @(obj,chnl,v)SetWindowStart(obj,chnl,v),...
                                      @(obj,chnl,v)SetWindowWidth(obj,chnl,v)};   
            obj.chnlPropGetMothds = {@(obj,chnl)GetRecordLength(obj,chnl),...
                                      @(obj,chnl)GetRange(obj,chnl),...
									  @(obj,chnl)GetDemodFreq(obj,chnl),...
									  @(obj,chnl)GetSamplingRate(obj,chnl),...
									  @(obj,chnl)GetDemodMode(obj,chnl),...
                                      @(obj,chnl)GetDelayStep(obj,chnl),...
                                      @(obj,chnl)GetWindowStart(obj,chnl),...
                                      @(obj,chnl)GetWindowWidth(obj,chnl)};
			obj.demodFreq = cell(1,obj.numChnls);
            obj.window_start = cell(1,obj.numChnls);
            obj.window_width = cell(1,obj.numChnls);
        end
    end
    methods (Hidden = true)
		function val = GetRecordLength(obj,chnl)
            val = obj.ustcaddaObj.GetAdRecordLength(obj.chnlMap(chnl));
        end
        function SetRecordLength(obj,chnl,val)
             obj.ustcaddaObj.SetAdRecordLength(obj.chnlMap(chnl),val);
        end
		
		function val = GetRange(obj,chnl)
            val = obj.ustcaddaObj.GetAdRange(obj.chnlMap(chnl));
        end
		
		function val = GetDemodFreq(obj,chnl)
            val = obj.demodFreq{chnl};
        end
        function SetDemodFreq(obj,chnl,val)
            obj.demodFreq{chnl} = val;
        end
		
		function val = GetSamplingRate(obj,chnl)
			val = obj.ustcaddaObj.GetADChnlSamplingRate(obj.chnlMap(chnl));
        end
		
		function val = GetDemodMode(obj,chnl)
			val = obj.ustcaddaObj.GetADDemod(fix((obj.chnlMap(chnl)+1)/2));
        end
		function val = SetDemodMode(obj,chnl,val)
			 obj.ustcaddaObj.SetADDemod(fix((obj.chnlMap(chnl)+1)/2),val);
        end
		function val = GetDelayStep(obj,chnl)
% 			val = obj.ustcaddaObj.GetAdDelayStep(obj.chnlMap(chnl));
            val = obj.ustcaddaObj.adDelayStep;
        end
        function val = GetWindowStart(obj,chnl)
            val = obj.window_start{chnl};
        end
        function SetWindowStart(obj,chnl,val)
            obj.window_start{chnl} = val;
        end
        function val = GetWindowWidth(obj,chnl)
            val = obj.window_width{chnl};
        end
        function SetWindowWidth(obj,chnl,val)
            obj.window_width{chnl} = val;
        end

        function [I,Q] = Run(obj,chnl,N)
            
            % benchmark
%             numReps = [100:100:1900,2000:250:1e4];
%             % numReps = [numReps,fliplr(numReps)];
%             t = NaN(1,numel(numReps));
%             t0 = numReps/3.3333e3;
%             h = figure();
%             for ii = 1:numel(numReps)
%                 obj.ustcaddaObj.runReps = numReps(ii);
%                 tic;
%                 [I,Q] = obj.ustcaddaObj.Run(true);
%                 t(ii) = toc;
%                 plot(numReps,t-t0,'-');
% %                 plot(numReps,t,'-+',numReps,t0,'--');
%                 xlabel('stats');
%                 ylabel('overhead time(s)');
%                 drawnow();
%             end

            obj.ustcaddaObj.runReps = N; % this only takes ~70us, the next line takes ~300ms
			if GetDemodMode(obj,chnl)
% 				[I,Q] = obj.ustcaddaObj.Run(obj.demodFreq{chnl});
                demodfreqs = obj.demodFreq{chnl};
                ndemofreqs = length(demodfreqs);
                if obj.window_start{chnl}<8
                    warning('Onboard Demodulation: widows_start<8,widows_start has been set to 8.');
%                     w(2) = w(2)-8+w(1);
%                     w(1) = 8;
                end
%                 obj.ustcaddaObj.SetADDemodFreq(fix((chnl+1)/2), obj.window_start{chnl}+zeros(1,12),...
%                                             obj.window_width{chnl}+zeros(1,12),[demodfreqs,zeros(1,12-ndemofreqs)]);
                obj.ustcaddaObj.SetADDemodFreq(fix((chnl+1)/2), [obj.window_start{chnl},zeros(1,12-ndemofreqs)],...
                                            [obj.window_width{chnl},zeros(1,12-ndemofreqs)],[demodfreqs,zeros(1,12-ndemofreqs)]);
                ret = obj.ustcaddaObj.Run(1);
                while ret~=1
                    ret = obj.ustcaddaObj.Run(1);
                end
                I = obj.ustcaddaObj.ad_list(fix((chnl+1)/2)).I(1:ndemofreqs,:);
                I = double(I)/2^11./obj.window_width{chnl}';
                Q = obj.ustcaddaObj.ad_list(fix((chnl+1)/2)).Q(1:ndemofreqs,:);
                Q = double(Q)/2^11./obj.window_width{chnl}';
            else
                ret = obj.ustcaddaObj.Run(1);
                sret=0;
                while ret~=1
                    ret = obj.ustcaddaObj.Run(1);
                    sret=sret+1;
                    if sret>5
                        error('Some board error, check Errorlog for more info.');
                    end
                end
                I = obj.ustcaddaObj.ad_list(1).I;
                Q = obj.ustcaddaObj.ad_list(1).Q;
			end
        end
	end
	methods
		function delete(obj)
			obj.ustcaddaObj.ReleaseADChnls(obj.chnlMap);
            if isempty(obj.ustcaddaObj.adTakenChnls) &&...
                    isempty(obj.ustcaddaObj.daTakenChnls)
                obj.ustcaddaObj.delete();
            end
		end
    end
    
    methods (Static = true)
        function obj = GetInstance(name,chnlMap_) 
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.ustc_ad_v1(name,chnlMap_);
                objlst = obj;
            else
                obj = objlst;
            end
        end
    end
end