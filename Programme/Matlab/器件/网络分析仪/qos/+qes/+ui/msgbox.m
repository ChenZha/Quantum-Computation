function msgbox(msg,title,modal)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    if nargin > 2
       if modal
           msgbox(msg,['QOS | ',title],'modal');
       else
           msgbox(msg,['QOS | ',title]);
       end
    elseif nargin > 1
        msgbox(msg,['QOS | ',title],'modal');
    else
        msgbox(msg,'QOS | Message','modal');
    end
end