classdef (Abstract = true) tomography < qes.measurement.measurement
    % tomography
	% data: m^n by 2^n, m, number of tomography operations, n, number of qubits
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


% 
%             if ~isempty(scz.dynamicPhase)
%                 q1.g_XY_phaseOffset = q1.g_XY_phaseOffset + scz.dynamicPhase(1);
%                 q2.g_XY_phaseOffset = q2.g_XY_phaseOffset + scz.dynamicPhase(2);
%             end

	properties
        delay = 8; % idle length before measurement operations, non negative integers
		showProgress@logical scalar = true; % print measurement progress to command window or not
		progInfoPrefix = ''
	end
	properties (SetAccess = private)
		isParallel@logical scalar = false; % joint(multi-qubit) tomography or parallel(single-qubit) tomography
		qubits
    end
    properties (GetAccess = private, SetAccess = private)
		readoutGates
		process % for process tomography
        R
        numReadouts
    end
    methods
        function obj = tomography(qubits, readoutGates,isParallel)
            obj = obj@qes.measurement.measurement([]);
			if nargin > 2
				obj.isParallel = isParallel;
            end
			import sqc.op.physical.gate.*
			if ~iscell(qubits)
                qubits = {qubits};
            end
            numTomoQs = numel(qubits);
            for ii = 1:numTomoQs
                if ischar(qubits{ii})
                    qubits{ii} = sqc.util.qName2Obj(qubits{ii});
				end
            end
			obj.qubits = qubits;
			obj.readoutGates = cell(1,numTomoQs);
            obj.numReadouts = numel(readoutGates);
            for ii = 1:obj.numReadouts
                readoutGates{ii} = str2func(['@(q)sqc.op.physical.gate.',readoutGates{ii},'(q)']);
            end
			
			for ii = 1:numTomoQs
                for jj = 1:obj.numReadouts
                    % in looper, the last element is swept first(the inner most loop index)
                    obj.readoutGates{numTomoQs-ii+1}{jj} = feval(readoutGates{jj},obj.qubits{ii});
                end
            end
            obj.numericscalardata = false;
			obj.R = sqc.measure.resonatorReadout(obj.qubits,~isParallel,false);
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
			if obj.isParallel
                obj.runParallel();
			else
				obj.runJoint();
			end
        end
    end
	methods(Access = private)
		function runJoint(obj)
			numTomoQs = numel(obj.qubits);
			lpr = qes.util.looper_(obj.readoutGates);
			data = nan*ones(obj.numReadouts^numTomoQs,2^numTomoQs);
			numShots = obj.numReadouts^numTomoQs;
            if obj.delay > 0
                delayI = sqc.op.physical.gate.I(obj.qubits{1});
                delayI.ln = obj.delay;
            end
			idx = 0;
			while true
				idx = idx + 1;
				if obj.showProgress
					disp(sprintf('%sTomography: %0.0f of %0.0f',...
						obj.progInfoPrefix, idx-1, numShots));
				end
				rGates = lpr();
				if isempty(rGates)
					break;
                end
%                 if numTomoQs == 1 &&...
%                     isa(rGates{1},'sqc.op.physical.gate.XY_base')
%                     rGates{1}.phaseOffset = obj.xyGatePhaseOffset;
%                 end
                
        
				P = rGates{1};
				for ii = 2:numTomoQs
					P = P.*rGates{ii};
                end
                if obj.delay > 0
                    P = delayI*P;
                end
				if ~isempty(obj.process)
					P = obj.process*P;
                end
				obj.R.delay = P.length;
				P.Run();
				data(idx,:) = obj.R();
			end
            obj.data = data;
			obj.dataready = true;
		end
		function runParallel(obj)
			numTomoQs = numel(obj.qubits);
			data = nan(numTomoQs,2,obj.numReadouts);
            if obj.delay > 0
                delayI = sqc.op.physical.gate.I(obj.qubits{1});
                delayI.ln = obj.delay;
            end
			for ii = 1:obj.numReadouts
				if obj.showProgress
					disp(sprintf('%sTomography: %0.0f of %0.0f',...
						obj.progInfoPrefix, ii, obj.numReadouts));
				end
				opLn = 0;
				P = obj.readoutGates{1}{ii};
				for jj = 2:numTomoQs
					P = P.*obj.readoutGates{jj}{ii};
				end
				if obj.delay > 0
					P = delayI*P;
				end
				if ~isempty(obj.process)
					P = obj.process*P;
                end
				obj.R.delay = P.length;
				P.Run();
				data(:,:,ii) = obj.R();
			end

            obj.data = data;
			obj.dataready = true;
		end
	end
	methods(Hidden = true)
		function setProcess(obj,p)
			% for process tomography
			if ~isempty(p) && ~isa(p,'sqc.op.physical.operator')
				throw(MException('QOS_stateTomography:invalidInput',...
						'the input is not a valid quantum operator.'));
            end
            % this ristriction is remved for conditions like a two qubit
            % process but read only one of the qubit
% 			if ~qes.util.identicalArray(p.qubits,obj.qubits)
% 				throw(MException('QOS_stateTomography:differentQubtSet',...
% 						'the input process acts on a different qubit set than the state tomography qubits.'));
% 			end
			obj.process = p;
		end
	end
end