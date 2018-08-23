%function mHist = hist2d ([vY, vX], vYEdge, vXEdge)
%2 Dimensional Histogram
%Counts number of points in the bins defined by vYEdge, vXEdge.
%size(vX) == size(vY) == [n,1]
%size(mHist) == [length(vYEdge) -1, length(vXEdge) -1]
%
%EXAMPLE
%   mYX = rand(100,2);
%   vXEdge = linspace(0,1,10);
%   vYEdge = linspace(0,1,20);
%   mHist2d = hist2d(mYX,vYEdge,vXEdge);
%
%   nXBins = length(vXEdge);
%   nYBins = length(vYEdge);
%   vXLabel = 0.5*(vXEdge(1:(nXBins-1))+vXEdge(2:nXBins));
%   vYLabel = 0.5*(vYEdge(1:(nYBins-1))+vYEdge(2:nYBins));
%   pcolor(vXLabel, vYLabel,mHist2d); colorbar
function [vXLabel,vYLabel,mHist] = hist2d (X, Y, XBinEdges, YBinEdges)
if length(X)~=length(Y)
    error ('X, Y length not equal.')
end
nRow = length (XBinEdges)-1;
nCol = length (YBinEdges)-1;
mHist = zeros(nRow,nCol);
for iRow = 1:nRow
    rRowLB = XBinEdges(iRow);
    rRowUB = XBinEdges(iRow+1);
    vColFound = Y((X > rRowLB) & (X <= rRowUB));
    if (~isempty(vColFound))
        mHist(iRow, :)= histcounts(vColFound, YBinEdges);
    end
end
vXLabel = 0.5*(XBinEdges(1:end-1)+XBinEdges(2:end));
vYLabel = 0.5*(YBinEdges(1:end-1)+YBinEdges(2:end));


