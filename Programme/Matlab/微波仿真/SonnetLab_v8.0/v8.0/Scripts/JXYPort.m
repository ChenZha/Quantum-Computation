%  The JXYPort class defines the settings to be used for a port (or series of ports)
%  that are to be excited during a current export.
%
%  Usage:
%    aJXYPort=JXYPort(thePortNumber,theVoltage,thePhase,theResistance,theReactance,theInductance,theCapacitance)
%    thePortNumber may be either a number for a port or 'ALL' to indicate all ports should have
%    these values.
%
%    aJXYPort=JXYPort(aGeometryPort) will build an JXYPort out of an existing Sonnet geometry port object.
%    The values for resistance, inductance, capacitance, reactance, and inductance will be copied from
%    the geometry port. The voltage and phase values will be initialized to zero.
%
%  Examples:
%    p1=JXYPort('All',5,0,50,0,0,0)
%    p2=JXYPort(2,1,0,50,0,0,0)
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

classdef JXYPort < handle
    
    properties
        Number
        Voltage
        Phase
        Resistance
        Reactance
        Inductance
        Capacitance
    end
    
    methods
        function obj=JXYPort(theNumber,theVoltage,thePhase,theResistance,theReactance,theInductance,theCapacitance)
            
            % If the user specified an existing
            % geometry port as the base for a
            % jxy port then build a jxy port that
            % uses the specified port's values
            % and zero for voltage and phase.
            if nargin == 1
                % The variable theVoltage has the
                % geometry port object.
                aPort=theNumber;
                obj.Number=theNumber.PortNumber;
                obj.Voltage=0;
                obj.Phase=0;
                obj.Resistance=aPort.Resistance;
                obj.Reactance=aPort.Reactance;
                obj.Inductance=aPort.Inductance;
                obj.Capacitance=aPort.Capacitance;
                
            elseif nargin == 7
                % If the user specified the values
                % for each property of the JXY port.
                obj.Number=theNumber;
                obj.Voltage=theVoltage;
                obj.Phase=thePhase;
                obj.Resistance=theResistance;
                obj.Reactance=theReactance;
                obj.Inductance=theInductance;
                obj.Capacitance=theCapacitance;
            else
                error('Improper number of arguments')
            end
        end
        
        function write(obj,theDom,theDrive)
            
            aPort1 = theDom.createElement('JXYPort');
            theDrive.appendChild(aPort1);
            
            aNumber=theDom.createAttribute('Number');
            aNumber.setNodeValue(num2str(obj.Number));
            aPort1.setAttributeNode(aNumber);
            
            aVoltage=theDom.createAttribute('Voltage');
            aVoltage.setNodeValue(num2str(obj.Voltage));
            aPort1.setAttributeNode(aVoltage);
            
            aPhase=theDom.createAttribute('Phase');
            aPhase.setNodeValue(num2str(obj.Phase));
            aPort1.setAttributeNode(aPhase);
            
            aResistance=theDom.createAttribute('Resistance');
            aResistance.setNodeValue(num2str(obj.Resistance));
            aPort1.setAttributeNode(aResistance);
            
            aReactance=theDom.createAttribute('Reactance');
            aReactance.setNodeValue(num2str(obj.Reactance));
            aPort1.setAttributeNode(aReactance);
            
            aInductance=theDom.createAttribute('Inductance');
            aInductance.setNodeValue(num2str(obj.Inductance));
            aPort1.setAttributeNode(aInductance);
            
            aCapacitance=theDom.createAttribute('Capacitance');
            aCapacitance.setNodeValue(num2str(obj.Capacitance));
            aPort1.setAttributeNode(aCapacitance);
            
        end
    end
end

