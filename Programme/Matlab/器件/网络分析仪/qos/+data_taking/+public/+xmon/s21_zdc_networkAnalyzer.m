function varargout = s21_zdc_networkAnalyzer(varargin)
% [s21] vs [power] with network analyzer
% 
%  <_o_> = s21_zdc_networkAnalyzer('qubit',_c|o_,'NAName',<[_c_]>,...
%       'startFreq',_f_,'stopFreq',_f_,...
%       'numFreqPts',_i_,'avgcounts',_i_,'NApower',[_f_],...
%       'biasAmp',[_f_],'bandwidth',_f_,...
%       'notes',<[_c_]>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.
% example: 
% s21_zdc_networkAnalyzer('qubit','q1','NAName',[],'startFreq',6.5e9,'stopFreq',6.9e9,'numFreqPts',1000,'avgcounts',10,'NApower',-10,'biasAmp',[-1e4:1e3:1e4],'bandwidth',20000,'notes','','gui',true,'save',false)

% Yulin Wu, 2017/2/14
% GM, 2017/04/12

    fcn_name = 'data_taking.public.s21_zdc_networkAnalyzer'; % this and args will be saved with data
    import qes.*
    
    args = util.processArgs(varargin,{'NAName',[],'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    if isempty(args.NAName)
        na = [qHandle.FindByClass('qes.hwdriver.sync.networkAnalyzer'),...
            qHandle.FindByClass('qes.hwdriver.async.networkAnalyzer')];
        if isempty(na)
            throw(MException('s21_scan_networkAnalyzer:networkAnalyzerNotFound',...
                    'no network analyzer found.'));
        else
            na = na{1};
        end
    else
        na = qHandle.FindByClassProp('qes.hwdriver.sync.networkAnalyzer',args.NAName);
        if isempty(na)
            na = qHandle.FindByClassProp('qes.hwdriver.async.networkAnalyzer',args.NAName);
        end
        if isempty(na)
            throw(MException('s21_scan_networkAnalyzer:networkAnalyzerNotFound',...
                    'no network analyzer found.'));
        end
    end
    
    dcSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.z_dc.instru);
    dcChnl = dcSrc.GetChnl(q.channels.z_dc.chnl);
    
    na.swpstartfreq = args.startFreq;
    na.swpstopfreq = args.stopFreq;
    na.swppoints = args.numFreqPts;
    na.bandwidth = args.bandwidth;
    na.avgcounts = args.avgcounts;
    na.power = args.NApower;
    
    R = qes.measurement.sParam(na);
    R.name = 'S21';
    
    x = expParam(dcChnl,'dcval');
    x.name = [q.name,' dc bias'];
    s1 = sweep(x);
    s1.vals = args.biasAmp;
    e = experiment();
    e.name = 'S21 with NA';
    e.sweeps = s1;
    e.measurements = R;
    e.datafileprefix = sprintf('%s_s21_zdc', q.name);
    e.plotfcn = @util.plotfcn.sparam.Amplitude;
    
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
    data_taking.public.util.setZDC(q);
end