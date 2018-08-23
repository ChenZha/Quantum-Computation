% fit ramsey
[pxx,f] = plomb(y,x);
[~,idx] = max(pxx);
freq0 = f(idx);

td0 = mean(x);
    
[B,C,D,freq,td1,td2,J] = tool_box.fitting.sinDecay4Ramsey(x,y,...
    1,[0.8,1.2],... % B, range
    0.5,[0.3,0.7],... % y center
    0,[-pi,pi],...
    freq0,[0.7*freq0,1.5*freq0],...
    td0,[0.1*td0,10*td0],...
    td0,[0.1*td0,10*td0]);

figure();
plot(x,y,'ro','MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on;

xf = linspace()
yf = B*(exp(-(t/td1)-(t/td2).^2).*(sin(2*pi*freq*t+D)+C));