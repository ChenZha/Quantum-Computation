function varargout = DRAGalpha_auto(varargin)
% GM, 20180422


fcn_name = 'data_taking.public.xmon.tuneup.DRAGalpha_auto'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

if numel(varargin)==1
    varargin=varargin{1,1};
end
args = util.processArgs(varargin,{'alpha',[],'phase',0,...
    'numI',[11,21,31,41],'gui',false,'notes','','save',true,'update',true});
if isempty(args.alpha)
    alpha0=sqc.util.getQSettings('qr_xy_dragAlpha',args.qubit);
    args.alpha=linspace(alpha0-1,alpha0+1,41);
end

data=data_taking.public.xmon.tuneup.DRAGAlphaAPE('qubit',args.qubit,'alpha',args.alpha,...
    'phase',args.phase,'numI',args.numI,...
    'gui',false,'save',args.save);
alpha0=sqc.util.getQSettings('qr_xy_dragAlpha',args.qubit);
xval=data.sweepvals{1,1}{1,1};
numI=data.sweepvals{1,2}{1,1};
ddata=data.data{1,1};
sss=smooth(sum(ddata,2));
[~,lo]=max(sss);
alpha=xval(lo);
if args.update
sqc.util.setQSettings('qr_xy_dragAlpha',alpha,args.qubit)
end

hf = qes.ui.qosFigure(sprintf('DRAG alpha auto | %s', args.qubit),true,30);
ax = axes('parent',hf);
plot(ax,xval,ddata')
hold(ax,'on');
plot(ax,[alpha0,alpha0],get(ax,'YLim'),'--','Color',[1,0.7,0.7]);
plot(ax,[alpha,alpha],get(ax,'YLim'),'--r');
xlabel(ax,'numI')
ylabel('P|1>')
title([args.qubit ' alpha = ' num2str(alpha)])
legend(ax,{num2str(args.numI),'alpha(old)','alpha(new)'})
QS = qes.qSettings.GetInstance();
dataSvName = fullfile(QS.loadSSettings('data_path'),...
    ['DRAGalpha_auto_',args.qubit,'_',datestr(now,'yymmddTHHMMSS'),...
    num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
try
    saveas(hf,dataSvName);
catch
    warning('saving figure failed.');
end

% if lo==1 || lo==numel(xval)
%     varargout=data_taking.public.xmon.tuneup.DRAGalpha_auto(varargin);
%     data=varargout{1};
%     alpha=varargout{2};
% end

varargout{1}=data;
varargout{2}=alpha;

end