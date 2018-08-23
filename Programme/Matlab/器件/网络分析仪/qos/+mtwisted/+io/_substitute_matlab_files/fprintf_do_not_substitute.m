function fprintf(obj, cmd, mode)
    % send out txt string
    % mode 0, syncronized
    % mode 1, asyncronized

    % a simplified version of fprintf for speed
    % all checkings are removed

    % Copyright 2016 Yulin Wu, USTC
    % mail4ywu@gmail.com/mail4ywu@icloud.com

    % Call the fprintf java method.
    try
       fprintf(igetfield(obj, 'jobject'), cmd, mode);
    catch aException
        throw(MException('instrument:fprintf:opfailed', aException.message));
    end
end


% the following is matlab original

% function fprintf(obj, varargin)
% %FPRINTF Write text to instrument.
% %
% %   FPRINTF(OBJ,'CMD') writes the string, CMD, to the instrument
% %   connected to interface object, OBJ. OBJ must be a 1-by-1 
% %   interface object.
% %
% %   The interface object must be connected to the instrument with the 
% %   FOPEN function before any data can be written to the instrument
% %   otherwise an error is returned. A connected interface object has 
% %   a Status property value of open.
% %
% %   FPRINTF(OBJ,'FORMAT','CMD') writes the string CMD, to the instrument
% %   connected to interface object, OBJ, with the format, FORMAT. By
% %   default, the %s\n FORMAT string is used. The SPRINTF function is 
% %   used to format the data written to the instrument.
% % 
% %   For serial port, VISA-serial, TCPIP and UDP objects, each occurrence
% %   of \n in CMD is replaced with OBJ's Terminator property value. When
% %   using the default FORMAT, %s\n, all commands written to the instrument
% %   will end with the Terminator value.
% %
% %   For GPIB, VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, VISA-TCPIP and VISA-USB
% %   objects, each occurrence of \n in CMD is replaced with OBJ's
% %   EOSCharCode property value if OBJ's EOSMode property is configured to
% %   either write or read&write.
% %
% %   For VISA-RSIB objects, each occurrence of \n in CMD is ignored.
% %
% %   FORMAT is a string containing C language conversion specifications. 
% %   Conversion specifications involve the character % and the conversion 
% %   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. See the SPRINTF
% %   file I/O format specifications or a C manual for complete details.
% %
% %   FPRINTF(OBJ, 'CMD', 'MODE')
% %   FPRINTF(OBJ, 'FORMAT', 'CMD', 'MODE') writes data asynchronously
% %   to the instrument when MODE is 'async' and writes data synchronously
% %   to the instrument when MODE is 'sync'. By default, the data is 
% %   written with the 'sync' MODE, meaning control is returned to  
% %   the MATLAB command line after the specified data has been written  
% %   to the instrument or a timeout occurs. When the 'async' MODE is 
% %   used, control is returned to the MATLAB command line immediately 
% %   after executing the FPRINTF function. 
% %
% %   OBJ's TransferStatus property will indicate if an asynchronous 
% %   write is in progress.
% %
% %   OBJ's ValuesSent property will be updated by the number of values 
% %   written to the instrument.
% %
% %   If OBJ's RecordStatus property is configured to on with the RECORD
% %   function, the data written to the instrument will be recorded in
% %   the file specified by OBJ's RecordName property value.
% %
% %   Example:
% %       s = serial('COM1');
% %       fopen(s);
% %       fprintf(s, 'Freq 2000');
% %       fclose(s);
% %       delete(s);
% %
% %   See also ICINTERFACE/FOPEN, ICINTERFACE/STOPASYNC, ICINTERFACE/FWRITE, 
% %   ICINTERFACE/QUERY, ICINTERFACE/RECORD, INSTRUMENT/PROPINFO, INSTRHELP,
% %   SPRINTF.
% %
% 
% %   MP 7-13-99
% %   Copyright 1999-2011 The MathWorks, Inc. 
% %   $Revision: 1.1.6.2 $  $Date: 2011/05/13 18:05:48 $
% 
% % Error checking.
% if ~isa(obj, 'icinterface')
%     error(message('instrument:fprintf:invalidOBJInterface'));
% end
% 
% if length(obj)>1
%     error(message('instrument:fprintf:invalidOBJDim'));
% end
% 
% % Parse the input.
% switch (nargin)
% case 1
%    error(message('instrument:fprintf:invalidSyntaxCmd'));
% case 2
%    % Ex. fprintf(obj, cmd); 
%    cmd = varargin{1};
%    format = '%s\n';
%    mode = 0;
% case 3
%    % Original assumption: fprintf(obj, format, cmd); 
%    [format, cmd] = deal(varargin{1:2});
%    mode = 0;
%    if ~(isa(cmd, 'char') || isa(cmd, 'double'))
% 	   error(message('instrument:fprintf:invalidArg'));
%    end
%    
%    if strcmpi(cmd, 'sync') 
%        % Actual: fprintf(obj, cmd, mode);
%        mode = 0;
%        cmd = format;
%        format = '%s\n';
%    elseif strcmpi(cmd, 'async') 
%        % Actual: fprintf(obj, cmd, mode);
%        mode = 1;
%        cmd = format;
%        format = '%s\n';
%    end
% case 4
%    % Ex. fprintf(obj, format, cmd, mode); 
%    [format, cmd, mode] = deal(varargin{1:3}); 
%    
%    if ~ischar(mode)
% 	   error(message('instrument:fprintf:invalidMODE'));
%    end
%    
%    switch lower(mode)
%    case 'sync'
%        mode = 0;
%    case 'async'
%        mode = 1;
%    otherwise
% 	   error(message('instrument:fprintf:invalidMODE'));
%    end
% otherwise
%    error(message('instrument:fprintf:invalidSyntaxRet'));
% end   
% 
% % Error checking.
% if ~isa(format, 'char')
% 	error(message('instrument:fprintf:invalidFORMATstring'));
% end
% if ~(isa(cmd, 'char') || isa(cmd, 'double'))
% 	error(message('instrument:fprintf:invalidCMD'));
% end
% 
% % Format the string.
% [formattedCmd, errmsg] = sprintf(format, cmd);
% if ~isempty(errmsg)
%     error(message('instrument:fprintf:invalidFormat', errmsg));
% end
% 
% % Call the fprintf java method.
% try
%    fprintf(igetfield(obj, 'jobject'), formattedCmd, mode);
% catch aException
%     newExc = MException('instrument:fprintf:opfailed', aException.message);
%     throw(newExc);
% end
