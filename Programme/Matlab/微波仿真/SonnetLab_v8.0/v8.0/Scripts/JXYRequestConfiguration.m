% This class stores current data export configuration settings. These settings are used 
% by JXYRequest to export current data from Sonnet projects.
%
% Usage:
%
%   JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,theGridX,theGridY)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY' or 'JXY'. thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for. theGridX and theGridY will specify many datapoints at which
%   the current will be calculated.
%
%
%   JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,...
%                theFrequency,theGridX,theGridY,theLevel)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY' or 'JXY'. thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for. theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel].
%
%
%   JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
%                theGridX,theGridY,theLevel,theComplex)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY' or 'JXY'. thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for. theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel]. theComplex should be either
%   true or false.
%
%
%   JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
%                theGridX,theGridY,theLevel,theComplex,theParameterName,theParameterValue)
%   theFilename is the name of the file that the current data should be exported to.
%   theLabel provides users with the ability to assign a unique identifier to the export.
%   theRegion must be either a JXYLine object, a JXYRectangle object or []. If
%   theRegion is [] then the currents for the entire layout will be outputted. theType
%   should be either 'JX','JY' or 'JXY'. thePorts should be a vector of JXYPort
%   objects. theFrequency should be a vector of the desired frequency values that Sonnet
%   should return data for. theGridX and theGridY will specify
%   many datapoints at which the current will be calculated. theLevel specifies what
%   metalization level(s) should be outputted. theLevel should be [] if all levels
%   should be outputted; theLevel should be a single number (ex: 4) if only one level
%   should be outputted; if more than one level should be outputted then theLevel should
%   be a vector in the form of [startLevel, endLevel]. theComplex should be either
%   true or false. If the user would like to specify values for parameters they may
%   use the last two arguments. theParameterName should either be a vertical vector of
%   strings (use strvcat) or a cell array of strings. theParameterValue should be either
%   a vector or a cell array of values such that the Nth element of theParameterValue
%   is the value for the parameter specified by the Nth element of theParameterName.
%
% Examples:
%   JXYRequestConfiguration('Export1.csv','Iteration 1',[],'jx',p1,1e9,5,5)
%   JXYRequestConfiguration('Export2.csv','Iteration 2',Rectange,'jy',[p1 p2],[1e9 10e9],0,5,5,true,'X1',1.1)
%   JXYRequestConfiguration('Export3.csv','Iteration 3',Line,'jxy',[p1 p2],[1e9 10e9],1,5,5,true,strvcat('X1','X2'),[1.1 1.2])
%
% See also JXYRequest

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

classdef JXYRequestConfiguration < handle
    
    properties
        Filename
        Label
        Region
        Type
        Ports
        GridX
        GridY
        Frequency
        Level
        Complex
        ParameterName
        ParameterValue
    end
    
    methods
        
        function obj=JXYRequestConfiguration(theFilename,theLabel,theRegion,theType,thePorts,theFrequency,...
                theGridX,theGridY,theLevel,theComplex,theParameterName,theParameterValue)
            
            obj.Filename=theFilename;
            obj.Label=theLabel;
            obj.Region=theRegion;
            obj.Type=theType;
            obj.GridX=theGridX;
            obj.GridY=theGridY;
            obj.Frequency=theFrequency;
            obj.Ports=thePorts;
            
            if nargin < 9
                obj.Level=[];
            else
                obj.Level=theLevel;
            end
            
            if nargin < 10
                obj.Complex=false;
            else
                obj.Complex=theComplex;
            end
            
            if nargin < 11
                obj.ParameterName=[];
                obj.ParameterValue=[];
            else
                % Convert the parameter name to a cell array
                % and the parameter value to a matrix
                obj.ParameterName=cell(size(theParameterName,1),1);
                if isa(theParameterName,'char')
                    for iCounter=1:size(theParameterName,1)
                        obj.ParameterName{iCounter}=theParameterName(iCounter,:);
                    end
                else
                    obj.ParameterName=theParameterName;
                end
                obj.ParameterValue=cell(length(theParameterValue));
                if isa(theParameterValue,'cell')
                    obj.ParameterValue=cell2mat(theParameterValue);
                else
                    obj.ParameterValue=theParameterValue;
                end
            end
            
        end
        
        function write(obj,theDom)
            % Define the root node. All current
            % requests are children of this node.
            aRootNode = theDom.getDocumentElement;
            
            aRequest = theDom.createElement('JXY_Export');
            aRootNode.appendChild(aRequest);
            aLabel=theDom.createAttribute('Label');
            aLabel.setNodeValue(obj.Label);
            aRequest.setAttributeNode(aLabel);
            aFilename=theDom.createAttribute('Filename');
            aFilename.setNodeValue(obj.Filename);
            aRequest.setAttributeNode(aFilename);
            
            % Determine values for the Region
            if isempty(obj.Region)
                aRegion = theDom.createElement('Region');
                aRequest.appendChild(aRegion);
                aStyle=theDom.createAttribute('Style');
                aStyle.setNodeValue('Whole');
                aRegion.setAttributeNode(aStyle);
            else
                obj.Region.write(theDom,aRequest);
            end
            
            % Determine values for the level
            aLevels = theDom.createElement('Levels');
            aRequest.appendChild(aLevels);
            
            if isempty(obj.Level)
                
                aRange=theDom.createAttribute('Range');
                aRange.setNodeValue('ALL');
                aLevels.setAttributeNode(aRange);
                
            elseif length(obj.Level) > 1
                
                aRange=theDom.createAttribute('Range');
                aRange.setNodeValue('Some');
                aLevels.setAttributeNode(aRange);
                
                aStart=theDom.createAttribute('Start');
                aStart.setNodeValue(num2str(obj.Level(1)));
                aLevels.setAttributeNode(aStart);
                
                aEnd=theDom.createAttribute('End');
                aEnd.setNodeValue(num2str(obj.Level(2)));
                aLevels.setAttributeNode(aEnd);
                
            else
                
                aRange=theDom.createAttribute('Range');
                aRange.setNodeValue('One');
                aLevels.setAttributeNode(aRange);
                
                aLevel=theDom.createAttribute('Level');
                aLevel.setNodeValue(num2str(obj.Level));
                aLevels.setAttributeNode(aLevel);
                
            end
            
            % Determine values for the Grid
            aGrid = theDom.createElement('Grid');
            aRequest.appendChild(aGrid);
            
            aXStep=theDom.createAttribute('XStep');
            aXStep.setNodeValue(num2str(obj.GridX));
            aGrid.setAttributeNode(aXStep);
            
            aYStep=theDom.createAttribute('YStep');
            aYStep.setNodeValue(num2str(obj.GridY));
            aGrid.setAttributeNode(aYStep);
            
            % Determine values for the Measurement
            aMeasurement = theDom.createElement('Measurement');
            aRequest.appendChild(aMeasurement);
            
            if strcmpi(obj.Type,'jxy')
                aType=theDom.createAttribute('Type');
                aType.setNodeValue('JXY');
                aMeasurement.setAttributeNode(aType);
            elseif strcmpi(obj.Type,'jx')
                aType=theDom.createAttribute('Type');
                aType.setNodeValue('JX');
                aMeasurement.setAttributeNode(aType);
            elseif strcmpi(obj.Type,'jy')
                aType=theDom.createAttribute('Type');
                aType.setNodeValue('JY');
                aMeasurement.setAttributeNode(aType);
            elseif strcmpi(obj.Type,'PWR')
                aType=theDom.createAttribute('Type');
                aType.setNodeValue('pwr');
                aMeasurement.setAttributeNode(aType);
            else
                error('Improper type for measurement');
            end
            
            if obj.Complex
                aComplex=theDom.createAttribute('Complex');
                aComplex.setNodeValue('Yes');
                aMeasurement.setAttributeNode(aComplex);
            else
                aComplex=theDom.createAttribute('Complex');
                aComplex.setNodeValue('No');
                aMeasurement.setAttributeNode(aComplex);
            end
            
            % Determine values for the Drive
            aDrive = theDom.createElement('Drive');
            aRequest.appendChild(aDrive);
            
            for iCounter=1:length(obj.Ports)
                obj.Ports(iCounter).write(theDom,aDrive);
            end
            
            % Determine values for the Locator
            aLocator = theDom.createElement('Locator');
            aRequest.appendChild(aLocator);
            
            for iCounter=1:length(obj.Frequency)
                aFrequency = theDom.createElement('Frequency');
                aLocator.appendChild(aFrequency);
                
                aValue=theDom.createAttribute('Value');
                aValue.setNodeValue(num2str(obj.Frequency(iCounter)));
                aFrequency.setAttributeNode(aValue);
            end
            
            if ~isempty(obj.ParameterName)
                for iCounter=1:length(obj.ParameterName)
                    aParameters = theDom.createElement('Parameters');
                    aLocator.appendChild(aParameters);
                    
                    aParameter=theDom.createAttribute(obj.ParameterName{iCounter});
                    aParameter.setNodeValue(num2str(obj.ParameterValue(iCounter)));
                    aParameters.setAttributeNode(aParameter);
                end
                
            end
            
        end
        
    end
    
end