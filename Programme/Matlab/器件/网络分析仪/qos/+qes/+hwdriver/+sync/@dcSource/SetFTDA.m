function  SetFTDA( obj,val,chnl )
% val=(-2^19,2^19)
if val<=-2^19 || val>=2^19
error('dc value is beyond the range')
end
% DA_value=fix(2^19-0.6/2^15*val*2^19/7);
DA_value=fix(2^19-val);
% obj.Open();
i=1;
result=1;
while result
    fclose(obj.interfaceobj);
    fopen(obj.interfaceobj)
    str=sprintf('DA=%d;RW=1;ADDR=0x01;VAL=0x%05X',chnl,DA_value);
    fprintf(obj.interfaceobj, str);%写一次
    fclose(obj.interfaceobj);%和CPU中的关闭配合成对出现
    fopen(obj.interfaceobj)
    str=sprintf('DA=%d;RW=0;ADDR=0x01;VAL=0x%05X',chnl,DA_value);
    fprintf(obj.interfaceobj, str);%读一次
    val_readout= fscanf(obj.interfaceobj,'%s',7);
    fclose(obj.interfaceobj);;%和CPU中的关闭配合成对出现

    str = sprintf('0x%05X',DA_value);
    if (~isempty(val_readout) && strcmp(str,val_readout))
        result=0;
        fclose(obj.interfaceobj);
    else
        result=1;
    %     obj.err_cnt = obj.err_cnt+1;
%         disp('SetValule error occured\n');
        i=i+1;
    end
    if i>3
        fclose(obj.interfaceobj);
        error('SetValule error occured\n');
    end
    pause(0.5);
end

% obj.Close();

end


