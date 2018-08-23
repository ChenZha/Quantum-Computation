function v = zStepResponse(sigma,td1,r1,td2,r2,t)
% Yulin Wu, 17/08/05

    ag = exp(-t.^2/sigma^2);
    ae1 = r1*exp(-t/td1);
    ae2 = r2*exp(-t/td2);
    
    v = ag+ae1+ae2;
    v = v/max(v);
    v = 1-v;

end