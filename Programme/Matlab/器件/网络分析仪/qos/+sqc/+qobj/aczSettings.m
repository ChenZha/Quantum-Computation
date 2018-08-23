classdef aczSettings < handle
    properties
        key
        typ
		aczLn
		amp
        ampInDetune@logical scalar = false;
		thf
		thi
		lam2
		lam3
        qubits
		dynamicPhases
        detuneFreq
        detuneLonger
		padLn
    end
    methods
        function obj = aczSettings(k)
            obj.key = k;
        end
        function load(obj)
            QS = qes.qSettings.GetInstance();
			scz = QS.loadSSettings({'shared','g_cz',obj.key});
            fn = fieldnames(scz);
			for ii = 1:numel(fn)
				obj.(fn{ii}) = scz.(fn{ii});
            end
        end
    end
    methods(Hidden = true)
        function b = eq(obj1, obj2)
            b = strcmp(obj1.key, obj2.key);
        end
    end
end