function b = samePropVal(objs, prop_names)
% check if objs(of the same class) has the same value for properties listed in
% prop_names(cell array of property names)
% obj.field1.field2.field3 => prop_names = {'field1','field2','field3'}

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    if numel(unique(cellfun(@class,objs,'UniformOutput',false))) > 1
        error('samePropVal only works for objects of the same class.');
    end
    numObjs = numel(objs);
    num_prop = numel(prop_names);
    b = logical(ones(1,num_prop));
    if numObjs < 2 || ~num_prop
        return;
    end
	function propVal = getPorpVal(obj,propName)
		if iscell(propName)
			S = struct();
			for iii = 1:numel(propName)
				S(iii).type = '.';
				S(iii).subs = propName{iii};
				propVal = subsref(obj,S);
			end
		else
			propVal = obj.(propName);
		end
	end
    for ii = 1:numel(prop_names)
        pv1 = getPorpVal(objs{1},prop_names{ii});
        if isnumeric(pv1) || islogical(pv1)
            sz = size(pv1);
            if all(sz>1)
				val_1 = pv1;
				val_1 = val_1(:);
                for jj = 1:numObjs
                    pv2 = getPorpVal(objs{jj},prop_names{ii});
					if numel(sz) ~= numel(pv2)
						b(ii) = false;
						break;
					else
						val_jj = pv2;
						if ~all(val_1(:) == val_jj(:))
							b(ii) = false;
							break;
                        end
					end
				end
            end
            n_rows = max(sz);
            val = NaN(n_rows,numObjs);
            for jj = 1:numObjs
                val_jj = getPorpVal(objs{jj},prop_names{ii});
                if all(size(val_jj) == sz)
                    val(:,jj) = val_jj(:);
                else
                    b(ii) = false;
                    break;
                end
            end
            if size(unique(val','rows'),1) > 1
                b(ii) = false;
            end
        else
            val = cell(1,numObjs);
            for jj = 1:numObjs
                val{jj} = getPorpVal(objs{jj},prop_names{ii});
            end
            if numel(unique(val)) > 1
                b(ii) = false;
            end
        end
    end
end