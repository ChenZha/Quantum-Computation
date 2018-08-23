function WriteLog(ip,data)
    fid = fopen('log.txt','a+');
    str = [datestr(now),' ','ip:',ip,' ','data:',num2str(data)];
    fseek(fid,0,'eof');
    fprintf(fid,'%s\n',str);
    fclose(fid);
end

