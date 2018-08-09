function  aProject = SimulateNetlistProjectFromTouchtoneFile(theTTFilename)
    %SimulateNetlistProjectFromTouchtoneFile creates and simulates a netlist
    %       project from a touchtone file
    % 
    %   Author: Robert Roach
    %
    %   Version Number: 6.4
    %
    %   Version Notes:
    %       This function is intended for Sonnet versions 14.
    %
    %       This script requires a version of Matlab with object-oriented
    %       programming support (>= R2008a). This script was written
    %       and tested with Matlab 7.8.0 (R2009a), Matlab 7.9.0 (R2009b),
    %       Matlab 7.10.0 (R2010a), and Matlab 7.12.0 (2011a). This interface 
    %       has been tested on Windows XP 32-bit, Windows Vista 32-bit, 
    %       Windows Vista 64-bit and Windows 7 64-bit.
    %
    %       This software is provided without warranty. Neither Sonnet nor the
    %       author of these scripts are responsible for misuse or defects.    
    %  
    %   EXAMPLE :
    %       aProject = SimulateNetlistProjectFromTouchtoneFile(theTTFilename);


    % Check to see if the file exist in the directory structure
    aRet = exist(theTTFilename, 'file');   
    
    if aRet == 0
        disp('The specified file could not be found in the path. Please try again.');
        return; 
    end
    
    % get filename to save the sonnet project
    [pathstr, name, ext] = fileparts(theTTFilename);

    aSonnetProjectFn = strcat(pathstr, '\', name, '.son');
    aIMEFn = strcat(pathstr, '\', name, '.scs');
    
    % Retrieve Touchstone data
    [aFreq, aData, aZo, aDataCell] = TouchstoneRead(theTTFilename);
    
    [aRow, aColumn, aCount] = size(aData);   
    
    aProject = SonnetProject();
    aProject.initializeNetlist();
    aProject.VersionOfSonnet = '14.52';
    
    aArrayOfPortNodeNumbers = 1:aRow;
    aNetworkNumber=1;
    aGroundReference=[];
    
    aProject.addDataResponseFileElement(theTTFilename, aArrayOfPortNodeNumbers, ...
        aNetworkNumber, aGroundReference);
    
    % add Step frequency
    aNumOfFreq = numel(aFreq);
    
    for i = 1:aNumOfFreq
        aProject.addStepFrequencySweep(aFreq(i));
    end   
    
    % add IME extraction not center tapped   
    aEmbed = 'ND';
    aIncludeAbs = 'Y';
    aModelType = 'aModelType';
    aIncludeComments = 'IC';
    aSig = 15;
    aFormat = 'SPECTRE';
    aGen_Data = 'Y';
    aModelType = 'SKIN_EFFECT';
    aSource = 'auto';
    aStart= [];
    aStop = [];
    
    aProject.addINDModel(aEmbed, aIncludeAbs, aIMEFn, aIncludeComments, ...
        aSig, aFormat, aGen_Data, aModelType, aSource, aStart, aStop);
    
    aProject.saveAs(aSonnetProjectFn);
    
    % simulate project
    [aStatus, aMessage] = aProject.simulate('-r');

end

