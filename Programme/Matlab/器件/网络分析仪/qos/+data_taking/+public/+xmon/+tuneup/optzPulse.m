function varargout = optzPulse(varargin)
% <_o_> = fminzPulseRipplePhase('qubit',_c|o_,'delayTime',[_i_],...
%       'zAmp',_f_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
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

import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r',[],'td',[],'delayTime',500,'MaxIter',50,'gui',false,'notes','','detuning',0,'save',true});


    function f=zPulseRipplePhaseval2(x)
        
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        
        s.r = x;
        s.td = args.td;
        
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
        
        data_phase=data_taking.public.xmon.zPulseRingingPhase('qubit',args.qubit,'delayTime',delayTime,...
            'xfrFunc',[xfrFunc_f],'zAmp',args.zAmp,'s',s,...
            'notes',args.notes,'gui',args.gui,'save',false);
        phasedifference=sign(data_phase(1,1)-data_phase(2,1))*toolbox.data_tool.unwrap_plus(data_phase(1,:)-data_phase(2,:));
        
        f=std(phasedifference);
    end

delayTime = unique(round(linspace(sqrt(2),sqrt(args.delayTime),30).^2));

xx0=args.r;
if numel(args.r)==2
x0 = [xx0(1)*0.9,xx0(2)*0.9;xx0(1)*0.9,xx0(2)*1.1;xx0(1)*1.1,xx0(2)*1.1];
tolX = [0.0002,0.0002];
elseif numel(args.r)==3
x0 = [xx0(1)*0.9,xx0(2)*0.9,xx0(3)*0.9;xx0(1)*0.9,xx0(2)*0.9,xx0(3)*1.1;xx0(1)*0.9,xx0(2)*1.1,xx0(3)*1.1;xx0(1)*1.1,xx0(2)*1.1,xx0(3)*1.1];
tolX = [0.0002,0.0002,0.0002];
elseif numel(args.r)==4
x0 = [xx0(1)*0.9,xx0(2)*0.9,xx0(3)*0.9,xx0(4)*0.9;xx0(1)*0.9,xx0(2)*0.9,xx0(3)*0.9,xx0(4)*1.1;xx0(1)*0.9,xx0(2)*0.9,xx0(3)*1.1,xx0(4)*1.1;xx0(1)*0.9,xx0(2)*1.1,xx0(3)*1.1,xx0(4)*1.1;xx0(1)*1.1,xx0(2)*1.1,xx0(3)*1.1,xx0(4)*1.1];
tolX = [0.0002,0.0002,0.0002,0.0002];
end

tolY = [1e-2];

maxFEval = args.MaxIter;

[optParams, x_trace, y_trace, n_feval] = qes.util.NelderMead(@zPulseRipplePhaseval2, x0, tolX, tolY, maxFEval);
fval = y_trace(end);
fval0 = zPulseRipplePhaseval2(xx0);

if fval0<fval
    varargout{1} = xx0;
    varargout{2} = args.td;
else
    varargout{1} = optParams;
    varargout{2} = args.td;
end
end