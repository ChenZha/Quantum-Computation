function saveJson(fullfilename,fields,value,formatedArray)

% zhaouv https://zhaouv.github.io/

% type limit:
% : must be after field with no \n  

% format:
% array p*q*..=n num->[1*n num]
% formated -> []
% cell(p*q*..=n string)->[1*n string]
%

value_backup = value;

if ~qes.util.endsWith(fullfilename,'.key')
    fullfilename = [fullfilename,'.key'];
end
if nargin == 3
    formatedArray = false;
end
if ~formatedArray
    if ischar(value)
		if ~isempty(value) && value(1)=='['
			value=['a' value];
		else 
			value=['s"' value '"'];
		end
    elseif isnumeric(value)
        if numel(value)==1
            value=['n' num2str(value)];
        else
            str='a[';
            for i=1:numel(value)
                str=[str num2str(value(i)) ','];
            end
            value=[str(1:end-1) ']']; 
        end
    elseif iscell(value)
        str='a[';
            for i=1:numel(value)
                if ~ischar(value{i}) && ~isnumeric(value{i})
                    error('not string or numeric in cell')
                end
                if isnumeric(value{i})
                    value{i} = qes.util.num2strCompact(value{i});
                else
                    value{i}=['"' value{i} '"'];
                end
                str=[str  value{i} ','];
            end
            value=[str(1:end-1) ']']; 
	else
        error('type error');
    end
else
    value=['a[' value ']'];
end
%mod = py.importlib.import_module('python.saveJson');  
mod = py.importlib.import_module('+qes.+util.saveJson');  
py.importlib.reload(mod);    
result=cell(mod.func1(fullfilename,fields,value));

if result{1}== 1
%     if isnumeric(value_backup) && numeric(value_backup) == 1
%         qes.util.saveJson(fullfilename,fields,['a[',qes.util.num2strCompact(value_backup,5),']'],true);
%     else
%         if ischar(value_backup)
%             try
%                 value = str2double(value_backup);
%                 if numel(value) == 1 && ~isnan(value)
%                     qes.util.saveJson(fullfilename,fields,['a[',value_backup,']'],true);
%                 end
%             catch
%             end
%         end
%         error('type error');
%     end
%     error('type error');
    if isnumeric(value_backup)
        valueInStr = num2str(value_backup);
    elseif ischar(value_backup)
        valueInStr = value_backup;
    else
        valueInStr = ['of class: ', class(value_backup)];
    end
    if iscell(fields)
        fstr = fields{1};
        for ww = 2:numel(fields)
            fstr = [fstr, '.', fields{ii}];
        end
    else
        fstr = fields;
    end
    msg = sprintf('error at saving value %s to field %s of json file: ',valueInStr, fstr, strrep(fullfilename,'\','\\'));
    throw(MException('QOS_saveJson:typeError',msg))
end
%if result{1}== 2
%    error('not a last layer');
%end
%if result{1}== 3
%    error('not in one row');
%end
if result{1}== 4
    error('index error');
end
if result{1}== 5
    if numel(fields) > 1
        fields = fields(2:end);
        if nargin == 4
            qes.util.saveJson(fullfilename,fields,value_backup,formatedArray);
        else
            qes.util.saveJson(fullfilename,fields,value_backup);
        end
    else
        error('not found');
    end
end


end