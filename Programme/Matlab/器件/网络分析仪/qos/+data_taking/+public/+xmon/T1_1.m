function varargout = T1_1(varargin)
% T1_1: T1
% bias, drive and readout all one qubit
% 
% <_o_> = T1_1('qubit',_c|o_,'biasAmp',<[_f_]>,'biasDelay',<_i_>,...
%       'backgroundWithZBias',<_b_>,...
%       'time',[_i_],'r_avg',<_i_>,...
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

import qes.*
import data_taking.public.xmon.T1_111
args = util.processArgs(varargin,{'r_avg',[],'biasAmp',0,'biasDelay',20,'backgroundWithZBias',true,...
    'gui',false,'notes','','save',true,'fit',false});
varargout{1} = T1_111('biasQubit',args.qubit,'biasAmp',args.biasAmp,'biasDelay',args.biasDelay,...
    'backgroundWithZBias',args.backgroundWithZBias,'driveQubit',args.qubit,...
    'readoutQubit',args.qubit,'time',args.time,'r_avg',args.r_avg,'notes',args.notes,'gui',args.gui,'save',args.save);
if args.fit % Add by GM, 170623
    fitType=1; % 1: base is 0; 2: base is fitable
    data=cell2mat(varargout{1,1}.data{1,1}');
    T1_data=NaN(size(data,2)/2,size(data,1));
    for ii=1:size(data,2)/2
        T1_data(ii,:)=(data(:,2*ii-1)-data(:,2*ii))';
    end
    bias=args.biasAmp;
    T1_time=args.time/2;
    if length(bias)==1
        [T1,T1_err,fitT1_time,fitT1_data]=toolbox.data_tool.fitting.t1Fit(T1_time,T1_data,fitType);
        
        if args.gui
            q = data_taking.public.util.getQubits(args,{'qubit'});
            vis=sum(q.r_iq2prob_fidelity)-1;
            err=abs(sqrt(T1_data.*(1-T1_data)/q.r_avg)/vis);
            hf=figure();hold off;
            errorbar(T1_time,T1_data,err,'.','MarkerFaceColor','b','LineWidth',1);
            hold on;
            plot(fitT1_time,fitT1_data,'LineWidth',1.5,'Color','r');
            
            xlabel('Pulse delay (ns)');
            ylabel('diff(P<1>)')
            drawnow;
%             if T1<T1_time(end)
                title([args.qubit ' T_1 = ' num2str(T1/1e3,'%.2f') '\pm' num2str(T1_err/1e3,'%.2f') ' us'])
%             else
%                 title([args.qubit ' Fit failed!'])
%             end
        end
    else
        xlabelFreq=false;
        if bias(end)-bias(end-1)~=bias(2)-bias(1)
            p=sqc.util.getQSettings('zpls_amp2f01',args.qubit);
            bias=polyval(p,bias);
            xlabelFreq=true;
        end
        for ii = 1:length(bias)
            [T1(ii),T1_err(ii),~,~]=toolbox.data_tool.fitting.t1Fit(T1_time,T1_data(ii,:),fitType);
        end
        
        if args.gui
            
            hf=figure();
            imagesc(bias,T1_time,T1_data');
            hold on;
            errorbar(bias,T1,T1_err,'ro','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
            set(gca,'YDir','normal');
            if xlabelFreq
                xlabel('Freq (Hz)');
            else
                xlabel('Z Bias');
            end
            ylabel('Time (ns)');
%             if mean(T1)<T1_time(end)
                title([args.qubit ' Fit average T_1 = ' num2str(mean(T1/1e3),'%.2f') ' us'])
%             else
%                 title([args.qubit ' Fit failed!'])
%             end
            colorbar;
            caxis([0,1]);
        end
    end
    if args.gui && args.save
        QS = qes.qSettings.GetInstance();
        dataSvName = fullfile(QS.loadSSettings('data_path'),...
            [args.qubit '_T1_fit_',datestr(now,'yymmddTHHMMSS'),...
            num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
        saveas(hf,dataSvName);
    end
    varargout{2}=T1;
    varargout{3}=T1_err;
end
end