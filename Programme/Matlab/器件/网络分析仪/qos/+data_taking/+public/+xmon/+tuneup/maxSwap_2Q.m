function phaseCal()
    error('todo...');
    
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    X1 = gate.X(q1)
    X2 = op.XY2p(q2,0)
    % sweep(X2.phase), measure P01-P10
    % finds zpls amplitude that maximize abs(P01-P10)
end