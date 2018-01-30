%利用计算的方法计算腔的f0，Qc，以及qubit的Qi
% function  [f0,Qi,Qc] = QCal(path)
% 
% if (nargin<1)
        path = 'readout.s2p';
% end

ckt=read(rfdata.data, path);
f = reshape(ckt.Freq,1,length(ckt.Freq));
S = ckt.S_Parameters;
S_21 = reshape(S(2,1,:),1,length(S(2,1,:)));
%%
S_21= 1./S_21-1;%求S21^(-1)-1
[smax,arg] = max(abs(S_21));
f0 = f(arg);
Sl =  S_21(1:arg-1) ; Sr = S_21(arg+1:end);
fl =  f(1:arg-1) ; fr = f(arg+1:end);

[slmin,argl] = min(abs(abs(Sl)-smax/sqrt(2)));
% figure();plot(fl,abs(Sl)-smax/sqrt(2));
dl = abs(Sl)-smax/sqrt(2);
fl = fl(argl);
[srmin,argr] = min(abs(abs(Sr)-smax/sqrt(2)));
% figure();plot(fr,abs(Sr)-smax/sqrt(2));
dr = abs(Sr)-smax/sqrt(2);
fr = fr(argr);
deltaf = fr-fl;

Qi = f0/deltaf;
Qc = Qi/smax;
disp(Qi);
disp(Qc);
% end