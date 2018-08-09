function word = Phrase2Word(phrase,separator_list);
% word = Phrase2Word(phrase,separator_list);
%
% transforma o linie in cuvinte separate de separator_list

% ver 0.0 : 09.05.2003, noua (pt ParseSXP in printzip)

if nargin < 2 separator_list = {' '}; end;

phrase = deblank(lower(phrase));
buff = ['']; word = [''];

for i=1:size(phrase,2)
    if ~sum(strcmp(phrase(i), separator_list)) 
        buff = [buff phrase(i)];
        % keep reading
    elseif ~sum(strcmp(buff, separator_list)) 
        word = strvcat(word, deblank(buff)); 
        buff=[];        
    end;
end;

word = strvcat(word, deblank(buff));
