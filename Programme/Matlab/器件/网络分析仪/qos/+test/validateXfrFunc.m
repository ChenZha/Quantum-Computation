%% validate Numeric XfrFunc
frequency = linspace(-0.6,0.6,100);
ampRe = exp(-frequency.^2/0.2);
figure();plot(frequency,ampRe,'-+');

xfrFunc = com.qos.waveform.XfrFuncNumeric(frequency,ampRe,0*ampRe);
freq1 = linspace(-0.5,0.5,200);
ampE = xfrFunc.eval(freq1);
hold on;
plot(freq1,ampE(1:2:end),'-+');
%%
s = struct();
s.type = 'function';
s.funcName = 'qes.waveform.xfrFunc.gaussianExp';
s.bandWidht = 0.25;
s.r = [0,0.02]; 
s.td = [5000,500]; 
xfrFunc = qes.util.xfrFuncBuilder(s);
xfrFunc_inv = xfrFunc.inv();
xfrFunc_lp = com.qos.waveform.XfrFuncFastGaussianFilter(0.13);
xfrFunc_f = xfrFunc_lp.add(xfrFunc_inv);