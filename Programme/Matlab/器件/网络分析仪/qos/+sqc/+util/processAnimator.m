classdef processAnimator < handle
    % processAnimator animats single qubit quantum process on bloch sphere
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % cell array of single qubit gates, char string of standard
        % gate name(check supportedGates for all supported standard gates)
        % or arbitary rotations around X, Y or Z axis:
        % {'Y', pi/3} is pi/3 rotation around the Y axis
        % example: obj.process = {'H','X2m',{'Y', pi/3},'X',{'Z', -pi/5}}
        process
        % initial qubit state, 1 by 2 array or char string like
        % '|1>', '0.74|0>-0.74i|1>' etc.
        % no need to be normalized,
        % the setter will do the normalization.
        initialState
        drawHistory  % draw trace or not
        showText = true;
        color = [1,0,0] % state arrow color, default red
        title = 'Process Animation'
        resolution = 2*pi/150
        playDuration = 10 % the amount of time in seconds to play the animation for one pass
    end
    properties (Constant = true)
        supportedGates = {'X','X/2','-X/2','X/4','-X/4',...
            'X2p','X2m','X4p','X4m',...
            'Y','Y/2','-Y/2','Y/4','-Y/4',...
            'Y2p','Y2m','Y4p','Y4m',...
            'Z','Z/2','-Z/2','Z2p','Z2m'...
            'H','T'};
    end
    properties (SetAccess = private, GetAccess = private)
        ax
        blochSphere
        gateText
        stateText
        
        numFrames
        frameIdx = 1
        vsTrace
        gnTrace
        stateTrace
        
        playTmr
    end
    methods
        function obj = processAnimator(ax_)
            if nargin ~=0 
                obj.ax = ax_;
            end
            obj.blochSphere = sqc.util.blochSphere(ax_);
            obj.blochSphere.drawHistory = false;
            obj.playTmr = timer('BusyMode','drop','ExecutionMode','fixedRate',...
                'ObjectVisibility','off',...
                'TimerFcn',{@drawFrame});
            function drawFrame(~,~)
                if obj.frameIdx < obj.numFrames
                    obj.blochSphere.addState(obj.vsTrace(:,obj.frameIdx));
                    obj.blochSphere.draw();
                    if obj.showText
                        if ishghandle(obj.gateText)
                            delete(obj.gateText);
                        end
                        if ishghandle(obj.stateText)
                            delete(obj.stateText);
                        end
                        obj.gateText = text(-2.2,-1.2,0,['Gate: ',...
                            obj.gnTrace{obj.frameIdx}],'FontSize',10,'Parent',obj.ax);
                        obj.stateText = text(0.2,-0.1,-1.35,...
                            ['State: ',obj.stateTrace{obj.frameIdx}],'FontSize',10,...
                            'Parent',obj.ax,'Interpreter','tex');
                    end
                    obj.frameIdx = obj.frameIdx + 1;
                else
                    stop(obj.playTmr);
                end
            end
        end
        function set.playDuration(obj,val)
            obj.playDuration = val;
            if isempty(obj.numFrames)
                return;
            end
            isPalying = false;
            if strcmp(obj.playTmr.Running,'on')
                isPalying = true;
                stop(obj.playTmr);
            end
            set(obj.playTmr,'Period',ceil(1000*val/obj.numFrames)/1000);
            if isPalying
                start(obj.playTmr);
            end
        end
        function set.showText(obj,val)
            val = logical(val);
            if val == obj.showText
                return;
            end
            if ~val
                if ishghandle(obj.gateText)
                    delete(obj.gateText);
                end
                if ishghandle(obj.stateText)
                    delete(obj.stateText);
                end
            end
            obj.showText = val;
        end
        function val = get.ax(obj)
            val = obj.blochSphere.ax;
        end
        function set.color(obj,val)
            obj.blochSphere.color = val;
            obj.color = val;
        end
        function set.drawHistory(obj,val)
            obj.blochSphere.drawHistory = val;
        end
        function val = get.drawHistory(obj)
            val = obj.blochSphere.drawHistory;
        end
        function set.process(obj,val)
            if ischar(val)
                val = {val};
            end
            for ii = 1:numel(val)
                if ischar(val{ii}) && ~qes.util.ismember(val{ii},obj.supportedGates) % standard Gates
                    throw(MException('QOS_processAnimator:unsupportedGate',...
                        'at least one of the input gate is not a suppoerted gate, check supportedGates for all supported gates'));
                elseif iscell(val{ii}) && ischar(val{ii}{1}) % arbitary rotation around X, Y, or Z axis with specified angle, {'Y', pi/3} is pi/3 rotation around the Y axis
                    if numel(val{ii}) ~= 2
                        throw(MException('QOS_processAnimator:invalidInput',...
                            'if the input gate is not a suppoerted gate, it should be a rotation around one of X, Y or Z axis with specified rotation angle'));
                    elseif ~isreal(val{ii}{2}) % rotaion angle
                        throw(MException('QOS_processAnimator:invalidInput',...
                            'if the input gate is not a suppoerted gate, it should be a rotation around one of X, Y or Z axis with specified rotation angle'));
                    end
                end
                obj.process = val;
            end
            obj.vsTrace = [];
            obj.gnTrace = [];
            obj.stateTrace = [];
        end
        function set.initialState(obj,val)
            s = sqc.qs.state(val);
            obj.initialState = s.v;
        end
        function play(obj,loop)
            % start run animation
            % loop: run forever or just once(default)
            if nargin == 1
                loop = false;
            end
            obj.prepareAnimationData();
            while 1
                obj.frameIdx = 1;
                start(obj.playTmr);
                if ~loop
                    break;
                end
            end
        end
        function delete(obj)
            stop(obj.playTmr);
            delete(obj.playTmr);
        end
    end
    methods (Access = private)
        function prepareAnimationData(obj)
            if ~isempty(obj.vsTrace)
                return;
            end
            vs = obj.initialState;
            gNames = {''};
            numGates = numel(obj.process);
            rotStep = obj.resolution;
            for ii = 1:numGates
                if ischar(obj.process{ii})
                    gClass = obj.process{ii};
                else
                    gClass = [obj.process{ii}{1},' Rotation'];
                end
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
                    case 'X Rotation'
                        A = obj.process{ii}{2};
                        numSteps = ceil(A/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                        gn = sprintf('%s\\pi X Rotation',qes.util.num2strCompact(A/pi,2));
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{gn}];
                        end
                    case {'X2m','-X/2'}
                        A = -pi/2;
                        numSteps = ceil(abs(A)/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                        end
                        gNames = [gNames,{'-X/2'}];
                    case {'X2p','X/2'}
                        A = pi/2;
                        numSteps = ceil(A/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                        end
                        gNames = [gNames,{'X/2'}];
                    case {'X4m','-X/4'}
                        A = -pi/4;
                        numSteps = ceil(abs(A)/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-1i*sin(theta/2);-1i*sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{'-X/4'}];
                        end
                    case {'X4p','X/4'}
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
                    case 'Y Rotation'
                        A = obj.process{ii}{2};
                        numSteps = ceil(A/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                        gn = sprintf('%s\\pi Y Rotation',qes.util.num2strCompact(A/pi,2));
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{gn}];
                        end
                    case {'Y2m','-Y/2'}
                        A = -pi/2;
                        numSteps = ceil(abs(A)/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{'-Y/2'}];
                        end
                    case {'Y2p','Y/2'}
                        A = pi/2;
                        numSteps = ceil(A/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{'Y/2'}];
                        end
                    case {'Y4m','-Y/4'}
                        A = -pi/4;
                        numSteps = ceil(abs(A)/rotStep);
                        theta = A/numSteps;
                        m = [cos(theta/2),-sin(theta/2);sin(theta/2),cos(theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{'-Y/4'}];
                        end
                    case {'Y4p','Y/4'}
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
                    case 'Z Rotation'
                        A = obj.process{ii}{2};
                        numSteps = ceil(A/rotStep);
                        theta = A/numSteps;
                        m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                        gn = sprintf('%s\\pi Z Rotation',qes.util.num2strCompact(A/pi,2));
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{gn}];
                        end
                    case {'Z2m','-Z/2'}
                        A = -pi/2;
                        numSteps = ceil(abs(A)/rotStep);
                        theta = A/numSteps;
                        m = [exp(-1i*theta/2),0;0,exp(1i*theta/2)];
                        for ii = 1:numSteps
                            vs = [vs,m*vs(:,end)];
                            gNames = [gNames,{'-Z/2'}];
                        end
                    case {'Z2p','Z/2'}
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
                       throw(MException('QOS_processAnimator:invalidInput',...
                            sprintf('unsupported gate %s.',...
                            gClass)));
                end
            end
            states = cell(1,size(vs,2));
            for ii = 1:size(vs,2)
                ang = angle(vs(1,ii));
                a = vs(1,ii)*exp(-1j*ang);
                b = vs(2,ii)*exp(-1j*ang);
                theta = 2*acos(a);
                phi = real(log(b/sin(theta/2))/1j);
                if abs(a) < 0.01
                    states{ii} = '|1>';
                elseif abs(b) < 0.01
                    states{ii} = '|0>';
                else
                    a = qes.util.num2strCompact(real(a),2);
                    if abs(phi) < 0.01
                        b =  qes.util.num2strCompact(abs(b),2);
                    else
                        ba = qes.util.num2strCompact(phi/pi,2);
                        if strcmp(ba,'1') || strcmp(ba,'-1')
                            ba(end) = [];
                        end
                        b =  sprintf('e^{%si\\pi}%s',ba,...
                            qes.util.num2strCompact(abs(b),2));
                    end
                    if qes.util.startsWith(b,'-')
                        states{ii} = sprintf('%sf|0>%s|1>',a,b);
                    else
                        states{ii} = sprintf('%s|0>+%s|1>',a,b);
                    end
                end
            end
            obj.vsTrace = vs;
            obj.gnTrace = gNames;
            obj.stateTrace = states;
            obj.numFrames = numel(obj.stateTrace);
            isPalying = false;
            if strcmp(obj.playTmr.Running,'on')
                isPalying = true;
                stop(obj.playTmr);
            end
            set(obj.playTmr,'Period',ceil(1000*obj.playDuration/obj.numFrames)/1000);
            if isPalying
                start(obj.playTmr);
            end
        end
    end
end
