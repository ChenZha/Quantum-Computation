function qubitFreqDiagram(qubits)

if nargin < 1
    qubits = {};
end

try
    QS = qes.qSettings.GetInstance();
catch
    throw(MException('QOS_readoutFreqDiagram:qSettingsNotCreated',...
        'qSettings not created: create the qSettings object, set user and select session first.'));
end

if isempty(qubits)
    qubits = sqc.util.loadQubits();
else
    if ~iscell(qubits)
        qubits = {qubits};
    end
    for ii = 1:numel(qubits)
        if isa(qubits{ii},'sqc.qobj.qubit')
            continue;
        elseif ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        else
            throw(MException('QOS_readoutFreqDiagram:illegalArgument',...
                'at least one of qubits is not a qubit name or a qubit object.'));
        end
    end
end
numQs = numel(qubits);
f01 = NaN*ones(1,numQs);
f01_max = NaN*ones(1,numQs);
f01_set = NaN*ones(1,numQs);
fah = NaN*ones(1,numQs);
zdc2f01 = NaN*ones(numQs,3);
qNames = cell(1,numQs);
for ii = 1:numQs
    f01(ii) = qubits{ii}.f01;
    if ~isempty(qubits{ii}.f01_set)
        f01_set(ii) = qubits{ii}.f01_set;
    else
        f01_set(ii) = 0;
    end
    if ~isempty(qubits{ii}.f_ah)
        fah(ii) = qubits{ii}.f_ah;
    else
        fah(ii) = 0;
    end
    if ~isempty(qubits{ii}.zdc_amp2f01)
        zdc2f01(ii,:) = qubits{ii}.zdc_amp2f01;
        aa=zdc2f01(ii,:);
        f01_max(ii)=(4*aa(1)*aa(3)-aa(2)^2)/4/aa(1);
        f01_min(ii)=min(polyval(aa,[-5e5,5e5]));
    else
        zdc2f01(ii,:) = [0,0,f01(ii)];
        f01_max(ii)=f01(ii);
        f01_min(ii)=f01(ii);
    end
    qNames{ii} = qubits{ii}.name;
end
f01_org=f01;
h=figure('Menubar','figure','Toolbar','figure','Units','pixels','pos',[100 100 1200 700],...
    'Name','qubitFreqDiagram','NumberTitle', 'off','color',[1,1,1]);
main=uix.Grid('parent',h);
main_1=uix.Grid('parent',main);
main_2=uix.Grid('parent',main);
main.Widths=[1020,-1];
main.BackgroundColor=[1 1 1];

main_1_1=uix.Grid('parent',main_1);
main_1_2=uix.Grid('parent',main_1);
main_1_22=uix.Grid('parent',main_1);
main_1_3=uix.Grid('parent',main_1);
main_1.Heights=[-20,30,-0.3,-1];

main_1_2_1=uix.Grid('parent',main_1_2);
main_1_2_2=uix.Grid('parent',main_1_2);
main_1_2_3=uix.Grid('parent',main_1_2);
main_1_2.Widths=[75,932,-1];

main_1_3_1=uix.Grid('parent',main_1_3);
main_1_3_2=uix.Grid('parent',main_1_3);
main_1_3_3=uix.Grid('parent',main_1_3);
main_1_3.Widths=[75,932,-1];

main_2_1=uix.Grid('parent',main_2);
main_2_2=uix.Grid('parent',main_2);
% main_2_3=uix.Grid('parent',main_2);
main_2.Heights=[-4,-8];

ax=axes('parent',uicontainer('parent',main_1_1,'Units','pixels','pos',[-50 -40 1140 690]));
% xlabel('Qubits')

uicontrol('parent',main_1_2_1,'style','text','string','f01(GHz)','FontSize',11);
uicontrol('parent',main_1_3_1,'style','text','string','g_zz(MHz)','FontSize',11);
Q_freqs=cell(1,numQs);
Q_zz=cell(1,numQs);
for ii=1:numQs
    Q_freqs{ii}=uicontrol('parent',main_1_2_2,'style','edit','string',num2str(f01(ii)/1e9,'%.7f'),'FontSize',11);
    Q_zz{ii}=uicontrol('parent',main_1_3_2,'style','text','string','','FontSize',11);
end

uicontrol('parent',main_2_2,'style','text','string','neighboring g (MHz)','fontsize',12);
gstr=uicontrol('parent',main_2_2,'style','edit','string','11.5','fontsize',12);
uicontrol('parent',main_2_2,'style','text','string','','fontsize',12);
uicontrol('parent',main_2_2,'style','text','string','Min f01 gap (MHz)','fontsize',12);
f01gapstr=uicontrol('parent',main_2_2,'style','edit','string','40','fontsize',12);
uicontrol('parent',main_2_2,'style','text','string','Min f01_f12 gap (MHz)','fontsize',12);
f0112gapstr=uicontrol('parent',main_2_2,'style','edit','string','5','fontsize',12);
uicontrol('parent',main_2_2,'style','text','string','','fontsize',12);
checkf01=uicontrol('parent',main_2_2,'string','Reset f01 to orginal','fontsize',12,'callback',@(o,e)Resetf01(o,e));
checkf01=uicontrol('parent',main_2_2,'string','Check f01 available','fontsize',12,'callback',@(o,e)Checkf01(o,e));
updata_plot=uicontrol('parent',main_2_2,'string','Update f01 Plot','fontsize',12,'callback',@(o,e)updatequbitfreq(o,e));
updata_f01=uicontrol('parent',main_2_2,'string','Update f01_set in RE','fontsize',12,'callback',@(o,e)updatef01set(o,e));
main_2_2.Heights=[-0.8,-1,-1,-0.8,-1,-0.8,-1,-1,-1,-1,-1,-1];

[Gamma1,bias]=toolbox.data_tool.fitting.getAllGamma1();
plotqubitfreq();

    function Resetf01(o,e)
        for jj=1:numQs
            set(Q_freqs{jj},'string',num2str(f01_org(jj)/1e9,'%.7f'));
        end
        updatequbitfreq(o,e)
    end

    function plotqubitfreq()
        cla(ax);
        
        %plot Gamma
        len=0;
        for ii=1:12
            len=max(len,numel(Gamma1{ii}));
        end
        qq=(0.37:0.25:12.36)'*ones(1,len);
        bb=NaN(12*4,len);
        for ii=1:12
            bb(ii*4-1,1:numel(Gamma1{ii}))=bias{ii};
            bb(ii*4,1:numel(Gamma1{ii}))=bias{ii};
        end
        mm=NaN(12*4,len);
        for ii=1:12
            mm(ii*4-1,1:numel(Gamma1{ii}))=Gamma1{ii};
            mm(ii*4,1:numel(Gamma1{ii}))=Gamma1{ii};
        end
        surf(ax,qq,bb,-mm,'edgecolor','none')
        view(0,90);
        c=colorbar;
        caxis([-0.70000e-04 c.Limits(2) ])
        colorbar off;

        grid(ax,'on');
        box(ax,'on')
        hold(ax,'on');
        ylabel(ax,'Freq (Hz)')
        xlim(ax,[0.8,numQs+0.2]);
        plot(ax,1:numQs,f01_max,'vb','LineWidth',1)
        plot(ax,1:numQs,f01_min,'^b','LineWidth',1)
        plot(ax,1:numQs,f01+fah,'*','LineWidth',1)
        plot(ax,1:numQs,f01,'or','LineWidth',2,'MarkerFaceColor','r')
        legend(ax,'\Gamma_1','Max f01','Min f01','f12','Current f01','location','best');
        ax.XTick=1:numQs;
        ax.XTickLabel=qNames;
        ax.FontSize=12;
        g=str2num(get(gstr,'string'))*1e6;
        for jj=1:numQs
            if jj~=1
                zzl=-2*g^2*(fah(jj)+fah(jj-1))/(f01(jj)-f01(jj-1)+fah(jj))/(f01(jj)-f01(jj-1)-fah(jj-1))/1e6;
            else
                zzl=0;
            end
            if jj~=numQs
                zzr=-2*g^2*(fah(jj)+fah(jj+1))/(f01(jj)-f01(jj+1)+fah(jj))/(f01(jj)-f01(jj+1)-fah(jj+1))/1e6;
            else
                zzr=0;
            end
            gzz(jj)=zzl+zzr;
            set(Q_zz{jj},'string',num2str(gzz(jj),'%.2f'));
        end
    end

    function updatequbitfreq(o,e)
        for jj=1:numQs
            f01(jj)=str2num(get(Q_freqs{jj},'string'))*1e9;
        end
        disp('Update f01:')
        Checkf01(o,e);
        plotqubitfreq()
    end

    function Checkf01(o,e)
        f01gap=str2num(get(f01gapstr,'string'))*1e6;
        f0112gap=str2num(get(f0112gapstr,'string'))*1e6;
        confinfo=cell(0);
        for jj=1:numQs
            if f01(jj)>f01_max(jj)
                str = [qNames{jj} ': f01 cannot be higher than its maximum value!'];
                choice  = questdlg(str,'f01 max exceeded',...
                    'OK','OK');
                f01(jj)=f01_max(jj);
                set(Q_freqs{jj},'string',num2str(floor(f01(jj)/1e3)/1e6,'%.6f'));
                disp([qNames{jj} '->' num2str(f01(jj))])
            end
            pos=(abs(round(f01-f01(jj)))<f01gap);
            for kk=1:numQs
                if pos(kk) && kk~=jj
                    confinfo=[confinfo,sprintf('%s: f01 = %.6e  conflict with %s: f01 = %.6e ',qNames{jj},f01(jj),qNames{kk},f01(kk))];
                end
            end
            pos=(abs(f01+fah-f01(jj))<f0112gap);
            for kk=1:numQs
                if pos(kk) && kk~=jj
                    confinfo=[confinfo,sprintf('%s: f01 = %.6e  conflict with %s: f12 = %.6e ',qNames{jj},f01(jj),qNames{kk},f01(kk)+fah(kk))];
                end
            end
        end
        for jj=1:numel(confinfo)
            disp(confinfo{jj})
        end
        if ~isempty(confinfo)
        str = ['f01 Confliction information: ',confinfo];
        choice  = questdlg(str,'f01 Confliction information',...
            'OK','OK');
        end
    end

    function updatef01set(o,e)
        Qchange=cell(0);
        for jj=1:numQs
            if abs(f01_org(jj)-f01(jj))>1e6
                sqc.util.setQSettings('f01_set',f01(jj),qNames{jj});
                Qchange=[Qchange,qNames{jj}];
                disp(['sqc.util.SetWorkingPoint(''' qNames{jj} ''',' num2str(f01(jj)) ',false)'])
            end
        end
        if ~isempty(Qchange)
            str = ['Remember, f01_set of the following qubits are changed!',Qchange];
            choice  = questdlg(str,'f01_set changed in RE',...
                'OK','OK');
            disp('f01_set of the above qubits are changed! Commend manually plsese!')
        end
    end

end




