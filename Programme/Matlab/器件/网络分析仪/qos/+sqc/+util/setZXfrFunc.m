function setZXfrFunc(q,xfrFunc)
% Yulin Wu, 17/10/05

    if ischar(q)
        q = sqc.util.qName2Obj(q);
    end
    da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                         'name',q.channels.z_pulse.instru);
    z_daChnl = da.GetChnl(q.channels.z_pulse.chnl);
    z_daChnl.xfrFunc = xfrFunc;
    disp('xfrFunc set.');
end