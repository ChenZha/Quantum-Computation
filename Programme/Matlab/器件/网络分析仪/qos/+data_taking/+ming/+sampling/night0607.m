import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
import data_taking.public.xmon.tuneup.*
import data_taking.public.jpa.*
%%
% tuneup.autoCalibration(qubits,0,3)
%%
for ll=1:12
    figure(212);cla;
    legendlabel={};
    for jj=1:12
        if abs(ll-jj)<12 && ll~=jj
            legendlabel=[legendlabel,qubits{jj}];
            measureQs = {qubits{ll}};
            opQs = [measureQs,{qubits{jj}}];
            r_amp0=sqc.util.getQSettings('r_amp',measureQs{1});
%             r_amp=linspace(1000,1600,21);
            r_amp=round(r_amp0*linspace(0.7,1.3,61));
%             r_amp=r_amp0;
            stats = 10000;
            measureType = 'MzjRaw'; % default 'Mzj', z projection
            circuit = {{'',''},{'','X'},{'X',''},{'X','X'}};%
            dist=[];
            for kk=1:numel(r_amp)
                sqc.util.setQSettings('r_amp',r_amp(kk),measureQs{1})
                results=nan(1,numel(circuit));
                for ii=1:numel(circuit)
                    [result, ~, ~, ~] = sqc.util.runCircuit(circuit{ii},opQs,measureQs,stats,measureType);
                    results(ii)=result;
                end
                dd0=results(3)-results(1);
                dd1=results(2)-results(1);
                dd2=results(4)-results(3);
                dist(kk)=(abs([real(dd1),imag(dd1)]*[real(dd0),imag(dd0)]')+abs([real(dd2),imag(dd2)]*[real(dd0),imag(dd0)]'))/abs(dd0)^2;
                hf=figure(210);plot(r_amp(1:kk),dist,'-o')
                title(['R: ' opQs{1} '-' opQs{2} ]);
                ylabel('Distance percentage')
                xlabel(['r amp of ' measureQs{1}])
                figure(211);plot(results,'-o')
                title([num2str(r_amp(kk)) ' ' num2str(dist(kk))])
                drawnow
            end
%             datafile=['E:\data\20180216_12bit\readout cross talk\' 'R ' opQs{1} '-' opQs{2} '.fig'];
%             saveas(hf,datafile)
            hf=figure(212);hold on;plot(r_amp,dist,'-o');
            title(['R: ' opQs{1} ]);
            legend(legendlabel);
            ylabel('Distance percentage')
            xlabel(['r amp of ' measureQs{1}])
            sqc.util.setQSettings('r_amp',r_amp0,measureQs{1})
            disp('Done')
        end
    end
    datafile=['E:\data\20180216_12bit\readout cross talk\' 'R ' opQs{1} ' cross talk',datestr(now,'hhmmss'),'.fig'];
    saveas(hf,datafile)
end
%%
setQSettings('r_avg',700);
spectroscopy1_zpa_auto('qubit','q4','biasAmp',-5e3:500:5e3,...
    'swpInitf01',[],'swpInitBias',[0],...
    'swpBandWdth',25e6,'swpBandStep',1e6,...
    'dataTyp','P','r_avg',700,'gui',true);
%%
for ii=[6 7 8 9 12]
    q=qubits{ii};
f01=sqc.util.getQSettings('f01',q);
zp=sqc.util.f012zpa(q,f01-30e6:3e6:f01+30e6);
% zp=-1000:100:1000;
setQSettings('r_avg',1000);
T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:2000:38e3],... % [20:200:2.8e4]
        'gui',true,'save',true);
end
%%
for ii=2
    q=qubits{ii};
f01=sqc.util.getQSettings('f01',q);
zp=sqc.util.f012zpa(q,4.2e9:3e6:4.5e9);
% zp=-1000:100:1000;
setQSettings('r_avg',1000);
T1_1('qubit',q,'biasAmp',zp,'biasDelay',20,'time',[20:2000:38e3],... % [20:200:2.8e4]
        'gui',true,'save',true);
end
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T1_updater('qubits',qubits)
%%
setQSettings('r_avg',3000);
% tuneup.autoCalibration(qubits,0,1)
data_taking.public.xmon.tuneup.T2_updater('qubits',qubits)