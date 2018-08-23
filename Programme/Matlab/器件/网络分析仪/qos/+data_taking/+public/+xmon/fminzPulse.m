function [r,td]=fminzPulse(varargin)

import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r',[],'td',[],'delayTime',[0:10:1500],'Paras',3,'MaxIter',20,'gui',false,'notes','','detuning',0,'save',true});
td=[];
for ii=1:args.Paras
    if ~isempty(td)
        delayTime=min(args.delayTime,td*2);
    else
        delayTime=args.delayTime;
    end
    [r,td] = data_taking.public.xmon.fminzPulseRipplePhase('qubit',args.qubit,'delayTime',delayTime,'zAmp',args.zAmp,'MaxIter',args.MaxIter,...
        'r',args.r,'td',args.td,'notes','','gui',args.gui,'save',args.save);
    if r~=0
        args.r=[args.r,r];
        args.td=[args.td,td];
    end
    if td<30 || r==0
        break
    end
end

r=args.r;
td=args.td;

s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;

s.r = r;
s.td = td;

xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);

delayTime=unique(round(linspace(0,args.delayTime,40)));
data_taking.public.xmon.zPulseRingingPhase('qubit',args.qubit,'delayTime',delayTime,...
            'xfrFunc',[xfrFunc_f],'zAmp',args.zAmp,'s',s,...
            'notes','','gui',true,'save',args.save);

end