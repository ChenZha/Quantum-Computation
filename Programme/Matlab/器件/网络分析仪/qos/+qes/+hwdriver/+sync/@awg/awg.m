classdef awg < qes.hwdriver.sync.instrument
    % arbitary waveform generator(awg) driver

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com


    methods (Access = private)
        function obj = awg(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                throw(MException('QOS_awg:InvalidInput',...
                    sprintf('Input ''%s'' can not be empty!','interfaceobj')));
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
			obj.chnlMothdNames = {'SendWave','Run','RunContinuousWv','StopContinuousWv'};
			obj.chnlMothds = {@(obj,chnl,DASequence,isI,loFreq,loPower,sbFreq)SendWave(...
                obj,chnl,DASequence,isI,loFreq,loPower,sbFreq),...
								@(obj,chnl,N)Run(obj,chnl,N),...
								@(obj,chnl,wvData)RunContinuousWv(obj,chnl,wvData),...
								@(obj,chnl)StopContinuousWv(obj,chnl)};
			obj.chnlProps = {'xfrFunc','iqCalDataSet','trigOutDelay','vpp','dynamicReserve','samplingRate','padLength'};
            obj.chnlPropSetMothds = {@(obj,chnl,v)SetXfrFunc(obj,chnl,v),...
                                      @(obj,chnl,v)SetIqCalDataSet(obj,chnl,v),...
									  @(obj,chnl,v)SetTrigOutDelay(obj,chnl,v),...
									  [],... % read only
                                      @(obj,chnl,v)SetDynamicReserve(obj,chnl,v),...
									  [],...  % read only
                                      @(obj,chnl,v)SetPadLength(obj,chnl,v)};
            obj.chnlPropGetMothds = {@(obj,chnl)GetXfrFunc(obj,chnl),...
                                      @(obj,chnl)GetIqCalDataSet(obj,chnl),...
									  [],... % write only
									  @(obj,chnl)GetVpp(obj,chnl),...
									  @(obj,chnl)GetDynamicReserve(obj,chnl),...
                                      @(obj,chnl)GetSamplingRate(obj,chnl),...
                                      @(obj,chnl)SetPadLength(obj,chnl)};
           obj.InitializeInstr();
        end
        InitializeInstr(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
        function xfrFunc = loadParameterizedXfrFunc(p)
            xfrFuncTyp = ['qes.waveform.xfrFunc.',p.xfrFuncTyp];
            fieldNames = fieldnames(p);
            args = {};
            for ii = 1:fieldNames
                args{ii} = p.fieldNames{ii};
            end
            xfrFunc = feval(xfrFuncTyp,args{:});
        end
    end
	methods (Hidden = true)
		SendWave(obj,chnl,sequence,isI,loFreq,loPower,sbFreq)
		Run(obj,chnl,N)
		RunContinuousWv(obj,chnl,wvData)
		StopContinuousWv(obj,chnl)
		
		% xfrFunc
        function SetXfrFunc(obj,chnl,v)
			obj.xfrFunc{chnl} = v;
		end
		function v = GetXfrFunc(obj,chnl)
			v = obj.xfrFunc{chnl};
		end
		% 
		function SetIqCalDataSet(obj,chnl,v)
			obj.iqCalDataSet{chnl} = v;
		end
		function v = GetIqCalDataSet(obj,chnl)
			v = obj.iqCalDataSet{chnl};
		end
		%
		SetTrigOutDelay(obj,chnl,val)
		%
		function v = GetVpp(obj,chnl)
			v = obj.vpp(chnl);
		end
		%
        function v = SetDynamicReserve(obj,chnl,v)
			obj.dynamicReserve(chnl) = v;
        end
		function v = GetDynamicReserve(obj,chnl)
			v = obj.dynamicReserve(chnl);
        end
        %
		function v = GetSamplingRate(obj,chnl)
			v = obj.samplingRate(chnl);
		end
		%
        function v = SetPadLength(obj,chnl,v)
			obj.padLength(chnl) = v;
        end
		function v = GetPadLength(obj,chnl)
			v = obj.padLength(chnl);
        end
    end
    methods
        function mzeros = MixerZeros(obj,chnls,loFreq)
            % mixer zeros
            
            assert(numel(chnls) == 2);
            numIQCalDataSet = numel(obj.iqCalDataSet);
            if numIQCalDataSet == 0
                mzeros = [0,0];
                return;
            end
            for ii = 1:numIQCalDataSet
                if all(obj.iqCalDataSet(ii).chnls == chnls)
                    break;
                end
                if ii == numIQCalDataSet
                    mzeros = [0,0];
                    return;
                end
            end
            f = obj.iqCalDataSet(ii).loFreq;
            iZero = obj.iqCalDataSet(ii).iZero;
            qZero  = obj.iqCalDataSet(ii).qZero;
            if numel(f) > 1
                i0 = interp1(f,iZero,loFreq,'pchip',0);
                q0 = interp1(f,qZero,loFreq,'pchip',0);
            else
                idx = f==loFreq;
                i0 = iZero(idx);
                q0 = qZero(idx);
                if isempty(i0)
                    i0 = 0;
                    q0 = 0;
                end
            end
            mzeros = [i0,q0];
        end
    end
end