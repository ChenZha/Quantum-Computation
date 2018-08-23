function Fidelity=qeccData2Fid(data)
% Estimate fidelity from data for QECC.
% Measurement list:
% g1=XIZXZ
% g2=IXXZZ
% g3=XZIZX
% g4=ZZXXI
% Xbar=XXXXX
% Ybar=YYYYY
% Zbar=ZZZZZ
% data format is r*jj*ii. r is measurement repeat times. jj is 7 expectation
% value. ii is all 32 states of 5 qubits in order of |Q5Q4Q3Q2Q1>. Each
% data value stands for the probability of the state in that measurement.

% |psi>=a|0>+b|1>
a=1;b=0;
mbar=zeros(7,1);
for jj=1:7
    for ii=1:32
        state=dec2bin(ii-1,5);
        if jj==1
            state(4)=[];
        elseif jj==2
            state(5)=[];
        elseif jj==3
            state(3)=[];
        elseif jj==4
            state(1)=[];
        end
        mtag=0;
        for tt=1:numel(state)
            if state(tt)=='0'
                mtag=mtag+1;
            end
        end
        if jj<=4
            mbar(jj)= mbar(jj)+(1-mod(mtag,2)*2)*data(jj,ii);
        else
            mbar(jj)= mbar(jj)+(mod(mtag,2)*2-1)*data(jj,ii);
        end
    end
end

Fidelity=0.5*(sum(mbar(1:4))+(a*conj(a)-b*conj(b))*mbar(7)+(conj(a)*b+conj(b)*a)*mbar(5)-1i*(conj(a)*b-conj(b)*a)*mbar(6)-3);
end