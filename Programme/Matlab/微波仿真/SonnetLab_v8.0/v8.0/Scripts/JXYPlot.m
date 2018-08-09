%JXYPlot    Plots JX/JY/JXY/PWR data
%
% JXYPlot(theFilename) Will plot the JXY data for the
%   specified CSV file of JXY data obtained from Sonnet.
%
% JXYPlot(theData) Will plot the JXY data for the
%   specified JXY data object obtained from JXYRead.
%
%
% Note: This function supports plotting 
%        'JX,,'JY',JXY', and heat flux data
% Note: This function may not be used with 
%        current data in complex form.
%
% Usage:
%   JXYPlot(theFilename)
%       Will plot the specified JXY export file
%
% Example:
%   JXYPlot('Project1.csv')
%
% See also JXYRequest, JXYRectange

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

function JXYPlot(theFilename, theMagPhase)
if ~exist('input', 'var'), theMagPhase = true; end

% Check if we got a struct or a filename.
% if we got a filename then read the file
% in order to obtain a struct.
if isstruct(theFilename)
    aExport=theFilename;
elseif isa(theFilename,'char')
    aExport=JXYRead(theFilename);
else
    error('Invalid input type. Must be a JXY data struct or a filename');
end

for iCounter=1:length(aExport)
          
    aIsFoundData=false;
    aMatrixToPlot={};
    
    if isfield(aExport(iCounter),'Data')          
        if any(aExport(iCounter).Data(:))
            aIsFoundData=true;

            % Replace zero with nan
            aMatrixToPlot=aExport(iCounter).Data;
            i=find(aMatrixToPlot==0);
            aMatrixToPlot(i)=NaN(size(i));
        else
            continue;
        end
    end
    
    aFigure=figure;
    
    if isfield(aExport(iCounter),'XDirectedData')
        if ~isempty(aExport(iCounter).XDirectedData)
            
            aIsFoundData=true;

            aExport(iCounter).Type='JX';

            % Replace zero with nan
            aMatrixToPlot=aExport(iCounter).XDirectedData;
            i=find(aMatrixToPlot==0);
            aMatrixToPlot(i)=NaN(size(i));
        end
    end
    
    if isfield(aExport(iCounter),'YDirectedData')        
        if ~isempty(aExport(iCounter).YDirectedData)
            aIsFoundData=true;

            aExport(iCounter).Type='JY';

            % Replace zero with nan
            aMatrixToPlot=aExport(iCounter).YDirectedData;
            i=find(aMatrixToPlot==0);
            aMatrixToPlot(i)=NaN(size(i));
        end
    end
    
    if aIsFoundData
        % Load the data
        if theMagPhase
            img=imagesc(abs(aMatrixToPlot));
        else
            img=imagesc(angle(aMatrixToPlot)*180/pi);
        end
        
        set(img,'alphadata',~isnan(aMatrixToPlot));
        set(gca,'color',[.7 .7 .7]);
        axis image
     
    elseif ~aIsFoundData
        error('This method may not be used with complex data sets.');
    end
    
    % Set the figure title
    aTitle=['File: ' aExport(iCounter).DataFilename ...
        ' Label: ' aExport(iCounter).Label ...
        ' Freq: ' num2str(aExport(iCounter).Frequency) ...
        ' Level: ' num2str(aExport(iCounter).Level) ...
        ' Type: ' aExport(iCounter).Type];
    set(aFigure,'Name',aTitle);
    
    % Load the custom color map
    
    colorbar
    
    % Remove the axes labels because they wont be correct
    aAxes=get(gcf,'CurrentAxes');
    set(aAxes,'YTickLabel',[]);
    set(aAxes,'XTickLabel',[]);
    axis equal
end

end