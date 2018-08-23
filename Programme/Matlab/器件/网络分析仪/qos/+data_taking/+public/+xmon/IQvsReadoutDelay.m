function varargout = IQvsReadoutDelay(varargin)
% resonator s21 of state |0> and state |1> 
% 
% <_o_> = s21_01('qubit',_c|o_,...
%       'delay',[_i_],...
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

    fcn_name = 'data_taking.public.xmon.IQvsReadoutDelay'; % this and args will be saved with data
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
    R.name = 'IQ';
    
    x = expParam(R,'delay');
    x.offset = X.length;
    x.name = [q.name,' readout delay'];
    x.callbacks ={@(x_) X.Run()};
    s1 = sweep(x);
    s1.vals = args.delay;
    e = experiment();
    e.name = 'IQ - readout delay';
    e.sweeps = s1;
    e.measurements = R;
    e.showctrlpanel = false;
    e.plotdata = false;
    e.savedata = true;
    e.datafileprefix = sprintf('IQvsDelay_%s', q.name);
    e.Run();
    e.data{1} = cell2mat(e.data{1});
    
    if args.gui
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS |IQ vs Readout delay '));
        plot(ax, e.data{1}(:,1),'.b');
        hold(ax,'on');
        plot(ax, e.data{1}(:,2),'.r');
        legend(ax,{'|0>', '|1>'});
        drawnow;
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    if args.save
        e.SaveData();
    end
    varargout{1} = e;
end






























