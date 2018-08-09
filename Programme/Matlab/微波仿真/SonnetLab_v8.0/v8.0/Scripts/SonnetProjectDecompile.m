function [aListOfCommands aCommandsForEachBlock]=SonnetProjectDecompile(theFilename)
% SonnetLabDecompile  Generates SonnetLab Command List
%   [aListOfCommands aCommandsForEachBlock]=SonnetLabDecompile(theFilename)
%     will generate a list of SonnetLab commands necessary to construct a
%     Sonnet project file from scratch that matches the data for the Sonnet
%     project represented by theFilename. A vertical vector for the complete
%     list of commands is returned as well as a cell array containing the
%     commands for each block.

aProject=SonnetProject(theFilename);

aListOfCommands='Project=SonnetProject();';
if strcmpi(aProject.VersionOfSonnet,'12.52')==0
    aListOfCommands=char(aListOfCommands,['Project.VersionOfSonnet=' sf(aProject.VersionOfSonnet) ';']);
end

% If it is a netlist project then store a command to initialize
% the new project as a netlist.
if aProject.isNetlistProject
    aListOfCommands=char(aListOfCommands,['Project.initializeNetlist();']);
end

% Get the project type
if aProject.isGeometryProject
    aProjectType='GEO';
else
    aProjectType='NET';
end

% Analyze each block of the project independently
aCommandsForEachBlock=cell(size(aProject.CellArrayOfBlocks));
for iBlockCounter=1:length(aProject.CellArrayOfBlocks)
    
    aBlock=aProject.CellArrayOfBlocks{iBlockCounter};
    switch class(aBlock)
        case 'SonnetHeaderBlock'
            aCommands=DecompileHeaderBlock(aBlock);
            
        case 'SonnetDimensionBlock'
            aCommands=DecompileDimensionBlock(aBlock);
            
        case 'SonnetControlBlock'
            aCommands=DecompileControlBlock(aBlock,aProjectType);
            
        case 'SonnetFrequencyBlock'
            aCommands=DecompileFrequencyBlock(aBlock);
            
        case 'SonnetGeometryBlock'
            aCommands=DecompileGeometryBlock(aBlock,aProject.ComponentFileBlock);
            
        case 'SonnetCircuitBlock'
            aCommands=DecompileCircuitBlock(aBlock);
            
        case 'SonnetOptimizationBlock'
            aCommands=DecompileOptimizationBlock(aBlock);
            
        case 'SonnetVariableBlock'
            aCommands=DecompileVariableBlock(aBlock);
            
        case 'SonnetVariableSweepBlock'
            aCommands=DecompileVariableSweepBlock(aBlock);
            
        case 'SonnetFileOutBlock'
            aCommands=DecompileFileOutBlock(aBlock);
            
        case 'SonnetComponentFileBlock'
            aCommands=DecompileComponentFileBlock(aBlock);
            
        case 'SonnetUnknownBlock'
            aCommands=DecompileUnknownBlock(aBlock);
            
        otherwise
            warning(['Unknown block class found: ' class(aBlock)]);
            break;
            
    end
    
    % Remove empty lines from the list of commands for this block
    iCounter=1;
    while iCounter<size(aCommands,1)
        if isempty(strtrim(aCommands(iCounter,:)))
            aCommands(iCounter,:)=[];
        else
            iCounter=iCounter+1;
        end
    end
    
    % Store the commands for this block into the lists of project commands
    if ~isempty(strtrim(aCommands))
        aListOfCommands=char(aListOfCommands,aCommands);
        aCommandsForEachBlock{iBlockCounter}=cellstr(aCommands);
    end
    
end

end

function aString=sf(theString)
% String format a int, double or string to be a easy to read string

switch class(theString)
    case 'char'
        % Remove surrounding quotation marks
        if length(theString) >=2 && theString(1) == '"'
            theString(1)=[];
            theString(end)=[];
        end
        aString=['''' theString ''''];
    case 'double'
        if isempty(theString)
            aString='[]';
        elseif length(theString) > 1
            % Write the matrix as [x y z; q w e]
            aString='[';
            aTempString=num2str(theString);
            for iCounter=1:size(theString,1)
                aString=[aString ' ' aTempString(iCounter,:) ';'];
            end
            aString(end)=[];
            aString=[aString ' ]'];
        else
            aString=num2str(theString);
        end
end

end

function aCommands=DecompileHeaderBlock(theBlock)

aCommands=['Project.HeaderBlock.LicenseString=' sf(theBlock.LicenseString) ';'];

aCommand=['Project.HeaderBlock.DateTheFileWasLastSaved=' sf(theBlock.DateTheFileWasLastSaved) ';'];
aCommands=char(aCommands,aCommand);

aCommand=['Project.HeaderBlock.InformationAboutHowTheProjectWasCreated=' sf(theBlock.InformationAboutHowTheProjectWasCreated) ';'];
aCommands=char(aCommands,aCommand);

aCommand=['Project.HeaderBlock.InformationAboutHowTheProjectWasLastSaved=' sf(theBlock.InformationAboutHowTheProjectWasLastSaved) ';'];
aCommands=char(aCommands,aCommand);

aCommand=['Project.HeaderBlock.DateTheProjectWasSavedWithMediumImportanceChanges=' sf(theBlock.DateTheProjectWasSavedWithMediumImportanceChanges) ';'];
aCommands=char(aCommands,aCommand);

aCommand=['Project.HeaderBlock.DateTheProjectWasSavedWithHighImportanceChanges=' sf(theBlock.DateTheProjectWasSavedWithHighImportanceChanges) ';'];
aCommands=char(aCommands,aCommand);

for iCounter=1:length(theBlock.UnknownLines)
    aCommand=['Project.addComment(' sf(theBlock.UnknownLines{iCounter}) ');'];
    aCommands=char(aCommands,aCommand);
end

end

function aCommands=DecompileDimensionBlock(theBlock)

aCommands='';

if strcmpi(theBlock.FrequencyUnit,'GHZ')==0
    aCommand=['Project.changeFrequencyUnit(' sf(theBlock.FrequencyUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.InductanceUnit,'NH')==0
    aCommand=['Project.changeInductanceUnit(' sf(theBlock.InductanceUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.LengthUnit,'MIL')==0
    aCommand=['Project.changeLengthUnit(' sf(theBlock.LengthUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.AngleUnit,'DEG')==0
    aCommand=['Project.changeAngleUnit(' sf(theBlock.AngleUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.ConductivityUnit,'/OH')==0
    aCommand=['Project.changeConductivityUnit(' sf(theBlock.ConductivityUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.ResistanceUnit,'OH')==0
    aCommand=['Project.changeResistanceUnit(' sf(theBlock.ResistanceUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

if strcmpi(theBlock.CapacitanceUnit,'PF')==0
    aCommand=['Project.changeCapacitanceUnit(' sf(theBlock.CapacitanceUnit) ');'];
    aCommands=char(aCommands,aCommand);
end

end

function aCommands=DecompileControlBlock(theBlock,theProjectType)

aCommands='';

if strcmpi(theBlock.sweepType,'ABS')==0
    aCommand=['Project.changeSelectedFrequencySweep(' sf(theBlock.sweepType) ');'];
    aCommands=char(aCommands,aCommand);
end

% If the project is set to do current simulations then
% enable it with the specialized command. Any other
% options will need to be specified manually.
aOptions=theBlock.Options;
if ~isempty(strfind(aOptions,'j'))
    aCommands=char(aCommands,'Project.enableCurrentCalculations();');
    aOptions=strrep(aOptions,'j','');
end
if strcmpi(aOptions,'d')==0 && strcmpi(theProjectType,'GEO')==1
    aCommand=['Project.ControlBlock.Options=' sf(aOptions) ';'];
    aCommands=char(aCommands,aCommand);
end
if strcmpi(aOptions,'')==0 && strcmpi(theProjectType,'NET')==1
    aCommand=['Project.ControlBlock.Options=' sf(aOptions) ';'];
    aCommands=char(aCommands,aCommand);
end

if theBlock.isForceRun==true
    aCommands=char(aCommands,'Project.ControlBlock.isForceRun=true;');
end

if theBlock.Push==true
    aCommands=char(aCommands,'Project.ControlBlock.Push=true;');
end

if ~isempty(theBlock.SubsectionsPerLambdaInUse)
    aCommands=char(aCommands,['Project.ControlBlock.SubsectionsPerLambdaInUse=' sf(theBlock.SubsectionsPerLambdaInUse) ';']);
end

if ~isempty(theBlock.MaximumSubsectioningFrequencyInUse)
    aCommands=char(aCommands,['Project.ControlBlock.MaximumSubsectioningFrequencyInUse=' sf(theBlock.MaximumSubsectioningFrequencyInUse) ';']);
end

if ~isempty(theBlock.EstimatedEpsilonEffectiveInUse)
    aCommands=char(aCommands,['Project.ControlBlock.EstimatedEpsilonEffectiveInUse=' sf(theBlock.EstimatedEpsilonEffectiveInUse) ';']);
    aCommands=char(aCommands,['Project.ControlBlock.EstimatedEpsilonEffective=' sf(theBlock.EstimatedEpsilonEffective) ';']);
end

if ~isempty(theBlock.Filename)
    aCommands=char(aCommands,['Project.ControlBlock.Filename=' sf(theBlock.Filename) ';']);
end

if theBlock.Speed==1
    aCommands=char(aCommands,['Project.changeMeshToCoarseWithEdgeMesh();']);
elseif theBlock.Speed==2
    aCommands=char(aCommands,['Project.changeMeshToCoarseWithNoEdgeMesh();']);
end

if ~isempty(theBlock.EdgeCheckInUse)
    aCommands=char(aCommands,['Project.ControlBlock.EdgeCheckInUse=' sf(theBlock.EdgeCheckInUse) ';']);
    aCommands=char(aCommands,['Project.ControlBlock.EdgeCheck=' sf(theBlock.EdgeCheck) ';']);
end

if ~isempty(theBlock.AbsResolutionInUse)
    aCommands=char(aCommands,['Project.ControlBlock.AbsResolutionInUse=' sf(theBlock.AbsResolutionInUse) ';']);
    aCommands=char(aCommands,['Project.ControlBlock.AbsResolution=' sf(theBlock.AbsResolution) ';']);
end

if ~isempty(theBlock.CacheAbs)
    aCommands=char(aCommands,['Project.ControlBlock.CacheAbs=' sf(theBlock.CacheAbs) ';']);
end

if ~isempty(theBlock.TargetAbs)
    aCommands=char(aCommands,['Project.ControlBlock.TargetAbs=' sf(theBlock.TargetAbs) ';']);
end

if ~isempty(theBlock.QFactorAccuracy)
    aCommands=char(aCommands,['Project.ControlBlock.QFactorAccuracy=' sf(theBlock.QFactorAccuracy) ';']);
end

end

function aCommands=DecompileFrequencyBlock(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.SweepsArray)
    aSweep=theBlock.SweepsArray{iCounter};
    switch class(aSweep)
        case 'SonnetFrequencyAbs'
            aCommand=['Project.addAbsFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyAbsEntry'
            aCommand=['Project.addAbsEntryFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyAbsFmax'
            aCommand=['Project.addAbsFmaxFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.Maximum) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyAbsFmin'
            aCommand=['Project.addAbsFminFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.Minimum) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyDcFreq'
            if strcmpi(aSweep.Mode,'AUTO')==1
                aCommands=char(aCommands,['Project.addDcFrequencySweep(' sf('AUTO') ');']);
            else
                aCommand=['Project.addDcFrequencySweep(' sf('MAN') ',' sf(aSweep.Frequency) ');'];
                aCommands=char(aCommands,aCommand);
            end
        case 'SonnetFrequencyEsweep'
            aCommand=['Project.addEsweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.AnalysisFrequencies) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyLsweep'
            aCommand=['Project.addLsweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.AnalysisFrequencies) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencySimple'
            aCommand=['Project.addSimpleFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.StepValue) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencyStep'
            aCommand=['Project.addStepFrequencySweep(' sf(aSweep.StepValue) ');'];
            aCommands=char(aCommands,aCommand);
        case 'SonnetFrequencySweep'
            aCommand=['Project.addSweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.StepValue) ');'];
            aCommands=char(aCommands,aCommand);
    end
end

end

function aCommands=DecompileFileOutBlock(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfFileOutputConfigurations)
    aEntry=theBlock.ArrayOfFileOutputConfigurations{iCounter};
    if strcmpi(aEntry.FileType,'PIMODEL')==1
        aCommands=char(aCommands,DecompilePiModel(aEntry));
    elseif strcmpi(aEntry.FileType,'NCLINE')==1
        aCommands=char(aCommands,DecompileNcline(aEntry));
    elseif strcmpi(aEntry.FileType,'BBEXTRACT')==1
        aCommands=char(aCommands,DecompileBBExtract(aEntry));
    else
        aCommands=char(aCommands,DecompileFileOutLine(aEntry));
    end
end

% If there is a FOLDER line then make a command to mimic its definition
if ~isempty(theBlock.Folder)
    aCommands=char(aCommands,['Project.FileOutBlock.Folder=' sf(theBlock.Folder) ';']);
end

end

function aCommands=DecompileFileOutLine(aEntry)

aCommands='';

aArguments=[ sf(aEntry.Embed) ',' sf(aEntry.IncludeAbs) ','...
    sf(aEntry.Filename) ',' sf(aEntry.IncludeComments) ',' ...
    sf(aEntry.IsOutputHighPerformance) ',' sf(aEntry.ParameterType) ',' ...
    sf(aEntry.ParameterForm) ',' sf(aEntry.PortType)];

switch aEntry.PortType
    case 'R'
        aPortTerminationArguments=sf(aEntry.Resistance);
    case 'Z'
        aPortTerminationArguments=[sf(aEntry.Resistance) ',' sf(aEntry.Resistance)];
    case 'TERM'
        aPortTerminationArguments=['[' sf(aEntry.Resistance) '],[' sf(aEntry.Reactance) ']'];
    case 'FTERM'
        aPortTerminationArguments=['[' sf(aEntry.Resistance) '],[' sf(aEntry.Reactance) '],' ...
            '[' sf(aEntry.Inductance) '],[' sf(aEntry.Capacitance) ']'];
    otherwise
        error('Unknown type');
end

% If it is a geometry project then ignore the network name
if isempty(aEntry.NetworkName)
    aCommand=['Project.addFileOutput(' sf(aEntry.FileType) ',' aArguments ',' aPortTerminationArguments ');'];
    aCommands=char(aCommands,aCommand);
else
    aCommand=['Project.addFileOutput(' sf(aEntry.FileType) ',' sf(aEntry.NetworkName) ',' aArguments ',' aPortTerminationArguments ');'];
    aCommands=char(aCommands,aCommand);
end

end

function aCommands=DecompilePiModel(aEntry)

aArguments=[ sf(aEntry.TYPE) ',' sf(aEntry.Embed) ',' ...
    sf(aEntry.IncludeAbs) ',' sf(aEntry.Filename) ',' ...
    sf(aEntry.IncludeComments) ',' sf(aEntry.IsOutputHighPerformance) ',' ...
    sf(aEntry.PINT) ',' sf(aEntry.RMAX) ',' sf(aEntry.CMIN) ',' ...
    sf(aEntry.LMAX) ',' sf(aEntry.KMIN) ',' sf(aEntry.RZERO)];
            
aCommands=['Project.addPiModel(' aArguments ');'];

end

function aCommands=DecompileNcline(aEntry)

if isempty(aEntry.NetworkName)
    aCommands=['Project.addNCoupledLineOutput(' sf(aEntry.Embed) ',' sf(aEntry.IncludeAbs) ',' ...
        sf(aEntry.Filename) ',' sf(aEntry.IsOutputHighPerformance) ');'];
else
    aCommands=['Project.addNCoupledLineOutput(' sf(aEntry.Embed) ',' sf(aEntry.IncludeAbs) ',' ...
        sf(aEntry.Filename) ',' sf(aEntry.IsOutputHighPerformance) ',' sf(aEntry.NetworkName) ');'];
end

end

function aCommands=DecompileBBExtract(aEntry)

warning 'Currently there no method to add BBEXTRACT output files. Ignoring this entry.'

end

function aCommands=DecompileComponentFileBlock(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfFiles)
    
    aCommand=['Project.ComponentFileBlock.ArrayOfFiles{end+1}=' sf(theBlock.ArrayOfFiles{iCounter}) ';'];
    aCommands=char(aCommands,aCommand);
    
end

end

function aCommands=DecompileUnknownBlock(theBlock)

aCommands='Project.CellArrayOfBlocks{end+1}=SonnetUnknownBlock();';
aCommands=char(aCommands,'aUnknownBlock=Project.CellArrayOfBlocks{end};');
aCommands=char(aCommands,['aUnknownBlock.BlockName=' sf(theBlock.BlockName) ';']);

for iCounter=1:length(theBlock.ArrayOfStringsContainedInBlock)
    aCommand=['aUnknownBlock.Lines{end+1}=' sf(theBlock.ArrayOfStringsContainedInBlock{iCounter}) ';'];
    aCommands=char(aCommands,aCommand);
end

end

function aCommands=DecompileVariableSweepBlock(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfSweeps)
    aEntry=theBlock.ArrayOfSweeps{iCounter};
    
    % Add the sweep that will be used for for the variable sweep
    aSweep = aEntry.Sweep;
    switch class(aSweep)
        case 'SonnetFrequencyAbsEntry'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsEntry();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
        case 'SonnetFrequencyAbsFmax'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsFmax();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.Minimum=' sf(aSweep.Minimum) ';']);
        case 'SonnetFrequencyAbsFmin'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsFmin();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.Minimum=' sf(aSweep.Maximum) ';']);
        case 'SonnetFrequencyDcFreq'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyDcFreq();');
            if strcmpi(aSweep.Mode,'AUTO')==1
                aCommands=char(aCommands,['aSweep.Mode=' sf('AUTO') ';']);
            else
                aCommands=char(aCommands,['aSweep.Mode=' sf('MAN') ';']);
                aCommands=char(aCommands,['aSweep.Frequency=' sf(aSweep.Frequency) ';']);
            end
        case 'SonnetFrequencyEsweep'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyEsweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.AnalysisFrequencies=' sf(aSweep.AnalysisFrequencies) ';']);
        case 'SonnetFrequencyLsweep'
            aCommand=['Project.addLsweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.AnalysisFrequencies) ');'];
            aCommands=char(aCommands,'aSweep=SonnetFrequencyLsweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.AnalysisFrequencies=' sf(aSweep.AnalysisFrequencies) ';']);
        case 'SonnetFrequencySimple'
            aCommands=char(aCommands,'aSweep=SonnetFrequencySimple();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
        case 'SonnetFrequencyStep'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyStep();');
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
        case 'SonnetFrequencySweep'
            aCommand=['Project.addSweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.StepValue) ');'];
            aCommands=char(aCommands,'aSweep=SonnetFrequencySweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
    end
    
    aCommands=char(aCommands,'Project.addVariableSweep(aSweep);');
    
    % Add the variable sweep parameters
    for jCounter=1:length(aEntry.ParameterArray)
        
        aParameter=aEntry.ParameterArray{jCounter};
        
        % Get the number of points to use for the sweep.
        % If the step size is empty then it is a corner
        % sweep and ignore the value.
        if isempty(aParameter.StepValue) || isa(aParameter.StepValue,'char')
            aNumberOfPoints=[];
        else
            aNumberOfPoints=(aParameter.MaxValue - aParameter.MinValue) / aParameter.StepValue;
        end
        
        % Dont include the variable sweep entry index if it is one because
        % that is the default value anyway.
        if iCounter==1
            aCommands=char(aCommands,['Project.addVariableSweepParameter(' sf(aParameter.ParameterName) ',' ...
                sf(aParameter.MinValue) ',' sf(aParameter.MaxValue) ',' sf(aNumberOfPoints) ');']);
        else
            aCommands=char(aCommands,['Project.addVariableSweepParameter(' sf(aParameter.ParameterName) ',' ...
                sf(aParameter.MinValue) ',' sf(aParameter.MaxValue) ',' sf(aNumberOfPoints) ',' sf(iCounter) ');']);
        end
        
        % If the variable parameter is turned off then indicate that
        if strcmpi(aParameter.ParameterBeingUsedForSweep,'N')==1
            aCommands=char(aCommands,['Project.deactivateVariableSweepParameter(' sf(aParameter.ParameterName) ',' sf(iCounter) ');']);
        elseif strcmpi(aParameter.ParameterBeingUsedForSweep,'Y')==0
            aCommands=char(aCommands,['Project.changeVariableSweepParameterState(' sf(aParameter.ParameterName) ',' sf(aParameter.ParameterBeingUsedForSweep) ',' sf(iCounter) ');']);
        end
        
    end
end
end

function aCommands=DecompileVariableBlock(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfParameters)
    theVariableName=theBlock.ArrayOfParameters{iCounter}.ParameterName;
    theValue=theBlock.ArrayOfParameters{iCounter}.ParameterValue;
    aCommands=char(aCommands,['Project.defineVariable(' sf(theVariableName) ', ' sf(theValue) ');']);
end

end

function aCommands=DecompileOptimizationBlock(theBlock)

aCommands='';

% If there is no optimization sweep then return
for iCounter=1:length(theBlock.OptimizationSweep)
    
    % Add the sweep that will be used for for the optimization
    aSweep=theBlock.OptimizationSweep{iCounter};
    switch class(aSweep)
        case 'SonnetFrequencyAbsEntry'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsEntry();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
        case 'SonnetFrequencyAbsFmax'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsFmax();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.Minimum=' sf(aSweep.Minimum) ';']);
        case 'SonnetFrequencyAbsFmin'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyAbsFmin();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.Minimum=' sf(aSweep.Maximum) ';']);
        case 'SonnetFrequencyDcFreq'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyDcFreq();');
            if strcmpi(aSweep.Mode,'AUTO')==1
                aCommands=char(aCommands,['aSweep.Mode=' sf('AUTO') ';']);
            else
                aCommands=char(aCommands,['aSweep.Mode=' sf('MAN') ';']);
                aCommands=char(aCommands,['aSweep.Frequency=' sf(aSweep.Frequency) ';']);
            end
        case 'SonnetFrequencyEsweep'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyEsweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.AnalysisFrequencies=' sf(aSweep.AnalysisFrequencies) ';']);
        case 'SonnetFrequencyLsweep'
            aCommand=['Project.addLsweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.AnalysisFrequencies) ');'];
            aCommands=char(aCommands,'aSweep=SonnetFrequencyLsweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.AnalysisFrequencies=' sf(aSweep.AnalysisFrequencies) ';']);
        case 'SonnetFrequencySimple'
            aCommands=char(aCommands,'aSweep=SonnetFrequencySimple();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
        case 'SonnetFrequencyStep'
            aCommands=char(aCommands,'aSweep=SonnetFrequencyStep();');
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
        case 'SonnetFrequencySweep'
            aCommand=['Project.addSweepFrequencySweep(' sf(aSweep.StartFreqValue) ',' sf(aSweep.EndFreqValue) ',' sf(aSweep.StepValue) ');'];
            aCommands=char(aCommands,'aSweep=SonnetFrequencySweep();');
            aCommands=char(aCommands,['aSweep.StartFreqValue=' sf(aSweep.StartFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.EndFreqValue=' sf(aSweep.EndFreqValue) ';']);
            aCommands=char(aCommands,['aSweep.StepValue=' sf(aSweep.StepValue) ';']);
    end
    
    % Modify the max iteratiosn if it is not the default 100
    if theBlock.MaxIterations ~=100
        aCommands=char(aCommands,['Project.OptimizationBlock.MaxIterations{' sf(iCounter) '}=' sf(theBlock.MaxIterations{iCounter}) ';']);
    end
    
    % Add the optimization sweep
    aCommands=char(aCommands,['Project.addOptimizationParameter(aSweep,' sf(theBlock.ResponseType{iCounter}) ',' ...
        sf(theBlock.RelationString{iCounter}) ',' sf(theBlock.TargetType{iCounter}) ',' sf(theBlock.TargetValue{iCounter}) ',' ...
        sf(theBlock.TargetResponseType{iCounter}) ',' sf(theBlock.Weight{iCounter}) ');']);
end

% Add optimization variables to the optimization sweep entry
for jCounter=1:length(theBlock.VarsArray)
    aVar=theBlock.VarsArray{jCounter};
    aCommands=char(aCommands,['Project.editOptimizationVariable(' sf(aVar.VariableName) ',' ...
        sf(aVar.MinValue) ',' sf(aVar.MaxValue) ',' sf(aVar.StepValue) ',' sf(aVar.VariableBeingUsed) ');']);
end

end

function aCommands=DecompileGeometryBlock(theBlock,theComponentFileBlock)

aCommands='';

if ~isempty(theBlock.IsSymmetric) && strcmpi(theBlock.IsSymmetric,'TRUE')==0
    aCommands=char(aCommands,'Project.symmetryOn();');
end

aCommands=char(aCommands,DecompileMetalTypes(theBlock));
aCommands=char(aCommands,DecompileBrickTypes(theBlock));
aCommands=char(aCommands,DecompilePolygons(theBlock));
aCommands=char(aCommands,DecompileGeometryBlockBox(theBlock.SonnetBox));
aCommands=char(aCommands,DecompileParallelSubsections(theBlock));
aCommands=char(aCommands,DecompileReferencePlanes(theBlock));
aCommands=char(aCommands,DecompileDimensionSubblock(theBlock));
aCommands=char(aCommands,DecompileVariables(theBlock));
aCommands=char(aCommands,DecompileParameters(theBlock));
aCommands=char(aCommands,DecompileEdgeVias(theBlock));
aCommands=char(aCommands,DecompileCocalGroups(theBlock));
aCommands=char(aCommands,DecompilePorts(theBlock));
aCommands=char(aCommands,DecompileComponents(theBlock,theComponentFileBlock));

if ~isempty(theBlock.LocalOrigin)
    aCommands=char(aCommands,['Project.GeometryBlock.LocalOrigin.X=' sf(theBlock.LocalOrigin.X) ';' ]);
    aCommands=char(aCommands,['Project.GeometryBlock.LocalOrigin.Y=' sf(theBlock.LocalOrigin.Y) ';' ]);
    aCommands=char(aCommands,['Project.GeometryBlock.LocalOrigin.Locked=' sf(theBlock.LocalOrigin.Locked) ';' ]);
end

% % % UnknownLines

end

function aCommands=DecompileDimensionSubblock(theBlock)

aCommands='';

for iCounter=1:length(theBlock.ArrayOfDimensions)    
    aEntry=theBlock.ArrayOfDimensions{iCounter};
    aCommands=char(aCommands,['Project.addDimensionLabel(' sf(aEntry.ReferencePolygon1.DebugId) ',' ...
        sf(aEntry.ReferenceVertex1) ',' sf(aEntry.ReferencePolygon2.DebugId) ',' ...
        sf(aEntry.ReferenceVertex2) ',' sf(aEntry.Direction) ');' ]);
end
end

function aCommands=DecompileVariables(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfVariables)
    aVariableName=theBlock.ArrayOfVariables{iCounter}.VariableName;
    aValue=theBlock.ArrayOfVariables{iCounter}.Value;
    aType=theBlock.ArrayOfVariables{iCounter}.UnitType;
    aDescription=theBlock.ArrayOfVariables{iCounter}.Description;
    
    % If the variable has a description then include the optional argument
    if isempty(theBlock.ArrayOfVariables{iCounter}.Description)
        aCommands=char(aCommands,['Project.defineVariable(' sf(aVariableName) ', ' sf(aValue) ', ' sf(aType) ');']);
    else
        aCommands=char(aCommands,['Project.defineVariable(' sf(aVariableName) ', ' sf(aValue) ', ' sf(aType) ', ' sf(aDescription) ');']);
    end
end

end

function aCommands=DecompileParameters(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfParameters)
    
    % Get values necessary for creating the parameter
    aEntry=theBlock.ArrayOfParameters{iCounter};
    aName=aEntry.Parname;
    aVert1=aEntry.ReferenceVertex1;
    aVert2=aEntry.ReferenceVertex2;
    aDirection=aEntry.Direction;
    
    % Add commands to get instances of the reference polygons
    aIndex=theBlock.findPolygonIndex(aEntry.ReferencePolygon1);
    aCommands=char(aCommands,['aReferencePolygon1=Project.getPolygon(' sf(aIndex) ');']);
    aIndex=theBlock.findPolygonIndex(aEntry.ReferencePolygon2);
    aCommands=char(aCommands,['aReferencePolygon2=Project.getPolygon(' sf(aIndex) ');']);
    
    % Use the appropriate commands depending on the parameter type
    if strcmpi(aEntry.Partype,'ANC')==1 % Add anchored parameter
        % Generate a set of commands for the point set polygon/vertex pairs
        if isempty(aEntry.PointSet2.ArrayOfPolygons)
            aCommands=char(aCommands,'aArrayOfPolygons={};');
            aCommands=char(aCommands,'aArrayOfPoints={};');
        end
        for jCounter=1:length(aEntry.PointSet2.ArrayOfPolygons)
            aPolygon=aEntry.PointSet2.ArrayOfPolygons{jCounter};
            aIndex=theBlock.findPolygonIndex(aPolygon);
            aVertex=aEntry.PointSet2.ArrayOfVertexVectors{jCounter};
            
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['aArrayOfPolygons{' sf(jCounter) '}=' 'Polygon' ';']);
            aCommands=char(aCommands,['aArrayOfPoints{' sf(jCounter) '}=' sf(aVertex) ';']);
        end
        
        % If there is an associated equation then use the optional argument
        % otherwise add the parameter without it.
        if isempty(aEntry.Equation)
            aCommands=char(aCommands,['Project.addAnchoredDimensionParameter(' sf(aName) ...
                ', aReferencePolygon1, ' sf(aVert1) ', aReferencePolygon2, ' sf(aVert2) ...
                ', aArrayOfPolygons, aArrayOfPoints, ' sf(aDirection) ');']);
        else
            aCommands=char(aCommands,['Project.addAnchoredDimensionParameter(' sf(aName) ', ' ...
                sf(aRef1) ', ' sf(aVert1) ', ' sf(aRef2) ', ' sf(aVert2) ...
                ', aArrayOfPolygons, aArrayOfPoints, ' sf(aDirection) ',' sf(aEntry.Equation) ');']);
        end
    elseif strcmpi(aEntry.Partype,'SYM')==1 % Add symmetric parameter
        % Generate a set of commands for the point set polygon/vertex pairs
        if isempty(aEntry.PointSet1.ArrayOfPolygons)
            aCommands=char(aCommands,'aArrayOfPolygons1={};');
            aCommands=char(aCommands,'aArrayOfPoints1={};');
        end
        for jCounter=1:length(aEntry.PointSet1.ArrayOfPolygons)
            aPolygon=aEntry.PointSet1.ArrayOfPolygons{jCounter};
            aIndex=theBlock.findPolygonIndex(aPolygon);
            aVertex=aEntry.PointSet1.ArrayOfVertexVectors{jCounter};
            
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['aArrayOfPolygons1{' sf(jCounter) '}=' 'Polygon' ';']);
            aCommands=char(aCommands,['aArrayOfPoints1{' sf(jCounter) '}=' sf(aVertex) ';']);
        end
        if isempty(aEntry.PointSet2.ArrayOfPolygons)
            aCommands=char(aCommands,'aArrayOfPolygons2={};');
            aCommands=char(aCommands,'aArrayOfPoints2={};');
        end
        for jCounter=1:length(aEntry.PointSet2.ArrayOfPolygons)
            aPolygon=aEntry.PointSet2.ArrayOfPolygons{jCounter};
            aIndex=theBlock.findPolygonIndex(aPolygon);
            aVertex=aEntry.PointSet2.ArrayOfVertexVectors{jCounter};
            
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['aArrayOfPolygons2{' sf(jCounter) '}=' 'Polygon' ';']);
            aCommands=char(aCommands,['aArrayOfPoints2{' sf(jCounter) '}=' sf(aVertex) ';']);
        end
        
        % If there is an associated equation then use the optional argument
        % otherwise add the parameter without it.
        if isempty(aEntry.Equation)
            aCommands=char(aCommands,['Project.addSymmetricDimensionParameter(' sf(aName) ...
                ', aReferencePolygon1, ' sf(aVert1) ', aReferencePolygon2, ' sf(aVert2) ...
                ', aArrayOfPolygons1, aArrayOfPoints1, aArrayOfPolygons2, aArrayOfPoints2, ' sf(aDirection) ');']);
        else
            aCommands=char(aCommands,['Project.addSymmetricDimensionParameter(' sf(aName) ...
                ', aReferencePolygon1, ' sf(aVert1) ', aReferencePolygon2, ' sf(aVert2) ...
                ', aArrayOfPolygons1, aArrayOfPoints1, aArrayOfPolygons2, aArrayOfPoints2, ' sf(aDirection) ', ' sf(aEntry.Equation) ');']);
        end
    elseif strcmpi(aEntry.Partype,'RAD')==1 % Add radial parameter
        warning 'Currently there no method to add radial parameters. Ignoring this entry.'
    else
        warning 'Unknown parameter type. Ignoring this entry.'
    end
    
end
end

function aCommands=DecompileEdgeVias(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfEdgeVias)
    
    EdgeNumber=theBlock.ArrayOfEdgeVias{iCounter}.Vertex;
    Level=theBlock.ArrayOfEdgeVias{iCounter}.Level;
    
    % We will use the polygon's reference to add the edge via
    aIndex=theBlock.findPolygonIndex(theBlock.ArrayOfEdgeVias{iCounter}.Polygon);
    aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
    
    aCommands=char(aCommands,['Project.addEdgeVia(' 'Polygon' ',' sf(EdgeNumber) ',' sf(Level) ');']);
end

end

function aCommands=DecompilePorts(theBlock)

aCommands='';

% Determine if the port numbers are sequencial
% if they are then the port adding commands do
% not need to specify the port numbers
isSequencial=true;
for iCounter=1:length(theBlock.ArrayOfPorts)
    if iCounter~=theBlock.ArrayOfPorts{iCounter}.PortNumber
        isSequencial=false;
        break
    end
end

for iCounter= 1:length(theBlock.ArrayOfPorts)
    
    % Read port information
    aEntry=theBlock.ArrayOfPorts{iCounter};
    aVertex=aEntry.Vertex;
    aResistance=aEntry.Resistance;
    aReactance=aEntry.Reactance;
    aInductance=aEntry.Inductance;
    aCapacitance=aEntry.Capacitance;
    aPortNumber=aEntry.PortNumber;
    
    % We will use the polygon's reference to add the edge via
    aIndex=theBlock.findPolygonIndex(aEntry.Polygon);
    aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
    
    switch theBlock.ArrayOfPorts{iCounter}.Type
        case 'STD'
            % If the port numbers are sequencial then we dont need to
            % specify the port number for the newly created ports
            if isSequencial
                aCommands=char(aCommands,['Project.addPortStandard(Polygon,' sf(aVertex) ',' ...
                    sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ');']);
            else
                aCommands=char(aCommands,['Project.addPortStandard(Polygon,' sf(aVertex) ',' ...
                    sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ',' sf(aPortNumber) ');']);
            end
        case 'AGND'
            aTypeOfReferencePlane=aEntry.TypeOfReferencePlane;
            aReferencePlaneOrCalibrationLength=aEntry.ReferencePlaneOrCalibrationLength;
            aTypeOfReferencePlane=aEntry.TypeOfReferencePlane;
            aReferencePlaneOrCalibrationLength=aEntry.ReferencePlaneOrCalibrationLength;
            
            % If the port numbers are sequencial then we dont need to
            % specify the port number for the newly created ports
            if isSequencial
                aCommands=char(aCommands,['Project.addPortAutoGrounded(Polygon,' sf(aVertex) ',' ...
                    sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ',' ...
                    sf(aTypeOfReferencePlane) ',' sf(aReferencePlaneOrCalibrationLength) ');']);
            else
                aCommands=char(aCommands,['Project.addPortAutoGrounded(Polygon,' sf(aVertex) ',' ...
                    sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ',' ...
                    sf(aTypeOfReferencePlane) ',' sf(aReferencePlaneOrCalibrationLength) ',' sf(aPortNumber) ');']);
            end
        case 'CUP'
            aGroupName=aEntry.GroupName;
            
            % If the port numbers are sequencial then we dont need to
            % specify the port number for the newly created ports
            if isSequencial
                aCommands=char(aCommands,['Project.addPortCocalibrated(Polygon,' sf(aGroupName) ',' ...
                    sf(aVertex) ',' sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ');']);
            else
                aCommands=char(aCommands,['Project.addPortCocalibrated(Polygon,' sf(aGroupName) ',' ...
                    sf(aVertex) ',' sf(aResistance)  ',' sf(aReactance) ',' sf(aInductance) ',' sf(aCapacitance) ',' sf(aPortNumber) ');']);
            end
    end
end

end

function aCommands=DecompileComponents(theBlock,theComponentFileBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfComponents)
    
    % Get the values for the component
    aEntry=theBlock.ArrayOfComponents{iCounter};
    aName=aEntry.Name;
    aLevel=aEntry.Level;
    aTerminalWidthType=aEntry.TerminalWidthType;
    
    % Get the port data
    aPorts=[];
    for jCounter=1:length(aEntry.ArrayOfPorts)
        aPorts=[aPorts; aEntry.ArrayOfPorts{jCounter}.XLocation, aEntry.ArrayOfPorts{jCounter}.YLocation];
    end
        
    if strcmpi(aEntry.Type.Type,'IDEAL')==1 && strcmpi(aEntry.Type.Idealtype,'RES')==1      % If it is a resistor component
        aValue=aEntry.Type.Compval;
        if strcmpi(aTerminalWidthType,'FEED')==1
            aCommands=char(aCommands,['aComponent=Project.addResistorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('FEED') ');']);
        elseif strcmpi(aTerminalWidthType,'1CELL')==1
            aCommands=char(aCommands,['aComponent=Project.addResistorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('1CELL') ');']);
        elseif strcmpi(aTerminalWidthType,'CUST')==1
            aCommands=char(aCommands,['aComponent=Project.addResistorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf(aEntry.TerminalWidth) ');']);
        end
    elseif strcmpi(aEntry.Type.Type,'IDEAL')==1 && strcmpi(aEntry.Type.Idealtype,'CAP')==1  % If it is a capacitor component
        aValue=aEntry.Type.Compval;
        if strcmpi(aTerminalWidthType,'FEED')==1
            aCommands=char(aCommands,['aComponent=Project.addCapacitorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('FEED') ');']);
        elseif strcmpi(aTerminalWidthType,'1CELL')==1
            aCommands=char(aCommands,['aComponent=Project.addCapacitorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('1CELL') ');']);
        elseif strcmpi(aTerminalWidthType,'CUST')==1
            aCommands=char(aCommands,['aComponent=Project.addCapacitorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf(aEntry.TerminalWidth) ');']);
        end
    elseif strcmpi(aEntry.Type.Type,'IDEAL')==1 && strcmpi(aEntry.Type.Idealtype,'IND')==1  % If it is a inductor component
        aValue=aEntry.Type.Compval;
        if strcmpi(aTerminalWidthType,'FEED')==1
            aCommands=char(aCommands,['aComponent=Project.addInductorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('FEED') ');']);
        elseif strcmpi(aTerminalWidthType,'1CELL')==1
            aCommands=char(aCommands,['aComponent=Project.addInductorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf('1CELL') ');']);
        elseif strcmpi(aTerminalWidthType,'CUST')==1
            aCommands=char(aCommands,['aComponent=Project.addInductorComponent(' sf(aName) ',' sf(aValue) ',' sf(aLevel) ',' sf(aPorts) ',' sf(aEntry.TerminalWidth) ');']);
        end
    elseif strcmpi(aEntry.Type.Type,'SPARAM')==1                                            % If it is a S-parameter component
        aFileIndex=aEntry.Type.paramfileindex;
        aFilename=theComponentFileBlock.ArrayOfFiles{aFileIndex};
        if strcmpi(aTerminalWidthType,'FEED')==1
            aCommands=char(aCommands,['aComponent=Project.addDataFileComponent(' sf(aName) ',' sf(aFilename) ',' sf(aLevel) ',' sf(aPorts) ',' sf('FEED') ');']);
        elseif strcmpi(aTerminalWidthType,'1CELL')==1
            aCommands=char(aCommands,['aComponent=Project.addDataFileComponent(' sf(aName) ',' sf(aFilename) ',' sf(aLevel) ',' sf(aPorts) ',' sf('1CELL') ');']);
        elseif strcmpi(aTerminalWidthType,'CUST')==1
            aCommands=char(aCommands,['aComponent=Project.addDataFileComponent(' sf(aName) ',' sf(aFilename) ',' sf(aLevel) ',' sf(aPorts) ',' sf(aEntry.TerminalWidth) ');']);
        end
    else
        if strcmpi(aTerminalWidthType,'FEED')==1
            aCommands=char(aCommands,['aComponent=Project.addPortOnlyComponent(' sf(aName) ',' sf(aLevel) ',' sf(aPorts) ',' sf('FEED') ');']);
        elseif strcmpi(aTerminalWidthType,'1CELL')==1
            aCommands=char(aCommands,['aComponent=Project.addPortOnlyComponent(' sf(aName) ',' sf(aLevel) ',' sf(aPorts) ',' sf('1CELL') ');']);
        elseif strcmpi(aTerminalWidthType,'CUST')==1
            aCommands=char(aCommands,['aComponent=Project.addPortOnlyComponent(' sf(aName) ',' sf(aLevel) ',' sf(aPorts) ',' sf(aEntry.TerminalWidth) ');']);
        end
    end
    
    % Store a command to modify the ground reference
    if strcmpi(aEntry.GroundReference,'F')==0
        aCommands=char(aCommands,['aComponent.GroundReference=' sf(aEntry.GroundReference) ';']);
    end
    
    % Include commands to add reference planes to the component if necessary
    if ~isempty(aEntry.ReferencePlanes)
        if ~isempty(aEntry.ReferencePlanes.LeftSide)
            if isa(aEntry.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneFix')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('LEFT') ',' ...
                    sf('FIX') ',' sf(aEntry.ReferencePlanes.LeftSide.Length) ');' ]);
            elseif isa(aEntry.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneNone')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('LEFT') ',' ...
                    sf('NONE') ',' sf(aEntry.ReferencePlanes.LeftSide.Length) ');' ]);
            else
                aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.LeftSide.Polygon);
                aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('LEFT') ',' ...
                    sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.LeftSide.Polygon.Vertex) ');' ]);
            end
        end
        if ~isempty(aEntry.ReferencePlanes.RightSide)
            if isa(aEntry.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneFix')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('RIGHT') ',' ...
                    sf('FIX') ',' sf(aEntry.ReferencePlanes.RightSide.Length) ');' ]);
            elseif isa(aEntry.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneNone')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('RIGHT') ',' ...
                    sf('NONE') ',' sf(aEntry.ReferencePlanes.RightSide.Length) ');' ]);
            else
                aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.RightSide.Polygon);
                aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('RIGHT') ',' ...
                    sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.RightSide.Polygon.Vertex) ');' ]);
            end
        end
        if ~isempty(aEntry.ReferencePlanes.TopSide)
            if isa(aEntry.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneFix')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('TOP') ',' ...
                    sf('FIX') ',' sf(aEntry.ReferencePlanes.TopSide.Length) ');' ]);
            elseif isa(aEntry.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneNone')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('TOP') ',' ...
                    sf('NONE') ',' sf(aEntry.ReferencePlanes.TopSide.Length) ');' ]);
            else
                aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.TopSide.Polygon);
                aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('TOP') ',' ...
                    sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.TopSide.Polygon.Vertex) ');' ]);
            end
        end
        if ~isempty(aEntry.ReferencePlanes.BottomSide)
            if isa(aEntry.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneFix')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('BOTTOM') ',' ...
                    sf('FIX') ',' sf(aEntry.ReferencePlanes.BottomSide.Length) ');' ]);
            elseif isa(aEntry.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneNone')
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('BOTTOM') ',' ...
                    sf('NONE') ',' sf(aEntry.ReferencePlanes.BottomSide.Length) ');' ]);
            else
                aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.BottomSide.Polygon);
                aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
                aCommands=char(aCommands,['aComponent.addReferencePlane(' sf('BOTTOM') ',' ...
                    sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.BottomSide.Polygon.Vertex) ');' ]);
            end
        end
    end
    
end
end

function aCommands=DecompileCocalGroups(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfCoCalibratedGroups)
    aEntry=theBlock.ArrayOfCoCalibratedGroups{iCounter};
    aCommands=char(aCommands,['Project.addCoCalibratedGroup(' sf(aEntry.GroupName) ',' sf(aEntry.GroundReference) ',' sf(aEntry.TerminalWidthType) ');']);
    
    % If the group has reference planes then include lines to set them up
    if isempty(aEntry.ReferencePlanes)
        continue
    end
    
    if ~isempty(aEntry.ReferencePlanes.LeftSide)
        if isa(aEntry.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneFix')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('LEFT') ',' ...
                sf('FIX') ',' sf(aEntry.ReferencePlanes.LeftSide.Length) ');' ]);
        elseif isa(aEntry.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneNone')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('LEFT') ',' ...
                sf('NONE') ',' sf(aEntry.ReferencePlanes.LeftSide.Length) ');' ]);
        else
            aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.LeftSide.Polygon);
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('LEFT') ',' ...
                sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.LeftSide.Vertex) ');' ]);
        end
    end
    if ~isempty(aEntry.ReferencePlanes.RightSide)
        if isa(aEntry.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneFix')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('RIGHT') ',' ...
                sf('FIX') ',' sf(aEntry.ReferencePlanes.RightSide.Length) ');' ]);
        elseif isa(aEntry.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneNone')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('RIGHT') ',' ...
                sf('NONE') ',' sf(aEntry.ReferencePlanes.RightSide.Length) ');' ]);
        else
            aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.RightSide.Polygon);
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('RIGHT') ',' ...
                sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.RightSide.Vertex) ');' ]);
        end
    end
    if ~isempty(aEntry.ReferencePlanes.TopSide)
        if isa(aEntry.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneFix')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('TOP') ',' ...
                sf('FIX') ',' sf(aEntry.ReferencePlanes.TopSide.Length) ');' ]);
        elseif isa(aEntry.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneNone')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('TOP') ',' ...
                sf('NONE') ',' sf(aEntry.ReferencePlanes.TopSide.Length) ');' ]);
        else
            aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.TopSide.Polygon);
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('TOP') ',' ...
                sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.TopSide.Vertex) ');' ]);
        end
    end
    if ~isempty(aEntry.ReferencePlanes.BottomSide)
        if isa(aEntry.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneFix')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('BOTTOM') ',' ...
                sf('FIX') ',' sf(aEntry.ReferencePlanes.BottomSide.Length) ');' ]);
        elseif isa(aEntry.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneNone')
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('BOTTOM') ',' ...
                sf('NONE') ',' sf(aEntry.ReferencePlanes.BottomSide.Length) ');' ]);
        else
            aIndex=aEntry.findPolygonIndex(aEntry.ReferencePlanes.BottomSide.Polygon);
            aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
            aCommands=char(aCommands,['Project.addReferencePlaneToPortGroup(' sf(aEntry.GroupName) ',' sf('BOTTOM') ',' ...
                sf('LINK') ',Polygon,' sf(aEntry.ReferencePlanes.BottomSide.Vertex) ');' ]);
        end
    end
    
end

end

function aCommands=DecompilePolygons(theBlock)

aCommands='';

for iCounter= 1:length(theBlock.ArrayOfPolygons)
    aPolygon=theBlock.ArrayOfPolygons{iCounter};
    switch aPolygon.Type
        case 'BRI POLY'
            aCommands=char(aCommands,DecompileBrickPolygon(theBlock,aPolygon));
        case 'VIA POLYGON'
            aCommands=char(aCommands,DecompileViaPolygon(theBlock,aPolygon));
        otherwise
            aCommands=char(aCommands,DecompileMetalPolygon(theBlock,aPolygon));
    end
    
    aCommands=char(aCommands,['Polygon.DebugId=' sf(aPolygon.DebugId) ';']);
end

end

function aCommands=DecompileMetalPolygon(theBlock,thePolygon)

aCommands='';
aMetalIndex=thePolygon.MetalType+1;

% Add a default polygon; we will modify any settings for it there after
if aMetalIndex <=0
    aCommands=char(aCommands,['Polygon=Project.addMetalPolygonEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(cell2mat(thePolygon.XCoordinateValues)) ',' sf(cell2mat(thePolygon.YCoordinateValues)) ');']);
else
    aMetalTypeName=theBlock.ArrayOfMetalTypes{aMetalIndex}.Name;
    aCommands=char(aCommands,['Polygon=Project.addMetalPolygonEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(cell2mat(thePolygon.XCoordinateValues)) ',' sf(cell2mat(thePolygon.YCoordinateValues)) ',' sf(aMetalTypeName) ');']);
end

% Modify the FillType value
if strcmpi(thePolygon.FillType,'Staircase')==0
    aCommands=char(aCommands,['Polygon.FillType=' sf(thePolygon.FillType) ';']);
end

% Modify the XMinimumSubsectionSize value
if thePolygon.XMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.XMinimumSubsectionSize=' sf(thePolygon.XMinimumSubsectionSize) ';']);
end

% Modify the YMinimumSubsectionSize value
if thePolygon.YMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.YMinimumSubsectionSize=' sf(thePolygon.YMinimumSubsectionSize) ';']);
end

% Modify the XMaximumSubsectionSize value
if thePolygon.XMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.XMaximumSubsectionSize=' sf(thePolygon.XMaximumSubsectionSize) ';']);
end

% Modify the YMaximumSubsectionSize value
if thePolygon.YMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.YMaximumSubsectionSize=' sf(thePolygon.YMaximumSubsectionSize) ';']);
end

% Modify the MaximumLengthForTheConformalMeshSubsection value
if thePolygon.MaximumLengthForTheConformalMeshSubsection~=0
    aCommands=char(aCommands,['Polygon.MaximumLengthForTheConformalMeshSubsection=' sf(thePolygon.MaximumLengthForTheConformalMeshSubsection) ';']);
end

% Modify the EdgeMesh value
if strcmpi(thePolygon.EdgeMesh,'Y')==0
    aCommands=char(aCommands,['Polygon.EdgeMesh=' sf(thePolygon.EdgeMesh) ';']);
end

end

function aCommands=DecompileBrickPolygon(theBlock,thePolygon)

aCommands='';
aMaterialIndex=thePolygon.MetalType;

% Add a default polygon; we will modify any settings for it there after
if isempty(theBlock.ArrayOfDielectricMaterials) || aMaterialIndex <1
    aCommands=char(aCommands,['Polygon=Project.addDielectricBrickEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(cell2mat(thePolygon.XCoordinateValues)) ',' sf(cell2mat(thePolygon.YCoordinateValues)) ');']);
else
    aMetalTypeName=theBlock.ArrayOfDielectricMaterials{aMaterialIndex}.Name;
    aCommands=char(aCommands,['Polygon=Project.addDielectricBrickEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(cell2mat(thePolygon.XCoordinateValues)) ',' sf(cell2mat(thePolygon.YCoordinateValues)) ',' sf(aMetalTypeName) ');']);
end

% Modify the FillType value
if strcmpi(thePolygon.FillType,'Staircase')==0
    aCommands=char(aCommands,['Polygon.FillType=' sf(thePolygon.FillType) ';']);
end

% Modify the XMinimumSubsectionSize value
if thePolygon.XMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.XMinimumSubsectionSize=' sf(thePolygon.XMinimumSubsectionSize) ';']);
end

% Modify the YMinimumSubsectionSize value
if thePolygon.YMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.YMinimumSubsectionSize=' sf(thePolygon.YMinimumSubsectionSize) ';']);
end

% Modify the XMaximumSubsectionSize value
if thePolygon.XMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.XMaximumSubsectionSize=' sf(thePolygon.XMaximumSubsectionSize) ';']);
end

% Modify the YMaximumSubsectionSize value
if thePolygon.YMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.YMaximumSubsectionSize=' sf(thePolygon.YMaximumSubsectionSize) ';']);
end

% Modify the MaximumLengthForTheConformalMeshSubsection value
if thePolygon.MaximumLengthForTheConformalMeshSubsection~=0
    aCommands=char(aCommands,['Polygon.MaximumLengthForTheConformalMeshSubsection=' sf(thePolygon.MaximumLengthForTheConformalMeshSubsection) ';']);
end

% Modify the EdgeMesh value
if strcmpi(thePolygon.EdgeMesh,'Y')==0
    aCommands=char(aCommands,['Polygon.EdgeMesh=' sf(thePolygon.EdgeMesh) ';']);
end

end

function aCommands=DecompileViaPolygon(theBlock,thePolygon)

aCommands='';
aMetalIndex=thePolygon.MetalType+1;

% Add a default polygon; we will modify any settings for it there after
if aMetalIndex <=0
    aCommands=char(aCommands,['Polygon=Project.addViaPolygonEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(thePolygon.LevelTheViaIsConnectedTo) ',' sf(cell2mat(thePolygon.XCoordinateValues)) ',' ...
        sf(cell2mat(thePolygon.YCoordinateValues)) ');']);
else
    aMetalTypeName=theBlock.ArrayOfMetalTypes{aMetalIndex}.Name;
    aCommands=char(aCommands,['Polygon=Project.addViaPolygonEasy(' sf(thePolygon.MetalizationLevelIndex) ',' ...
        sf(thePolygon.LevelTheViaIsConnectedTo) ',' sf(cell2mat(thePolygon.XCoordinateValues)) ',' ...
        sf(cell2mat(thePolygon.YCoordinateValues)) ',' sf(aMetalTypeName) ');']);
end

% Modify the FillType value
if strcmpi(thePolygon.FillType,'Staircase')==0
    aCommands=char(aCommands,['Polygon.FillType=' sf(thePolygon.FillType) ';']);
end

% Modify the XMinimumSubsectionSize value
if thePolygon.XMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.XMinimumSubsectionSize=' sf(thePolygon.XMinimumSubsectionSize) ';']);
end

% Modify the YMinimumSubsectionSize value
if thePolygon.YMinimumSubsectionSize ~= 1
    aCommands=char(aCommands,['Polygon.YMinimumSubsectionSize=' sf(thePolygon.YMinimumSubsectionSize) ';']);
end

% Modify the XMaximumSubsectionSize value
if thePolygon.XMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.XMaximumSubsectionSize=' sf(thePolygon.XMaximumSubsectionSize) ';']);
end

% Modify the YMaximumSubsectionSize value
if thePolygon.YMaximumSubsectionSize ~= 100
    aCommands=char(aCommands,['Polygon.YMaximumSubsectionSize=' sf(thePolygon.YMaximumSubsectionSize) ';']);
end

% Modify the MaximumLengthForTheConformalMeshSubsection value
if thePolygon.MaximumLengthForTheConformalMeshSubsection~=0
    aCommands=char(aCommands,['Polygon.MaximumLengthForTheConformalMeshSubsection=' sf(thePolygon.MaximumLengthForTheConformalMeshSubsection) ';']);
end

% Modify the EdgeMesh value
if strcmpi(thePolygon.EdgeMesh,'Y')==0
    aCommands=char(aCommands,['Polygon.EdgeMesh=' sf(thePolygon.EdgeMesh) ';']);
end

% Modify the covers value
if ~isempty(thePolygon.isCapped) && thePolygon.isCapped
    aCommands=char(aCommands,['Polygon.includeMetalCaps();']);
end

% Modify the via meshing value
if ~isempty(thePolygon.Meshing) && strcmpi(thePolygon.Meshing,'RING')==0
    aCommands=char(aCommands,['Polygon.changeViaMeshing(' sf(thePolygon.Meshing) ');']);
end

end

function aCommands=DecompileParallelSubsections(theBlock)

aCommands='';

if isempty(theBlock.ParallelSubsections)
    return
end

if ~isempty(theBlock.ParallelSubsections.LeftDistance)
    aCommands=char(aCommands,['Project.addParallelSubsection(' sf('LEFT') ',' sf(theBlock.ParallelSubsections.LeftDistance) ');' ]);
end
if ~isempty(theBlock.ParallelSubsections.RightDistance)
    aCommands=char(aCommands,['Project.addParallelSubsection(' sf('RIGHT') ',' sf(theBlock.ParallelSubsections.RightDistance) ');' ]);
end
if ~isempty(theBlock.ParallelSubsections.TopDistance)
    aCommands=char(aCommands,['Project.addParallelSubsection(' sf('TOP') ',' sf(theBlock.ParallelSubsections.TopDistance) ');' ]);
end
if ~isempty(theBlock.ParallelSubsections.BottomDistance)
    aCommands=char(aCommands,['Project.addParallelSubsection(' sf('BOTTOM') ',' sf(theBlock.ParallelSubsections.BottomDistance) ');' ]);
end

end

function aCommands=DecompileReferencePlanes(theBlock)

aCommands='';

if isempty(theBlock.ReferencePlanes)
    return
end

if ~isempty(theBlock.ReferencePlanes.LeftSide)
    if isa(theBlock.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneFix')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('LEFT') ',' ...
            sf('FIX') ',' sf(theBlock.ReferencePlanes.LeftSide.Length) ');' ]);
    elseif isa(theBlock.ReferencePlanes.LeftSide,'SonnetGeometryReferencePlaneNone')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('LEFT') ',' ...
            sf('NONE') ',' sf(theBlock.ReferencePlanes.LeftSide.Length) ');' ]);
    else
        aIndex=theBlock.findPolygonIndex(theBlock.ReferencePlanes.LeftSide.Polygon);
        aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('LEFT') ',' ...
            sf('LINK') ',Polygon,' sf(theBlock.ReferencePlanes.LeftSide.Vertex) ');' ]);
    end
end
if ~isempty(theBlock.ReferencePlanes.RightSide)
    if isa(theBlock.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneFix')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('RIGHT') ',' ...
            sf('FIX') ',' sf(theBlock.ReferencePlanes.RightSide.Length) ');' ]);
    elseif isa(theBlock.ReferencePlanes.RightSide,'SonnetGeometryReferencePlaneNone')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('RIGHT') ',' ...
            sf('NONE') ',' sf(theBlock.ReferencePlanes.RightSide.Length) ');' ]);
    else
        aIndex=theBlock.findPolygonIndex(theBlock.ReferencePlanes.RightSide.Polygon);
        aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('RIGHT') ',' ...
            sf('LINK') ',Polygon,' sf(theBlock.ReferencePlanes.RightSide.Vertex) ');' ]);
    end
end
if ~isempty(theBlock.ReferencePlanes.TopSide)
    if isa(theBlock.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneFix')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('TOP') ',' ...
            sf('FIX') ',' sf(theBlock.ReferencePlanes.TopSide.Length) ');' ]);
    elseif isa(theBlock.ReferencePlanes.TopSide,'SonnetGeometryReferencePlaneNone')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('TOP') ',' ...
            sf('NONE') ',' sf(theBlock.ReferencePlanes.TopSide.Length) ');' ]);
    else
        aIndex=theBlock.findPolygonIndex(theBlock.ReferencePlanes.TopSide.Polygon);
        aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('TOP') ',' ...
            sf('LINK') ',Polygon,' sf(theBlock.ReferencePlanes.TopSide.Vertex) ');' ]);
    end
end
if ~isempty(theBlock.ReferencePlanes.BottomSide)
    if isa(theBlock.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneFix')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('BOTTOM') ',' ...
            sf('FIX') ',' sf(theBlock.ReferencePlanes.BottomSide.Length) ');' ]);
    elseif isa(theBlock.ReferencePlanes.BottomSide,'SonnetGeometryReferencePlaneNone')
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('BOTTOM') ',' ...
            sf('NONE') ',' sf(theBlock.ReferencePlanes.BottomSide.Length) ');' ]);
    else
        aIndex=theBlock.findPolygonIndex(theBlock.ReferencePlanes.BottomSide.Polygon);
        aCommands=char(aCommands,['Polygon=Project.getPolygon(' sf(aIndex) ');']);
        aCommands=char(aCommands,['Project.addReferencePlane(' sf('BOTTOM') ',' ...
            sf('LINK') ',Polygon,' sf(theBlock.ReferencePlanes.BottomSide.Vertex) ');' ]);
    end
end

end

function aCommands=DecompileMetalTypes(theBlock)

aCommands='';

for iCounter=1:length(theBlock.ArrayOfMetalTypes)
    aMetal=theBlock.ArrayOfMetalTypes{iCounter};
    theType=upper(aMetal.Type);
    switch theType
        
        case 'NOR'      % Normal Metal
            aCommands=char(aCommands,['Project.defineNewNormalMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.CurrentRatio) ',' ...
                sf(aMetal.Thickness) ');' ]);
        case 'NORMAL'
            aCommands=char(aCommands,['Project.defineNewNormalMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.CurrentRatio) ',' ...
                sf(aMetal.Thickness) ');' ]);
        case 'RES'      % Resistor Metal
            aCommands=char(aCommands,['Project.defineNewResistorMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Resistance) ');' ]);
        case 'RESISTOR'
            aCommands=char(aCommands,['Project.defineNewResistorMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Resistance) ');' ]);
        case 'NAT'      % Native Metal
            aCommands=char(aCommands,['Project.defineNewNativeMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Resistance) ',' ...
                sf(aMetal.SkinCoefficient) ');' ]);
        case 'NATURAL'
            aCommands=char(aCommands,['Project.defineNewNativeMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Resistance) ',' ...
                sf(aMetal.SkinCoefficient) ');' ]);
        case 'SUP'      % General Metal
            aCommands=char(aCommands,['Project.defineNewGeneralMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Resistance) ',' ...
                sf(aMetal.SkinCoefficient) ',' ...
                sf(aMetal.Reactance) ',' ...
                sf(aMetal.KineticInductance) ');' ]);
        case 'GENERAL'
            aCommands=char(aCommands,['Project.defineNewGeneralMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Resistance) ',' ...
                sf(aMetal.SkinCoefficient) ',' ...
                sf(aMetal.Reactance) ',' ...
                sf(aMetal.KineticInductance) ');' ]);
        case 'SEN'      % Sense Metal
            aCommands=char(aCommands,['Project.defineNewSenseMetalType(' sf(aMetal.Name) ',' sf(aMetal.Reactance) ');' ]);
        case 'SENSE'
            aCommands=char(aCommands,['Project.defineNewSenseMetalType(' sf(aMetal.Name) ',' sf(aMetal.Reactance) ');' ]);
        case 'TMM'      % Thick Metal
            aCommands=char(aCommands,['Project.defineNewThickMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Conductivity) ','  ...
                sf(aMetal.CurrentRatio) ','  ...
                sf(aMetal.Thickness) ','  ...
                sf(aMetal.NumSheets) ');' ]);
        case 'THICK'
            aCommands=char(aCommands,['Project.defineNewThickMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Conductivity) ','  ...
                sf(aMetal.CurrentRatio) ','  ...
                sf(aMetal.Thickness) ','  ...
                sf(aMetal.NumSheets) ');' ]);
        case 'VOL'      % Volume Metal
            % If the wall thickness is SOLID then indicate so
            if aMetal.isSolid
                aThickness='SOLID';
            else
                aThickness=aMetal.WallThickness;
            end
            
            aCommands=char(aCommands,['Project.defineNewVolumeMetalType(' ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Conductivity) ','  ...
                sf(aThickness) ');' ]);
        case 'VOLUME'
            % If the wall thickness is SOLID then indicate so
            if aMetal.isSolid
                aThickness='SOLID';
            else
                aThickness=aMetal.WallThickness;
            end
            
            aCommands=char(aCommands,['Project.defineNewVolumeMetalType(' ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Conductivity) ','  ...
                sf(aThickness) ');' ]);
        case 'SFC'      % Surface Metal
            aCommands=char(aCommands,['Project.defineNewSurfaceMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Rdc) ','  ...
                sf(aMetal.Rrf) ','  ...
                sf(aMetal.Xdc) ');' ]);
        case 'SURFACE'
            aCommands=char(aCommands,['Project.defineNewSurfaceMetalType('  ...
                sf(aMetal.Name) ','  ...
                sf(aMetal.Rdc) ','  ...
                sf(aMetal.Rrf) ','  ...
                sf(aMetal.Xdc) ');' ]);
        case 'ARR'      % Array Metal
            aCommands=char(aCommands,['Project.defineNewArrayMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.FillFactor) ');' ]);
        case 'ARRAY'
            aCommands=char(aCommands,['Project.defineNewArrayMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.FillFactor) ');' ]);
        case 'ROG'      % Rough Metal
            if aMetal.isThick
                aThicknessModel='thick';
            else
                aThicknessModel='thin';
            end
            aCommands=char(aCommands,['Project.defineNewRoughMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aThicknessModel) ',' ...
                sf(aMetal.Thickness) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.CurrentRatio) ',' ...
                sf(aMetal.TopRoughness) ',' ...
                sf(aMetal.BottomRoughness) ');' ]);
        case 'RUF'
            if aMetal.isThick
                aThicknessModel='thick';
            else
                aThicknessModel='thin';
            end
            aCommands=char(aCommands,['Project.defineNewRoughMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aThicknessModel) ',' ...
                sf(aMetal.Thickness) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.CurrentRatio) ',' ...
                sf(aMetal.TopRoughness) ',' ...
                sf(aMetal.BottomRoughness) ');' ]);
        case 'ROUGH'
            if aMetal.isThick
                aThicknessModel='thick';
            else
                aThicknessModel='thin';
            end
            aCommands=char(aCommands,['Project.defineNewRoughMetalType(' ...
                sf(aMetal.Name) ',' ...
                sf(aThicknessModel) ',' ...
                sf(aMetal.Thickness) ',' ...
                sf(aMetal.Conductivity) ',' ...
                sf(aMetal.CurrentRatio) ',' ...
                sf(aMetal.TopRoughness) ',' ...
                sf(aMetal.BottomRoughness) ');' ]);
    end
end

if strcmpi(theBlock.TopCoverMetal.Name,'Lossless')==0
    aCommands=char(aCommands,['Project.changeTopCover(' sf(theBlock.TopCoverMetal.Name) ');' ]);
end

if strcmpi(theBlock.BottomCoverMetal.Name,'Lossless')==0
    aCommands=char(aCommands,['Project.changeBottomCover(' sf(theBlock.BottomCoverMetal.Name) ');' ]);
end

end

function aCommands=DecompileBrickTypes(theBlock)

aCommands='';

for iCounter=1:length(theBlock.ArrayOfDielectricMaterials)
    aBrick=theBlock.ArrayOfDielectricMaterials{iCounter};
    if isa(aBrick,'SonnetGeometryIsotropic')
        aCommands=char(aCommands,['Project.defineNewBrickType(' ...
            sf(aBrick.Name) ','...
            sf(aBrick.RelativeDielectricConstant) ','...
            sf(aBrick.LossTangent) ','...
            sf(aBrick.BulkConductivity) ');' ]);
    else
        aCommands=char(aCommands,['Project.defineNewBrickType(' ...
            sf(aBrick.Name) ','...
            sf(aBrick.XRelativeDielectricConstant) ','...
            sf(aBrick.XLossTangent) ','...
            sf(aBrick.XBulkConductivity) ','...
            sf(aBrick.YRelativeDielectricConstant) ','...
            sf(aBrick.YLossTangent) ','...
            sf(aBrick.YBulkConductivity) ','...
            sf(aBrick.ZRelativeDielectricConstant) ','...
            sf(aBrick.ZLossTangent) ','...
            sf(aBrick.ZBulkConductivity) ');' ]);
    end
end

end

function aCommands=DecompileGeometryBlockBox(theBlock)

aCommands='';

if theBlock.XWidthOfTheBox~=160
    aCommands=char(aCommands,['Project.changeBoxSizeX(' sf(theBlock.XWidthOfTheBox) ');']);
end

if theBlock.YWidthOfTheBox~=160
    aCommands=char(aCommands,['Project.changeBoxSizeY(' sf(theBlock.YWidthOfTheBox) ');']);
end

if theBlock.DoubleNumberOfCellsInXDirection~=32
    aCommands=char(aCommands,['Project.changeNumberOfCellsX(' sf(theBlock.DoubleNumberOfCellsInXDirection/2) ');']);
end

if theBlock.DoubleNumberOfCellsInYDirection~=32
    aCommands=char(aCommands,['Project.changeNumberOfCellsY(' sf(theBlock.DoubleNumberOfCellsInYDirection/2) ');']);
end

if theBlock.NumberOfSubsections~=20
    aCommands=char(aCommands,['Project.GeometryBlock.SonnetBox.NumberOfSubsections=' sf(theBlock.NumberOfSubsections) ';']);
end

if theBlock.EffectiveDielectricConstant~=0
    aCommands=char(aCommands,['Project.GeometryBlock.SonnetBox.EffectiveDielectricConstant=' sf(theBlock.EffectiveDielectricConstant) ';']);
end

aCommands=char(aCommands,['Project.deleteLayer(2);']);
aCommands=char(aCommands,['Project.deleteLayer(1);']);
for iCounter=1:length(theBlock.ArrayOfDielectricLayers)
    % Read the data for the layer
    Thickness=theBlock.ArrayOfDielectricLayers{iCounter}.Thickness;
    RelativeDielectricConstant=theBlock.ArrayOfDielectricLayers{iCounter}.RelativeDielectricConstant;
    RelativeMagneticPermeability=theBlock.ArrayOfDielectricLayers{iCounter}.RelativeMagneticPermeability;
    DielectricLossTangent=theBlock.ArrayOfDielectricLayers{iCounter}.DielectricLossTangent;
    MagneticLossTangent=theBlock.ArrayOfDielectricLayers{iCounter}.MagneticLossTangent;
    DielectricConductivity=theBlock.ArrayOfDielectricLayers{iCounter}.DielectricConductivity;
    NumberOfZPartitions=theBlock.ArrayOfDielectricLayers{iCounter}.NumberOfZPartitions;
    NameOfDielectricLayer=theBlock.ArrayOfDielectricLayers{iCounter}.NameOfDielectricLayer;
    RelativeDielectricConstantForZDirection=theBlock.ArrayOfDielectricLayers{iCounter}.RelativeDielectricConstantForZDirection;
    RelativeMagneticPermeabilityForZDirection=theBlock.ArrayOfDielectricLayers{iCounter}.RelativeMagneticPermeabilityForZDirection;
    DielectricLossTangentForZDirection=theBlock.ArrayOfDielectricLayers{iCounter}.DielectricLossTangentForZDirection;
    MagneticLossTangentForZDirection=theBlock.ArrayOfDielectricLayers{iCounter}.MagneticLossTangentForZDirection;
    DielectricConductivityForZDirection=theBlock.ArrayOfDielectricLayers{iCounter}.DielectricConductivityForZDirection;
    
    % Check if the layer is anisotropic or not
    if isempty(RelativeDielectricConstantForZDirection)
        % If the number of Z-partitions is zero
        % then dont include the optional argument
        if NumberOfZPartitions==0
            aCommands=char(aCommands,['Project.addDielectricLayer(' ...
                sf(NameOfDielectricLayer) ',' ...
                sf(Thickness) ',' ...
                sf(RelativeDielectricConstant)  ',' ...
                sf(RelativeMagneticPermeability) ',' ...
                sf(DielectricLossTangent) ',' ...
                sf(MagneticLossTangent) ',' ...
                sf(DielectricConductivity) ');']);
        else
            aCommands=char(aCommands,['Project.addDielectricLayer('  ...
                sf(NameOfDielectricLayer) ',' ...
                sf(Thickness) ',' ...
                sf(RelativeDielectricConstant)  ',' ...
                sf(RelativeMagneticPermeability) ',' ...
                sf(DielectricLossTangent) ',' ...
                sf(MagneticLossTangent) ','...
                sf(DielectricConductivity) ','...
                sf(NumberOfZPartitions) ');']);
        end
    else
        % If the number of Z-partitions is zero
        % then dont include the optional argument
        if NumberOfZPartitions==0
            aCommands=char(aCommands,['Project.addAnisotropicDielectricLayer('  ...
                sf(NameOfDielectricLayer) ',' ...
                sf(Thickness) ',' ...
                sf(RelativeDielectricConstant)  ',' ...
                sf(RelativeMagneticPermeability) ',' ...
                sf(DielectricLossTangent) ',' ...
                sf(MagneticLossTangent) ','...
                sf(DielectricConductivity) ','...
                sf(RelativeDielectricConstantForZDirection) ','...
                sf(RelativeMagneticPermeabilityForZDirection) ','...
                sf(DielectricLossTangentForZDirection) ','...
                sf(MagneticLossTangentForZDirection) ','...
                sf(DielectricConductivityForZDirection) ');']);
        else
            aCommands=char(aCommands,['Project.addAnisotropicDielectricLayer('  ...
                sf(NameOfDielectricLayer) ',' ...
                sf(Thickness) ',' ...
                sf(RelativeDielectricConstant)  ',' ...
                sf(RelativeMagneticPermeability) ',' ...
                sf(DielectricLossTangent) ',' ...
                sf(MagneticLossTangent) ','...
                sf(DielectricConductivity) ','...
                sf(RelativeDielectricConstantForZDirection) ','...
                sf(RelativeMagneticPermeabilityForZDirection) ','...
                sf(DielectricLossTangentForZDirection) ','...
                sf(MagneticLossTangentForZDirection) ','...
                sf(DielectricConductivityForZDirection) ','...
                sf(NumberOfZPartitions) ');']);
        end
    end
end

end

function aCommands=DecompileCircuitBlock(theBlock)

% Remove all existing networks and add the new networks
aCommands='Project.deleteAllElements();';

for iCounter=1:length(theBlock.ArrayOfResistorElements)
    aElement=theBlock.ArrayOfResistorElements{iCounter};
    if aElement.NetworkIndex~=1
        aCommands=char(aCommands,['Project.addResistorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ResistanceValue) ');']);
    else
        aCommands=char(aCommands,['Project.addResistorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ResistanceValue) ',' ...
            sf(aElement.NetworkIndex) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfInductorElements)
    aElement=theBlock.ArrayOfInductorElements{iCounter};
    if aElement.NetworkIndex~=1
        aCommands=char(aCommands,['Project.addInductorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.InductanceValue) ');']);
    else
        aCommands=char(aCommands,['Project.addInductorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.InductanceValue) ',' ...
            sf(aElement.NetworkIndex) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfCapacitorElements)
    aElement=theBlock.ArrayOfCapacitorElements{iCounter};
    if aElement.NetworkIndex~=1
        aCommands=char(aCommands,['Project.addCapacitorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.CapacitanceValue) ');']);
    else
        aCommands=char(aCommands,['Project.addCapacitorElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.CapacitanceValue) ',' ...
            sf(aElement.NetworkIndex) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfTransmissionLineElements)
    aElement=theBlock.ArrayOfTransmissionLineElements{iCounter};
    if aElement.NetworkIndex~=1
        aCommands=char(aCommands,['Project.addTransmissionLineElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ImpedanceValue) ',' ...
            sf(aElement.LengthValue) ',' ...
            sf(aElement.Frequency) ');']);
    else
        aCommands=char(aCommands,['Project.addTransmissionLineElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ImpedanceValue) ',' ...
            sf(aElement.LengthValue) ',' ...
            sf(aElement.Frequency) ',' ...
            sf(aElement.NetworkIndex) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfPhysicalTransmissionLineElements)
    aElement=theBlock.ArrayOfPhysicalTransmissionLineElements{iCounter};
    if aElement.NetworkIndex==1 && isempty(aElement.GroundNode)
        aCommands=char(aCommands,['Project.addPhysicalTransmissionLineElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ImpedanceValue) ',' ...
            sf(aElement.LengthValue) ',' ...
            sf(aElement.FrequencyValue) ',' ...
            sf(aElement.EeffValue) ',' ...
            sf(aElement.AttenuationValue) ');']);
    elseif aElement.NetworkIndex~=1 && isempty(aElement.GroundNode)
        aCommands=char(aCommands,['Project.addPhysicalTransmissionLineElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ImpedanceValue) ',' ...
            sf(aElement.LengthValue) ',' ...
            sf(aElement.FrequencyValue) ',' ...
            sf(aElement.EeffValue) ',' ...
            sf(aElement.AttenuationValue) ',' ...
            sf(aElement.NetworkIndex) ');']);
    else
        aCommands=char(aCommands,['Project.addPhysicalTransmissionLineElement(' ...
            sf(aElement.NodeNumber1) ',' ...
            sf(aElement.NodeNumber2) ',' ...
            sf(aElement.ImpedanceValue) ',' ...
            sf(aElement.LengthValue) ',' ...
            sf(aElement.FrequencyValue) ',' ...
            sf(aElement.EeffValue) ',' ...
            sf(aElement.AttenuationValue) ',' ...
            sf(aElement.NetworkIndex) ',' ...
            sf(aElement.GroundNode) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfDataResponseFileElements)
    aElement=theBlock.ArrayOfDataResponseFileElements{iCounter};
    if aElement.NetworkIndex==1 && isempty(aElement.GroundNode)
        aCommands=char(aCommands,['Project.addDataResponseFileElement(' ...
            sf(aElement.Filename) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ');']);
    elseif aElement.NetworkIndex~=1 && isempty(aElement.GroundNode)
        aCommands=char(aCommands,['Project.addDataResponseFileElement(' ...
            sf(aElement.Filename) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.NetworkIndex) ');']);
    else
        aCommands=char(aCommands,['Project.addDataResponseFileElement(' ...
            sf(aElement.Filename) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.NetworkIndex) ',' ...
            sf(aElement.GroundNode) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfProjectFileElements)
    aElement=theBlock.ArrayOfProjectFileElements{iCounter};
    if aElement.NetworkIndex~=1
        aCommands=char(aCommands,['Project.addProjectFileElement(' ...
            sf(aElement.Filename) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.UseSweepFromSubproject) ');']);
    else
        aCommands=char(aCommands,['Project.addProjectFileElement(' ...
            sf(aElement.Filename) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.UseSweepFromSubproject) ',' ...
            sf(aElement.NetworkIndex) ');']);
    end
end

for iCounter=1:length(theBlock.ArrayOfNetworkElements)
    aElement=theBlock.ArrayOfNetworkElements{iCounter};
    if strcmp(aElement.PortType,'Z')==1 % Real + Imaginary port terminations
        aCommands=char(aCommands,['Project.addNetworkElement(' ...
            sf(aElement.Name) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.Resistance) ',' ...
            sf(aElement.ImaginaryResistance) ');']);
    elseif strcmp(aElement.PortType,'TERM')==1
        aPortSettings='[';
        for jCounter=1:length(aElement.Resistance)
            aPortSettings=[aPortSettings sf(aElement.Resistance(jCounter)) ','...
                sf(aElement.Reactance(jCounter)) ';']; %#ok<*AGROW>
        end
        aPortSettings(end)=']';
        
        aCommands=char(aCommands,['Project.addNetworkElement(' ...
            sf(aElement.Name) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            aPortSettings ');']);
    elseif strcmp(aElement.PortType,'FTERM')==1
        aPortSettings='[';
        for jCounter=1:length(aElement.Resistance)
            aPortSettings=[aPortSettings sf(aElement.Resistance(jCounter)) ',' ...
                sf(aElement.Reactance(jCounter)) ',' ...
                sf(aElement.Inductance(jCounter)) ',' ...
                sf(aElement.Capacitance(jCounter)) ';'];
        end
        aPortSettings(end)=']';
        
        aCommands=char(aCommands,['Project.addNetworkElement(' ...
            sf(aElement.Name) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            aPortSettings ');']);
    elseif strcmp(aElement.PortType,'R')==1 % Resistive port terminations
        aCommands=char(aCommands,['Project.addNetworkElement(' ...
            sf(aElement.Name) ',' ...
            sf(aElement.ArrayOfPortNodeNumbers) ',' ...
            sf(aElement.Resistance) ');']);
    end
end

end