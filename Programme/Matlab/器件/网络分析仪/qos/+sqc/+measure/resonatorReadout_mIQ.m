classdef resonatorReadout_mIQ < sqc.measure.resonatorReadout
    % resonator readout multiple qubits, return IQ modulus of a single state
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    methods
        function obj = resonatorReadout_mIQ(q)
            obj = obj@sqc.measure.resonatorReadout(q,false,true);
            obj.numericscalardata = true;
            obj.name =  '|IQ|';
        end
        function Run(obj)
			Run@sqc.measure.resonatorReadout(obj);
            obj.data = mean(abs(obj.extradata));
        end
    end
end