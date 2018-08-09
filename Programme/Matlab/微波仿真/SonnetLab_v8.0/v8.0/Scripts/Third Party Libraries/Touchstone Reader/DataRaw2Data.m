function Data=DataRaw2Data(DataTemp,Frmat)


[Rows,Cols,Sheets]=size(DataTemp);
nPorts=sqrt(Cols/2);
Data=zeros(nPorts,nPorts,Sheets);

if strcmp(Frmat,'db')
    for p=1:Sheets
        for n=1:nPorts
            for m=1:nPorts
                Data(m,n,p)=10^(DataTemp(1,((m-1)*nPorts+n+1)*2-3,p))/20*exp(1j*DataTemp(1,((m-1)*nPorts+n+1)*2-2,p)*pi/180);
            end
        end
    end
end

if strcmp(Frmat,'ma')
    for p=1:Sheets
        for n=1:nPorts
            for m=1:nPorts
                Data(m,n,p)=(DataTemp(1,((m-1)*nPorts+n+1)*2-3,p))*exp(1j*DataTemp(1,((m-1)*nPorts+n+1)*2-2,p)*pi/180);
            end
        end
    end
end

if strcmp(Frmat,'ri')
    for p=1:Sheets
        for n=1:nPorts
            for m=1:nPorts
                Data(m,n,p)=DataTemp(1,((m-1)*nPorts+n+1)*2-3,p)+j*DataTemp(1,((m-1)*nPorts+n+1)*2-2,p);
            end
        end
    end
end
