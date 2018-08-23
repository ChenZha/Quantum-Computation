path='E:\data\20180216_12bit\sampling\20180502';
layers={'L1','L2','L3','L4','L6'};
for nn=1:numel(layers)
    files=dir([path '\' '*' layers{nn} '*.mat']);
    numfiles=numel(files);
    if numfiles>0
        P=[];
%         P={};
        Events={};
        Fidelities={};
        for ii=2:numfiles
            filenames=files(ii).name;
            data=load([path '\' filenames]);
            P(ii,:)=data.P;
%             P{ii}=data.P;
            Events{ii}=data.Events;
            Fidelities{ii}=data.Fidelities;
        end
%         circuit=data.circuit;
%         notes=data.notes;
%         save([path '\Overall_' filenames],'P','Events','Fidelities','circuit','sequenceSamples','notes')
%         
    
        Pavg=mean(P,1);
        distance=[];
        for ii=1:numfiles
            if ii==1 
                distance(ii)=0.5*sum(abs(P(ii,:)-Pavg));
            else
                distance(ii)=0.5*sum(abs(P(ii,:)-P(ii-1,:)));
            end
        end
        figure;plot(1:numfiles,distance);xlabel('Measurment sets');ylabel('Distance');title(layers{nn})
    end
end