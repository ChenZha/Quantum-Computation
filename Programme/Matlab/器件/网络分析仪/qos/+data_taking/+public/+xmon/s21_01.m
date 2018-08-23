function varargout = s21_01(varargin)
% resonator s21 of state |0> and state |1> 
% 
% <_o_> = s21_01('qubit',_c|o_,...
%       'freq',<_f_>,...
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

% Yulin Wu, 2017/1/13

    fcn_name = 'data_taking.public.xmon.s21_01'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'freq',[],'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    if isempty(args.freq)
        args.freq = q.r_freq-3*q.t_rrDipFWHM_est:q.t_rrDipFWHM_est/10:q.r_freq+3*q.t_rrDipFWHM_est;
    end
    
    X = gate.X(q);
    R = measure.rReadout4S21_01(q);
    R.delay = X.length;
    R.name = '|IQ|';
    
    x = expParam(R,'mw_src_frequency');
    x.offset = q.r_fc - q.r_freq;
    x.name = [q.name,' readout frequency'];
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
    e.data{1} = cell2mat(e.data{1});
    e.datafileprefix = sprintf('%s', q.name);
    if args.gui
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS | s21 of |0>, |1> '));
        plot(ax, args.freq,abs(e.data{1}(:,1)));
        hold(ax,'on');
        plot(ax, args.freq, abs(e.data{1}(:,2)));
        legend(ax,{'|0>', '|1>'});
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    if args.save
        e.SaveData();
    end
    varargout{1} = e;
end