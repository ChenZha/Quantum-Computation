function varargout = correctf01byRamsey_1(varargin)
% correct f01 at the current working point(defined by zdc_amp in registry)
% by ramsey: f01 already set previously, correctf01byRamsey is just to
% remeasure f01 in case f01 has drifted away slightly.
% note: T2* time can not be too short
%
% <_f_> = correctf01byRamsey('qubit',_c&o_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017/4/14
% when resolution low, not recommended, use correctf01bySpc instead
% Mod by GM, 20171026

MAXFREQDRIFT = 15e6;
DELAYTIMERANGE = 500e-9;

import data_taking.public.xmon.ramsey

args = qes.util.processArgs(varargin,{'gui',false,'save',true});
q = data_taking.public.util.getQubits(args,{'qubits'});
da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
    q.channels.xy_i.instru);
if strcmp(da.name,'da_ustc_1')
daSamplingRate = 2e9;
end

t = unique(round((4e-9:4e-9:DELAYTIMERANGE)*daSamplingRate));
e = ramsey('qubit',q,'mode','dp',...
    'time',t,'detuning',MAXFREQDRIFT,'gui',false,'save',false);
Pp = e.data{1};
e = ramsey('qubit',q,'mode','dp',...
    'time',t,'detuning',-MAXFREQDRIFT,'gui',false,'save',false);
Pn = e.data{1};
t = t/daSamplingRate;

[tdp,tdp_err,freqp,tf,Ppf,freqp_err]=toolbox.data_tool.fitting.ramseyFit(t,Pp,1);

if freqp_err>freqp/2
    tdp_err
    tdp
    freqp_err
    freqp
    if args.gui
        h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
        ax = axes('parent',h);
        plot(ax,t,Pp,'.',tf,Ppf);
        legend(ax,{num2str(freqp/1e6,'%0.2fMHz'),'fit'});
        xlabel(ax,'time(us)');
        ylabel(ax,'P|1>');
        title('fitting failed.');
    end
    throw(MException('QOS_correctf01byRamsey:fittingFailed',...
        'fitting failed.'));
end

[tdn,tdn_err,freqn,tf,Pnf,freqn_err]=toolbox.data_tool.fitting.ramseyFit(t,Pn,1);

if freqn_err>freqn/2
    tdn_err
    tdn
    freqn_err
    freqn
    if args.gui
        h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
        ax = axes('parent',h);
        plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
        hold on;
        plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
        legend(ax,{'','',num2str(freqp/1e6,'%0.2fMHz'),num2str(-freqn/1e6,'%0.2fMHz')});
        xlabel(ax,'time(us)');
        ylabel(ax,'P|1>');
        title('fitting failed.');
        drawnow;
    end
    throw(MException('QOS_correctf01byRamsey:fittingFailed',...
        'fitting failed.'));
end

if ((freqn + freqp)/2-MAXFREQDRIFT)/MAXFREQDRIFT > 0.05
    [tdp,tdp_err,freqp,tf,Ppf,freqp_err]=toolbox.data_tool.fitting.ramseyFit(t,Pp,3);
    [tdn,tdn_err,freqn,tf,Pnf,freqn_err]=toolbox.data_tool.fitting.ramseyFit(t,Pn,3);
    if ((freqn + freqp)/2-MAXFREQDRIFT)/MAXFREQDRIFT > 0.05
        throw(MException('QOS_correctf01byRamsey:fittingFailed',...
            'fitting failed or frequency drift out of measureable range.'));
    end
end

f01 = q.f01+(freqn - freqp)/2;

if args.gui
    h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
    ax = axes('parent',h);
    plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
    hold on;
    plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
    legend(ax,{'','',num2str(freqp/1e6,'%0.2fMHz'),num2str(-freqn/1e6,'%0.2fMHz')});
    xlabel(ax,'time(us)');
    ylabel(ax,'P|1>');
    title(sprintf('Original f01: %0.5fGHz, current f01: %0.5fGHz',q.f01/1e9,f01/1e9));
    drawnow;
end

if ischar(args.save)
    args.save = false;
    choice  = questdlg('Update settings?','Save options',...
        'Yes','No','No');
    if ~isempty(choice) && strcmp(choice, 'Yes')
        args.save = true;
    end
end
if args.save
    QS = qes.qSettings.GetInstance();
    QS.saveSSettings({q.name,'f01'},f01);
end
varargout{2} = f01;
varargout{3} = sqrt(freqn_err^2+freqp_err^2);
end
