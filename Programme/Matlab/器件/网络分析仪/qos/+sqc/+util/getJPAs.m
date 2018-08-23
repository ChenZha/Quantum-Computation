function varargout  = getJPAs(args,jpaNames)
    % get jpa by name
    
    % Yulin Wu, 2017/2/20
    
    jpas = sqc.util.loadJPAs();
    num_fields = numel(jpaNames);
    for ii = 1:num_fields
        if ~isfield(args,jpaNames{ii}) || ~qes.util.ismember(args.(jpaNames{ii}),jpas)
            ME = MException('getJPAs:inValidInput',...
				sprintf('%s is not specified or not one of the selected jpas.',jpaNames{ii}));
            ME.throwAsCaller();
        end
		if isa(args.(jpaNames{ii}),'sqc.qobj.qobject') % already a jpa object, return itself
			varargout{ii} = args.(jpaNames{ii});
		else
			varargout{ii} = jpas{qes.util.find(args.(jpaNames{ii}),jpas)};
		end
    end
end