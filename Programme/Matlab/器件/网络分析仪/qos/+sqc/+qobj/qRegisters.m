classdef qRegisters < handle
	%
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

% how to use:
% qRegs = sqc.qobj.qRegisters.GetInstance();
% q1 = qRegs.get('q1');
%
% before running a script, it is recommended to relaod all qubits: 
% qRegs = sqc.qobj.qRegisters.GetInstance();
% qRegs.reloadAllQubits();

    properties (GetAccess = private, SetAccess = private)
        qubitNames = {}
		qubits ={}
    end
	methods
		function obj = get(this,qubitName)
			index = qes.util.find(qubitName, this.qubitNames);
			if ~isempty(index)
				obj = this.qubits{index};
				if isvalid(obj)
					return;
				else
					this.qubitNames(index) = [];
					this.qubits(index) = [];
				end
			end
			this.qubits(end+1) = {sqc.util.qName2Obj(qubitName)};
			this.qubitNames(end+1) = {qubitName};
			obj = this.qubits{end};
		end
		function reloadQubit(this,qubitName)
			index = qes.util.find(this.qubitName, this.qubitNames);
			if ~isempty(index)
				this.qubitNames(index) = [];
				this.qubits(index) = [];
			end
		end
		function reloadAllQubits(this)
			% will be reloaded upon next get
			this.qubitNames = {};
			this.qubits ={};
		end
	end
    methods (Access = private)
        function obj = qRegisters()
        end
    end
    methods (Static)
        function obj = GetInstance()
            persistent instance;
            if ~isempty(instance) &&  isvalid(instance)
                obj = instance;
                return;
			end
            instance = sqc.qobj.qRegisters();
            obj = instance;
        end
    end
end