function sendmailby_(recipients,subject,content,attachments)
    % this is just an example to show how to send email by Matlab.
    % you should change 'SendMailAddress', 'SMTP_Server' and 'password', 
    % after that, use pcode sendmailby_ to encrypt the code mfile since the 
    % password is in plain text.
    % examples:
    % sendmailby163mail4ywu({'mail4ywu@icloud.com','mail4ywu@gmail.com'},...
    %     'A test mail from MATLAB',['This is a test mail sent by Matlab', 10,...
    %     'Best regards',10,'Yulin Wu'],...
    %     {'C:\YulinWu\Finance_20131025backup.zip',...
    %     'C:\YulinWu\Finance_20131102backup.zip'});

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    %%%%%%% these are what you need to change
    SendMailAddress = 'mail4ywu@163.com';
    SMTP_Server = 'smtp.163.com';
    password = '**********';
    %%%%%%%
    
    setpref('Internet','E_mail',SendMailAddress);
    setpref('Internet','SMTP_Server',SMTP_Server);
    setpref('Internet','SMTP_Username',SendMailAddress);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    sendmail(recipients,subject,content,attachments);
end


