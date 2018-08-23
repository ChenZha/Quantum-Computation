function varargout = Tomo_1QProcess_animation(varargin)
% demonstration of state tomography on single qubit.
% state tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that state tomography is working properly.
% prepares a a state(options are: '|0>', '|1>','|0>+|1>','|0>-|1>','|0>+i|1>','|0>-i|1>')
% and do state tomography.
%
% <_o_> = Tomo_1QProcess_animation('qubit',_c|o_,...
%       'process',<_c_>,'numPts',_i_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a|b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    R = measure.stateTomography(q);
    
    isXhPi = false;
    switch args.process
        case {'X'}
            if strcmp(q.g_XY_impl,'pi')
                p = gate.X(q);
            else
                p = gate.X2p(q);
                isXhPi = true;
            end
        case {'Y'}
            if strcmp(q.g_XY_impl,'pi')
                p = gate.Y(q);
            else
                p = gate.Y2p(q);
                isXhPi = true;
            end
        case {'-Y/2','Y2m'}
            p = gate.Y2m(q);
        case {'Y/2','Y2p'}
            p = gate.Y2p(q);
        case {'X/2','X2p'}
            p = gate.X2p(q);
        case {'-X/2','X2m'}
            p = gate.X2m(q);
        case 'H'
            p = [];
        otherwise
            throw(MException('Tomo_1QProcess_animation:unsupportedGate',...
                sprintf('available process options for singleQProcessTomo is %s, %s given.',...
                '''X'',''Y'',''X/2'',''-X/2'',''Y/2'',''-Y/2'',''H''',args.process)));
    end
    R.setProcess(p);
    h = qes.ui.qosFigure(sprintf('State tomography | %s', q.name),false);
    ax = axes('parent',h);
    blochSphere = sqc.util.blochSphere(ax);
    blochSphere.drawHistory = true;
    blochSphere.showMenubar = true;
    blochSphere.showToolbar = true;
%     blochSphere.historyMarkerSize = 6;
    blochSphere.historyMarker = 'o';
    if strcmp(args.process,'H')
        args.numPts = 4*ceil(args.numPts/4);
        Y4p = gate.Y4p(q);
        amps1 = linspace(0,Y4p.amp,args.numPts/4);
        Y4p.amp = 0;
        if strcmp(q.g_XY_impl,'pi')
            X = gate.X(q);
            amps2 = linspace(0,X.amp,args.numPts/2);
            X.amp = 0;
        else
            X = gate.X2p(q);
            amps2 = linspace(0,X.amp,args.numPts/2);
            X.amp = 0;
        end
        Y4m = gate.Y4m(q);
        amps3 = linspace(0,Y4m.amp,args.numPts/4);
        Y4m.amp = 0;
    else
        amps = linspace(0,p.amp,args.numPts);
    end
    data = NaN(3,args.numPts);
    for ii = 1:args.numPts
        
        if isXhPi
            p.amp = amps(ii);
            R.setProcess(p*p);
        elseif strcmp(args.process,'H')
            if ii <= args.numPts/4
            	Y4m.amp = amps1(ii);
            elseif ii <= 3*args.numPts/4
                Y4m.amp = amps1(end);
                X.amp = amps2(ii- args.numPts/4);
            else
                X.amp = amps2(end);
                Y4p.amp = amps3(ii - 3*args.numPts/4);
            end
            if ii == args.numPts
                Y4p.amp = amps3(end);
            end
            if strcmp(q.g_XY_impl,'pi')
                p = Y4m*X*Y4p;
            else
                p = Y4m*X*X*Y4p;
            end
            R.setProcess(p);
        else
            p.amp = amps(ii);
        end
        P = R();
        % data(:,ii) = P*[-1;1]; % {'Y2m','X2p','I'}
        data(:,ii) = P*[-1;1]; % {'Y2p','X2m','I'}, |0> state on +z direction 
        blochSphere.addStateXYZ(data(1,ii),data(2,ii),data(3,ii),1,true);
        drawnow();
    end

    if args.save
        QS = qes.qSettings.GetInstance();
        dataPath = QS.loadSSettings('data_path');
        timeStamp = datestr(now,'_yymmddTHHMMSS_');
        dataFileName = ['STomo1_',q.name,timeStamp,'.mat'];
        figFileName = ['STomo1_',q.name,timeStamp,'.fig'];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        save(fullfile(dataPath,dataFileName),'data','args','sessionSettings','hwSettings');
        if isgraphics(ax)
            saveas(ax,fullfile(dataPath,figFileName));
        end
    end
    varargout{1} = data;
end