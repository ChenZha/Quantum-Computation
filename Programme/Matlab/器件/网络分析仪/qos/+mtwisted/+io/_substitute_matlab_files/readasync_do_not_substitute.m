function readasync(obj, numBytes)
    % a simplified version of readasync for speed
    % all checkings are removed

    % Copyright 2016 Yulin Wu, USTC
    % mail4ywu@gmail.com/mail4ywu@icloud.com

    % Call the java readasync method.
    try
        readasync(igetfield(obj, 'jobject'), numBytes);
    catch aException
        throw(MException('instrument:readasync:opfailed', aException.message));
    end
end

% the following is matlab original

% function readasync(obj, varargin)
% %READASYNC Read data asynchronously from instrument.
% %
% %   READASYNC(OBJ) reads data asynchronously from the instrument
% %   connected to interface object, OBJ. READASYNC returns control
% %   to MATLAB immediately.  
% %
% %   The data read is stored in the input buffer. The BytesAvailable
% %   property indicates the number of bytes stored in the input
% %   buffer. 
% %
% %   For serial port, VISA-serial and TCPIP objects, READASYNC will stop 
% %   reading data when one of the following occurs:
% %       1. The terminator is received as specified by the Terminator 
% %          property.
% %       2. A timeout occurs as specified by the Timeout property
% %       3. The input buffer is filled 
% % 
% %   For GPIB, VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, VISA-TCPIP, VISA-USB
% %   and VISA-RSIB objects, READASYNC will stop reading data when one of the
% %   following occurs:
% %       1. The EOI line is asserted 
% %       2. The terminator is received as specified by the EOSCharCode
% %          property (if defined). This option is not available for 
% %          VISA-RSIB objects.
% %       3. A timeout occurs as specified by the Timeout property
% %       4. The input buffer is filled
% %
% %   For UDP objects, READASYNC blocks until one of the following occurs:
% %       1. The terminator is received as specified by the terminator
% %          property (if DatagramTerminateMode is off).
% %       2. A datagram has been received (if DatagramTerminateMode is on).
% %       3. A timeout occurs as specified by the Timeout property.
% %
% %   The interface object must be connected to the instrument with the 
% %   FOPEN function before any data can be read from the instrument 
% %   otherwise an error is returned. A connected interface object has 
% %   a Status property value of open. 
% %
% %   For GPIB, VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, VISA-TCPIP and VISA-USB
% %   objects, the terminator is defined by setting OBJ's EOSMode property to
% %   read and setting OBJ's EOSCharCode property to the ASCII code for the
% %   character received. For example, if the EOSMode property is set 
% %   to read and the EOSCharCode property is set to 10, then one of
% %   the ways that the read terminates is when the linefeed character 
% %   is received. A terminator cannot be defined for VISA-RSIB objects.
% %
% %   READASYNC(OBJ, SIZE) reads at most SIZE bytes from the instrument.
% %   If SIZE is greater than the difference between OBJ's InputBufferSize
% %   property value and OBJ's BytesAvailable property value an error will
% %   be returned.
% %
% %   The TransferStatus property indicates the type of asynchronous 
% %   operation that is in progress.
% %
% %   For all objects, an error is returned if READASYNC is called while 
% %   an asynchronous read is in progress. For serial port and VISA-serial
% %   objects, an asynchronous write can occur while an asynchronous read
% %   is in progress. For GPIB, VISA-GPIB, VISA-VXI, VISA-GPIB-VXI, VISA-TCPIP,
% %   VISA-USB, TCPIP and UDP objects, an error is returned if data is
% %   written before the asynchronous read operation completes. For VISA-RSIB
% %   objects, data cannot be read asynchronously.
% %
% %   The STOPASYNC function can be used to stop an asynchronous read
% %   operation.
% %
% %   Example:
% %       s = serial('COM1', 'InputBufferSize', 5000);
% %       fopen(s);
% %       fprintf(s, 'Curve?');
% %       readasync(s);
% %       data = fread(s, 2500);
% %       fclose(s);
% %      
% %   See also ICINTERFACE/FOPEN, ICINTERFACE/STOPASYNC, INTRUMENT/PROPINFO,
% %   INSTRHELP.
% %
% 
% %   MP 12-30-99
% %   Copyright 1999-2011 The MathWorks, Inc. 
% %   $Revision: 1.1.6.2 $  $Date: 2011/05/13 18:05:58 $
% 
% % Error checking.
% if (nargin > 2)
%     error(message('instrument:readasync:invalidSyntax'));
% end
% 
% if ~isa(obj, 'icinterface')
%     error(message('instrument:readasync:invalidOBJ'));
% end
% 
% if length(obj) > 1
%     error(message('instrument:readasync:invalidOBJ'));
% end
% 
% switch nargin
% case 2
%     numBytes = varargin{1};
%     if ~isa(numBytes, 'double')
%         error(message('instrument:readasync:invalidSIZEdboule'));
%     elseif length(numBytes) > 1
%         error(message('instrument:readasync:invalidSIZEscalar'));
%     elseif (numBytes <= 0)
%         error(message('instrument:readasync:invalidSIZEpos'));
%     elseif (isinf(numBytes))
%         error(message('instrument:readasync:invalidSIZEinf'));
%     elseif (isnan(numBytes))
%         error(message('instrument:readasync:invalidSIZEnan'));
%     end
% end
% 
% % Get the java object.
% jobject = igetfield(obj, 'jobject');
% 
% % Call the java readasync method.
% try
%     readasync(jobject, varargin{:});
% catch aException
%     newExc = MException('instrument:readasync:opfailed', aException.message);
%     throw(newExc);
% end
