%% on server
addpath(genpath('F:\program\qos'));

num_records = 1000;
record_ln = 1024/2;

ATSServer = qes.hwdriver.sync.alazarATS_Server('ATS_Digitizer1',1,1,37592,...
    500e6,...
    true,true,...
    0.4,0.4,...
    num_records,...
    record_ln);      

%% on client
addpath(genpath('F:\program\qos'));

num_records = 1000;
record_ln = 1024/2;
ATSClient = qes.hwdriver.async.alazarATS_Client('ATS','localhost',37592,num_records*record_ln);

%% on client
import mtwisted.defer.Deferred
D = Deferred.empty(0,10);
tic
for ii = 1:10
    D(ii) = ATSClient.FetchData();
end
toc