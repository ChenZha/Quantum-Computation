function varargout = s21_01_multiplexed(varargin)
% resonator s21 of state |0> and state |1> 
% 
% <_o_> = s21_01('qubits',_c&o_,...
%       'freq',<_f_>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017/1/13

    fcn_name = 'data_taking.public.xmon.s21_01'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'freq',[],'gui',false,'notes','','save',true});
    
    qubits = args.readoutQubits;
    numQs = numel(qubits);
%     Xs = cell(1,numQs);
	RDelay = 0;
    for ii = 1:numQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
%         Xs{ii} = gate.X(qubits{ii});
% 		RDelay = max(RDelay,Xs{ii}.length);
    end
    
    driveQ = args.driveQubit;
    if ischar(driveQ)
        driveQ = sqc.util.qName2Obj(driveQ);
    end
    X = gate.X(driveQ);
    RDelay = X.length;
    
    R = measure.rReadout4S21_01_multiplexed(qubits);
    R.delay = RDelay;
    R.name = '|IQ|';
    
    x = expParam(R,'mw_src_frequency');
    x.name = ' readout frequency';
    x.callbacks ={@(x_) X.Run()};
    s1 = sweep(x);
    s1.vals = args.freq;
    e = experiment();
    e.name = 'S21 - |0>,|1>';
    e.sweeps = s1;
    e.measurements = R;
    e.showctrlpanel = false;
    e.plotdata = false;
    e.savedata = false;
    e.Run();
    
    
    data_ = e.data{1};
    freqLn = numel(data_);
    data0 = NaN(numQs,freqLn);
    data1 = NaN(numQs,freqLn);
    for ii = 1:freqLn
        data0(:,ii) = data_{ii}(:,2);
        data1(:,ii) = data_{ii}(:,1);
    end

    if args.gui
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS | s21 of |0>, |1> '));
                hold(ax,'on');
                plot(ax, args.freq, abs(data0.'));
                plot(ax, args.freq, abs(data1.'));
                legend(ax,{'|0>', '|1>'});
        ylabel('S21 Amplitude');
        xlabel('lo frequency(GHz)');
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS | s21 of |0>, |1> '));
                hold(ax,'on');
                plot(ax, args.freq, unwrap(angle(data0.')));
                plot(ax, args.freq, unwrap(angle(data1.')));
                legend(ax,{'|0>', '|1>'});
        ylabel('S21 angle(rad)');
        xlabel('lo frequency(GHz)');
    end
    
    
    e.data{1} = cell2mat(e.data{1});
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    if args.save
        e.SaveData();
    end
    varargout{1} = e;
end