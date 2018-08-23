function bol = identicalArray(a, b)
% check two arrays are identical or not, elements should have eq methods

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	bol = true;
	numA = numel(a);
	numB = numel(b);
	if numA ~=numB
		bol = false;
		return;
	end
    if iscell(a)
		if ~iscell(b)
			bol = false;
			return;
		end
		for ii = 1:numB
			if ~qes.util.ismember(b{ii},a)
				bol = false;
				return;
			end
		end
	else
		if iscell(b)
			bol = false;
			return;
		end
		for ii = 1:numB
			if all(b(ii)~=a)
				bol = false;
				return;
			end
		end
	end
end