function varargout = ramsey(varargin)
% ramsey
% mode: df01,dp,dz
% df01(default): detune by detuning iq frequency(sideband frequency)
% dp: detune by changing the second pi/2 pulse tracking frame
% dz: detune by z detune pulse
%
% <_o_> = ramsey('qubit',_c|o_,'mode',m...
%       'time',[_i_],'detuning',<_f_>,'phaseOffset',<_f_>,...
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


% Yulin Wu, 2016/12/27

import qes.util.processArgs
import data_taking.public.xmon.*
args = processArgs(varargin,{'mode', 'df01','dataTyp','P','phaseOffset',0,'fit',false,'T1',[],...
    'gui',false,'notes','','detuning',0,'save',true});
switch args.mode
    case 'df01'
        e = ramsey_df01('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
            'time',args.time,'detuning',args.detuning,...
            'notes',args.notes,'gui',args.gui,'save',args.save);
    case 'dp'
        e = ramsey_dp('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
            'time',args.time,'detuning',args.detuning,...
            'notes',args.notes,'gui',args.gui,'save',args.save);
    case 'dz'
        e = ramsey_dz('qubit',args.qubit,'biasqubit',args.biasqubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
            'time',args.time,'detuning',args.detuning,...
            'notes',args.notes,'gui',args.gui,'save',args.save);
    otherwise
        throw(MException('QOS_spin_echo:illegalModeTyp',...
            sprintf('available modes are: df01, dz and dp, %s given.', args.mode)));
end
varargout{1} = e;
if args.fit % Add by GM, 170623
    fitType=2; % 1: only T2 in fit function; 2: both T1 and T2 in fit function
    Ramsey_data0=e.data{1,1};
    Ramsey_time=args.time/2;
    loopn=size(Ramsey_data0,1);
    T2=NaN(1,loopn);
    T2_err=NaN(1,loopn);
    detuningf=NaN(1,loopn);
    detuningf_err=NaN(1,loopn);
    for II=1:loopn
        Ramsey_data=Ramsey_data0(II,:);
        T1=args.T1;
        [T2(II),T2_err(II),detuningf(II),fitramsey_time,fitramsey_data,detuningf_err(II)]=toolbox.data_tool.fitting.ramseyFit(Ramsey_time,Ramsey_data,fitType,T1*1000);
    end
    if size(Ramsey_data0,1)==1
        q = data_taking.public.util.getQubits(args,{'qubit'});
        vis=sum(q.r_iq2prob_fidelity)-1;
        err=abs(sqrt(Ramsey_data0.*(1-Ramsey_data0)/q.r_avg)/vis.*ones(1,length(Ramsey_time)));
        hf=figure;hold off;
        errorbar(Ramsey_time,Ramsey_data,err,'.','MarkerFaceColor','b','LineWidth',1);
        hold on;
        plot(fitramsey_time,fitramsey_data,'LineWidth',1.5,'Color','r');
        title([args.qubit ' T_2*=' num2str(T2/1e3,'%.2f') '\pm' num2str(T2_err/1e3,'%.2f') 'us, \Deltaf=' num2str(1e3*detuningf,'%.2f') '\pm' num2str(1e3*detuningf_err,'%.3f') 'MHz'])
        xlabel('Pulse delay (ns)');
        ylabel('P<1>');
    else
        hf=figure(21);
        title([args.qubit ' Fit average T_2* = ' num2str(mean(T2)/1e3,'%.2f') '\pm' num2str(std(T2)/1e3,'%.2f') 'us'])
        if args.mode=='dz'
            subplot(2,1,1)
            h1=errorbar(args.detuning,T2/1e3,T2_err/1e3);
            ylim([0,Ramsey_time(end)*2/1e3])
            ylabel('T_2* (us)')
            subplot(2,1,2)
            errorbar(args.detuning,detuningf*1e3,detuningf_err*1e3);
            ylabel('\Delta f (MHz)')
            xlabel('Detune Amp')
            ff=polyfit(args.detuning,abs(detuningf).*sign(args.detuning)*1e9,1);
            title([args.biasqubit '->' args.qubit ' ' num2str(ff(1)) 'Hz/bit'])
        else
            h1=errorbar(args.detuning,T2/1e3,T2_err/1e3);
            ylim([0,Ramsey_time(end)*2/1e3])
            ylabel('T_2* (us)')
            xlabel('Detuning Freq (Hz)')
        end
        set(h1,'LineStyle','-','Marker','o','MarkerFaceColor','b')
    end
    if args.save
        QS = qes.qSettings.GetInstance();
        dataSvName = fullfile(QS.loadSSettings('data_path'),...
            [args.qubit '_T2_fit_',datestr(now,'yymmddTHHMMSS'),...
            num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
        saveas(hf,dataSvName);
    end
    varargout{2} = T2;
    varargout{3} = T2_err;
    varargout{4} = detuningf;
end
end