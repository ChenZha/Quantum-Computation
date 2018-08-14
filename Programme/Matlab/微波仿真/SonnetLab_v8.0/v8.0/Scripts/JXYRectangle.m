% This class defines a rectangular region where current data will be exported.
%
% Usage:
%   JXYRectangle(theLeft,theRight,theTop,theBottom)
%
% Example:
%   JXYRectangle(70,770,38,488)
%
% See also JXYRequest, JXYLine

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

classdef JXYRectangle < handle
    
    properties
        Left
        Right
        Top
        Bottom
    end
    
    methods
        function obj=JXYRectangle(theLeft,theRight,theTop,theBottom)
            obj.Left=theLeft;
            obj.Right=theRight;
            obj.Top=theTop;
            obj.Bottom=theBottom;
        end
        
        function write(obj,theDom,theRequest)
            
            aRegion = theDom.createElement('Region');
            theRequest.appendChild(aRegion);
            
            aStyle=theDom.createAttribute('Style');
            aStyle.setNodeValue('Rect');
            aRegion.setAttributeNode(aStyle);
            
            aLeft=theDom.createAttribute('Left');
            aLeft.setNodeValue(num2str(obj.Left));
            aRegion.setAttributeNode(aLeft);
            
            aTop=theDom.createAttribute('Top');
            aTop.setNodeValue(num2str(obj.Top));
            aRegion.setAttributeNode(aTop);
            
            aRight=theDom.createAttribute('Right');
            aRight.setNodeValue(num2str(obj.Right));
            aRegion.setAttributeNode(aRight);
            
            aBottom=theDom.createAttribute('Bottom');
            aBottom.setNodeValue(num2str(obj.Bottom));
            aRegion.setAttributeNode(aBottom);
        end
    end
end

