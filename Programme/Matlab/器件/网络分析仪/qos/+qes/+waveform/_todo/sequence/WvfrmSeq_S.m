classdef WvfrmSeq_S < WvfrmSequence
    % waveform sequence formed of a single waveform object, repeat n times.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (SetAccess = private)
        parent
        n % repeat n times
    end
    methods
        function obj = WvfrmSeq_S(Parentwvobj,n)
            if ~isa(Parentwvobj,'Waveform')
                 error('WvfrmSeq_DS:InvalidInput','Parentwvobj is not a valid Waveform class object');   
            end
            if isempty(Parentwvobj.awg) || ~isa(Parentwvobj.awg,'AWG')...
                    ||~IsValid(Parentwvobj.awg)
                error('WvfrmSeq_DS:InvalidInput','awg of Parentwvobj not set or not valid');   
            end
            if isempty(Parentwvobj.awgchnl)
                error('WvfrmSeq_DS:InvalidInput','awgchnl of Parentwvobj not set'); 
            end
            n = round(n);
            if n <= 1
                error('WvfrmSeq_DS:InvalidInput','n < 2'); 
            end
            obj = obj@WvfrmSequence();
            obj.parent = deepcopy(Parentwvobj);
            NewWave = obj.parent;
            NewWave.name = [NewWave.name,'_sq'];
            obj.waveforms = NewWave;
            obj.n = n;
            obj.waveformnames = [];
            for ii = 1:n
                obj.waveformnames = [obj.waveformnames,{NewWave.name}];
            end
        end
        function AddWaveform(obj,waveforms)
            % overwrite the super class method.
            warnning('WvfrmSeq_DS:AddWaveform','AddWaveform method is disabled for class WvfrmSeq_S');
        end
        obj.waveformnames
    end
end