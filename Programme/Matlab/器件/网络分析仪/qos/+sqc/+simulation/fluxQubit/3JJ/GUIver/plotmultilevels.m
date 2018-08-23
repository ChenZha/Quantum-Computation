
EL = [VarName4,VarName6,VarName8];
el0 = [VarName2,VarName2,VarName2];
el = EL - el0;
figure
plot(x,el);
xlabel('\Phi_{ex} (Phi_0)');
ylabel('E');
legend({'E_{01}','E_{02}','E_{03}'});

