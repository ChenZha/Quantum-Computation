function HWUSBATT(db)

Obj=serial('com3','baudrate',9600,'parity','none','databits',8,'stopbits',1);
fopen(Obj);

fwrite(Obj,255*16*16+db,'uint16')

fclose(Obj);

end