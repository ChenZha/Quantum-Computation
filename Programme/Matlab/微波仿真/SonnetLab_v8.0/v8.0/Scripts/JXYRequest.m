%JXYRequest   Stores one or more current export configurations
%
%   This class has functionality to build current data export configurations.
%       addExport(...)     Will add a current data export request to the array of export requests.
%       deleteExport(N)    Will delete the Nth export configuration from vector of outpur configurations
%       write(theFilename) Will write the output configurations to a XML request file
%
% Usage:
%
%   RequestObject.addExport(theFilename,theLabel,theRegion,theType,thePorts,theFrequencies,theGridX,theGridY)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY','JXY' or 'PWR' (for heat flux). thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for (units are Hz). theGridX and theGridY will specify
%   many datapoints at which the current will be calculated.
%
%
%   RequestObject.addExport(theFilename,theLabel,theRegion,theType,thePorts,theFrequencies,...
%                theGridX,theGridY,theLevel)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY','JXY' or 'PWR' (for heat flux). thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for (units are Hz). theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (Ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel].
%
%
%   RequestObject.addExport(theFilename,theLabel,theRegion,theType,thePorts,theFrequencies,...
%                theGridX,theGridY,theLevel,theComplex)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY','JXY' or 'PWR' (for heat flux). thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for (units are Hz). theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (Ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel]. theComplex should be either
%   true or false.
%
%
%   RequestObject.addExport(theFilename,theLabel,theRegion,theType,thePorts,theFrequencies,...
%                theGridX,theGridY,theLevel,theComplex,theParameterName,theParameterValue)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY','JXY' or 'PWR' (for heat flux). thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for (units are Hz). theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (Ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel]. theComplex should be either
%   true or false. If the user would like to specify values for parameters they may
%   use the last two arguments. theParameterName should either be a vertical vector of
%   strings (use strvcat) or a cell array of strings. theParameterValue should be either
%   a vector or a cell array of values such that the Nth element of theParameterValue
%   is the value for the parameter specified by the Nth element of theParameterName.
%
% Examples:
%   RequestObject.addExport('Output.csv','Out1',[],'jx',p1,[1e9 10e9],0,1,[1 8])
%   RequestObject.addExport('Output.csv','Out2',aLine,'jy',[p1 p2],[1e9 10e9],0,1,1,true,'X1',1.1)
%   RequestObject.addExport('Output.csv','Out3',aRectangle,'jxy',[p1 p2],[1e9 10e9],1,1,1,true,strvcat('X1','X2'),[1.1 1.2])
%   RequestObject.addExport('Output.csv','Out3',aRectangle,'pwr',[p1 p2],[1e9 10e9],1,1,1,true,strvcat('X1','X2'),[1.1 1.2])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef JXYRequest < handle
    
    properties
        ArrayOfExports
    end
    
    methods
        
        function obj=JXYRequest()
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function addExport(obj,theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
                theGridX,theGridY,theLevel,theComplex,theParameterName,theParameterValue)
            
            if nargin == 2 % We have recieved an existing Export object to include
                obj.ArrayOfExports{length(obj.ArrayOfExports)+1}=theFilename;
            elseif nargin == 9
                aExport=JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,theGridX,theGridY);
                obj.ArrayOfExports{length(obj.ArrayOfExports)+1}=aExport;
            elseif nargin == 10
                aExport=JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
                    theGridX,theGridY,theLevel);
                obj.ArrayOfExports{length(obj.ArrayOfExports)+1}=aExport;
            elseif nargin == 11
                aExport=JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
                    theGridX,theGridY,theLevel,theComplex);
                obj.ArrayOfExports{length(obj.ArrayOfExports)+1}=aExport;
            elseif nargin == 13
                aExport=JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
                    theGridX,theGridY,theLevel,theComplex,theParameterName,theParameterValue);
                obj.ArrayOfExports{length(obj.ArrayOfExports)+1}=aExport;
            else
                error('Improper number of arguments');
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function deleteExport(obj,theIndex)
            %addNewExport   Add a new export
            %   deleteExport(N) will delete the
            %   Nth export request from the array of
            %   export requests.
            %
            %   Example usage:
            %       Request.deleteExport(2)
            
            obj.ArrayOfExports(theIndex)=[];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function write(obj,theFilename)
            %write   Add a new export
            %   write(Filename) Will write the current request
            %   to an XML file to be used by Sonnet.
            %
            %   Example usage:
            %       Request.write('Request.xml')
            
            aDom = com.mathworks.xml.XMLUtils.createDocument('JXY_Export_Set');
            
            for iCounter=1:length(obj.ArrayOfExports)
                obj.ArrayOfExports{iCounter}.write(aDom);
            end
            
            xmlwrite(theFilename,aDom);
            
        end
    end
    
end
