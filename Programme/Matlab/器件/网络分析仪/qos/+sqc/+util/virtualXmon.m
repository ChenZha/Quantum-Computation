function q = virtualXmon()
% creates virtual Xmon qubits

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    q = sqc.qobj.xmon();
    q.name = 'virtualQubit';
    addprop(q,'r_avg');
    addprop(q,'r_jpa_pumpPower');
    addprop(q,'r_jpa_biasAmp');
    addprop(q,'r_jpa_pumpFreq');
    addprop(q,'r_jpa_pumpAmp');
    addprop(q,'r_amp');
    addprop(q,'r_ln');
    addprop(q,'r_fc');
    addprop(q,'r_freq');
    addprop(q,'r_uSrcPower');
    addprop(q,'r_iq2prob_center0');
    addprop(q,'r_iq2prob_center1');
    addprop(q,'r_iq2prob_center2');
    addprop(q,'r_iq2prob_intrinsic');
    addprop(q,'r_jpa');
    addprop(q,'r_truncatePts');
    addprop(q,'r_wvTyp');
    q.r_wvTyp = 'rr_ring';
    addprop(q,'r_wvSettings');
    addprop(q,'syncDelay_r');
    q.syncDelay_r = [0,0];
    addprop(q,'r_jpa_longer');
    q.r_jpa_longer = 0;
    addprop(q,'r_iq2prob_fidelity');
    q.r_iq2prob_fidelity = [1,1];
end