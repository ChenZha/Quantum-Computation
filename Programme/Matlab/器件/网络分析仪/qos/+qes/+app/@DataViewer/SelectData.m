function SelectData(obj,choice)
    %
    
% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    handles = obj.uihandles;

    switch choice
        case 1 % all
            if (~isempty(obj.allfiles) && length(obj.files2show) == length(obj.allfiles)) && all(obj.files2show == obj.allfiles)
                return;
            end
            files2show_old = obj.files2show;
            obj.changed2newlst = true;
            obj.files2show = obj.allfiles;
            if isempty(obj.allfiles)
                obj.currentfile = [];
                obj.changed2newlst = false;
                return;
            end
            if isempty(obj.currentfile)
                obj.currentfile = length(obj.allfiles);
            else
                idx = find(obj.allfiles >= files2show_old(obj.currentfile),1);
                if isempty(idx)
                    obj.currentfile = length(obj.allfiles);
                else
                    obj.currentfile = idx;
                end
            end
            obj.changed2newlst = false;
            
        case 2 % exclude hidden
            if (~isempty(obj.allfiles) && length(obj.files2show) == length(obj.unhidden)) && all(obj.files2show == obj.unhidden)
                return;
            end
            files2show_old = obj.files2show;
            obj.files2show = obj.unhidden;
            obj.changed2newlst = true;
            if isempty(obj.unhidden)
                obj.currentfile = [];
                obj.changed2newlst = false;
                return;
            end
            if isempty(obj.currentfile)
                obj.currentfile = length(obj.unhidden);
            else
                idx = find(obj.unhidden >= files2show_old(obj.currentfile),1);
                if isempty(idx)
                    obj.currentfile = length(obj.unhidden);
                else
                    obj.currentfile = idx;
                end
            end
            obj.changed2newlst = false;
            
        case 3 % highlighted
            if (~isempty(obj.allfiles) && length(obj.files2show) == length(obj.hilighted)) && all(obj.files2show == obj.hilighted)
                return;
            end
            files2show_old = obj.files2show;
            obj.files2show = obj.hilighted;
            obj.changed2newlst = true;
            if isempty(obj.hilighted)
                obj.currentfile = [];
                obj.changed2newlst = false;
                return;
            end
            if isempty(obj.currentfile)
                obj.currentfile = length(obj.hilighted);
            else
                idx = find(obj.hilighted >= files2show_old(obj.currentfile),1);
                if isempty(idx)
                    obj.currentfile = length(obj.hilighted);
                else
                    obj.currentfile = idx;
                end
            end
            obj.changed2newlst = false;
            
        otherwise
            error('Available choices are 1/2/3 for all/excude hidden/highlighted.');
    end
end