function varargout = zPulseXfrFunc(varargin)
% <_o_> = zPulseXfrFunc('qubit',_c|o_,'delayTime',[_i_],...
%       'numTerms',<_i_>,'rAmp0',[_f_],'td0',[_i_],'zAmp',_f_,...
%       'maxFEval',<_i_>,'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2018/1/11


    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    Z_LENGTH = 2000;

    args = util.processArgs(varargin,{'maxFEval',100,'numTerms',2,'gui',false,'notes','','detuning',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    Y2 = gate.Y2m(q);
    I1 = gate.I(q);
    I2 = gate.I(q);
    
    Z1 = op.zRect(q);
    Z1.ln = Z_LENGTH;
    Z1.amp = args.zAmp;
    Z2 = gate.I(q);
    Z2.ln = Z_LENGTH;

    R = measure.phase(q);
    
    maxDelayTime = max(args.delayTime);
    function procFactory1(delay)
        I1.ln = Z_LENGTH+delay;
        I2.ln = maxDelayTime - delay;
        proc = Z1.*(I1*Y2*I2); % minus delay is allowed
        R.setProcess(proc);
    end
    function procFactory2(delay)
        I1.ln = Z_LENGTH+delay;
        I2.ln = maxDelayTime - delay;
        proc = I1*Y2*I2; % minus delay is allowed
        R.setProcess(proc);
        proc.Run();
    end

    da = qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
            q.channels.z_pulse.instru);
    daChnl = da.GetChnl(q.channels.z_pulse.chnl);
    xfrFunc_backup = daChnl.xfrFunc;
    
    function data_ = measurement_(dt)
        procFactory1(dt);
        data_withZ = R();
        procFactory2(dt);
        data_noZ = R();
        if data_withZ > pi
            data_withZ = data_withZ -2*pi;
        elseif data_withZ <= -pi
            data_withZ = data_withZ +2*pi;
        end
        if data_noZ > pi
            data_noZ = data_noZ -2*pi;
        elseif data_withZ <= -pi
            data_noZ = data_noZ +2*pi;
        end
        data_ = data_withZ - data_noZ;
    end
    function data = measurement()
        numDT = numel(args.delayTime);
        pd = zeros(1,numDT);
        for iii = 1:numDT
            pd(iii) = measurement_(args.delayTime(iii));
        end
        data = sum(abs(pd(1:end-1) - pd(end)));
    end

    rAmp1 = qes.util.hvar(0);
    rAmp2 = qes.util.hvar(0);
    rAmp3 = qes.util.hvar(0);
    td1 = qes.util.hvar(30);
    td2 = qes.util.hvar(150);
    td3 = qes.util.hvar(800);
    LPFBandwidth = 0.13;
    function setXfrFunc()
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        s.r = [rAmp1.val,rAmp2.val,rAmp3.val];
        s.td = [td1.val,td2.val,td3.val];
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(LPFBandwidth);
        xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
        sqc.util.setZXfrFunc(q,xfrFunc_f);
    end

    p_rAmp1 = qes.expParam(rAmp1,'val');
    p_rAmp1.callbacks = {@setXfrFunc};
    p_rAmp2 = qes.expParam(rAmp2,'val');
    p_rAmp2.callbacks = {@setXfrFunc};
    p_rAmp3 = qes.expParam(rAmp3,'val');
    p_rAmp3.callbacks = {@setXfrFunc};
    p_td1 = qes.expParam(td1,'val');
    p_td1.callbacks = {@setXfrFunc};
    p_td2 = qes.expParam(td2,'val');
    p_td2.callbacks = {@setXfrFunc};
    p_td3 = qes.expParam(td3,'val');
    p_td3.callbacks = {@setXfrFunc};

    m = qes.measurement.measureByFunction(@measurement);
    
    if args.numTerms == 1
        assert(numel(args.rAmp0) == 1 & numel(args.td0) == 1);
        p_rAmp2.val = 0;
        p_rAmp3.val = 0;
        f = qes.expFcn([p_rAmp1, p_td1],m);
        x0 = [0.5*args.rAmp0,0.5*args.td0;...
              1.5*args.rAmp0,0.5*args.td0;...
              1.5*args.rAmp0,1.5*args.td0;];
        tolX = [0.0005,1];
        tolY = 0.02;
        h = qes.ui.qosFigure(sprintf('ZPulse XfrFunc Opt. | %s', q.name),false);
        axs(1) = subplot(2,2,1,'Parent',h);
        axs(2) = subplot(2,2,2);
        axs(3) = subplot(2,2,[3,4]);
        [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, args.maxFEval, axs);
        sOpt = struct();
        sOpt.type = 'function';
        sOpt.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        sOpt.bandWidht = 0.25;
        sOpt.r = [rAmp1.val,rAmp2.val];
        sOpt.td = [td1.val,td2.val];
    elseif args.numTerms == 2
        assert(numel(args.rAmp0) == 2 & numel(args.td0) == 2);
        p_rAmp3.val = 0;
        f = qes.expFcn([p_rAmp1, p_rAmp2, p_td1, p_td2],m);
        x0 = [0.5*args.rAmp0,0.5*args.td0;...
              1.5*args.rAmp0(1),0.5*args.rAmp0(2),0.5*args.td0;...
              1.5*args.rAmp0,0.5*args.td0;...
              1.5*args.rAmp0,1.5*args.td0(1),0.5*args.td0(2);
              1.5*args.rAmp0,1.5*args.td0;];
        tolX = [0.0005,0.0005,1,1];
        tolY = 0.02;
        h = qes.ui.qosFigure(sprintf('ZPulse XfrFunc Opt. | %s', q.name),false);
        axs(1) = subplot(3,2,1,'Parent',h);
        axs(2) = subplot(3,2,2);
        axs(3) = subplot(3,2,3);
        axs(4) = subplot(3,2,4);
        axs(5) = subplot(3,2,[5,6]);
        [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, args.maxFEval, axs);
        sOpt = struct();
        sOpt.type = 'function';
        sOpt.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        sOpt.bandWidht = 0.25;
        sOpt.r = [rAmp1.val,rAmp2.val];
        sOpt.td = [td1.val,td2.val];
    elseif args.numTerms == 3
        assert(numel(args.rAmp0) == 3 & numel(args.td0) == 3);
        f = qes.expFcn([p_rAmp1, p_rAmp2, p_rAmp3, p_td1, p_td2, p_td3],m);
        x0 = [args.rAmp0,args.td0];
        tolX = [0.0005,0.0005,0.0005,1,1,1];
        tolY = 0.02;
        h = qes.ui.qosFigure(sprintf('ZPulse XfrFunc Opt. | %s', q.name),false);
        axs(1) = subplot(4,2,[7,8],'Parent',h);
        axs(2) = subplot(4,2,6);
        axs(3) = subplot(4,2,5);
        axs(4) = subplot(4,2,4);
        axs(5) = subplot(4,2,3);
        axs(6) = subplot(4,2,2);
        axs(7) = subplot(4,2,1);
        [optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(f.fcn, x0, tolX, tolY, maxFEval, axs);
        sOpt = struct();
        sOpt.type = 'function';
        sOpt.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        sOpt.bandWidht = 0.25;
        sOpt.r = [rAmp1.val,rAmp2.val,rAmp3.val];
        sOpt.td = [td1.val,td2.val,td3.val];
    else
        error('numTerms not 2 or 3');
    end
    
    daChnl.xfrFunc = xfrFunc_backup;

    varargout{1} = sOpt;
    varargout{2} = LPFBandwidth;
end