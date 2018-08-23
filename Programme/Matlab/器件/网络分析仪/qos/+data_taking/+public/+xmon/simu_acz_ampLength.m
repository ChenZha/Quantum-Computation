function varargout = simu_acz_ampLength(varargin)
% <_o_> = simu_acz_ampLength('controlQ',_c|o_,'targetQ',_c|o_,...
%       'czLength',[_i_],'czAmp',[_f_],'cState','0',...
%       'dataTyp',<_c_>,...  % options: P, or Phase
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

% Yulin Wu, 2017/7/2
% GM, 20180421

    import qes.*
    import sqc.*
    import sqc.op.physical.*

	if nargin > 1  % otherwise playback
		fcn_name = 'data_taking.public.xmon.acz_ampLength'; % this and args will be saved with data
		args = util.processArgs(varargin,{'czLength',[],'cState','0','readoutQubit',[],'gui',false,'notes','','save',true});
	end
	
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});
    
    % Get simutanous cz qubits sets
    qubits = sqc.util.loadQubits();
    
    simuCZ=false;
    simuCZset=sqc.util.getQSettings('g_cz.simuCZ','shared');
    for ii=1:numel(simuCZset)
        for jj=1:numel(simuCZset{ii})
            for kk=1:numel(simuCZset{ii}{jj})
                if strcmp(simuCZset{ii}{jj}{kk},qc.name)
                    for ll=1:numel(simuCZset{ii}{jj})
                        if strcmp(simuCZset{ii}{jj}{ll},qt.name)
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
    
    %
    if ~isempty(args.readoutQubit)
        rq = data_taking.public.util.getQubits(args,{'readoutQubit'});
    else
        rq = data_taking.public.util.getQubits(args,{'targetQ'});
    end

    switch args.dataTyp
        case 'P'
            if rq == qt
                if args.cState == '0'
                    X = gate.I(qc);
                else
                    X = gate.X(qc);
                end
                Ip = gate.I(qt);
                Ip.ln = X.length;
                Y2m = gate.Y2m(qt);
                Y2p = gate.Y2p(qt);
            else
                if args.cState == '0'
                    X = gate.I(qc);
                else
                    X = gate.X(qc);
                end
                Ip = gate.I(qc);
                Ip.ln = X.length;
                Y2m = gate.Y2m(qc);
                Y2p = gate.Y2p(qc);
            end
        case {'Phase','Tomography'}
            if args.cState == '0'
                X = gate.I(qc);
            else
                X = gate.X(qc);
            end
            Ip = gate.I(qt);
            Ip.ln = X.length;
            Y2m = gate.Y2m(qt);
            Y2p = gate.Y2p(qt);
        otherwise
            throw(MException('QOS_ramsey_dp:unrcognizedDataTyp',...
            'unrecognized dataTyp %s, available dataTyp options are P or Phase.', args.dataTyp));
    end
    

    CZ = gate.CZ(qc,qt);
    if isempty(args.czLength)
        args.czLength = CZ.aczLn;
    end
    isTomography = false;
    switch args.dataTyp
        case 'P' 
            % in case of measure |2> state leakage, rq must be the qubit
            % with lower f01 frequency and readout state must be |0>
            R = measure.resonatorReadout_ss(rq); 
            R.state = 1;
            R.name = [rq.name,' ',R.name];
        case 'Phase'
            R = measure.phase(qt);
            isTomography = true;
        case 'Tomography'
            R = measure.stateTomography(qt);
            isTomography = true;
        otherwise
            throw(MException('QOS_ramsey_dp:unrcognizedDataTyp',...
                'unrecognized dataTyp %s, available dataTyp options are P or Phase.', args.dataTyp));
    end

    X_ = gate.X(qt);

    czLength = qes.util.hvar(0);
    function procFactory(amp)
        CZ.aczLn = czLength.val;
        CZ.amp = amp;
        % proc = (X.*Y2m)*Id*CZ*Id*Y2p;
        if isTomography
            preop=((X.*Ip)*Y2m);
            proc = preop*CZ;
            for dd=1:numel(simuCZ)
                simuI{dd}.ln=preop.length;
                proc=proc.*(simuI{dd}*simuCZ{dd});
            end
            R.setProcess(proc);
        else
            preop=(X.*X_);
            proc = preop*CZ; % for |11> state leakage
            for dd=1:numel(simuCZ)
                simuI{dd}.ln=preop.length;
                proc=proc.*(simuI{dd}*simuCZ{dd});
            end
            % proc = ((X.*Ip)*Y2m)*CZ*Y2p; % CNOT

            proc.Run();
            R.delay = proc.length;
        end
    end

    x = expParam(czLength,'val');
	x.name = ['CZ[',qc.name,',', qt.name,'] length'];
    
    y = expParam(@procFactory);
    y.name = ['CZ[',qc.name,',', qt.name,'] amplitude'];
    s1 = sweep(x);
    s1.vals = args.czLength;
    s2 = sweep(y);
    s2.vals = args.czAmp;
    e = experiment();
    e.name = 'ACZ amplitude';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('CZ%s%s', qc.name,qt.name);
    if ~args.gui
        e.showctrlpanel = false;
        e.plotdata = false;
    end
    if ~args.save
        e.savedata = false;
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    varargout{1} = e;
end