classdef ustc_dc_v1 < qes.hwdriver.icinterface_compatible
    % wrap ustcadda as dc source
    
% Copyright 2017 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        numChnls
    end
    properties (SetAccess = private, GetAccess = private)
        chnlMap
        ustcaddaObj
    end
    properties (Dependent = true)
        range
    end
    methods
        function obj = ustc_dc_v1(chnlMap_)
            if iscell(chnlMap_) % for chnlMap_ data loaded from registry saved as json array
                chnlMap_ = cell2mat(chnlMap_);
            end
            obj.ustcaddaObj = qes.hwdriver.sync.ustcadda_v1.GetInstance();
            obj.ustcaddaObj.Open(); % in case not openned already
            if numel(unique(chnlMap_)) ~= numel(chnlMap_) ||...
				~all(round(chnlMap_) == chnlMap_) ||...
				~all(chnlMap_>0)
                throw(MException('QOS_ustc_dc:inValidInput','bad chnlMap'));
            end
            if ~all(chnlMap_ <= obj.ustcaddaObj.numDAChnls)
                throw(MException('QOS_ustc_dc:inValidInput','chnlMap contains non-exist channels on DA'));
            end
            
			obj.ustcaddaObj.TakeDAChnls(chnlMap_);
			obj.chnlMap = chnlMap_;
			obj.numChnls = numel(chnlMap_);

            obj.cmdList = {'*IDN?','*CLS','*RST'};
            obj.ansList = {'USTC,USTC_DADC_V1','',''};
            obj.fcnList = {[],[],[]};
        end
        function val = get.range(obj)
            val = obj.ustcaddaObj.daVpp/2;
        end
        function SetDC(obj,dcval,chnl)
            code = -dcval+32768;
            code = round(code);
            if code > 65535
                code = 65535;
            elseif code < 0
                code = 0;
            end
            obj.ustcaddaObj.SendContinuousWave(obj.chnlMap(chnl),code);
        end
        function delete(obj)
% 			for ii = 1:numel(obj.chnlMap)
%                 obj.SetDC(0,obj.chnlMap(ii));
% 				obj.ustcaddaObj.StopContinuousWave(obj.chnlMap(ii));
% 			end
			obj.ustcaddaObj.ReleaseDAChnls(obj.chnlMap);
            if isempty(obj.ustcaddaObj.adTakenChnls) &&...
                    isempty(obj.ustcaddaObj.daTakenChnls)
                obj.ustcaddaObj.delete();
            end
		end
    end
end