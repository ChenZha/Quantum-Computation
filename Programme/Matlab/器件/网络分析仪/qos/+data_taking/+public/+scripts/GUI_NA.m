function GUI_NA
global handles;
handles.currnetname=mfilename('fullpath');
handles.currPath = fileparts(mfilename('fullpath'));% get current path
%导入数据

try
    load([handles.currnetname '.mat'])
catch
    handles.IP='192.168.1.106';
    handles.Freq_star='6';
    handles.Freq_stop='7';
    handles.Freq_SwpPoint=200;
    handles.IF_Bandwith=1;
    handles.Avg_Counts=10;
    handles.NA_Power='[10:-1:-30]';
    handles.Repeat='1';
    handles.QTh='1e3';
    handles.saveas='';
%     handles.MagneticCurrent='0';
    handles.Savepath='E:\tmp';
    handles.basefile='E:\tmp\testline.mat';
end
handles.defacultfontsize=11;
handles.absphase=1;
%窗口设置
S21PD=figure('Menubar','none','Toolbar','figure','Units','normalize','pos',[0.2,0.2,0.55,0.55],...
    'Name','GUI_NetworkAnalyser','NumberTitle', 'off');

mainlayout1=uix.Grid('parent',S21PD);
mainlayout1_1=uix.Grid('parent',mainlayout1);
Freq_Box=uix.Grid('parent',mainlayout1_1 );
label_box=uix.Grid('parent',Freq_Box );
uix.Empty( 'Parent', label_box );
uicontrol('parent',label_box,'style','text','string','Savepath','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','SaveAs','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','IP','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Freq start (GHz)','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Freq stop (GHz)','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Freq SwpPoint','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','IF Bandwith (kHz)','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Average','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Power (dBm)','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Q Threshold','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uicontrol('parent',label_box,'style','text','string','Base File','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
label_box.Heights=[ 20 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];

content_box=uix.Grid('parent',Freq_Box );
handles.save_edit=uicontrol('parent',content_box,'style','edit','string',handles.Savepath,'fontsize',handles.defacultfontsize);
handles.saveas_edit=uicontrol('parent',content_box,'style','edit','string',handles.saveas,'fontsize',handles.defacultfontsize);
handles.IP_edit=uicontrol('parent',content_box,'style','edit','string',handles.IP,'tag','IP_tag','fontsize',handles.defacultfontsize);
handles.Freq_star_edit=uicontrol('parent',content_box,'style','edit','string',(handles.Freq_star),'tag','Freq_star_tag','fontsize',handles.defacultfontsize);
handles.Freq_stop_edit=uicontrol('parent',content_box,'style','edit','string',(handles.Freq_stop),'tag','Freq_stop_tag','fontsize',handles.defacultfontsize);
handles.Freq_SwpPoint_edit=uicontrol('parent',content_box,'style','edit','string',num2str(handles.Freq_SwpPoint),'tag','Freq_SwpPoint_tag','fontsize',handles.defacultfontsize);
handles.IF_Bandwith_edit=uicontrol('parent',content_box,'style','edit','string',num2str(handles.IF_Bandwith),'tag','IF_Bandwith_tag','fontsize',handles.defacultfontsize);
handles.Avg_Counts_edit=uicontrol('parent',content_box,'style','edit','string',num2str(handles.Avg_Counts),'tag','Avg_Counts_tag','fontsize',handles.defacultfontsize);
handles.NA_Power_edit=uicontrol('parent',content_box,'style','edit','string',handles.NA_Power,'tag','NA_Power_tag','fontsize',handles.defacultfontsize);
handles.QTh_edit=uicontrol('parent',content_box,'style','edit','string',handles.QTh,'tag','QTh_tag','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
handles.Basefile_edit=uicontrol('parent',content_box,'style','edit','string',handles.basefile,'tag','Basefile_tag','HorizontalAlignment','center','fontsize',handles.defacultfontsize);
uix.Empty( 'Parent', content_box );

content_box.Heights=[ -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 20];
Freq_Box.Widths=[-1, -2.2];
% DC_source_Box=uix.Grid('parent',mainlayout1_1 );
% uicontrol('parent',DC_source_Box,'style','edit','string','DC_source_Box','HorizontalAlignment','center');
% DC_source_Box.Widths=[-1,-2, -0.5];
Star_Box=uix.Grid('parent',mainlayout1_1 );
handles.star_button=uicontrol('parent',Star_Box,'string','START','fontsize',handles.defacultfontsize);

dispose_fig_Box=uix.Grid('parent',mainlayout1_1 );
handles.absphase_button=uicontrol('parent',dispose_fig_Box,'string','ABS','fontsize',handles.defacultfontsize);
dip_button=uicontrol('parent',dispose_fig_Box,'string','DIP','fontsize',handles.defacultfontsize);
peak_button=uicontrol('parent',dispose_fig_Box,'string','PEAK','fontsize',handles.defacultfontsize);
fit_button=uicontrol('parent',dispose_fig_Box,'string','FIT Q','fontsize',handles.defacultfontsize','enable','on');
dispose_fig_Box.Widths=[-1 -1 -1 -1];
mainlayout1_1.Heights=[-8 -1  -1];


mainlayout1_2=uix.Grid('parent',mainlayout1 );
handles.ax_window=axes('parent',uicontainer('parent',mainlayout1_2));
box on
xlabel('NA Power (dBm)','parent',handles.ax_window);
ylabel('Frequency (GHz)','parent',handles.ax_window);

mainlayout1.Widths=[-1, -1.8];

%按钮定义
set(handles.star_button,'callback',@(o,e)set_parameter_callback(o,e));
set(handles.absphase_button,'callback',@(o,e)absphase_callback(o,e));
set(dip_button,'callback',@(o,e,handles)find_dip(o,e));
set(peak_button,'callback',@(o,e,handles)find_peak(o,e));
set(fit_button,'callback',@(o,e,handles)fit_callbak(o,e));
end




function set_parameter_callback(o,e)
global handles
handles.IP=get(handles.IP_edit,'string');
set(handles.IP_edit,'string',[handles.IP]);
handles.Freq_star=(get(handles.Freq_star_edit,'string'));
handles.Freq_stop=(get(handles.Freq_stop_edit,'string'));
handles.Freq_SwpPoint=str2double(get(handles.Freq_SwpPoint_edit,'string'));
handles.IF_Bandwith=str2double(get(handles.IF_Bandwith_edit,'string'));
handles.Avg_Counts=str2double(get(handles.Avg_Counts_edit,'string'));
handles.NA_Power=(get(handles.NA_Power_edit,'string'));
handles.QTh=str2double(get(handles.QTh_edit,'string'));
handles.saveas=get(handles.saveas_edit,'string');
handles.basefile=get(handles.Basefile_edit,'string');
%handles.MagneticCurrent=get(handles.MagneticCurrent_edit,'string');
%set(handles.MagneticCurrent_edit,'string',[handles.MagneticCurrent]);
filepath=get(handles.save_edit,'string');
if filepath(end)~='\'
    set(handles.save_edit,'string',[filepath,'\'])
end
handles.Savepath=get(handles.save_edit,'string');
set(handles.save_edit,'string',handles.Savepath);
eval(['handles.num_NA_Power=',handles.NA_Power,';'])
handles.n_NA_Power=length(handles.num_NA_Power);
if(handles.n_NA_Power>1)
    cla(handles.ax_window);
end
if ~isempty(handles.basefile)
    handles.base=load(handles.basefile);
end
if ~exist(handles.Savepath)
    mkdir(handles.Savepath)
end
save([handles.currnetname '.mat'],'handles');

handles.iobj = visa('agilent',['TCPIP0::' handles.IP '::inst0::INSTR']);
handles.na = qes.hwdriver.sync.networkAnalyzer.GetInstance('na_agln5230c_1',handles.iobj);

mission_start(o,e)
end

function mission_start(o,e)
global handles
set(handles.star_button,'string','Running...','enable','on')
drawnow()
eval(['freqstarts=(',get( handles.Freq_star_edit,'string'),');']);
eval(['freqstops=(',get( handles.Freq_stop_edit,'string'),');']);

if length(freqstarts)~=length(freqstops)
    error('Freq Length different!')
end

for II=1:length(freqstarts)
    handles.Freq_star=freqstarts(II);
    handles.Freq_stop=freqstops(II);
    star_callback(o,e)
end

set(handles.star_button,'string','START','enable','on')
end

function star_callback(o,e)
global handles

filepath=get(handles.save_edit,'string');
FreqStart = (handles.Freq_star)*10^9;
FreqStop = (handles.Freq_stop)*10^9;
SwpPoints = (handles.Freq_SwpPoint);
IFBandwith = handles.IF_Bandwith*1e3;
AvgCounts = (handles.Avg_Counts);
% MagneticCurrent  = str2double(handles.MagneticCurrent);
NAPower=handles.num_NA_Power;
Repeat=str2double(handles.Repeat);

fileprefix = 'S21_';
timestr = datestr(now,'yyyymmddTHHMMSS');
filename = [filepath fileprefix '_' timestr];
if ~strcmp(handles.saveas_edit.String,'')
    filename=[filepath handles.saveas_edit.String '_' fileprefix '_' timestr];
end
handles.filename=filename;
%%DC not added yet
% DCSource1.dcval = [-1e-3 0];
% DCSource1.dcval = [MagneticCurrent,0];

handles.Freq = linspace(FreqStart,FreqStop,SwpPoints);
Freq=handles.Freq;

nPower = length(NAPower);
nFreq = length(Freq);
S21 = NaN(nPower,nFreq);

handles.na.timeout=990;
handles.na.avgcounts = AvgCounts;
handles.na.swpstopfreq = FreqStop;
handles.na.swpstartfreq = FreqStart;
handles.na.swppoints = SwpPoints;
handles.na.bandwidth = IFBandwith;
handles.na.DeleteMeasurement();
handles.na.CreateMeasurement('TRACE_S21',[2,1]);


fprintf('Measurement start\n');
tstart = tic();

for n_Repeat=1:Repeat
    
    for iPower = 1:nPower
        
        handles.na.power = NAPower(iPower);
        
        if nPower>1
            handles.na.avgcounts = AvgCounts*(NAPower(1)-NAPower(iPower)+2)/2;
        end
                
        handles.na.CreateMeasurement('TRACE_S21',[2,1]);
        
        if AvgCounts<3
        pause(1e4/IFBandwith)
        end
        
        [~,s] = handles.na.GetData;
        
        S21(iPower,:) = s;
        
        if ~isempty(handles.basefile)
            currentbase=log10(interp1(handles.base.Freq,abs(handles.base.S21),Freq,'spline'))*20;
        else
            currentbase=0;
        end
        
        handles.abs_S21_average=log10(abs(S21'))*20-currentbase';
        handles.phase_S21_average=angle(S21);
        handles.S21=S21;
        
        handles.absphase=mod(handles.absphase+1,2);
        absphase_callback(o,e)
        
        pause(0.1);
        save([filename,num2str(n_Repeat),'.mat'],...
            'Freq','S21',...
            'IFBandwith',...
            'AvgCounts',...
            'NAPower');
        
    end
    
end

% clock0=[2017,5,5,16,21,12.4550000000000];
% 
% disp(['Time: ' num2str(etime(clock,clock0)) ', phase difference is ' num2str(handles.phase_S21_average(1)-handles.phase_S21_average(end))])

%存abs图
h_loop=figure();
if(handles.n_NA_Power>1)
    imagesc(NAPower,Freq/1e9,handles.abs_S21_average);
    xlabel('NA Power (dBm)')
    ylabel('Frequency (GHz)')
else
    plot(Freq/1e9,handles.abs_S21_average);
    xlabel('Frequency (GHz)')
    ylabel('|S21| (dB)')
end
set(gca,'ydir','normal')
title(handles.saveas_edit.String)
saveas(h_loop,[filename,num2str(n_Repeat),'_abs', '.fig'])
close(figure(h_loop));
% %存phase图
% h_loop=figure();
% if(handles.n_NA_Power>1)
%     imagesc(NAPower,Freq/1e9,handles.phase_S21_average);
%     xlabel('NA Power (dBm)')
%     ylabel('Frequency (GHz)')
% else
%     plot(Freq/1e9,handles.phase_S21_average);
%     xlabel('Frequency (GHz)')
%     ylabel('\angle S21')
% end
% saveas(h_loop,[filename,num2str(n_Repeat),'_phase', '.fig'])
% close(figure(h_loop));
telapsed = toc(tstart);
fprintf('Elapsed time is %02d:%02d:%02d.\n',...
    fix(fix(telapsed/60)/60),...
    mod(fix(telapsed/60),60),...
    fix(mod(telapsed,60))...
    );

end

function absphase_callback(o,e)
global handles
FreqStart = (handles.Freq_star)*10^9;
FreqStop = (handles.Freq_stop)*10^9;
SwpPoints = (handles.Freq_SwpPoint);
Freq = linspace(FreqStart,FreqStop,SwpPoints);
NAPower=handles.num_NA_Power;
if(handles.absphase==1)
    handles.absphase=0;
    set(handles.absphase_button,'string','PHASE');
    if(handles.n_NA_Power>1)
        imagesc(NAPower,Freq/1e9,handles.phase_S21_average,'parent',handles.ax_window);
        colorbar
        xlabel('NA Power (dBm)')
        ylabel('Frequency (GHz)')
    else
        plot(Freq/1e9,handles.phase_S21_average,'parent',handles.ax_window);
        
        xlabel('Frequency (GHz)')
        ylabel('\angle S21')
    end
else
    handles.absphase=1;
    set(handles.absphase_button,'string','ABS');
    if(handles.n_NA_Power>1)
        imagesc(NAPower,Freq/1e9,handles.abs_S21_average,'parent',handles.ax_window);
        colorbar
        xlabel('NA Power (dBm)')
        ylabel('Frequency (GHz)')
    else
        plot(Freq/1e9,handles.abs_S21_average,'parent',handles.ax_window);
        xlabel('Frequency (GHz)')
        ylabel('|S21| (dB)')
    end
end

set(gca,'ydir','normal')
end

function find_dip(o,e)
global handles

Freq=handles.Freq;
absS21=handles.abs_S21_average;
phaseS21=handles.phase_S21_average;
QTh=str2double(get(handles.QTh_edit,'string'));

if handles.absphase==0
    absphase_callback
else
    absphase_callback
    absphase_callback
end

if(handles.n_NA_Power>1)
    error('Only 1D S21 can find dip!')
else
    
    [Dip,AbsDip]=findQ(Freq,absS21,QTh);
    
end

disp([num2str(length(Dip)) ' Dip(s) @ ']);disp(['[' num2str(Dip/1e9,'%.5f ') ']'])
hold on;
plot(Dip/1e9,AbsDip,'*k','LineWidth',1,'parent',handles.ax_window);
hold off;
end


function find_peak(o,e)
global handles

Freq=handles.Freq;
absS21=-handles.abs_S21_average;
phaseS21=handles.phase_S21_average;
QTh=str2double(get(handles.QTh_edit,'string'));

if handles.absphase==0
    absphase_callback
else
    absphase_callback
    absphase_callback
end

if(handles.n_NA_Power>1)
    error('Only 1D S21 can find dip!')
else
    
    [Dip,AbsDip]=findQ(Freq,absS21,QTh);
    
end

disp([num2str(length(Dip)) ' Peak(s) @ ']);disp(['[' num2str(Dip/1e9,'%.5e ') ']'])
hold on;
plot(Dip/1e9,-AbsDip,'*k','LineWidth',1,'parent',handles.ax_window);
hold off;
end


function fit_callbak(o,e)
global handles

Freq=handles.Freq;
S21=handles.S21;
Power=handles.num_NA_Power;

calibrate21=toolbox.data_tool.fitting.QFit1.calibrate(Freq,S21);

for ipower=1:length(Power)
    [ c(ipower,:),dc(ipower,:) ]=toolbox.data_tool.fitting.QFit1.qfit1(Freq,calibrate21(ipower,:),false);
end
h=toolbox.data_tool.fitting.QFit1.showfittingresult(handles.saveas,Power,Freq,calibrate21,c,dc);
saveas(h,[handles.filename '_fit.fig'])
end

function [Dip,AbsDip]=findQ(freq,absS21,Q_t)
% This function is to find the dips with Q factor higher than Q_t from the S21 curve.
% Return are the frequency and Abs of the dips.
% GM 20170502

b=freq/Q_t;
freq_step=(freq(end)-freq(1))/length(freq);
b_step=ceil(b/freq_step);
N=1;
C=[];
for II=1:length(freq)
    if II-b_step(II)>=1 && II+b_step(II)<=length(freq)
        if absS21(II)-absS21(II+b_step(II))<=-3 && absS21(II)-absS21(II-b_step(II))<=-3
            C(N)=II;
            N=N+1;
        end
    end
end
% figure;plot(C)

Dip=[];
AbsDip=[];
if ~isempty(C)
dC=C(2:length(C))-C(1:length(C)-1);
lC=1;
lC=[lC,find(dC>b_step(1)),length(C)];
for II=1:length(lC)-1
    [~,CC]=min(absS21(C(lC(II)+1):C(lC(II+1))));
    Dip(II)=freq(CC+C(lC(II)+1)-1);
    AbsDip(II)=absS21(CC+C(lC(II)+1)-1);
end
end

end