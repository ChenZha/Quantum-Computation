%% Matlab version
% Elapsed time is 2.3 seconds.
tic; 
for ii = 1:1e4
g = qes.waveform.gaussian(40);
end
toc
%% java version
% Elapsed time is 0.122 seconds
tic; 
for ii = 1:1e4
g = qes.waveform.gaussian(40,1);
end
toc