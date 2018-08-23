function varargout = Tomo_2QProcess(varargin)
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

    args = util.processArgs(varargin,{'gui',false,'notes','','save',true});
    [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});

    if ischar(args.process)
        switch args.process
            case 'I'
                I1 = gate.I(q1);
                I2 = gate.I(q2);
                p = I2.*I1;
            case 'CZ'
                p = gate.CZ(q1,q2); 
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
	
    R = measure.processTomography({q1,q2},p);

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