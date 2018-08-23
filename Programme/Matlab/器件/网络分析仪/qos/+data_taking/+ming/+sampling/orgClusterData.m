function orgClusterData(path)
if nargin<1
    path='E:\data\20180216_12bit\sampling\180517\cluster';
end

files=dir([path '\*.mat']);
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10','q11','q12'};

bitnum=2:12;


numQ=numel(qubits);

for ii=1:numel(bitnum)
    for kk=1:numQ-bitnum(ii)+1
        Pxz={};
        Pzx={};
        Pxzz={};
        Pzz={};
        savefilename='';
        for mm=1:numel(files)
%             disp(files(mm).name)
            if ~isempty(strfind(files(mm).name,['_' qubits{kk} '_'])) && ~isempty(strfind(files(mm).name,['_' qubits{kk+bitnum(ii)-1} '_'])) && isempty(strfind(files(mm).name,'Overall'))
                data=load([path '\' files(mm).name]);
                if ~isempty(strfind(files(mm).name,'L1'))
                    if isempty(Pzx)
                        Pzx=data.P;
                    else
                        Pzx=[Pzx;data.P];
                    end
                elseif ~isempty(strfind(files(mm).name,'L2'))
                    if isempty(Pxz)
                        Pxz=data.P;
                    else
                        Pxz=[Pxz;data.P];
                    end
                elseif ~isempty(strfind(files(mm).name,'L3'))
                    if isempty(Pxzz)
                        Pxzz=data.P;
                    else
                        Pxzz=[Pxzz;data.P];
                    end
                elseif ~isempty(strfind(files(mm).name,'L4'))
                    if isempty(Pzz)
                        Pzz=data.P;
                    else
                        Pzz=[Pzz;data.P];
                    end
                end
                circuit=data.circuit;
                measureQs=data.measureQs;
                numTakes=data.numTakes;
                numRunsPerTake=data.numRunsPerTake;
                savefilename=['Overall_' num2str(bitnum(ii)) 'bit_' files(mm).name];
            end
        end
        if ~isempty(savefilename)
            save([path '\' savefilename],'Pxz','Pzx','Pxzz','Pzz','circuit','measureQs','numTakes','numRunsPerTake')
        end
    end
end


end