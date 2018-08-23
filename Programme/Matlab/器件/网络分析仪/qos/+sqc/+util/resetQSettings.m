function resetQSettings()

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


    choice  = questdlg('Reset all qubit settings?','Reset all qubit settings?',...
            'Yes','No','No');
    if isempty(choice) || strcmp(choice, 'No')
        return;
    end
    
    
    qubits = [];
    try
        S = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_resetQSettings:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    s = S.loadSSettings();
    if isempty(s)
        return;
    end
    fnames = fieldnames(s);
    num_fields = numel(fnames);
    for ii = 1:num_fields
        if ismember(fnames{ii},{'public','data_path'}) ||...
                ~isstruct(s.(fnames{ii}))
            continue;
        end
        qs = s.(fnames{ii});
        if ~isfield(qs,'type') || ~strcmp(qs.type,'qubit')
            continue;
        end
%         doTheReset(fnames{ii});
        try
            doTheReset(fnames{ii});
        catch
        end
    end
    
    
end

function doTheReset(qName)

% todo: fail when one key value is empty

    import sqc.util.setQSettings;
    
	setQSettings('f01',6e9,qName);
	setQSettings('f02',11.5e9,qName);
	
	setQSettings('g_I_ln',0,qName);
	setQSettings('g_X_amp','',qName);
	setQSettings('g_X2m_amp','',qName);
	setQSettings('g_X2p_amp','',qName);
	setQSettings('g_X4m_amp','',qName);
	setQSettings('g_X4p_amp','',qName);
	setQSettings('g_XY_4m_amp','',qName);
	setQSettings('g_XY_4p_amp','',qName);
	setQSettings('g_XY_ln','',qName);
	setQSettings('g_XY_phaseOffset',0,qName);
	setQSettings('g_XY2_ln','',qName);
	setQSettings('g_XY4_ln','',qName);
	setQSettings('g_XY12_amp','',qName);
	setQSettings('g_XY12_ln','',qName);
	setQSettings('g_Y_amp','',qName);
	setQSettings('g_Y2m_amp','',qName);
	setQSettings('g_Y2p_amp','',qName);
	setQSettings('g_Y4m_amp','',qName);
	setQSettings('g_Y4p_amp','',qName);
	setQSettings('g_Z_amp','',qName);
	setQSettings('g_Z_z_ln','',qName);
	
	setQSettings('g_Z2_z_ln','',qName);
	setQSettings('g_Z2m_z_amp','',qName);
	setQSettings('g_Z2p_z_amp','',qName);
	setQSettings('notes','',qName);
	
	setQSettings('qr_xy_dragAlpha',0,qName);
	setQSettings('qr_xy_dragPulse',true,qName);
	setQSettings('qr_xy_fc','',qName);
    setQSettings('qr_xy_uSrcPower',0,qName);
	
	setQSettings('qr_z_amp2f01','',qName);
	setQSettings('qr_z_amp2f02','',qName);
	
	setQSettings('r_amp','',qName);
	setQSettings('r_avg',500,qName);
	setQSettings('r_fc','',qName);
	setQSettings('r_fr','',qName);
	setQSettings('r_freq','',qName);
	setQSettings('r_jpa','',qName);
	setQSettings('r_jpa_biasAmp',0,qName);
	setQSettings('r_jpa_delay',0,qName);
	setQSettings('r_jpa_longer',0,qName);
	setQSettings('r_jpa_pumpAmp','',qName);
	setQSettings('r_jpa_pumpFreq','',qName);
	setQSettings('r_jpa_pumpPower','',qName);
	setQSettings('r_ln','',qName);
	setQSettings('r_truncatePts',[0,0],qName);
	setQSettings('r_uSrcPower',0,qName);
	setQSettings('r_iq2prob_center0',0,qName);
	setQSettings('r_iq2prob_center1',0,qName);
	setQSettings('r_iq2prob_center2',0,qName);
	setQSettings('r_iq2prob_fidelity',[1,1],qName);
	setQSettings('r_iq2prob_intrinsic',true,qName);
	
	setQSettings('spc_biasRise',1,qName);
	setQSettings('spc_driveAmp','',qName);
	setQSettings('spc_driveLn','',qName);
	setQSettings('spc_driveRise',1,qName);
	setQSettings('spc_sbFreq','',qName);
	
	setQSettings('syncDelay_r',[0,0],qName);
	setQSettings('syncDelay_xy',[0,0],qName);
	setQSettings('syncDelay_z',0,qName);
	
	setQSettings('t_rrDipFWHM_est','',qName);
	setQSettings('t_spcFWHM_est','',qName);
	
	setQSettings('t_zAmp2freqFreqSrchRng','',qName);
	setQSettings('t_zAmp2freqFreqStep','',qName);

	setQSettings('zdc_amp',0,qName);
	setQSettings('zdc_amp2f01','',qName);
	setQSettings('zdc_amp2f02','',qName);
	setQSettings('zdc_amp2fFreqRng','',qName);
	setQSettings('zdc_ampCorrection','',qName);
	setQSettings('zdc_settlingTime',0,qName);
	setQSettings('zpls_amp2f01Df','',qName);
	setQSettings('zpls_amp2f02Df','',qName);
    setQSettings('zpls_amp2fFreqRng','',qName);
    
    setQSettings('T1','',qName);
	setQSettings('T2','',qName);
end