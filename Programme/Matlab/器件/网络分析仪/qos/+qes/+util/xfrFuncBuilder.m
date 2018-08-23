function xfrFunc = xfrFuncBuilder(s)
% Yulin Wu, 17/08/06

    switch s.type
        case 'numeric'
            xfrFunc = com.qos.waveform.XfrFuncNumeric(...
                s.data.frequency,...
                s.data.amplitudeRe,...
                s.data.amplitudeIm);
        case 'function'
            fcn = str2func(['@',s.funcName]);
            % fcn = str2func(['@qes.waveform.xfrFunc.',s.funcName]);
            s = rmfield(s,{'type','funcName'});
            fn_= fieldnames(s);
            args = {};
            for ww = 1:numel(fn_)
                args{ww} = s.(fn_{ww});
            end
            xfrFunc = feval(fcn,args{:});
        otherwise
            throw(MException('QOS_xfrFuncBuilder:unsupportedXfrFuncTyp',...
                sprintf('xfrFunc type: %s is not supported.',...
                s.type)));
    end
end