function [input]=showRB2Gates(m,n,r,show)
% m: number of gates
% n: nth random sequence
% r = 1, reference
% r = 2, interleaved

if nargin<4
    show=0;
end
C2Gates=sqc.measure.randBenchMarking.C2Gates();
Gates=evalin('base','Gates');
cGates=C2Gates(Gates{m,n,r});
pGates=cGates{1};
rGates=cGates{2};
Q1Gates={'Q1:'};
Q2Gates={'Q2:'};
input='';

for ww = 1:numel(cGates)
    pGates = cGates{ww};
    for II=1:numel(pGates)
        if iscell(pGates{II})
            numG=max(numel(pGates{II}{1}),numel(pGates{II}{2}));
            Q1Gates=[Q1Gates, repmat({''},[1,numG-numel(pGates{II}{1})]),pGates{II}{1}];
            Q2Gates=[Q2Gates, repmat({''},[1,numG-numel(pGates{II}{2})]),pGates{II}{2}];
            input=[input '('];
            for JJ=1:numel(pGates{II}{1})-1
                input=[input pGates{II}{1}{JJ} '1*'];
            end
            input=[input pGates{II}{1}{end} '1).*('];
            for JJ=1:numel(pGates{II}{2})-1
                input=[input pGates{II}{2}{JJ} '2*'];
            end
            input=[input pGates{II}{2}{end} '2)'];
        elseif strcmp(pGates{II},'CZ')
            Q1Gates=[Q1Gates, 'CZ'];
            Q2Gates=[Q2Gates, 'CZ'];
            input=[input '*CZ*'];
        end
    end
    if ww < numel(cGates)
        input=[input '*'];
    end
end

% for II=1:numel(rGates)
%     if iscell(rGates{II})
%         numG=max(numel(rGates{II}{1}),numel(rGates{II}{2}));
%         Q1Gates=[Q1Gates, repmat({''},[1,numG-numel(rGates{II}{1})]),rGates{II}{1}];
%         Q2Gates=[Q2Gates, repmat({''},[1,numG-numel(rGates{II}{2})]),rGates{II}{2}];
%         input=[input '('];
%         for JJ=1:numel(rGates{II}{1})-1
%             input=[input rGates{II}{1}{JJ} '1*'];
%         end
%         input=[input rGates{II}{1}{end} '1).*('];
%         for JJ=1:numel(rGates{II}{2})-1
%             input=[input rGates{II}{2}{JJ} '2*'];
%         end
%         input=[input rGates{II}{2}{end} '2)'];
%     elseif strcmp(rGates{II},'CZ')
%         Q1Gates=[Q1Gates, 'CZ'];
%         Q2Gates=[Q2Gates, 'CZ'];
%         input=[input '*CZ*'];
%     end
% end
if show
    nG=numel(Q1Gates);
    figure;
    xlim([0,nG+0.5])
    ylim([0.5,2.5])
    text([1:nG],1*ones(1,nG),Q1Gates)
    text([1:nG],2*ones(1,nG),Q2Gates)
    box on;
    grid on;
end

end