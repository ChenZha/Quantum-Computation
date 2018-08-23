function Notes = trimNotes(Notes)
    % 
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    sz = size(Notes);
    if sz(1) > 1
        Notes_ = '';
        for ww = 1:sz(1);
            tempstr = strtrim(Notes(ww,:));
            tempstr((tempstr == 10) | (tempstr == 13)) = [];
            if ~isempty(tempstr)
                Notes_ = [Notes_,10,tempstr];
            end
        end
        if Notes_(1) == 10
            Notes_(1) = [];
        end
        Notes = Notes_;
    end
end