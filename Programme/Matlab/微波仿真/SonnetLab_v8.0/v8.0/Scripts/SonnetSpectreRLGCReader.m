%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is helpful when reading in a SpectreRLGC file
%
% SonnetLab, all included documentation, all included examples 
% and all other files (unless otherwise specified) are copyrighted by Sonnet Software 
% in 2011 with all rights reserved.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". ANY AND 
% ALL EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. UNDER NO CIRCUMSTANCES AND UNDER 
% NO LEGAL THEORY, TORT, CONTRACT, OR OTHERWISE, SHALL THE COPYWRITE HOLDERS,  CONTRIBUTORS, 
% MATLAB, OR SONNET SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR 
% CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
% GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL 
% DAMAGES OR LOSSES, OR FOR ANY DAMAGES EVEN IF THE COPYWRITE HOLDERS, CONTRIBUTORS, MATLAB, 
% OR SONNET SOFTWARE HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM 
% BY ANY OTHER PARTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef SonnetSpectreRLGCReader
    %   Reads SpectreRLGC file
    
    properties
        FreqD
        Data 
        LineLengths
        PhysicalLineLength
    end
    
    methods
        
      function obj = SonnetSpectreRLGCReader(theFilename)
          
        initialize(obj);       
       
        aRet = exist(theFilename, 'file');
        
        if aRet == 0
            disp('The specified file could not be found in the path. Please try again.');
            return; 
        end
        
        if nargin == 1
        
            % Reads Sonnet's Spectre Simulator's RLGC file format.

            format long g

            fid = fopen(theFilename);

            aFreqD = [];
            aLineNum = 0;
            aDataBlockNumber = 0;
            aLtemp = [];
            aRtemp = [];
            aGtemp = [];
            aCtemp = [];
            aLineLengths = [];

            aZ0EigVec = [];
            aZ0EigVal = [];
            aGammaEigVec = [];
            aGammaEigVal = [];
            aElecLineLength = [];
            aGuidedWavelength = [];
            aEffRelPerm = [];

            aZ0EigVecD = [];
            aZ0EigValD = [];
            aGammaEigVecD = [];
            aGammaEigValD = [];
            aElecLineLengthD = [];
            aGuidedWavelengthD = [];
            aEffRelPermD = [];

            while 1

            aLineNum = aLineNum+1;aTextLine = fgetl(fid);

            if ~ischar(aTextLine),break;end

            if ~isempty(strfind(aTextLine,'Computation Frequency'))
                aDataBlockNumber = aDataBlockNumber+1;
                aZ0EigVec = [];
                aZ0EigVal = [];
                aGammaEigVec = [];
                aGammaEigVal = [];
                aElecLineLength = [];
                aGuidedWavelength = [];
                aEffRelPerm = [];
            end

            if ~isempty(strfind(aTextLine,'of length'))
                aStringLength = length(obj.GrabTextToNextSpace(aTextLine((strfind(aTextLine,'of length')+10):length(aTextLine))));
                aUnitsString = obj.GrabTextToFirstPeriod(aTextLine((strfind(aTextLine,'of length')+10+aStringLength):length(aTextLine)));
            end
            if ~isempty(strfind(aTextLine,'of length'))
                aPhysicalLineLength = str2num(obj.GrabTextToNextSpace(aTextLine((strfind(aTextLine,'of length')+10):length(aTextLine))));
                aPhysicalLineLength = obj.ConvertToMeters(aPhysicalLineLength,aUnitsString);
            end

            if ~isempty(strfind(aTextLine,'Z0 Matrix Eigenvectors'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aZ0EigVecs = str2num(aTextLine(2:length(aTextLine)));
                aZ0EigVecs(find(abs(aZ0EigVecs)<1e-3)) = 0;
                aNoOfModes = length(aZ0EigVecs)/2;
                for n = 1:aNoOfModes
                    aZ0EigVec(1,n) = aZ0EigVecs((n-1)*2+1)+j*aZ0EigVecs((n-1)*2+2);
                end
                for m = 2:aNoOfModes
                    aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                    aZ0EigVecs = str2num(aTextLine([2:length(aTextLine)]));
                    aZ0EigVecs(find(abs(aZ0EigVecs)<1e-3)) = 0;
                    for n = 1:aNoOfModes
                        aZ0EigVec(m,n) = aZ0EigVecs((n-1)*2+1)+j*aZ0EigVecs((n-1)*2+2);
                    end
                end
                aZ0EigVecFlipped = 0;
                if any(aZ0EigVec(:,1)<0)
                    aZ0EigVecFlipped = 1;
                    aZ0EigVec = fliplr(aZ0EigVec);
                end
                if aNoOfModes>1
                    if aZ0EigVec(1,2)<aZ0EigVec(2,2)
                        aZ0EigVec = flipud(aZ0EigVec);
                    end
                end
            end

            if ~isempty(strfind(aTextLine,'Z0 Matrix Eigenvalues'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                Z0EigVals = str2num(aTextLine([2:length(aTextLine)]));
                for n = 1:aNoOfModes
                    aZ0EigVal(1,n) = Z0EigVals((n-1)*2+1)-j*Z0EigVals((n-1)*2+2);
                end
                if aZ0EigVecFlipped == 1
                    aZ0EigVal = fliplr(aZ0EigVal);
                end
            end

            if ~isempty(strfind(aTextLine,'Gamma Matrix Eigenvectors'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aGammaEigVecs = str2num(aTextLine([2:length(aTextLine)]));
                aGammaEigVecs(find(abs(aGammaEigVecs)<1e-3)) = 0;
                aNoOfModes = length(aGammaEigVecs)/2;
                for n = 1:aNoOfModes
                    aGammaEigVec(1,n) = aGammaEigVecs((n-1)*2+1)+j*aGammaEigVecs((n-1)*2+2);
                end
                for m = 2:aNoOfModes
                    aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                    aGammaEigVecs = str2num(aTextLine([2:length(aTextLine)]));
                    aGammaEigVecs(find(abs(aGammaEigVecs)<1e-3)) = 0;
                    for n = 1:aNoOfModes
                        aGammaEigVec(m,n) = aGammaEigVecs((n-1)*2+1)+j*aGammaEigVecs((n-1)*2+2);
                    end
                end
                aErrorRaw = sum(sum(abs(aGammaEigVec-aZ0EigVec)));
                aErrorFlippedRows = sum(sum(abs(flipud(aGammaEigVec)-aZ0EigVec)));
                aErrorFlippedCols = sum(sum(abs(fliplr(aGammaEigVec)-aZ0EigVec)));
                aErrorFlippedColsRows = sum(sum(abs(fliplr(flipud(aGammaEigVec))-aZ0EigVec)));
                aError = [aErrorRaw aErrorFlippedRows aErrorFlippedCols aErrorFlippedColsRows];
                [minErr, aMinErrI] = min(aError);
                if aMinErrI == 1
                    aDataFlipped = 0;
                elseif aMinErrI == 2
                    aDataFlipped = 1;
                    aGammaEigVec = flipud(aGammaEigVec);
                elseif aMinErrI == 3
                    aDataFlipped = 2;
                    aGammaEigVec = fliplr(aGammaEigVec);
                elseif aMinErrI == 4
                    aDataFlipped = 3;
                    aGammaEigVec = fliplr(flipud(aGammaEigVec));
                end
            end

            if ~isempty(strfind(aTextLine,'Gamma Matrix Eigenvalues'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aGammaEigVals = str2num(aTextLine([2:length(aTextLine)]));

                for n = 1:aNoOfModes
                    aGammaEigVal(1,n) = (aGammaEigVals((n-1)*2+1))-j*(aGammaEigVals((n-1)*2+2))*sign(aGammaEigVals((n-1)*2+1));
                end

                if aDataFlipped>1
                    aGammaEigVal = fliplr(aGammaEigVal);
                end
            end

            if ~isempty(strfind(aTextLine,'Electrical Length of Lines for Each Mode'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                LineLength = str2num(aTextLine(2:length(aTextLine)));
                aLineLengths = [aLineLengths; max(LineLength)];

                if aDataFlipped>1
                    aElecLineLength = fliplr(LineLength);
                else
                    aElecLineLength = LineLength;
                end
            end

            if ~isempty(strfind(aTextLine,'Guided Wavelength of Each Mode'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aGuidedWavelength = str2num(aTextLine(2:length(aTextLine)));
                if aDataFlipped>1
                    aGuidedWavelength = fliplr(aGuidedWavelength);
                end
            end

            if ~isempty(strfind(aTextLine,'Effective Relative Permittivity for Each Mode'))
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                EffRelPerms = str2num(aTextLine([2:length(aTextLine)]));
                for n = 1:aNoOfModes
                    aEffRelPerm(1,n) = EffRelPerms((n-1)*2+1)+j*EffRelPerms((n-1)*2+2);
                end
                if aDataFlipped>1
                    aEffRelPerm = fliplr(aEffRelPerm);
                end
            end

            if strcmp(aTextLine(1),';') && ~isempty(aLtemp)
                aData.L(:,:,aDataBlockNumber) = obj.Matricize(aLtemp);
                aData.R(:,:,aDataBlockNumber) = obj.Matricize(aRtemp);
                aData.C(:,:,aDataBlockNumber) = obj.Matricize(aCtemp);
                aData.G(:,:,aDataBlockNumber) = obj.Matricize(aGtemp);
                aLtemp = [];
                aRtemp = [];
                aGtemp = [];
                aCtemp = [];

                aZ0EigVecD(:,:,aDataBlockNumber) = aZ0EigVec;
                aZ0EigValD = [aZ0EigValD;aZ0EigVal];
                aGammaEigVecD(:,:,aDataBlockNumber) = aGammaEigVec;
                aGammaEigValD = [aGammaEigValD;aGammaEigVal];
                aElecLineLengthD = [aElecLineLengthD;aElecLineLength];
                aGuidedWavelengthD = [aGuidedWavelengthD;aGuidedWavelength];
                aEffRelPermD = [aEffRelPermD;aEffRelPerm];

                aFreqD = [aFreqD;FreqTemp];

                FreqTemp = [];
                aZ0EigVec = [];
                aZ0EigVal = [];
                aGammaEigVec = [];
                aGammaEigVal = [];
                aElecLineLength = [];
                aGuidedWavelength = [];
                aEffRelPerm = [];

            end

            if aDataBlockNumber~= 0 && ~strcmp(aTextLine(1),';')
                FreqTemp = str2num(aTextLine(1:strfind(aTextLine,' : ')));
                if isempty(strfind(aTextLine,':'))
                    aLtemp = [aLtemp str2num(aTextLine(13:length(aTextLine)))];
                else
                    aLtemp = [aLtemp str2num(aTextLine(strfind(aTextLine,':')+1:length(aTextLine)))];
                end
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aRtemp = [aRtemp str2num(aTextLine(13:length(aTextLine)))];
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aCtemp = [aCtemp str2num(aTextLine(13:length(aTextLine)))];
                aTextLine = fgetl(fid);aLineNum = aLineNum+1;
                aGtemp = [aGtemp str2num(aTextLine(13:length(aTextLine)))];
            end
            end

            aFreqD = [aFreqD;FreqTemp];
            aZ0EigVecD(:,:,aDataBlockNumber) = aZ0EigVec;
            aZ0EigValD = [aZ0EigValD;aZ0EigVal];
            aGammaEigVecD(:,:,aDataBlockNumber) = aGammaEigVec;
            aGammaEigValD = [aGammaEigValD;aGammaEigVal];
            aElecLineLengthD = [aElecLineLengthD;aElecLineLength];
            aGuidedWavelengthD = [aGuidedWavelengthD;aGuidedWavelength];
            aEffRelPermD = [aEffRelPermD;aEffRelPerm];
            aData.L(:,:,aDataBlockNumber) = obj.Matricize(aLtemp);
            aData.R(:,:,aDataBlockNumber) = obj.Matricize(aRtemp);
            aData.C(:,:,aDataBlockNumber) = obj.Matricize(aCtemp);
            aData.G(:,:,aDataBlockNumber) = obj.Matricize(aGtemp);

            aData.Z0EigVec = aZ0EigVecD;
            aData.Z0EigVal = aZ0EigValD;
            aData.GammaEigVec = aGammaEigVecD;
            aData.GammaEigVal = aGammaEigValD;
            aData.ElecLineLength = aElecLineLengthD;
            aData.GuidedWavelength = aGuidedWavelengthD;
            aData.EffRelPerm = aEffRelPermD;

            obj.FreqD = aFreqD;
            obj.Data = aData;
            obj.LineLengths = aLineLengths;
            obj.PhysicalLineLength = aPhysicalLineLength;

            fclose(fid);

        end
      end     
    end
    
    methods (Access = private)
        
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function initialize(obj)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This function initializes the object's properties to some default
        %   values. This is called by the constructor and can
        %   be called by the user to reinitialize the object to
        %   default values.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        aBackup=warning();
        warning off all
        aProperties = properties(obj);
        
        for iCounter = 1:length(aProperties)
            obj.(aProperties{iCounter}) = [];
        end
        
        warning(aBackup);
      end
        
      function aMatOut = Matricize(~, theVecIn)
        % This is the size of the matrix deduced
        % from the number of elements in its upper or lower triangle (diag
        % included)

        MatN = (-1+sqrt(1+8*length(theVecIn)))/(2); 

        aMatOut = zeros(MatN);

        for n = 1:MatN
          for m = n:MatN
            aMatOut(n,m) = theVecIn(1);
            theVecIn(1) = [];
          end
        end

        for n = 1:MatN
          for m = n:MatN
            aMatOut(m,n) = aMatOut(n,m);
          end
        end
      end
      
      function theLength = ConvertToMeters(~, theLength, theUnitsString)

        if strcmpi(theUnitsString,'mils')
            theLength = theLength*2.54e-5;
        elseif strcmpi(theUnitsString,'mm')
            theLength = theLength*1e-3;
        elseif strcmpi(theUnitsString,'cm')
            theLength = theLength*1e-2;
        elseif strcmpi(theUnitsString,'km')
            theLength = theLength*1e3;
        elseif strcmpi(theUnitsString,'um')
            theLength = theLength*1e-6;
        elseif strcmpi(theUnitsString,'nm')
            theLength = theLength*1e-9;
        elseif strcmpi(theUnitsString,'inches')
            theLength = theLength*2.54e-2;
        elseif strcmpi(theUnitsString,'m')
            theLength = theLength*1;
        end      
      end
    
      function aTextOut = GrabTextToFirstPeriod(~, theTextIn) 
        [PeriodLocations] = strfind(theTextIn,'.');
    
        aTextOut = theTextIn(1:PeriodLocations(1)-1);
      end
    
      function aTextOut = GrabTextToNextPeriod(~, theTextIn)  
        [PeriodLocations] = strfind(theTextIn,'.');
    
        aTextOut = theTextIn(1:PeriodLocations(2)-1);
      end

      function aTextOut = GrabTextToNextSpace(~, theTextIn)    
        [SpaceLocations] = strfind(theTextIn,' ');
    
        aTextOut = theTextIn(1:SpaceLocations(1));
      end
      
    end
    
end

