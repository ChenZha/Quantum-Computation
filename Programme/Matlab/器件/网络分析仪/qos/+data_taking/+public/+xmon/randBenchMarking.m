function varargout = randBenchMarking(varargin)
% randBenchMarking
% process options are: 'X','Z','Y','X/2','-X/2','Y/2','-Y/2', 'CZ'
%
% <_o_> = randBenchMarking('qubit1',_c|o_,'qubit2',<_c|o_>,...
%       'process',<_c_>,'numGates',[_i_],'numReps',_i_,...
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
	
	qRegs = sqc.qobj.qRegisters.GetInstance();
	qRegs.reloadAllQubits(); 

    args = util.processArgs(varargin,{'doCalibration',false,'state','|0>','reps',1,'gui',false,'notes','','detuning',0,'save',true});
    if isempty(args.qubit2)
        q = data_taking.public.util.getQubits(args,{'qubit1'});
        figTitle = q.name;
    else
        [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});
        q = {q1,q2};
        figTitle = [q1.name,',',q2.name];
    end

    if numel(q) == 1
        switch args.process
            case 'I'
                p = gate.I(q);
            case 'X'
                p = gate.X(q);
            case 'Y'
                p = gate.Y(q);
            case {'X/2','X2p'}
                p = gate.X2p(q);
            case {'Y/2','Y2p'}
                p = gate.Y2p(q);
            case {'-X/2','X2m'}
                p = gate.X2m(q);
            case {'-Y/2','Y2m'}
                p = gate.Y2m(q);
            case {'Z'}
                p = gate.Z(q);
            otherwise
                throw(MException('randBenchMarking:unsupportedGate',...
                    sprintf('available process options is %s, %s given.',...
                    '''X'',''Z'',''Y'',''X/2'',''-X/2'',''Y/2'',''-Y/2'' for single qubit.',args.process)));
        end
    else
        switch args.process
            case {'CZ'}
                p = gate.CZ(q{1},q{2});
            case {'Cluster'}
                q{1}.cz_impl = 'Cluster';
                q{2}.cz_impl = 'Cluster';
                p = gate.CZ(q{1},q{2});
            otherwise
                throw(MException('randBenchMarking:unsupportedGate',...
                    sprintf('available process options is %s, %s given.',...
                    '''CZ'' for two qubits',args.process)));
        end
    end
	
    N = numel(args.numGates);
    Pref =  zeros(1,N);
    Pgate = zeros(1,N);
    ax = NaN;

    Pref = NaN(args.numReps,N); 
    Pgate = NaN(args.numReps,N);
    Gates = cell(N,args.numReps,2);
	if numel(q) == 1
		dataFileName = ['RB_',q.name,datestr(now,'_yymmddTHHMMSS_'),'.mat'];
	else
		dataFileName = ['RB_',q1.name,q2.name,datestr(now,'_yymmddTHHMMSS_'),'.mat'];
	end
    QS = qes.qSettings.GetInstance();
    dataPath = QS.loadSSettings('data_path');
    sessionSettings = QS.loadSSettings;
    hwSettings = QS.loadHwSettings;
    for ii = 1:N
%         if args.doCalibration
%             q_ = q;
%             if ~iscell(q_)
%                 q_ = {q_};
%             end
%             for cc = 1:numel(q_)
%                 data_taking.public.xmon.tuneup.iq2prob_01(...
%                     'qubits',q_{cc},'numSamples',1e4,'gui',false,'save',true);
%             end
%         end
        if numel(q) == 2 && strcmp(q{1}.cz_impl,'Cluster')
            R = measure.randBenchMarking(q,p,args.numGates(ii),args.numReps,false,'CZ');
        else
            R = measure.randBenchMarking(q,p,args.numGates(ii),args.numReps);
        end
        data = R();
        Pref(:,ii) = data(:,1);
        Pgate(:,ii) = data(:,2);

        % C2Gates = sqc.measure.randBenchMarking.C2Gates();
        % C2Gates(Gates{n,k,1}) is the reference gate
        % series of the kth random series of n th Cliford Gates
        % C2Gates(Gates{n,k,2}) is the interleaved gate
        % series of the kth random series of n th Cliford Gates
        % to count CZ gates(in nth gate reference):
        % g1_ref = cell2mat(Gates(n,:,1).');
        % czCount = zeros(1,size(g1_ref,1));
        % for ii = 1:size(g1_ref,1)
        %     for jj = 1:size(g1_ref,2)
        %         g = C2Gates{g1_ref(ii,jj)};
        %         for kk = 1: length(g)
        %             if ischar(g{kk})
        %                 czCount(ii) = czCount(ii) + 1;
        %             end
        %         end
        %     end
        % end
        
        Gates(ii,:,:) = R.extradata;

        if args.gui
            if ~ishghandle(ax)
                h = qes.ui.qosFigure(sprintf('Randomized Benchmarking | %s:%s', figTitle,args.process),false);
                ax = axes('parent',h);
            end
            try
                plot(ax,args.numGates(1:ii),mean(Pref(:,1:ii),1),'b-s');
                hold(ax,'on');
                plot(ax,args.numGates(1:ii),mean(Pgate(:,1:ii),1),'r-s');
                hold(ax,'off');
            catch
            end
            xlabel(ax,'number of gates');
            if numel(q) == 1
                ylabel(ax,'P|0>');
            else
                ylabel(ax,'P|00>');
            end
            legend(ax,{'reference','interleaved'});
            drawnow;
        end
        if args.save
            save(fullfile(dataPath,dataFileName),'Pref','Pgate','Gates','args','sessionSettings','hwSettings');
            try
            if args.gui && isgraphics(h)
                figFileName = [dataFileName(1:end-3),'fig'];
                saveas(h,fullfile(dataPath,figFileName));
            end
            catch
            end
        end
    end

    varargout{1} = Pref;
    varargout{2} = Pgate;
end