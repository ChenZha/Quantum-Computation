function args_out = processArgs(args_in,add_args)
    % example:
    % args_in = {'arg1', 1, 'arg2', 200, 'arg3', '|q1>', 'arg4', true};
    % args_out = processArgs(args_in); % returns the following struct:
    % args_out = 
    %    arg1: 1
    %    arg2: 200
    %    arg3: '|q1>'
    %    arg4: 1
    % non existing fields can be added with add_args, in case of the above: 
    % args_out = processArgs(args_in,{'addedField1', val1, 'addedField2', val2}); 
    % returns the following struct:
    % args_out = 
    %           arg1: 1
    %           arg2: 200
    %           arg3: '|q1>'
    %           arg4: 1
    %	 addedField1: val1
    %	 addedField2: val2
    % this is usefull in adding default values to fields that is not
    % specified by user.

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if ~iscell(args_in)
        error('args_in not a cell array.');
    end
    if mod(numel(args_in),2)
        error('args_in can not form pairs.')
    end
    args_in = reshape(args_in(:)',2,[]);
    if ~all(cellfun(@isvarname,args_in(1,:)))
        error('invalid property name(s).');
    end
    for ii = 1:size(args_in,2)
        args_out.(args_in{1,ii}) = args_in{2,ii};
    end
    % add defaults:
    if ~isfield(args_out,'gui') 
        args_out.gui = false;
    end
    if ~isfield(args_out,'notes') 
        args_out.notes = '';
    end
    if nargin > 1
        add_args_s = qes.util.processArgs(add_args);
        fieldNames = fieldnames(add_args_s);
        for ii = 1:size(fieldNames,1)
            if ~isfield(args_out,fieldNames{ii})
                args_out.(fieldNames{ii}) = add_args_s.(fieldNames{ii});
            end
        end
    end
end