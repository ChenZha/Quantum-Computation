% async I\O speedup test
%%  % 0.0053s
import mtwisted.defer.Deferred
awgobj = mtwisted.io.async.tcpip_client('10.0.0.201',4001);
fopen(awgobj);
tic;
D = Deferred.empty(0,1);
for ii = 1:2
    D(ii) = query(awgobj,'*IDN?');
end
toc
%%
fclose(awgobj);
%%  0.224s
awgobj = tcpip('1.0.0.201',4001);
fopen(awgobj);
tic;
d2 = query(awgobj,'*IDN?');
toc
fclose(awgobj);