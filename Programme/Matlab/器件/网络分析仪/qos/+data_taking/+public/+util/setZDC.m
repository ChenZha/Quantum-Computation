function setZDC(qubits,dcLevel)
% dcLevel the dc value to set, if ommitted, the value of zdc_amp in
% registry is set

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    if ~iscell(qubits)
        qubits = {qubits};
    end
    for ii = 1:numel(qubits)
        if ischar(qubits{ii})
            q = sqc.util.qName2Obj(qubits{ii});
        else
            q = qubits{ii};
        end
        dcSrc = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.z_dc.instru);
        dcChnl = dcSrc.GetChnl(q.channels.z_dc.chnl);
        if nargin == 2 && ~isempty(dcLevel)
            dcChnl.dcval = dcLevel;
        else
            dcChnl.dcval = q.zdc_amp;
        end
    end
end