classdef Oscilloscope < qes.hwdriver.sync.instrument
    % Temporary Oscilloscope driver for IQ readout, basic.
    % Currently support Tek DPO7040C Digital Phosphor Oscilloscope only.

% Copyright 2016 Yarui_Zheng, Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% zhengyarui@iphy.ac.cn,mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (Access = private)
        uihandles
    end
    properties  
        samplerate % unit : samples per second
        acqlength % record length.
        acqduration % timebase duration.
        horizontalscale % unit : second per division
        horizontalposition % horizontalposition is from 0 to¡Ö100 and is the
                           % position of the trigger point on the screen 
                           % (0 = left edge, 100 = right edge)
                           % POSITION=10 sets the trigger position of the waveform such that
                           % 10% of the display is to the left of the trigger position.
                           
        acquisitionmode % SAMple|PEAKdetect|HIRes|AVErage|WFMDB|ENVelope
        acquisitionnumavg % Average number of Average Acquisition Mode
        acquisitionstopafter % RUNSTop|SEQuence for Run/Stop|Single Sequence
        acquisitionstate % <NR1>|OFF|ON|RUN|STOP
        
        
        measurementgating % ON|OFF|<NR1>|ZOOM<x>|CURSor 
                          % <NR1>= 0 turns off measurement gating; any other value turns on measurement
        measure1
        measure2
    end
    
    properties %Fast Frame Group
        fastframecount % frame count
        fastframemaxframes % Rea Only. the maximum number of FastFrame frames
                  % which can be acquired at the current frame length
        fastframerefsource % FastFrame Reference waveform source
        fastframeselectedsource % FastFrame source waveform
        fastframesequence % {FIRst|LAST}
                          % FastFrame single-sequence mode stop condition
                          % FIRstsets single sequence to stop after n frames.
                          % LASTsets single sequenceto stop manually.
        fastframesingleframemath % {ON|OFF|1|0|true|false}
        fastframesixteenbit % {ON|OFF|1|0|true|false}
        fastframestate % state of FastFrame acquisition
        fastframesumframe % {NONe|AVErage|ENVelope}
                          % summary frame mode
    end
    methods % Fast Frame Group
        function val = get.fastframecount(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'HORizontal:FASTframe:COUNt?'));
        end
        function set.fastframecount(obj,val)
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:COUNt ' num2str(val)]);
            pause(0.005)
            actualcount = str2double(query(obj.interfaceobj,'HORizontal:FASTframe:COUNt?'));
            if actualcount ~= val
                warning(['Oscilloscope_Temp: The actual Fast Frame count ('...
                    num2str(actualcount) ')is diffrent from the setting value(' ...
                    num2str(val) ')' ]);
            end
        end
        function val = get.fastframemaxframes(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'HORizontal:FASTframe:MAXFRames?'));
        end
        function val = get.fastframerefsource(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:REF:SOUrce?');
            val = str(1:end-1);
        end
        function set.fastframerefsource(obj,val)
            switch lower(val)
                case {'chanel1','chanel 1','ch1'}
                    str = 'CH1';
                case {'chanel2','chanel 2','ch2'}
                    str = 'CH2';
                case {'chanel3','chanel 3','ch3'}
                    str = 'CH3';
                case {'chanel4','chanel 4','ch4'}
                    str = 'CH4';
                case {'math1','math 1','m1'}
                    str = 'MATH1';
                case {'math2','math 2','m2'}
                    str = 'MATH2';
                case {'math3','math 3','m3'}
                    str = 'MATH3';
                case {'math4','math 4','m4'}
                    str = 'MATH4';
                otherwise
                    error('Oscilloscope_Temp: Unknow reference source!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:REF:SOUrce ' str]);
        end
        function val = get.fastframeselectedsource(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:SELECTED:SOUrce?');
            val = str(1:end-1);
        end
        function set.fastframeselectedsource(obj,val)
            switch lower(val)
                case {'chanel1','chanel 1','ch1'}
                    str = 'CH1';
                case {'chanel2','chanel 2','ch2'}
                    str = 'CH2';
                case {'chanel3','chanel 3','ch3'}
                    str = 'CH3';
                case {'chanel4','chanel 4','ch4'}
                    str = 'CH4';
                case {'math1','math 1','m1'}
                    str = 'MATH1';
                case {'math2','math 2','m2'}
                    str = 'MATH2';
                case {'math3','math 3','m3'}
                    str = 'MATH3';
                case {'math4','math 4','m4'}
                    str = 'MATH4';
                otherwise
                    error('Oscilloscope_Temp: Unknow waveform source!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:SELECTED:SOUrce ' str]);
        end
        function val = get.fastframesequence(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORIZONTAL:FASTFRAME:SEQUENCE?');
            val = str(1:end-1);
        end
        function set.fastframesequence(obj,val)
            switch lower(val)
                case {'first','fir','auto'}
                    str = 'FIRst';
                case {'last','manual','manually'}
                    str = 'LAST';
                otherwise
                    error('Oscilloscope_Temp: Unknow single-sequence mode!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORIZONTAL:FASTFRAME:SEQUENCE ' str]);
        end
        function val = get.fastframesingleframemath(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:SINGLEFramemath?');
            val = str(1:end-1);
        end
        function set.fastframesingleframemath(obj,val)
            switch val
                case {1,true}
                     str = 'ON';
                case {0,false}
                     str = 'OFF';
                otherwise
                    switch lower(val)
                        case {'0','off','false'}
                            str = 'OFF';
                        case {'1','on','true'}
                            str = 'ON';
                        otherwise
                            error('Oscilloscope_Temp: Unknow singleframemath!')
                    end
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:SINGLEFramemath ' str]);
        end
        function val = get.fastframesixteenbit(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:SIXteenbit?');
            val = str(1:end-1);
        end
        function set.fastframesixteenbit(obj,val)
            switch val
                case {1,true}
                     str = 'ON';
                case {0,false}
                     str = 'OFF';
                otherwise
                    switch lower(val)
                        case {'0','off','false'}
                            str = 'OFF';
                        case {'1','on','true'}
                            str = 'ON';
                        otherwise
                            error('Oscilloscope_Temp: Unknow sixteenbit!')
                    end
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:SIXteenbit ' str]);
        end
        function val = get.fastframestate(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:STATE?');
            val = str(1:end-1);
        end
        function set.fastframestate(obj,val)
            switch val
                case {1,true}
                     str = 'ON';
                case {0,false}
                     str = 'OFF';
                otherwise
                    switch lower(val)
                        case {'0','off','false'}
                            str = 'OFF';
                        case {'1','on','true'}
                            str = 'ON';
                        otherwise
                            error('Oscilloscope_Temp: Unknow fastframestate!')
                    end
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:STATE ' str]);
        end
        function val = get.fastframesumframe(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:SUMFrame?');
            val = str(1:end-1);
        end
        function set.fastframesumframe(obj,val)
            switch lower(val)
                case {'none','off','non'}
                    str = 'NONe';
                case {'ave','average'}
                    str = 'AVErage';
                case {'envelope','env'}
                    str = 'ENVelope';
                otherwise
                    error('Oscilloscope_Temp: Unknow Sum Frame mode!')
            end
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:SUMFrame ' str]);
        end
    end
    
    properties % Data Transfer group
        dataformat % format of outgoing waveform data
                   % {ASCIi|FAStest|RIBinary|RPBinary|FPBinary|SRIbinary|SRPbinary|SFPbinary}
                   % This command is equivalent to settingWFMOutpre:ENCdg, WFMOutpre:BN_Fmt,
                   % and WFMOutpre:BYT_Or. Setting the DATa:ENGdg value causes the
                   % corresponding WFMOutpre values to be updated and vice versa.
                   %
                   % ASCIi specifiesthe ASCII representation of signed INT, FLOAT.
                   %    If ASCII is the value, then :BN_Fmt and :BYT_Or are ignored.
                   %
                   % FAStest specifies that the data be sent in the fastest possible manner
                   %    consistent with maintaining accuracyand is interpreted with respect to the
                   %    first waveform specified in the DATA:SOUrce list.
                   %    :ENCdg will always be BIN, :BYT_Or will always be LSB, but :BN_Fmt and
                   %    :BYT_Nr will depend on thefirst DATa:SOUrce waveform. :BN_Fmt will
                   %    be RI unless the waveform is internally stored as afloating point number, in
                   %    which case the FP format will be used.
                   %
                   % RIBinary specifies signed integer data point representation with the most
                   %	significant byte transferred first.
                   %	When :BYT_Nr is 1, the range is from -128 through 127. When :BYT_Nr
                   %	is 2, the range is from -32,768 through 32,767. When :BYT_Nr is 8, then
                   %	the waveform being queried is set to Fast Acquisition mode. Center screen
                   %	is 0 (zero). The upper limit is the top of the screen and the lower limit is the
                   %	bottom of the screen. This is the default argument.
                   %
                   % RPBinary specifies the positive integer data-point representation, with the
                   %    most significant byte transferred first.
                   %    When :BYT_Nr is 1, the range from 0 through 255. When :BYT_Nr is 2, the
                   %    range is from 0 to 65,535. When :BYT_Nr is 8, then the waveform being
                   %    queried is set to Fast Acquisition mode. The center of the screen is 127.
                   %    The upper limit is the top of the screen and the lower limit is the bottom of
                   %    the screen.
                   %
                   % FPBinary specifies thefloating point (width = 4) data.
                   %    The range is from ¨C3.4 ¡Á 10^38to 3.4 ¡Á 10^38.
                   % 	The center of the screen is 0.
                   %    The upper limit is the top of the screen and the lower limit is the bottom of
                   %    the screen.
                   %    The FPBinaryargument is only applicable to math waveforms or ref
                   %    waveforms saved from math waveforms.
                   %
                   % SRIbinary is the same as RIBinaryexcept that the byte order is swapped,
                   %    meaning that the least significant byte is transferredfirst. This format is useful
                   %    when transferring data to IBM compatible PCs.
                   %
                   % SRPbinary is the same as RPBinaryexcept that the byte order is swapped,
                   %    meaning that the least significant byte is transferredfirst. This format is useful
                   %    when transferring data to PCs.
                   %
                   % SFPbinary specifies floating point data in IBM PC format. The SFPbinary
                   %    argument only works on math waveforms or ref waveforms saved from math
                   %    waveforms.
                   %
                   % WFMOutpre Settings
                   % ======================================================
                   % DATa:ENCdg Setting     :ENCdg	:BN_Fmt	:BYT_Or	:BYT_NR
                   % ASCii                  ASC     N/A     N/A     1,2,4,8
                   % FAStest                BIN     RI/FP   MSB     1,2,4
                   % RIBinary               BIN     RI      MSB     1,2,8
                   % RPBinary               BIN     RP      MSB     1,2,8
                   % FPBinary               BIN     FP      MSB     4
                   % SRIbinary              BIN     RI      LSB     1,2,8
                   % SRPbinary              BIN     RP      LSB     1,2,8
                   % SFPbinary              BIN     FP      LSB     4
                   % ======================================================
        framestart % starting data frame for waveform transfers
        framestop % stop data frame for waveform transfers
        datasource % location of waveform data
                   % <wfm>[<,><wfm>] 
                   % CH<x>selects the specified analog channel as the source.
                   % MATH<x>selects the specified reference waveform as the source.
                   % REF<x>selects the specified reference waveform as the source.
                   % DIGITALALLselects digital waveforms as the source.
        datastart % starting data point for waveform transfer
        datastop % last data point that will be transferred
        syncsource % sets or queries if the data sync sources are on or off
        wfmoutputbitnr % Number of bits per waveform point that outgoing waveforms contain
                       %This specification is only meaningful when WFMOutpre:ENCdgis set to BIN and
                       % WFMOutpre:BN_Fmt is set to either RI or RP
                       % number of bits per data point can be 8, 16, 32 or 64.
        wfmoutputbnfmt % format of binary data for outgoing waveforms
                       % {RI|RP|FP}
                       % RI specifies signed integer data point representation.
                       % RP specifies positive integer datapoint representation.
                       % FP specifies single-precision binaryfloating point data point representation.
        wfmoutputbytnr % binary field data width for the waveform.
                       % This specification is only meaningful
                       % when WFMOutpre:ENCdg is set to BIN, and WFMOutpre:BN_Fmt is set to
                       % either RI or RP.
        wfmoutputbytor % This property sepecifies which byte of binary waveform data is transmitted first,
                       % during a waveform data transfer, when data points require more than one byte.
                       %{LSB|MSB}
                       % This property sepecifies which byte of binary waveform data is transmitted
                       % This specification only has meaning when WFMOutpre:ENCdgis set to BIN.
                       % LSB specifies that the least significant byte will be transmittedfirst.
                       % MSB specifies that the most significant byte will be transmittedfirst.
        wfmoutprenrpt % number of points for theDATa:SOUrce waveform that will be transmitted in response to a CURVe? query.
        wfmoutprenrfr % number of frames for theDATa:SOUrce waveform transmitted in response to aCURVe?query
        wfmoutpreencdg % type of encoding for outgoing waveforms
                       % {ASCii|BINary}
    end
    methods % Data Transfer group
        function val = get.dataformat(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'DATa:ENCdg?');
            val = str(1:end-1);
        end
        function set.dataformat(obj,val)
            switch lower(val)
                case {'ascii','asci','asc'}
                    str = 'ASCIi';
                case {'fastest','fas'}
                    str = 'FAStest';
                case {'ribinary','rib'}
                    str = 'RIBinary';
                case {'rpbinary','rpb'}
                    str = 'RPBinary';
                case {'fpbinary','fpb'}
                    str = 'FPBinary';
                case {'sribinary','sri'}
                    str = 'SRIbinary';
                case {'srpbinary','srp'}
                    str = 'SRPbinary';
                case {'sfpbinary','sfp'}
                    str = 'SFPbinary';
                otherwise
                    error('Oscilloscope_Temp: Unknow Sum Frame mode!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['HORizontal:FASTframe:SUMFrame ' str]);
        end
        function val = get.framestart(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'DATa:FRAMESTARt?'));
        end
        function set.framestart(obj,val)
            pause(0.005)
            fprintf(obj.interfaceobj,['DATa:FRAMESTARt ' num2str(val)]);
        end
        function val = get.framestop(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'DATa:FRAMESTOP?'));
        end
        function set.framestop(obj,val)
            pause(0.005)
            fprintf(obj.interfaceobj,['DATa:FRAMESTOP ' num2str(val)]);
        end
        function val = get.datasource(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'DATa:SOUrce?');
            val = str(1:end-1);
        end
        function set.datasource(obj,val)
            val = lower(regexprep(val,' ',''));
            if strcmp(val,'')
                error('Oscilloscope_Temp: Data Source could not emty');
            else
                sources = strsplit(val,{','});
                sourcesstr = '';
                for source = sources
                    sourcestr = source;
                    switch source{1}
                        case {'ch1','chanel1'}
                            sourcestr = 'CH1';
                        case {'ch2','chanel2'}
                            sourcestr = 'CH2';
                        case {'ch3','chanel3'}
                            sourcestr = 'CH3';
                        case {'ch4','chanel4'}
                            sourcestr = 'CH4';
                        case {'math1'}
                            sourcestr = 'MATH1';
                        case {'math2'}
                            sourcestr = 'MATH2';
                        case {'math3'}
                            sourcestr = 'MATH3';
                        case {'math4'}
                            sourcestr = 'MATH4';
                        case {'ref1','reference1'}
                            sourcestr = 'REF1';
                        case {'ref2','reference2'}
                            sourcestr = 'REF2';
                        case {'ref3','reference3'}
                            sourcestr = 'REF3';
                        case {'ref4','reference4'}
                            sourcestr = 'REF4';
                        case {'digitalall','digital'}
                            sourcestr = 'DIGITALALL';
                        otherwise
                            error('Oscilloscope_Temp: Data Source could conist of CH<x>, MATH<x>, REF<x>, DIGITALALL');
                    end
                    sourcesstr = [sourcesstr ',' sourcestr];
                end
                sourcesstr = sourcesstr(2:end);
                pause(0.005)
                fprintf(obj.interfaceobj,['DATa:SOUrce ' sourcesstr]);
            end
        end
        function val = get.datastart(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'DATa:STARt?'));
        end
        function set.datastart(obj,val)
            pause(0.005)
            fprintf(obj.interfaceobj,['DATa:STARt ' num2str(val)]);
        end
        function val = get.datastop(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'DATa:STOP?'));
        end
        function set.datastop(obj,val)
            pause(0.005)
            fprintf(obj.interfaceobj,['DATa:STOP ' num2str(val)]);
        end
        function val = get.syncsource(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'HORizontal:FASTframe:STATE?');
            val = str(1:end-1);
        end
        function set.syncsource(obj,val)
            switch val
                case {1,true}
                     str = 'ON';
                case {0,false}
                     str = 'OFF';
                otherwise
                    switch lower(val)
                        case {'0','off','false'}
                            str = 'OFF';
                        case {'1','on','true'}
                            str = 'ON';
                        otherwise
                            error('Oscilloscope_Temp: Unknow Data Sync Sources!')
                    end
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['DATa:SYNCSOUrces ' str]);
        end
        function val = get.wfmoutputbitnr(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'WFMOutpre:BIT_Nr?'));
        end
        function set.wfmoutputbitnr(obj,val)
            if (val == 8)||(val == 16)||(val == 32)||(val == 64)
                pause(0.005)
                fprintf(obj.interfaceobj,['BIT_Nr ' num2str(val)]);
            else
                error('Oscilloscope_Temp: Unsupport bit number!')
            end
        end
        function val = get.wfmoutputbnfmt(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'WFMOutpre:BN_Fmt?');
            val = str(1:end-1);
        end
        function set.wfmoutputbnfmt(obj,val)
            switch lower(val)
                case {'ri'}
                    % RI specifies signed integer data point representation.
                    str = 'RI';
                case {'rp'}
                    % RPspecifies positive integer datapoint representation.
                    str = 'RP';
                case {'fp'}
                    % FPspecifies single-precision binaryfloating point data point representation
                    str = 'FP';
                otherwise
                    error('Oscilloscope_Temp: Unknow error!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['WFMOutpre:BN_Fmt ' str]);
        end
        function val = get.wfmoutputbytnr(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'WFMOutpre:BYT_Nr?'));
        end
        function set.wfmoutputbytnr(obj,val)
            if (val == 1)||(val == 2)||(val == 4)||(val == 8)
                pause(0.005)
                fprintf(obj.interfaceobj,['BYT_Nr ' num2str(val)]);
            else
                error('Oscilloscope_Temp: Unsupport byte number!')
            end
        end
        function val = get.wfmoutputbytor(obj)
            pause(0.01)
            str = query(obj.interfaceobj,'WFMOutpre:BYT_Or?');
            val = str(1:end-1);
        end
        function set.wfmoutputbytor(obj,val)
            switch lower(val)
                case {'lsb'}
                    str = 'LSB';
                case {'msb'}
                    str = 'MSB';
                otherwise
                    error('Oscilloscope_Temp: Unknow error!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['WFMOutpre:BYT_Or ' str]);
        end
        function val = get.wfmoutprenrpt(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'WFMOutpre:NR_Pt?'));
        end
        function val = get.wfmoutprenrfr(obj)
            pause(0.005)
            val = str2double(query(obj.interfaceobj,'WFMOutpre:NR_FR?'));
        end
        function val = get.wfmoutpreencdg(obj)
            pause(0.005)
            str = query(obj.interfaceobj,'WFMOutpre:ENCdg?');
            val = str(1:end-1);
        end
        function set.wfmoutpreencdg(obj,val)
            switch lower(val)
                case {'ascii','asc'}
                    str = 'ASCii';
                case {'binary','bin'}
                    str = 'BINary';
                otherwise
                    error('Oscilloscope_Temp: Unknow error!')
            end
            pause(0.005)
            fprintf(obj.interfaceobj,['WFMOutpre:ENCdg ' str]);
        end
        function datas = getdata(obj)
            datas = [];
            getdatatimer = tic();
            pause(0.005)
            fprintf(obj.interfaceobj,'*CLS');
            dataformatstr = lower(obj.dataformat);
            wfmoutputbnfmtstr = lower(obj.wfmoutputbnfmt);
            nbits = obj.wfmoutputbitnr;
            wfmoutputbytorstr = obj.wfmoutputbytor;
            npoints = obj.wfmoutprenrpt;
            nframes = obj.wfmoutprenrfr;
            pause(0.005)
            fprintf(obj.interfaceobj,'CURVENext?');
                pause(0.05);
            while(toc(getdatatimer)<obj.timeout)
                pause(0.01);
                nextchar = fread(obj.interfaceobj,1,'char');
                if nextchar == '#'
                    pause(0.01)
                    strx = char(fread(obj.interfaceobj,1,'char'));
                    x = hex2dec(strx);
                    pause(0.01)
                    stry = char(fread(obj.interfaceobj,x,'char'));
                    ndatabytes = str2double(stry);
                    data = [];
                    pause(0.01)
                    switch dataformatstr
                        case 'ascii' % ASCIi specifiesthe ASCII representation of signed INT, FLOAT.
                            datastr = fread(obj.interfaceobj,ndatabytes,'char');
                            datastrs = strsplit(datastr,',');
                            data = num2str(datastrs);
                        case 'fastest'% FAStest specifies that the data be sent in the fastest possible manner
                            obj.interfaceobj.ByteOrder = 'b';
                            if strcmp(wfmoutputbnfmtstr,'ri')
                                data = fread(obj.interfaceobj,ndatabytes/nbits*8,['int' num2str(nbits)]);
                            elseif strcmp(wfmoutputbnfmtstr,'fp')
                                data = fread(obj.interfaceobj,ndatabytes/nbits*8,['float' num2str(nbits)]);
                            else
                                error('Oscilloscope_Temp: Unkown error!')
                            end
                        case 'ribinary' % RIBinary specifies signed integer data point representation with the most significant byte transferred first.
                            obj.interfaceobj.ByteOrder = 'b';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['int' num2str(nbits)]);
                        case 'rpbinary' % RPBinaryspecifies the positive integer data-point representation, with the most significant byte transferred first.
                            obj.interfaceobj.ByteOrder = 'l';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['uint' num2str(nbits)]);
                        case 'fpbinary' % FPBinaryspecifies thefloating point (width = 4) data
                            obj.interfaceobj.ByteOrder = 'b';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['float' num2str(nbits)]);
                        case 'sribinary'
                            error('to be writed')
                        case 'sprbinary'
                            error('to be writed')
                        case 'sfrbinary'
                            error('to be writed')
                    end
                    if isempty(data)
                        error('Oscilloscope_Temp: Data readout fail!');
                    end
                    datas = [datas,data];
                else
                    pause(0.05);
                    msg = query(obj.interfaceobj,'*ESR?');
                    if str2double(msg) ~= 0
                        error(['Oscilloscope_Temp: Errmsg4 = ' msg])
                    end
                    break;
                end
            end
        end
        function datas = getdatanow(obj)
            datas = [];
            getdatatimer = tic();
            pause(0.005)
            fprintf(obj.interfaceobj,'*CLS');
            dataformatstr = lower(obj.dataformat);
            wfmoutputbnfmtstr = lower(obj.wfmoutputbnfmt);
            nbits = obj.wfmoutputbitnr;
            wfmoutputbytorstr = obj.wfmoutputbytor;
            npoints = obj.wfmoutprenrpt;
            nframes = obj.wfmoutprenrfr;
            pause(0.005)
            fprintf(obj.interfaceobj,'CURVe?');
                pause(0.05);
            while(toc(getdatatimer)<obj.timeout)
                pause(0.01);
                nextchar = fread(obj.interfaceobj,1,'char');
                if nextchar == '#'
                    pause(0.01)
                    strx = char(fread(obj.interfaceobj,1,'char'));
                    x = hex2dec(strx);
                    pause(0.01)
                    stry = char(fread(obj.interfaceobj,x,'char'));
                    ndatabytes = str2double(stry);
                    data = [];
                    pause(0.01)
                    switch dataformatstr
                        case 'ascii' % ASCIi specifiesthe ASCII representation of signed INT, FLOAT.
                            datastr = fread(obj.interfaceobj,ndatabytes,'char');
                            datastrs = strsplit(datastr,',');
                            data = num2str(datastrs);
                        case 'fastest'% FAStest specifies that the data be sent in the fastest possible manner
                            obj.interfaceobj.ByteOrder = 'b';
                            if strcmp(wfmoutputbnfmtstr,'ri')
                                data = fread(obj.interfaceobj,ndatabytes/nbits*8,['int' num2str(nbits)]);
                            elseif strcmp(wfmoutputbnfmtstr,'fp')
                                data = fread(obj.interfaceobj,ndatabytes/nbits*8,['float' num2str(nbits)]);
                            else
                                error('Oscilloscope_Temp: Unkown error!')
                            end
                        case 'ribinary' % RIBinary specifies signed integer data point representation with the most significant byte transferred first.
                            obj.interfaceobj.ByteOrder = 'b';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['int' num2str(nbits)]);
                        case 'rpbinary' % RPBinaryspecifies the positive integer data-point representation, with the most significant byte transferred first.
                            obj.interfaceobj.ByteOrder = 'l';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['uint' num2str(nbits)]);
                        case 'fpbinary' % FPBinaryspecifies thefloating point (width = 4) data
                            obj.interfaceobj.ByteOrder = 'b';
                            pause(0.01)
                            data = fread(obj.interfaceobj,ndatabytes/nbits*8,['float' num2str(nbits)]);
                        case 'sribinary'
                            error('to be writed')
                        case 'sprbinary'
                            error('to be writed')
                        case 'sfrbinary'
                            error('to be writed')
                    end
                    if isempty(data)
                        error('Oscilloscope_Temp: Data readout fail!');
                    end
                    datas = [datas,data];
                else
                    pause(0.05);
                    msg = query(obj.interfaceobj,'*ESR?');
                    if str2double(msg) ~= 0
                        error(['Oscilloscope_Temp: Errmsg4 = ' msg])
                    end
                    break;
                end
            end
        end
    end
    
    methods (Access = private)
        function obj = Oscilloscope(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('Oscilloscope_Temp:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('Oscilloscope_Temp:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
        end
        [varargout] = InitializeInstr(obj)
        val = GetMeasurements(obj)
        SetOnOff(obj,On)
        bol = GetOnOff(obj)
    end
    
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    
    methods
        function RunSingleSequency(obj)
            getdatatimer=tic;
            obj.acquisitionstopafter = 'SEQuence';
            fprintf(obj.interfaceobj,'ACQuire:STATE ON');
            while 1 && toc(getdatatimer) < obj.timeout
                pause(0.005);
                acqstatus = str2double(query(obj.interfaceobj,'ACQuire:STATE?'));
                if acqstatus == 0
                    break;
                end
            end
        end
        
        function set.samplerate(obj,val)
            pause(0.005);
            fprintf(obj.interfaceobj,['HORizontal:MODE:SAMPLERate ' num2str(val)]);
        end
        function val=get.samplerate(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'HORizontal:MODE:SAMPLERate?'));
        end
        function val=get.acqlength(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'HORizontal:ACQLENGTH?'));
        end
        function val=get.acqduration(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'HORizontal:ACQDURATION?'));
        end
        
        function set.horizontalscale(obj,val)
            pause(0.005);
            fprintf(obj.interfaceobj,['HORizontal:MODE:SCAle ' num2str(val)]);
        end
        function val=get.horizontalscale(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'HORizontal:MODE:SCAle?'));
        end
        
        function set.horizontalposition(obj,val)
            pause(0.005);
            fprintf(obj.interfaceobj,['HORizontal:POSition ' num2str(val)]);
        end
        function val=get.horizontalposition(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'HORizontal:POSition?'));
        end
        
        function set.measurementgating(obj,val)
            pause(0.005);
            if isnumeric(val)
                if val == 0
                    fprintf(obj.interfaceobj,'MEASUrement:GATing OFF');
                else
                    fprintf(obj.interfaceobj,'MEASUrement:GATing ON');
                end
            elseif ischar(val)
                str = lower(val);
                switch str
                    case {'on','off','0','1','cursor','cur',...
                            'zoom1','zoom2','zoom3','zoom4'}
                        pause(0.005);
                        fprintf(obj.interfaceobj,['MEASUrement:GATing ' val]);
                    otherwise
                        error('Oscilloscope_Temp: Unknow Measurement Gating!');
                end
            else
                error('Oscilloscope_Temp: Unknow Measurement Gating!');
            end
        end
        function val=get.measurementgating(obj)
            pause(0.005);
            str = query(obj.interfaceobj,'MEASUrement:GATing?');
            val = str(1:end-1);
        end
        
        function set.acquisitionmode(obj,val)
            if ischar(val)
                str = lower(val);
                switch str
                    case {'sample','sam','peakdetect','peak','hires','hir',...
                            'average','ave','wfmdb','envelope','env'}
                        pause(0.005);
                        fprintf(obj.interfaceobj,['ACQuire:MODe ' val]);
                    otherwise
                        error('Oscilloscope_Temp: Unknow Acquisition Mode!');
                end
            else
                error('Oscilloscope_Temp: Acquisition Mode should be string!');
            end
        end
        function val=get.acquisitionmode(obj)
            pause(0.005);
            str = query(obj.interfaceobj,'ACQuire:MODe?');
            val = str(1:end-1);
        end
        
        function set.acquisitionnumavg(obj,val)
            pause(0.005);
            fprintf(obj.interfaceobj,['ACQuire:NUMAVg ' num2str(val)]);
        end
        function val=get.acquisitionnumavg(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'ACQuire:NUMAVg?'));
        end
        
        function set.acquisitionstopafter(obj,val)
            if ischar(val)
                str = lower(val);
                switch str
                    case {'runstop','sequence'}
                        pause(0.005);
                        fprintf(obj.interfaceobj,['ACQuire:STOPAfter ' num2str(val)]);
                    otherwise
                        error('Oscilloscope_Temp: Unknow Acquisition StopAfter Mode!');
                end
            else
                error('Oscilloscope_Temp: Acquisition StopAfter Mode should be string!');
            end
        end
        function val=get.acquisitionstopafter(obj)
            pause(0.005);
            str = query(obj.interfaceobj,'ACQuire:STOPAfter?');
            val = str(1:end-1);
        end
        
        function set.acquisitionstate(obj,val)
            if isnumeric(val)
                pause(0.005);
                if val == 0
                    fprintf(obj.interfaceobj,'ACQuire:STATE OFF');
                else
                    fprintf(obj.interfaceobj,'ACQuire:STATE ON');
                end
            elseif ischar(val)
                str = lower(val);
                switch str
                    case {'on','off','0','1','run','stop'}
                        pause(0.005);
                        fprintf(obj.interfaceobj,['ACQuire:STATE ' val]);
                    otherwise
                        error('Oscilloscope_Temp: Unknow Acquisition State!');
                end
            else
                error('Oscilloscope_Temp: Unknow Acquisition State!');
            end
        end
        function val=get.acquisitionstate(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'ACQuire:STATE?'));
        end
        
        function val=get.measure1(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'MEASUrement:MEAS1:VALue?'));
        end
        function val=get.measure2(obj)
            pause(0.005);
            val = str2double(query(obj.interfaceobj,'MEASUrement:MEAS2:VALue?'));
        end
    end
    
    
    
end


