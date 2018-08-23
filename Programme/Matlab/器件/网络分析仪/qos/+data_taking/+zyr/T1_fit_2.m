function T1_fit_2(x,y,z)

    bias=x;
    time=y;
    if length(bias)==1

            A0 = z(end);
     
       
            B0 = z(1)-z(end);
       
      
        td0 = time(end)/2;
        
        [A_,B_,td_,temp] = toolbox.data_tool.fitting.expDecayFit(time,z,A0,B0,td0);
        
        
            tf = linspace(time(1),time(end),100);
            zf = toolbox.data_tool.fitting.expDecay([A_,B_,td_],tf);
            hf=figure;
            plot(gca, time/2000,z);
            hold on;
            plot(gca,tf/2000,zf,'r');
            plot(gca,temp(3,:)/2000,[zf(end),zf(end)],'g-+');
            plot(gca,td_/2000,zf(end),'r+');
            hold off;
            xlabel('Time (us)');
            drawnow;
            legend('Raw','Fit','Errorbar','FitValue')
            if td_<time(end)
                title(['Fit T_1 = ' num2str(td_/2000,'%.2f') ' us'])
            else
                title('Fit failed!')
            end
        
    else
        for ii = 1:length(bias)
            if ~isnan(z(ii,end))

                     A0 = z(ii,end);

        
                   B0 = z(ii,1)-z(ii,end);
                
                td0 = time(end)/4;
                [A_,B_,td_,temp] = toolbox.data_tool.fitting.expDecayFit(time,z(ii,:),A0,B0,td0);

                wci(ii,:) = temp(3,:); %
                A(ii) = A_;
                B(ii) = B_;
                td(ii) = td_;
            else
                A(ii) = NaN;
                B(ii) = NaN;
                td(ii) = NaN;
                wci(ii,:) = NaN(1,2);
            end
        end
        
    
            time = time/2e3;
            td = td/2e3;
            wci = wci/2e3;
            
            hf=figure();
            imagesc(bias,time,z');
            hold on;
            errorbar(bias,td,td-wci(:,1)',wci(:,2)'-td,'ro-','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
            set(gca,'YDir','normal');
            xlabel('Z Bias');
            ylabel('Time (us)');
            if mean(td(~isnan(td)))<time(end)
                title(['Fit average T_1 = ' num2str(mean(td(~isnan(td))),'%.2f') ' us'])
            else
                title('Fit failed!')
            end
            colorbar
        end
    
end