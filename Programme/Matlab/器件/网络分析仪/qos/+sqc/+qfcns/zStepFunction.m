function v = zStepFunction(t,td1,td2,as)
% Yulin Wu, 17/08/04

a1 = exp(-t/td1);
a2 = as*exp(-t/td2);
v = 1-a1-a2;
end