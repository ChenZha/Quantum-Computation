function varargout = f01DcTuningBySpc(varargin)
% tune qubit f01 to a desired frequency by changing dc bias with spectroscopy measurement
%
% <_f_> = f01DcTuningBySpc('qubit',_c&o_,...
%       'f01',_f_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.
    
    % Yulin Wu, 2017/3/4
    
    import data_taking.public.xmon.spectroscopy1_zdc
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(getQubits(args,{'qubit'})); % we may need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.
	
	
	if ischar(args.save)
        args.save = false;
        choice  = qes.ui.questdlg_timer(600,'Update settings?','Save options','Yes','No','Yes');
%         choice  = questdlg('Update settings?','Save options',...
%                 'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
	if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'f01'},f01(end));
        QS.saveSSettings({q.name,'zdc_amp'},dcAmp(end));
		QS.saveSSettings({q.name,'zdc_ampCorrection'},dcAmp(end)-dcAmp(1)+q.zdc_ampCorrection);
		QS.saveSSettings({q.name,'zpls_amp2f01Df'},[]);
		QS.saveSSettings({q.name,'zpls_amp2f02Df'},[]);
    end
	
	varargout{1} = dcAmp(end);
    varargout{2} = f01(end);
end
