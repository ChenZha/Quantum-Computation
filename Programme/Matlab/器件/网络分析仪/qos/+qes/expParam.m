classdef (Sealed = true) expParam < qes.qHandle
    % Experimental paramter

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        val % value of the experimental parameter
        % value offset, the real value is offset+val
        % setting a non zero offset is usefull in some cases, example:
        % suppose expobj.prop = 1; now we want sweep expobj.prop in a small
        % range [1-d, 1+d], d<<1, in a regular way one can use:
        % sweepobj.val = linspace(1-d, 1+d,50); % 
        % or one can use:
        % expParam.offset = 1;
        % sweepobj.val = linspace(-d, d,50); % this is better than
        % linspace(1-d, 1+d,50) when data is plotted
        offset = 0 
        snap_val
        % cell array of function handles, after setting of val, these
        % functions are executed in order. all callbacks takes the object
        % as argument
        callbacks
        deferCallbacks = false; % if true, call of callbacks are deferred till explicitly called later.
        % auxilary parameter, typically a object to implement some function
        % by callbacks, for example:
        % auxpara = ASampleHeaterObject; callbacks = {@(x) x.auxpara.Run};
        auxpara
    end
    properties (SetAccess = private)
        expobj % Instrument class objects or Waveforms class object
        fcnval % function output argument in case of isfunction
        propertyname % char, property name of expobj, or number of output arguments in case of isfunction
    end
    properties (SetAccess = private, GetAccess = private)
        isfunction = false;
        propertynames
        propertygettyp
        propertygetidx
        callbacksCalled
        
        nargsout
    end
    
    methods
        function obj = expParam(expobj,propertyname)
            % expobj, intrument class object or waveform class object
            % propertyname, the name of the property to be abstracted as an
            % experimental parameter.
            % in case of isfunction, propertyname is the number of output
            % arguments, default 0
            % examples:
            % ExpParam_flx_icm_ext = expParam(ISOURCE1,'dcval');
            % ExpParam_ZDvPlsAmp = expParam(ZDrvPulse,'waveform2.amp');
            % complex cases like the following are allowed:
            % ExpParam_xxx = expParam(xxx,'pa.pb{3}.pc.pd(2)');
            obj = obj@qes.qHandle('');
            if isa(expobj,'function_handle')
                obj.expobj = expobj;
                obj.isfunction = true;
                if nargin == 1
                    propertyname = false;
                end
                obj.propertyname = logical(propertyname);
                return;
            end
            if ~ischar(propertyname)
                error('expParam:InvalidInput',...
                'propertyname should be a character string!');
            end
            propertynames = strsplit(propertyname,'.');
            propertygettyp = {};
            propertygetidx = {};
            for jj = 1:length(propertynames)
                pnamewithidx = propertynames{jj};
                [sidx,eidx] = regexp(strrep(pnamewithidx,' ',''),'{\d+}');
                NI = numel(sidx);
                if NI
                    if NI > 1
                        errstr = sprintf('propertyname %s is not a valid property name of a(n) %s class object!',propertynames{jj},class(OBJ));
                        error('expParam:InvalidInput', errstr);
                    end
                    propertynames{jj} = pnamewithidx(1:sidx-1);
                    propertygettyp{jj} = 2; % cell
                    propertygetidx{jj} = str2double(pnamewithidx(sidx+1:eidx-1));
                else
                    [sidx,eidx] = regexp(strrep(pnamewithidx,' ',''),'\(\d+\)');
                    NI = numel(sidx);
                    if NI
                        if NI > 1
                            errstr = sprintf('propertyname %s is not a valid property name of a(n) %s class object!',propertynames{jj},class(OBJ));
                            error('expParam:InvalidInput', errstr);
                        end
                        propertynames{jj} = pnamewithidx(1:sidx-1);
                        propertygettyp{jj} = 1; % matrix
                        propertygetidx{jj} = str2double(pnamewithidx(sidx+1:eidx-1));
                    else
                        propertynames{jj} = pnamewithidx;
                        propertygettyp{jj} = 0; % no idxing
                        propertygetidx{jj} = NaN;
                    end
                end
                if jj == 1
                    OBJ = expobj;
                end
                if ~isprop(OBJ, propertynames{jj})
                    errstr = sprintf('propertyname %s is not a valid property name of a(n) %s class object!',propertynames{jj},class(OBJ));
                    error('expParam:InvalidInput', errstr);
                end
                switch propertygettyp{jj}
                    case 0
                        OBJ = OBJ.(propertynames{jj});
                    case 1
                        OBJ = OBJ.(propertynames{jj})(propertygetidx{jj});
                    case 2
                        OBJ = OBJ.(propertynames{jj}){propertygetidx{jj}};
                end
            end
            obj.expobj = expobj;
            obj.propertyname = propertyname;
            obj.propertynames = propertynames;
            obj.propertygettyp = propertygettyp;
            obj.propertygetidx = propertygetidx;
        end
        function set.callbacks(obj, val)
            if ~iscell(val)
                val = mat2cell(val);
            end
            for ii = 1:length(val)
                if ~isa(val{ii}, 'function_handle')
                    error('expParam:InvalidInput',...
                    'some callbacks are not valid funcion handles.');
                end
            end
            obj.callbacks = val;
        end
        function set.val(obj,val)
            if ~obj.callbacksCalled
                throw(MException('QOS_expParam:lastCallbackNotFinished',...
                    'last RunCallbacks not finised yet.'));
            else
                obj.callbacksCalled = false;
            end
            val = val + obj.offset; % add offset
            if ~isempty(obj.snap_val) % snap to snap_val if needed
                val = obj.snap_val*round(val/obj.snap_val);
            end
            OBJ = obj.expobj;
            if obj.isfunction
                if obj.propertyname
                    obj.fcnval = OBJ(val);
                else
                    OBJ(val);
                end
            else
                Nsub = numel(obj.propertynames);
                for kk = 1:Nsub
                    if kk == Nsub
                        switch obj.propertygettyp{kk}
                            case 0
                                OBJ.(obj.propertynames{kk}) = val;
                            case 1
                                OBJ.(obj.propertynames{kk})(obj.propertygetidx{kk}) = val;
                            case 2
                                OBJ.(obj.propertynames{kk}){obj.propertygetidx{kk}} = val;
                        end
                    else
                        switch obj.propertygettyp{kk}
                            case 0
                                OBJ = OBJ.(obj.propertynames{kk});
                            case 1
                                OBJ = OBJ.(obj.propertynames{kk})(obj.propertygetidx{kk});
                            case 2
                                OBJ = OBJ.(obj.propertynames{kk}){obj.propertygetidx{kk}};
                        end
                    end
                end
            end
            obj.val = val;
            if ~obj.deferCallbacks
                qes.expParam.RunCallbacks(obj);
            end
        end
        function val = get.val(obj)
            if isempty(obj.val)
                val = [];
                return;
            end
            if obj.isfunction
                val = obj.val - obj.offset;
                return;
            end
            OBJ = obj.expobj;
            Nsub = numel(obj.propertynames);
            for kk = 1:Nsub
                if kk == Nsub
                    switch obj.propertygettyp{kk}
                        case 0
                            val = OBJ.(obj.propertynames{kk});
                        case 1
                            val = OBJ.(obj.propertynames{kk})(obj.propertygetidx{kk});
                        case 2
                            val = OBJ.(obj.propertynames{kk}){obj.propertygetidx{kk}};
                    end
                else
                	switch obj.propertygettyp{kk}
                        case 0
                            OBJ = OBJ.(obj.propertynames{kk});
                        case 1
                            OBJ = OBJ.(obj.propertynames{kk})(obj.propertygetidx{kk});
                        case 2
                            OBJ = OBJ.(obj.propertynames{kk}){obj.propertygetidx{kk}};
                    end
                end
            end
            val = val - obj.offset;
        end
        %function SetAuxpara(obj,val) % for functional programming
        %    obj.auxpara  = val;
        %end
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            if obj.isfunction
                return;
            end
            if ~isvalid(obj.expobj) 
                bol = false;
                return;
            end
        end
    end
    methods (Static = true)
        function RunCallbacks(obj)
            for ii = 1:numel(obj.callbacks)
                % do not use cellfun, cellfun function does not perform
                % the calls in a specific order(cellfun doc).
                % here execution order is important.
                try
					feval(obj.callbacks{ii},obj);
                catch
                    kkk = 1;
                end
            end
            obj.callbacksCalled = true;
        end
    end
end