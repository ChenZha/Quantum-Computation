function varargout = fminzPulseRipplePhase(varargin)
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

args = util.processArgs(varargin,{'r',[],'td',[],'delayTime',500,'MaxIter',30,'gui',false,'notes','','detuning',0,'save',true});

% if args.delayTime<500
%     sqc.util.setQSettings('r_avg',3000);
% else
%     sqc.util.setQSettings('r_avg',1000);
% end


    function [f,td]=zPulseRipplePhaseval(x)
        
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        
        s.r = [args.r, x(1)];
        s.td = [args.td, x(2)];
        
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
        
        data_phase=data_taking.public.xmon.zPulseRingingPhase('qubit',args.qubit,'delayTime',delayTime,...
            'xfrFunc',[xfrFunc_f],'zAmp',args.zAmp,'s',s,...
            'notes',args.notes,'gui',args.gui,'save',false);
        phasedifference=sign(data_phase(1,1)-data_phase(2,1))*toolbox.data_tool.unwrap_plus(data_phase(1,:)-data_phase(2,:));
        
        func=@(a,x)(a(1)*exp(-x/a(3))+a(2));
        try
            a=[phasedifference(2)-phasedifference(end),phasedifference(end),args.delayTime/2];
            b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
        catch
            a=[phasedifference(2)-phasedifference(end),phasedifference(end),args.delayTime/2];
            b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
        end
        f=abs(b(1));
        td=round(b(3));
        
        figure(199);plot(delayTime,b(1)*exp(-delayTime/b(3))+b(2),delayTime,phasedifference,'.');title(num2str(b))
    end
    
    function f=zPulseRipplePhaseval2(x)
        
        s = struct();
        s.type = 'function';
        s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
        s.bandWidht = 0.25;
        
        s.r = [args.r, x];
        s.td = [args.td, td];
        
        xfrFunc = qes.util.xfrFuncBuilder(s);
        xfrFunc_inv = xfrFunc.inv();
        xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
        xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);
        
        data_phase1=data_taking.public.xmon.zPulseRinging('qubit',args.qubit,'delayTime',delayTime,...
            'xfrFunc',[xfrFunc_f],'zAmp',0,'s',s,...
            'notes',[num2str(x)],'gui',false,'save',false);
                
        data_phase=data_taking.public.xmon.zPulseRinging('qubit',args.qubit,'delayTime',delayTime,...
            'xfrFunc',[xfrFunc_f],'zAmp',args.zAmp,'s',s,...
            'notes',[num2str(x)],'gui',false,'save',false);
        
        phasedifference=data_phase-data_phase1;
%         phasedifference=sign(data_phase(1,1)-data_phase(2,1))*toolbox.data_tool.unwrap_plus(data_phase(1,:)-data_phase(2,:));
        
%         f=std(phasedifference);

%%
        figure(203);plot(delayTime,phasedifference);title([' x ' num2str(x,'%.4f')])
        
        func=@(a,x)(a(1)*exp(-x/a(3))+a(2)+a(4)*exp(-x/td));
        try
            a=[phasedifference(2)-phasedifference(end),phasedifference(end),args.delayTime/10,100];
            b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
        catch
            a=[phasedifference(2)-phasedifference(end),phasedifference(end),args.delayTime/10,10];
            b=nlinfit(delayTime(2:end),phasedifference(2:end),func,a);
        end
        f=abs(b(4));
        
        figure(201);plot(delayTime,b(1)*exp(-delayTime/b(3))+b(2)+b(4)*exp(-delayTime/td),delayTime,phasedifference,'.');title([num2str(b,'%.4e,') ' x' num2str(x,'%.4f')])
        
        %%
%         if b(3)>td
%             func=@(a,x)(a(1)*exp(-x/td)+a(2));
%             try
%                 a=[phasedifference(2)-phasedifference(end),phasedifference(end)];
%                 b=nlinfit(delayTime(1:end),phasedifference(1:end),func,a);
%             catch
%                 a=[0,phasedifference(end)];
%                 b=nlinfit(delayTime(1:end),phasedifference(1:end),func,a);
%             end
%             f=abs(b(1));
%             
%             figure(201);plot(delayTime,b(1)*exp(-delayTime/td)+b(2),delayTime,phasedifference,'.');title([num2str(b,'%.4e,') ' x' num2str(x,'%.4f')])
%         end

    end

delayTime=round(linspace(0,args.delayTime,40));
[~,td]=zPulseRipplePhaseval([0.0,600]);
%%
if td>100
%     delayTime=unique(round(linspace(0,td*2,20)));
    delayTime=unique(round(linspace(td*0.75,td*2,20)));
else
    delayTime=unique(round(linspace(0,td*2,20)));
end
if td<args.delayTime
    options = optimset('Display','off','PlotFcns',@optimplotfval,'MaxIter',args.MaxIter,'TolX',1e-4,'TolFun',0.01);
    x=fminbnd(@zPulseRipplePhaseval2,-0.01,0.04,options);
else
    x=0;
end
%%
% args.delayTime=temp;
% options = optimset('Display','iter','MaxIter',args.MaxIter,'TolX',5e-4,'TolFun',1e-2);
% x=fminsearch(@zPulseRipplePhaseval2,x0,options);

%%
% delayTime=round(linspace(td,td*2,20));
% x0=0:0.002:0.03;
% fval=NaN(1,numel(x0));
% for ii=1:numel(x0)
%     fval(ii)=zPulseRipplePhaseval2(x0(ii));
%     figure(202);plot(x0,fval,'o')
% end
% [~,lo]=min(fval);
% x=x0(lo);

% figure;plot(delayTime,phasedifference,delayTime,b(1)*exp(-delayTime/b(3))+b(2),'--');
% title(['td=' num2str(round(b(3)))])


varargout{1} = x;
varargout{2} = td;
end