function varargout = spectroscopy1_zdc_auto(varargin)
% spectroscopy1: qubit spectroscopy with band sweep
% 
% <_o_> = spectroscopy1_zdc_auto('qubit',_c&o_,'biasAmp',<[_f_]>,...
%       'swpBandCenterFcn',<_o_>,'swpBandWdth',<[_f_]>,...
%       'driveFreq',<[_f_]>,...
%       'notes',<_c_>,'updateSettings',<_b_>,'gui',<_b_>,'save',<_b_>)
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

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.spectroscopy1_zdc_auto'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*
import data_taking.public.xmon.spectroscopy1_zdc

args = util.processArgs(varargin,{'r_avg',[],'biasAmp',-3e4:1e3:3e4,'driveFreq',[],...
    'swpInitBias',0,'swpInitf01',[],'swpBandWdth',30e6,'swpBandStep',1e6,'gui',true,'peak',true,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if isempty(args.swpInitf01)
    args.swpInitf01=q.f01;
end
if ~isempty(args.r_avg)
    q.r_avg=args.r_avg;
end

II = 0;

function [f_,f_fit] = sweepFreq(ind,biasselected,f0list)
    if ind<=2
        f_center=args.swpInitf01;
        f_fit=[0,0,0,f_center];
    elseif II>2 && II<=3
        f0list(find(f0list==0))=[];
        f_fit=polyfit(biasselected,f0list,1);
        f_center=polyval(f_fit,bias0(inx(ind)))*1e9;
    elseif II>3 
        f0list(find(f0list==0))=[];
        f_fit=polyfit(biasselected,f0list,2);
        f_center=polyval(f_fit,bias0(inx(ind)))*1e9;
    end
    if II <= 5
        f_=floor((f_center-2*args.swpBandWdth/2:args.swpBandStep:f_center+2*args.swpBandWdth/2)/args.swpBandStep)*args.swpBandStep;
    else
        f_=floor((f_center-args.swpBandWdth/2:args.swpBandStep:f_center+args.swpBandWdth/2)/args.swpBandStep)*args.swpBandStep;
    end
end

bias0=args.biasAmp;
bias0=sort(bias0,'ascend');
bias_=bias0-args.swpInitBias;
[~,inx]=sort(abs(bias_));
sortedbias=bias0(inx);

f_= sweepFreq(1,0,0);
P=NaN(length(f_),length(inx));
Frequency=f_;
Bias=bias0;
f0list=zeros(1,length(inx));
biasselected=[];

if args.gui
    hf = qes.ui.qosFigure(sprintf('Spectroscopy | %s', q.name));
    ax = axes('parent',hf);
end

QS = qes.qSettings.GetInstance();

timeStamp = datestr(now,'yymmddTHHMMSS');
dataSvName = fullfile(QS.loadSSettings('data_path'),...
    [args.qubit, '_specAutoZDC_',timeStamp,...
    num2str(ceil(99*rand(1,1)),'%0.0f'),'_.mat']);

figSvName = fullfile(QS.loadSSettings('data_path'),...
    [args.qubit, '_specAutoZDC_',timeStamp,...
    num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);

for II=1:length(inx)
    [f,f_fit] = sweepFreq(II,biasselected,f0list);
    e = spectroscopy1_zdc('qubit',q,'biasAmp',bias0(inx(II)),'driveFreq',f,'updateReadoutFreq',false,'save',false,'gui',false,'dataTyp',args.dataTyp);
    [~,lo]=ismember(f,Frequency);
    f__=f;
    if lo(1)==0 && f(end)+args.swpBandStep>=Frequency(1)
        P=[NaN(sum(lo==0),length(inx)); P];
    elseif lo(1)==0 && f(end)+args.swpBandStep<Frequency(1)
        P=[NaN((Frequency(1)-f(1))/args.swpBandStep,length(inx)); P];
        f__=f(1):args.swpBandStep:(Frequency(1)-args.swpBandStep);
    elseif lo(1)==0 && f(1)-args.swpBandStep>Frequency(end)
        P=[ P; NaN((-Frequency(end)+f(end))/args.swpBandStep,length(inx));];
        f__=(Frequency(end)+args.swpBandStep):args.swpBandStep:f(end);
    elseif lo(1)>1 && lo(end)==0
        P=[ P; NaN(sum(lo==0),length(inx))];
    end
        
    Frequency=union(f__,Frequency);
    [~,lo]=ismember(f,Frequency);
    if strcmp(args.dataTyp,'S21')
        data=cell2mat(e.data{1,1});
    else
        data=cell2mat(e.data);
    end
    P(lo(1):lo(end),inx(II))=data;
    if args.peak
        [~,finx]=max(data);
    else
        [~,finx]=min(data); 
    end
    f0=f(finx);
    f0list(inx(II))=f0/1e9;
    if bias0(inx(II))>=max(biasselected)
        biasselected=[biasselected bias0(inx(II))];
    else
        biasselected=[bias0(inx(II)) biasselected];
    end
    save(dataSvName,'Bias','Frequency','P','f_fit');
    if args.gui
        if ~isgraphics(ax)
            hf = qes.ui.qosFigure(sprintf('Spectroscopy | %s', q.name));
            ax = axes('parent',hf);
        end
        imagesc(Bias,Frequency/1e9,P,'Parent',ax);
        xlabel(ax,[q.name ' zdc amplitude'])
        ylabel(ax,'Frequency (GHz)')
        set(ax,'Ydir','normal');
        fitval=polyval(f_fit,bias0(inx(II+1:end)));
        hold(ax,'on');plot(ax, bias0(inx(II+1:end)),fitval,'.r','LineWidth',2);hold(ax,'off');
        drawnow;
    end
end

% function f__ = amp2f01__(param_,x_)
%     f__ = param_(3)*sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))+...
%         param_(4)*(sqrt(abs(cos(pi*param_(1)*abs(x_-param_(2)))))-1);
% end
% 
% warning('off');
% [param,~,residual,~,~,~,~] = lsqcurvefit(@amp2f01__,[q.zdc_amp2f01(1),0,q.f01,0],bias0,f0list);
% warning('on');
% if mean(abs(residual)) > RESTOL
%     throw(MException('QOS_zpls2f01:fittingFailed','fitting failed.'));
% end

param=polyfit(biasselected,f0list(1:numel(biasselected))*1e9,2);
title(ax,[q.name ' Param: ' num2str(param,'%.5e ') ])
hold(ax,'on');plot(ax,biasselected,polyval(param,biasselected)/1e9,'r')

QS = qes.qSettings.GetInstance();
if ischar(args.save)
    choice  = questdlg('Update settings?','Save options',...
            'Yes','No','No');
    if ~isempty(choice) && strcmp(choice, 'Yes')
        QS.saveSSettings({q.name,'zdc_amp2f01'},param);
    end
elseif args.save
    QS.saveSSettings({q.name,'zdc_amp2f01'},param);
end

if args.gui && isgraphics(ax)
    saveas(ax,figSvName);
end

varargout{1}=param;

end