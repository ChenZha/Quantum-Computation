function arrayOfBlobs = AntennaDemoIdBlobs(theArrayOfPolygons,YNumberOfPatches)

arrayOfBlobs={};

for iCounter=1:length(theArrayOfPolygons)
    if theArrayOfPolygons{iCounter}.MetalType==1
        
        % Make a new blob
        arrayOfBlobs{length(arrayOfBlobs)+1}=AntennaDemoBlob(); %#ok<*AGROW>
        
        % Add the polygon to the blob
        arrayOfBlobs{length(arrayOfBlobs)}.add(theArrayOfPolygons{iCounter});
        
        % Search for adjacent polygons
        adjacentSearch(iCounter,arrayOfBlobs{length(arrayOfBlobs)},theArrayOfPolygons,YNumberOfPatches)
        
    end
end

% Remove duplicate blobs
aCounterMax=length(arrayOfBlobs);
iCounter=1;
while iCounter < aCounterMax 
    jCounter=iCounter+1;
    while jCounter <= aCounterMax
        if arrayOfBlobs{iCounter} == arrayOfBlobs{jCounter}
            arrayOfBlobs(jCounter)=[];
            aCounterMax=aCounterMax-1;
            jCounter=jCounter-1;
        end
        jCounter=jCounter+1;
    end  
    iCounter=iCounter+1;
end

end

function adjacentSearch(theIndex,theBlob,theArrayOfPolygons,YNumberOfPatches)

% Find a polygon to the left
if (theIndex-YNumberOfPatches) > 0
    if theArrayOfPolygons{theIndex-YNumberOfPatches}.MetalType==1
        if ~theBlob.contains(theArrayOfPolygons{theIndex-YNumberOfPatches})
            theArrayOfPolygons{theIndex-YNumberOfPatches}.MetalType=1;
            theBlob.add(theArrayOfPolygons{theIndex-YNumberOfPatches});
            adjacentSearch(theIndex-YNumberOfPatches,theBlob,theArrayOfPolygons,YNumberOfPatches)
        end
    end
end

% Find a polygon to the right
if (theIndex+YNumberOfPatches) < length(theArrayOfPolygons)
    if theArrayOfPolygons{theIndex+YNumberOfPatches}.MetalType==1
        if ~theBlob.contains(theArrayOfPolygons{theIndex+YNumberOfPatches})
            theArrayOfPolygons{theIndex+YNumberOfPatches}.MetalType=1;
            theBlob.add(theArrayOfPolygons{theIndex+YNumberOfPatches});
            adjacentSearch(theIndex+YNumberOfPatches,theBlob,theArrayOfPolygons,YNumberOfPatches)
        end
    end
end

% Find a polygon to the top
TopRowValue=theArrayOfPolygons{1}.CentroidYCoordinate;
if theArrayOfPolygons{theIndex}.CentroidYCoordinate ~= TopRowValue
    if theArrayOfPolygons{theIndex-1}.MetalType==1
        if ~theBlob.contains(theArrayOfPolygons{theIndex-1})
            theArrayOfPolygons{theIndex-1}.MetalType=1;
            theBlob.add(theArrayOfPolygons{theIndex-1});
            adjacentSearch(theIndex-1,theBlob,theArrayOfPolygons,YNumberOfPatches)
        end
    end
end

% Find a polygon to the bottom
BottomRowValue=theArrayOfPolygons{YNumberOfPatches}.CentroidYCoordinate;
if theArrayOfPolygons{theIndex}.CentroidYCoordinate ~= BottomRowValue
    if theArrayOfPolygons{theIndex+1}.MetalType==1
        if ~theBlob.contains(theArrayOfPolygons{theIndex+1})
            theArrayOfPolygons{theIndex+1}.MetalType=1;
            theBlob.add(theArrayOfPolygons{theIndex+1});
            adjacentSearch(theIndex+1,theBlob,theArrayOfPolygons,YNumberOfPatches)
        end
    end
end

end