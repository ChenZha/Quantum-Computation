classdef WvfrmSeq_DS < WvfrmSequence
    % waveform sequence derived from a single waveform object.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (SetAccess = private)
        parent
        proplst
    end
    properties
        propvals
    end
    properties (SetAccess = private, GetAccess = private)
        propertynames
        propertygettyp
        propertygetidx
    end
    methods
        function obj = WvfrmSeq_DS(Parentwvobj,Proplst)
            if ~isa(Parentwvobj,'Waveform')
                 error('WvfrmSeq_DS:InvalidInput','Parentwvobj is not a valid Waveform class object');   
            end
%             if isempty(Parentwvobj.awg) || ~isa(Parentwvobj.awg,'AWG')...
%                     ||~IsValid(Parentwvobj.awg)
%                 error('WvfrmSeq_DS:InvalidInput','awg of Parentwvobj not set or not valid');   
%             end
%             if isempty(Parentwvobj.awgchnl)
%                 error('WvfrmSeq_DS:InvalidInput','awgchnl of Parentwvobj not set'); 
%             end
            if ischar(Proplst)
                Proplst = {Proplst};
            end
            NumProplst = length(Proplst);
            propertynames = cell(1,NumProplst);
            propertygettyp = cell(1,NumProplst);
            propertygetidx = cell(1,NumProplst);
            for ii = 1:NumProplst
                if ~ischar(Proplst{ii})
                    error('WvfrmSeq_DS:InvalidInput',...
                    'proplst should be a cell array of character strings');
                end
                propertynames{ii} = strsplit(Proplst{ii},'.');
                for jj = 1:length(propertynames{ii})
                    pnamewithidx = propertynames{ii}{jj};
                    [sidx,eidx] = regexp(strrep(pnamewithidx,' ',''),'{\d+}');
                    NI = numel(sidx);
                    if NI
                        if NI > 1
                            error('ExpParam:InvalidInput',...
                            'propertyname is not a valid property name of expobj!');
                        end
                        propertynames{ii}{jj} = pnamewithidx(1:sidx-1);
                        propertygettyp{ii}{jj} = 2; % cell
                        propertygetidx{ii}{jj} = str2double(pnamewithidx(sidx+1:eidx-1));
                    else
                        [sidx,eidx] = regexp(strrep(pnamewithidx,' ',''),'\(\d+\)');
                        NI = numel(sidx);
                        if NI
                            if NI > 1
                                error('ExpParam:InvalidInput',...
                                'propertyname is not a valid property name of expobj!');
                            end
                            propertynames{ii}{jj} = pnamewithidx(1:sidx-1);
                            propertygettyp{ii}{jj} = 1; % matrix
                            propertygetidx{ii}{jj} = str2double(pnamewithidx(sidx+1:eidx-1));
                        else
                            propertynames{ii}{jj} = pnamewithidx;
                            propertygettyp{ii}{jj} = 0; % no idxing
                            propertygetidx{ii}{jj} = NaN;
                        end
                    end
                    if jj == 1
                        OBJ = Parentwvobj;
                    end
                    if ~isprop(OBJ, propertynames{ii}{jj})
                        error('ExpParam:InvalidInput',...
                        'propertyname is not a valid property name of expobj!');
                    end
                    switch propertygettyp{ii}{jj}
                        case 0
                            OBJ = OBJ.(propertynames{ii}{jj});
                        case 1
                            OBJ = OBJ.(propertynames{ii}{jj})(propertygetidx{ii}{jj});
                        case 2
                            OBJ = OBJ.(propertynames{ii}{jj}){propertygetidx{ii}{jj}};
                    end
                end
            end
            obj = obj@WvfrmSequence();
            obj.parent = Parentwvobj;
            obj.proplst = Proplst;
            obj.propertynames = propertynames;
            obj.propertygettyp = propertygettyp;
            obj.propertygetidx = propertygetidx;
        end
        function AddWaveform(obj,waveforms)
            % overwrite the super class method.
            warnning('WvfrmSeq_DS:AddWaveform','AddWaveform method is disabled for class WvfrmSeq_DS');
        end
        function set.propvals(obj,val)
            sz = size(val);
            if ~iscell(val)
                if sz(1) > 1 && sz(2) > 1 % maxtrix
                    error('WvfrmSeq_DS:SetError','propvals is not cell');
                else % array, convert to cell
                    val = {val};
                end
            end
            sz = size(val);
            if sz(1) > 1 && sz(2) > 1 % maxtrix
                error('WvfrmSeq_DS:SetError','propvals is not a cell array');
            end
            NumValCells = length(val);
            if  NumValCells ~= length(obj.proplst)
                error('WvfrmSeq_DS:SetError','number of propvals not equal to number of proplst');
            end
            ln = ones(1,NumValCells);
            for ii = 1:NumValCells
                ln(ii) = length(val{ii});
            end
            if length(unique(ln)) > 1
                error('WvfrmSeq_DS:SetError','propvals are not of the same length');
            end
            if ln(1) == 0
                error('WvfrmSeq_DS:SetError','propval empty');
            end
            obj.propvals = val;
        end
        function SendWave(obj)
            if isempty(obj.proplst)
                error('WvfrmSeq_DS:SendWaveError','proplst empty');
            end
            if ~IsValid(obj)
                error('WvfrmSeq_DS:SendWaveError','the object or some of its properties are not valid anymore');
            end
            NumProps = length(obj.proplst);
            NewWaveforms = [];
            for ii = 1:length(obj.propvals{1})
                NewWaveform = deepcopy(obj.parent); % deepcopy is Wavefrom class method
                NewWaveform.name = [NewWaveform.name,'_',num2str(ii,'%05.0f')];
                for jj = 1:NumProps
                    OBJ = NewWaveform;
                    Nsub = numel(obj.propertynames{jj});
                    for kk = 1:Nsub
                        if kk == Nsub
                            switch obj.propertygettyp{jj}{kk}
                                case 0
                                    OBJ.(obj.propertynames{jj}{kk}) = obj.propvals{jj}(ii);
                                case 1
                                    OBJ.(obj.propertynames{jj}{kk})(obj.propertygetidx{jj}{kk}) = obj.propvals{jj}(ii);
                                case 2
                                    OBJ.(obj.propertynames{jj}{kk}){obj.propertygetidx{jj}{kk}} = obj.propvals{jj}(ii);
                            end
                        else
                            switch obj.propertygettyp{jj}{kk}
                                case 0
                                    OBJ = OBJ.(obj.propertynames{jj}{kk});
                                case 1
                                    OBJ = OBJ.(obj.propertynames{jj}{kk})(obj.propertygetidx{jj}{kk});
                                case 2
                                    OBJ = OBJ.(obj.propertynames{jj}{kk}){obj.propertygetidx{jj}{kk}};
                            end
                        end
                    end
                end
                NewWaveforms = [NewWaveforms,NewWaveform];
            end
            obj.waveforms = NewWaveforms;
%             NewWaveforms(1).awg = obj.parent.awg;
%             NewWaveforms(1).awgchnl = obj.parent.
            obj.waveformnames = [];
            for ii = 1:length(obj.waveforms)
                obj.waveformnames = [obj.waveformnames,{obj.waveforms(ii).name}];
            end
            SendWave@WvfrmSequence(obj);
        end
        function bol = IsValid(obj)
            bol = true;
            if ~isvalid(obj) || ~IsValid(obj.parent)
                bol = false;
            end
        end
    end
end