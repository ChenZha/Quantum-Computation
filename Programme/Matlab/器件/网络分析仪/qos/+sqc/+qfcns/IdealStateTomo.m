I = [1,0;0,1];
X = [0,1;1,0];
Y = [0, -1i; 1i,0];
Y2m = expm(-1i*(-pi)*Y/4);
X2p = expm(-1i*pi*X/4);
TomoGateSet = {Y2m,X2p,I};
u = cell(3,3);
for u_q1 = 1:3
    for u_q2 = 1:3
        u{u_q2,u_q1} = kron(TomoGateSet{u_q2},TomoGateSet{u_q1});
    end
end
U = NaN(36,16);
for Ui = 1:36 % Ui is index as {u_q2,u_q1,s_q2,s_q1}
    for Uj = 1:16 % Uj is index as {j_col_q2,j_col_q1,j_row_q2,j_row_q1}
        ui = fix((Ui-1)/4)+1;
        s = Ui-(ui-1)*4;
        u_q2 = fix((ui-1)/3)+1;
        u_q1 = ui-(u_q2-1)*3;
        s_q2 = fix((s-1)/2)+1;
        s_q1 = s-(s_q2-1)*2;
        j_col = fix((Uj-1)/4)+1;
        j_row = Uj-(j_col-1)*4;
        j_col_q2 = fix((j_col-1)/2)+1;
        j_col_q1 = j_col-(j_col_q2-1)*2;
        j_row_q2 = fix((j_row-1)/2)+1;
        j_row_q1 = j_row-(j_row_q2-1)*2;
        U(Ui,Uj) = u{u_q2,u_q1}(s,j_row)*conj(u{u_q2,u_q1}(s,j_col));
    end
end
state_q2 = [1;1i]/sqrt(2);
state_q1 = [1;1i]/sqrt(2);
rho = kron(state_q2*state_q2',state_q1*state_q1');
P = U*rho(:);
P = reshape(P,4,9);
P = P.';
figure;bar3(real(P));
%%
s = cell(1,4);
s{1} = [1;0];
s{2} = [0;1];
s{3} = [1;1]/sqrt(2);
s{4} = [1;1i]/sqrt(2);

si = 16;
i_q2 = fix((si-1)/4)+1;
i_q1 = si-(i_q2-1)*4;
rho = kron(s{i_q2}*s{i_q2}',s{i_q1}*s{i_q1}');
figure;
subplot(1,2, 1);
bar3(real(rho));
subplot(1,2, 2);
bar3(imag(rho));
%%
s = cell(1,4);
s{1} = [1;0];
s{2} = [0;1];
s{3} = [1;1]/sqrt(2);
s{4} = [1;1i]/sqrt(2);

rho = cell(4,4);
for iq1 = 1:4
    for iq2 = 1:4
        rho{iq2,iq1} = kron(s{iq2}*s{iq2}',s{iq1}*s{iq1}');
    end
end
I = [1,0;0,1];
X = [0,1;1,0];
Y = [0, -1i; 1i,0];
Y2m = expm(-1i*(-pi)*Y/4);
X2p = expm(-1i*pi*X/4);
TomoGateSet = {Y2m,X2p,I};
u = cell(3,3);
for u_q1 = 1:3
    for u_q2 = 1:3
        u{u_q2,u_q1} = kron(TomoGateSet{u_q2},TomoGateSet{u_q1});
    end
end
U = NaN(36,16);
for Ui = 1:36 % Ui is index as {u_q2,u_q1,s_q2,s_q1}
    for Uj = 1:16 % Uj is index as {j_col_q2,j_col_q1,j_row_q2,j_row_q1}
        ui = fix((Ui-1)/4)+1;
        s = Ui-(ui-1)*4;
        u_q2 = fix((ui-1)/3)+1;
        u_q1 = ui-(u_q2-1)*3;
        s_q2 = fix((s-1)/2)+1;
        s_q1 = s-(s_q2-1)*2;
        j_col = fix((Uj-1)/4)+1;
        j_row = Uj-(j_col-1)*4;
        j_col_q2 = fix((j_col-1)/2)+1;
        j_col_q1 = j_col-(j_col_q2-1)*2;
        j_row_q2 = fix((j_row-1)/2)+1;
        j_row_q1 = j_row-(j_row_q2-1)*2;
        U(Ui,Uj) = u{u_q2,u_q1}(s,j_row)*conj(u{u_q2,u_q1}(s,j_col));
    end
end
P = NaN(16,9,4);
rho_ = cell(1,16);
cz = [1,0,0,0;
     0,1,0,0;
     0,0,1,0;
     0,0,0,-1];
cz = kron(I,expm(-1i*pi*[1,0;0,-1]/2))*cz;
for ii = 1:16
    iq2 = fix((ii-1)/4)+1;
    iq1 = ii-(iq2-1)*4;
    rho_{ii} = cz*rho{iq2,iq1}*cz';
    P_ = U*rho_{ii}(:);
    P_ = reshape(P_,4,9);
    P(ii,:,:) = P_.';
end