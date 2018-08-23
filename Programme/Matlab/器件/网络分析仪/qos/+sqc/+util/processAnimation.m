function processAnimation(gates,initialState)
    % ...

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    rotStep = 2*pi/100;
    if nargin < 2
        initialState = sqc.qs.state('|0>');
    else
        if ~isa(initialState,'sqc.qs.state')
            throw(MException('QOS_processAnimation:invalidInput','initialState not a quantum state'));
        end
    end
    state = initialState;
    vs = initialState.v;
    gNames = {''};
    numGates = numel(gates);
    for ii = 1:numGates
        if ~isa(gates{ii},'sqc.op.logical.operator') &&...
               ~isa(gates{ii},'sqc.op.physical.operator')
           throw(MException('QOS_processAnimation:invalidInput',...
               'gates not a cell array of quantum operators'));
        end
        if isa(gates{ii},'sqc.op.physical.operator') &&...
               isempty(gates{ii}.logical_op)
           throw(MException('QOS_processAnimation:invalidInput',...
               'at least one of the gates is a physical gate without logical gate'));
        end
        if isa(gates{ii},'sqc.op.physical.operator')
            gates{ii} = gates{ii}.logical_op;
        end
        if gates{ii}.dim > 1
            throw(MException('QOS_processAnimation:invalidInput',...
               sprintf('processAnimation only handles one qubit process, at least one gate is a %0.0f qubit gate.',...
               gates{ii}.dim)));
        end
        gClass = class(gates{ii});
        idx = strfind(gClass,'.');
        gClass = gClass(idx(end)+1:end);
        switch gClass
            case 'X'
                A = pi;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'X'}];
                end
            case 'X2m'
                A = -pi/2;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                end
                gNames = [gNames,{'-X/2'}];
            case 'X2p'
                A = pi/2;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                end
                gNames = [gNames,{'X/2'}];
            case 'X4m'
                A = -pi/4;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'-X/4'}];
                end
            case 'X4p'
                A = pi/4;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'X/4'}];
                end
            case 'Y'
                A = pi;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'Y'}];
                end
            case 'Y2m'
                A = -pi/2;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'-Y/2'}];
                end
            case 'Y2p'
                A = pi/2;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'Y/2'}];
                end
            case 'Y4m'
                A = -pi/4;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'-Y/4'}];
                end
            case 'Y4p'
                A = pi/4;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'Y/4'}];
                end
            case 'Z'
                A = pi;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'Z'}];
                end
            case 'Z2m'
                A = -pi/2;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'-Z/2'}];
                end
            case 'Z2p'
                A = pi/2;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'Z/2'}];
                end
            case 'H'
                % Y4m(qubit)*X(qubit)*Y4p(qubit)
                A = pi/4;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'H'}];
                end
                A = pi;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'H'}];
                end
                A = -pi/4;
                numSteps = ceil(abs(A)/rotStep);
                theta = A/numSteps;
                m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'H'}];
                end
            case 'T'
                A = pi/4;
                numSteps = ceil(A/rotStep);
                theta = A/numSteps;
                m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                for ii = 1:numSteps
                    vs = [vs,m*vs(:,end)];
                    gNames = [gNames,{'T'}];
                end
                
            otherwise
               throw(MException('QOS_processAnimation:invalidInput',...
                    sprintf('unsupported gate %s.',...
                    class(gates{ii}))));
        end
            
    end
%     vs = [vs,vs(:,end),vs(:,end),vs(:,end),vs(:,end),vs(:,end),...
%         vs(:,end),vs(:,end),vs(:,end),vs(:,end),vs(:,end),...
%         vs(:,end),vs(:,end),vs(:,end),vs(:,end),vs(:,end)];
    
    vs = [vs,vs(:,end)];
    gNames = [gNames,gNames(end)];
    states = cell(1,size(vs,2));
    for ii = 1:size(vs,2)
        a = angle(vs(1,ii));
        theta = 2*acos(vs(1,ii)*exp(-1j*a));
        phi = log((vs(2,ii)*exp(-1j*a))/sin(theta/2))/1j;
        vs(:,ii) = [real(theta);real(phi)];
        
%         a = vs(1,ii)*exp(-1j*a);
%         b = vs(2,ii)*exp(-1j*a);
%         if a < 0.01
%             states{ii} = '|1>';
%         elseif b < 0.01
%             states{ii} = '|0>';
%         else
%             a = qes.util.num2strCompact(a);
%             b = qes.util.num2strCompact(b);
%             if qes.util.startsWith(b,'-')
%                 states{ii} = sprintf('%sf|0>%s|1>',a,b);
%             else
%                 states{ii} = sprintf('%s|0>+%s|1>',a,b);
%             end
%         end
    end
    
    persistent fpos
    if isempty(fpos)
        fpos = [0,0,700,700];
    end
    
    hf = qes.ui.qosFigure('Prcocess Animation',false);
    set(hf,'ToolBar','none','MenuBar','none','Position',[0,0,800,800]);
    ax = axes('Parent',hf,'Position',[-0.25,-0.25,1.5,1.5]);
    while 1
    for ii = 1:size(vs,2)
%         ax = qes.ui.blochSpherePlot(ax, vs(1,ii:-1:max(ii-15,1)), vs(2,ii:-1:max(ii-15,1)));
        try
            fpos = get(hf,'Position');
            ax = qes.ui.blochSpherePlot(ax, vs(1,ii), vs(2,ii));
        catch
            if ~isvalid(ax)
                hf = qes.ui.qosFigure('Prcocess Animation',false);
                set(hf,'ToolBar','none','MenuBar','none','Position',fpos);
                ax = axes('Parent',hf,'Position',[-0.25,-0.25,1.5,1.5]);
                ax = qes.ui.blochSpherePlot(ax, vs(1,ii), vs(2,ii));
            end
        end
%         if ii > 1
%         ax = qes.ui.blochSpherePlot_t(ax, vs(1,ii), vs(2,ii),'replot');
%         else
%             ax = qes.ui.blochSpherePlot_t(ax, vs(1,ii), vs(2,ii));
%         end
        text(-2.2,-1.2,0,['Gate: ',gNames{ii}],'FontSize',16,'Parent',ax);
%        text(0,0,0,['State: ',states{ii}],'FontSize',16,'Parent',ax);
        drawnow;
%         pause(0.002);
    end
    end
end
