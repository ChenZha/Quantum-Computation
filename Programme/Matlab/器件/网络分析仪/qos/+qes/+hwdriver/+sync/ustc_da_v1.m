classdef ustc_da_v1 < qes.hwdriver.icinterface_compatible
    % wrap ustcadda as da
    
% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (Dependent = true)
        outputDelayStep
		trigDelayStep
        trigInterval
    end
    properties (SetAccess = private)
		numChnls
		samplingRate
    end
    properties (SetAccess = private, GetAccess = private)
        chnlMap
        ustcaddaObj
    end
    methods
        function obj = ustc_da_v1(chnlMap_)
            if iscell(chnlMap_) % for chnlMap_ data loaded from registry saved as json array
                chnlMap_ = cell2mat(chnlMap_);
            end
            obj.ustcaddaObj = qes.hwdriver.sync.ustcadda_v1.GetInstance();
            obj.ustcaddaObj.Open(); % in case not openned already
            if numel(unique(chnlMap_)) ~= numel(chnlMap_)
                throw(MException('QOS_ustc_da:duplicateChnls','bad chnlMap settings: duplicate channels found.'));
            end
            if ~all(chnlMap_<=obj.ustcaddaObj.numDAChnls)
                throw(MException('QOS_ustc_da:nonExistChnls','chnlMap contains non-exist channels on DA.'));
            end
            assert(all(round(chnlMap_) == chnlMap_) & all(chnlMap_>0),'invalidInput');
			
			obj.ustcaddaObj.TakeDAChnls(chnlMap_);
			obj.chnlMap = chnlMap_;
			obj.numChnls = numel(chnlMap_);
			obj.samplingRate = unique(obj.ustcaddaObj.GetDAChnlSamplingRate(obj.chnlMap));
			if numel(obj.samplingRate) > 1
				obj.ustcaddaObj.ReleaseDAChnls(chnlMap_);
				throw(MException('QOS_ustc_da:samplingRateMismatch','building a da object on channels with different sampling rate is not allowed '));
			end
            
            obj.cmdList = {'*IDN?','*CLS','*RST'};
            obj.ansList = {'USTC,USTC_DA_V1','',''};
            obj.fcnList = {[],[],[]};
        end
		function val=get.outputDelayStep(obj)
			val = obj.ustcaddaObj.daOutputDelayStep;
		end
		function val=get.trigDelayStep(obj)
			val = obj.ustcaddaObj.daTrigDelayStep;
		end
		function val=get.trigInterval(obj)
			val = obj.ustcaddaObj.GetTrigInterval();
        end
		function SendWave(obj,channel,data,loFreq,loPower,sbFreq)
            obj.ustcaddaObj.SendWave(obj.chnlMap(channel),data,loFreq,loPower,sbFreq);
        end
        function setChnlOutputDelay(obj,channel,delay)
             obj.ustcaddaObj.SetDAChnlOutputDelay(obj.chnlMap(channel),delay);
        end
        function Run(obj,runReps)
            obj.ustcaddaObj.runReps = runReps;
            obj.ustcaddaObj.Run(false);
        end
        
        function StartContinuousRun(obj,chnl,wavedata)
            obj.ustcaddaObj.SendContinuousWave(obj.chnlMap(chnl),wavedata);
        end
        function StopContinuousRun(obj,chnl)
            obj.ustcaddaObj.StopContinuousWave(obj.chnlMap(chnl));
        end
        
%         function SetBoardTrigDelayByChnl(obj,chnl,delay)
%             boardNames = obj.ustcaddaObj.GetDACNameByChnl(obj.chnlMap(chnl));
%             boardNames = unique(boardNames);
%             for ii = 1:numel(boardNames)
%                 obj.ustcaddaObj.SetDABoardTrigDelay(boardNames{ii},delay);
%             end
%         end
        function SetBoardTrigDelayByChnl(obj,chnl,delay)
            boardNums = obj.ustcaddaObj.GetDACNumByChnl(obj.chnlMap(chnl));
            for ii = 1:numel(boardNums)
                obj.ustcaddaObj.SetDABoardTrigDelay(boardNums(ii),delay);
            end
        end
        function val = GetBoardTrigDelayByChnl(obj,chnl)
            val =  obj.ustcaddaObj.GetDABoardTrigDelay(...
                obj,obj.ustcaddaObj.GetDACNameByChnl(obj.chnlMap(chnl)));
        end
        
        
		function delete(obj)
			obj.ustcaddaObj.ReleaseDAChnls(obj.chnlMap);
            if isempty(obj.ustcaddaObj.adTakenChnls) &&...
                    isempty(obj.ustcaddaObj.daTakenChnls)
                obj.ustcaddaObj.delete();
            end
		end

    end
end