function data = runSingleQGates(q,Gates,pow)
% run gate seuence on single qubit and perform measurement
% data = runSingleQGates('q5',{'Y2m','Delay(1e3)','Y2p'});
% data = runSingleQGates('q5',{'X'},11); % eleven X gates

% Yulin Wu, 170818

    args.qubit = q;
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    g = feval(str2func(['@(q)sqc.op.physical.gate.',Gates{1},'(q)']),q);
    for ii = 2:numel(Gates)
        g = g*feval(str2func(['@(q)sqc.op.physical.gate.',Gates{ii},'(q)']),q);
    end
    
    if nargin > 2
        g = g^pow;
    end

    R = sqc.measure.resonatorReadout(q);
    R.delay = g.length;
 
    g.Run();
    data = R();
end