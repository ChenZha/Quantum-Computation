% This tutorial provides a hands on demonstration of the SonnetLab project decompiler.
% The Sonnet project decompiler will read an existing Sonnet project from the hard drive
% and generate a list of SonnetLab compatable Matlab commands that can be used to create
% a default Sonnet project file that matches the passed project. The project decompiler
% is a useful tool for learning how to use SonnetLab features and it can be used to
% help generate project templates that, with a few modifications, may be used to simplify
% the automation of circuit design with SonnetLab.
%
% This example will generate a Matlab script that, when run, will create a 
% Sonnet project file on the hard drive matching the passed Sonnet project file. 
%
% This demo was written by Bashir Souid

function Driver(theSonFilename)

% If no filename was specified we will default to run the included demo file
if nargin == 0
    theSonFilename = 'Filter.son';
end

% Decompile the Sonnet Project file into SonnetLab compatable Matlab commands
aCommands = SonnetProjectDecompile(theSonFilename);

% Write the commands out to a .m file with the same name as the project
aMFilename = strrep(theSonFilename, '.son', '.m');
aFile = fopen(aMFilename, 'w');

for i = 1:size(aCommands,1)
    fprintf(aFile, '%s\n',aCommands(i,:));
end

disp(['Operation Complete. The file ' aMFilename ' contains the commands to decompile ' theSonFilename])

end