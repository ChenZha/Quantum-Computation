%*******************************************************
% This function analyzes the results of the circuit
% design with respect to BandWidth. It finds the
% BandWidth and returns it back to the caller.
%*******************************************************
function BandWidth=LayerDemoAnalyzeResults(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude,StartFreq,EndFreq,hasBeenAbove3dB)

%**************************************************
% Open the file that has the simulation results
%**************************************************
Sp1FileName=sprintf('%d_%s',iCounter,FileName);
Sp1FileName=strrep(Sp1FileName,'.son','.s1p');
    
theFid = fopen(Sp1FileName, 'r');

%*******************************************************
% Read in the first character of the line. We want to 
% check if the line is data or something else.
%*******************************************************
while (1==1)
  %************************************************************ 
  % Backup up the file pointer and just read one character. 
  % we can then restore the file pointer. this allows us to 
  % sample one character from the line without modifying our 
  % location in the file
  %************************************************************
  aBackupOfTheFid=ftell(theFid);         % Store a backup of the file ID
  aTempCharacter=fscanf(theFid,' %c',1);
  fseek(theFid,aBackupOfTheFid,'bof');	 % Restore the backup of the FID

  %**********************************************************
  % Check if the line is a Comment Line. If so then we can 
  % ignore the line. Otherwise just read in the frequency 
  % and magnitude. We dont need the angle so throw away the
  % rest of the line. 
  %**********************************************************
  if strcmp(aTempCharacter,'!')==1 || strcmp(aTempCharacter,'#')==1
    fgetl(theFid);	% Throw away the line
  
  else
    ReadFreqValue=fscanf(theFid,' %f',1);
    ReadMagValue=fscanf(theFid,' %f',1);
    fgetl(theFid);				% Throw away the rest of the line.
        
    % Convert the magnitude to dB
    ReadMagValue=20*log10(ReadMagValue);
    
    % Store the values in the data array
    Sp1DataFreq=[Sp1DataFreq ReadFreqValue]; %#ok<*AGROW>
    Sp1DataMagnitude=[Sp1DataMagnitude ReadMagValue];
    
    %***************************************************************** 
    % Check if we just crossed the -3dB barrier. If it was the 
    % first time we cross it then we want to record that frequency 
    % as the start frequency. If it is the second time we cross 
    % it then we want to record that frequency as the end 
    % frequency. We then can subtract them and get the BandWidth.
    %*****************************************************************
		%**********************************************
		% If we cross the -3 dB border and havent set 
		% the start entry then set the start entry
		%**********************************************
    if isempty(StartFreq) && ReadMagValue<-3 && ~isempty(hasBeenAbove3dB) && hasBeenAbove3dB==true
      StartFreq=ReadFreqValue;
      
      %**********************************************
      % If we cross the -3 dB border and havent set
      % the end entry then set the end entry and
      % compute the BandWidth and quit the function
      %**********************************************
    elseif ~isempty(StartFreq) && ReadMagValue>-3
      EndFreq=ReadFreqValue;
      BandWidth=EndFreq-StartFreq;
      
      %******************************************************************
      % Graph the results in a plot.
      %******************************************************************
      LayerDemoGraphResponse(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude);
      
      fclose all;
      return;
      
    elseif ReadMagValue>-3 % this indicates that we have been above 3db at one point
      hasBeenAbove3dB=true;
    
    end
 
  %**********************************************
  % At this point we have handled the line from
  % the file. We now wantto check if we are 
  % at the end of the file. 
  %**********************************************   
  end
  
 %******************************************************************
 % We only come here if we got to the end of the file without two
 % places where the response crossed -3dB then we will increase
 % the range of our search and try to find the proper BandWidth.
 %******************************************************************
  if (feof(theFid)==1)        	% If we are at the end of the file
    
    fclose all;
    
    %******************************************************************
    % Open the project that we are analyzing, modify the end
    %	frequency and then write the project back out. we
    %	will then recall analyze in order to determine the 
    %	results again.
    %******************************************************************
    DemoProjectFileName=sprintf('%d_%s',iCounter,FileName);
    DemoProject=SonnetProject(DemoProjectFileName);
    
    %******************************************************************
    % Let the user know that the frequency file didn't have two places
    % where it crossed -3dB.  We will have to increase the range
    % of our search to get enough data.
    %******************************************************************
    if (DemoProject.FrequencyBlock.SweepsArray{2}.EndFreqValue>=1.1)
      disp('Could not find the bandwidth for this circuit in the range of .4 to 1.1 GHZ');
      BandWidth=0;  % Set the bandwidth to zero, it doesnt meet the comparison parameters
      fclose all;
      return;
    else
      disp('The BandWidth could not be found in the sweep frequency range.');
      disp('We will have to increase the frequency range and resimulate.');
      disp('');
    end
    
    %******************************************************************
    % Modify the end sweep frequency value such that we will maybe 
    % catch enough of the Frequency range of the circuit in order 
    % to determine the BandWidth.
    %******************************************************************
    DemoProject.FrequencyBlock.SweepsArray{2}.StartFreqValue=DemoProject.FrequencyBlock.SweepsArray{2}.EndFreqValue;
    DemoProject.FrequencyBlock.SweepsArray{2}.EndFreqValue=DemoProject.FrequencyBlock.SweepsArray{2}.EndFreqValue+.2;
    DemoProject.saveAs(sprintf('%d_%s',iCounter,FileName));
    
    %******************************************************************
    % Graph the results in a plot.
    %******************************************************************
    LayerDemoGraphResponse(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude);
    
    %******************************************************************
    % Call EM to simulate the same circuit again but now we will have
    % a larger frequency range to search. We wont redraw the circuit
    % because it hasnt changed.
    %******************************************************************
    DemoProject.simulate();
    
    %******************************************************************
    % Reanalyze the results.  If the results are satisfactory (there 
    % are two places where it crosses -3dB) then we can return the 
    % BandWidth. This is recursive, we will keep increasing the 
    % outer range by .2 till we get satisfactory results
    %******************************************************************
    BandWidth=LayerDemoAnalyzeResults(iCounter,FileName,Sp1DataFreq,Sp1DataMagnitude,StartFreq,EndFreq);
    
    break;  % break out of the loop because we are at the end of the file
    
  end
  
end


end