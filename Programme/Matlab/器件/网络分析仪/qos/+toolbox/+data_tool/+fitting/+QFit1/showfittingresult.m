function [h ] = showfittingresult( name,power,datafreq,datas21,c,dc )
%SHOWFIT Summary of this function goes here
%   Detailed explanation goes here
f0 = c(:,1);
Qi = c(:,2);
Qc = c(:,3);
phi = c(:,4);

df0 = dc(:,1);
dQi = dc(:,2);
dQc = dc(:,3);
dphi = dc(:,4);

h = figure('Color',[1 1 1]);
set(h,'defaultuicontrolunits','normalized');
hax1 = axes('position',[0.1,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
hax2 = axes('position',[0.6,0.2,0.3,0.6],'linewidth',2.25,'fontsize',14);
popupstr = ['Qi&Qc^f0'];
npower = length(power);
if npower>0
    for ipower = 1:npower
        popupstr = [ popupstr '|' num2str(power(ipower)) 'dBm'];
    end
end
hpopup = uicontrol(h,'Style','popup',...
    'position',[0.4,0.85,0.2,0.1],...
    'string',popupstr,...
    'callback',@popupcallback);
popupcallback(hpopup,0)

    function popupcallback(hObject,callbackdata)
        ipop = get(hObject,'Value');
        switch ipop
            case 1
                % QI&Qc
                axes(hax1);
                [hax,hQi,hQc] = plotyy(power,Qi,power,Qc,...
                    @(x,y)errorbar(x,y,dQi,'linewidth',2.25),...
                    @(x,y)errorbar(x,y,dQc,'linewidth',2.25));
                title('Qi&Qc','fontsize',16);
                set(hax(1),'fontsize',14);set(hax(2),'fontsize',14);
                xlabel('Power(dBm)','fontsize',16); ylabel(hax(1),'Qi','fontsize',16);ylabel(hax(2),'Qc','fontsize',16);
                axes(hax2);
                errorbar(power,f0,df0,'linewidth',2.25);
                title('f0');
                xlabel('Power(dBm)','fontsize',16); ylabel('f0(Hz)','fontsize',16);
            otherwise
                iipower = ipop-1;
                fitteds21 = 1./inverseds21(c(iipower,:),datafreq);
                axes(hax1);
                plot(real(1./datas21(iipower,:)),imag(1./datas21(iipower,:)),'o','linewidth',2.25)
                hold on
                plot(real(1./fitteds21),imag(1./fitteds21),'LineWidth',2.25,'color','r');
                title('Smith of S21^{-1}','fontsize',16);
                xlabel('Re[S_{21}^{-1}]','fontsize',16); ylabel('Im[S_{21}^{-1}]','fontsize',16);
                hold off
                
                axes(hax2);
                plot(datafreq,log10(abs(datas21(iipower,:)))*20,'o','linewidth',2.25)
                hold on
                plot(datafreq,log10(abs(fitteds21))*20,'LineWidth',2.25,'color','r');
                title('Amlitude of S21','fontsize',16);
                xlabel('Frequency(Hz)','fontsize',16); ylabel('|S21|(dB)','fontsize',16);
                hold off
        end
    end
end

function [ invs21 ] = inverseds21( c,freq )
%INVERSES21 Summary of this function goes here
%   Detailed explanation goes here
f0 = c(1);
Qi = c(2);
Qc = c(3);
phi = c(4);
dx = (freq-f0)/f0;
invs21 = 1+exp(1i*phi)*Qi/Qc./(1+2*1i*Qi*dx);
end