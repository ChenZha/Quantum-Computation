function sendmail2me(to_address, subject, message, datapath)

from_address='15850725722@139.com';
password='docGong1';
% to_address='15850725722@139.com';
if nargin==0
    to_address='15850725722@139.com';
    subject='Message from MATLAB';
end

if (~exist('message', 'var')), message=[];end;
if (~exist('datapath', 'var')), datapath=[];end;
mode = 1;
if (~exist('mode', 'var')), mode=0;end; % Ĭ��Ϊ0����ϵͳ�Զ�ѡ���������

% ���÷����ĵ�ַ�����룬��������
setpref('Internet', 'E_mail', from_address);
setpref('Internet', 'SMTP_Username', from_address);
setpref('Internet', 'SMTP_Password', password);
serve_str=[];
if mode ~= 0 % ���㣬���������ã�����ϵͳ�Զ����á�
    index = strfind(from_address, '@');
    serve_str = sprintf('smtp.%s', from_address(index+1:end));
    setpref('Internet', 'SMTP_Server', serve_str);
end;
% java ������
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true'); 
props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

% ����
sendmail(to_address, subject, message, datapath);
end