function varargout = Tomo_2QProcess_incircuit(varargin)
% demonstration of process tomography on 2 qubits.
% process tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that process tomography is working properly.
% process options are: 'CZ','CNOT'
%
% <_o_> = Tomo_2QProcess('qubit1',_c|o_,'qubit1',_c|o_,...
%       'process',<_c_>,...
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

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'innerdelay',80,'gui',false,'notes','','save',true,'withPre',true,'withTail',true});
    [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});

    if ischar(args.process)
        switch args.process
            case 'I'
                I1 = gate.I(q1);
                I2 = gate.I(q2);
                p = I2.*I1;
            case 'CZ'
                % Get simutanous cz qubits sets
                allqubits = sqc.util.loadQubits();
                qubits={allqubits{1:end}};
                
                simuCZ=false;
                simuCZset=sqc.util.getQSettings('g_cz.simuCZ','shared');
                numlayers=numel(simuCZset);
                for ii=1:numel(simuCZset)
                    for jj=1:numel(simuCZset{ii})
                        for kk=1:numel(simuCZset{ii}{jj})
                            if strcmp(simuCZset{ii}{jj}{kk},q1.name)
                                for ll=1:numel(simuCZset{ii}{jj})
                                    if strcmp(simuCZset{ii}{jj}{ll},q2.name)
                                        simuCZ=true;
                                        loi=ii;
                                        loj=jj;
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                precq={};
                pretq={};
                preGateCZ={};
                innerdelay=args.innerdelay;
                for kk=1:numel(innerdelay)
                    innergate{kk} = gate.I(q1);
                    innergate{kk}.ln = innerdelay(kk);
                end
                if loi>1
                    for ii=1:loi-1
                        for jj=1:numel(simuCZset{ii})
                            precq{ii}{jj}=simuCZset{ii}{jj}{1};
                            pretq{ii}{jj}=simuCZset{ii}{jj}{2};
                        end
                    end
                    
                    preCZ={};
                    for ii=1:numel(precq)
                        for jj=1:numel(precq{ii})
                            preCZ{ii}{jj}=gate.CZ(qubits{qes.util.find(precq{ii}{jj},qubits)},qubits{qes.util.find(pretq{ii}{jj},qubits)});
                            if jj==1
                                preGate{ii}=preCZ{ii}{1};
                            else
                                preGate{ii}=preGate{ii}.*preCZ{ii}{jj};
                            end
                        end
                    end
                    
                    if loi>2
                        preGateCZ=preGate{1}*innergate{1};
                        for ii=2:numel(preGate)
                            preGateCZ=preGateCZ*preGate{ii}*innergate{ii};
                        end
                    else
                        preGateCZ=preGate{1}*innergate{1};
                    end
                    
                end
                                
                simucq={};
                simutq={};
                for mm=1:numel(simuCZset{loi})
                    if mm~=loj
                        simucq=[simucq,simuCZset{loi}{mm}{1}];
                        simutq=[simutq,simuCZset{loi}{mm}{2}];
                    end
                end
                simuCZ={};
                simuI={};
                for ii=1:numel(simucq)
                    simuCZ{ii}=gate.CZ(qubits{qes.util.find(simucq{ii},qubits)},qubits{qes.util.find(simutq{ii},qubits)});
                    simuI{ii}=gate.I(qubits{qes.util.find(simucq{ii},qubits)});
                end
                
                tailcq={};
                tailtq={};
                tailGateCZ={};
                if loi<numlayers
                    for ii=1:numlayers-loi
                        for jj=1:numel(simuCZset{loi+ii})
                            tailcq{ii}{jj}=simuCZset{loi+ii}{jj}{1};
                            tailtq{ii}{jj}=simuCZset{loi+ii}{jj}{2};
                        end
                    end
                    
                    tailCZ={};
                    for ii=1:numel(tailcq)
                        for jj=1:numel(tailcq{ii})
                            tailCZ{ii}{jj}=gate.CZ(qubits{qes.util.find(tailcq{ii}{jj},qubits)},qubits{qes.util.find(tailtq{ii}{jj},qubits)});
                            if jj==1
                                tailGate{ii}=tailCZ{ii}{1};
                            else
                                tailGate{ii}=tailGate{ii}.*tailCZ{ii}{jj};
                            end
                        end
                    end
                    
                    % No innerdelay considered in tail
                    if loi<numlayers-1
                        tailGateCZ=tailGate{1};
                        for ii=2:numel(tailGate)
                            tailGateCZ=tailGateCZ*tailGate{ii};
                        end
                    else
                        tailGateCZ=tailGate{1};
                    end
                end
                
                CZ = gate.CZ(q1,q2);
                CZset=CZ;
                for dd=1:numel(simuCZ)
                    CZset=CZset.*simuCZ{dd};
                end
                
                p=CZset;
                if args.withPre && ~isempty(preGateCZ)
                    p=preGateCZ*p;
                end
                if args.withTail && ~isempty(tailGateCZ)
                    p=p*tailGateCZ;
                end
            
            
            case 'CNOT'
                CZ = gate.CZ(q1,q2); 
                Y2m = gate.Y2m(q2);
                Y2p = gate.Y2p(q2);
                p = Y2m*CZ*Y2p; % q1, control qubit, q2, target qubit
            otherwise
                tokens = strsplit(args.process,',');
                assert(numel(tokens) == 2);
                g1 = feval(str2func(['@(q)sqc.op.physical.gate.',tokens{1},'(q)']),q1);
                g2 = feval(str2func(['@(q)sqc.op.physical.gate.',tokens{2},'(q)']),q2);
                p = g2.*g1;
                
%                 throw(MException('QOS_singleQProcessTomo:unsupportedGate',...
%                     sprintf('available process options for singleQProcessTomo is %s, %s given.',...
%                     '''CZ'',''CNOT''',args.process)));
        end
    else
        if ~isa(args.process,'sqc.op.physical.operator')
            throw(MException('QOS_singleQProcessTomo:illegalArgument',...
                    sprintf('process not a valid quantum operator.')));
        end
        p = args.process;
    end
    
	if exist('preGateCZ','var') && ~args.withPre && ~isempty(preGateCZ)
        R = measure.processTomography({q1,q2},p,preGateCZ);
    else
        R = measure.processTomography({q1,q2},p);
    end

    P = R();
    
    if args.gui
        axs = qes.util.plotfcn.Chi(P,[],1, NaN,true);
        if ischar(args.process)
            title(axs(1),[args.process, ' real part']);
            title(axs(2),[args.process, ' imaginary part']);
        else
            title(axs(1),[args.process.class(), ' real part']);
            title(axs(2),[args.process.class(), ' imaginary part']);
        end
    end
    if args.save
        QS = qes.qSettings.GetInstance();
        dataPath = QS.loadSSettings('data_path');
        
        timeStamp = datestr(now,'_yymmddTHHMMSS_');
        
        dataFileName = ['PTomo2_',q1.name,q2.name,timeStamp,'.mat'];
        figFileName = ['PTomo2_',q1.name,q2.name,timeStamp,'.fig'];
        
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        if ~ischar(args.process)
            args.process = 'operator object, can not be saved.';
        end
        save(fullfile(dataPath,dataFileName),'P','args','sessionSettings','hwSettings');
        if args.gui && isgraphics(axs(1))
            saveas(axs(1),fullfile(dataPath,figFileName));
        end
    end
    varargout{1} = P;
   
end