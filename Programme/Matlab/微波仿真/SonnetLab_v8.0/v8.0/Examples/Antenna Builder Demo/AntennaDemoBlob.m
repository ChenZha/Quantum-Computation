classdef AntennaDemoBlob < handle
    % Blobs are antenna shapes
    
    properties
        arrayOfPolygonsInTheBlob
    end
    
    methods%#ok<*MANU>      
        
        function obj = AntennaDemoBlob()
           obj.arrayOfPolygonsInTheBlob={}; 
        end
            
        function add(obj,thePolygon)
            obj.arrayOfPolygonsInTheBlob{length(obj.arrayOfPolygonsInTheBlob)+1}=thePolygon;
        end
        
        function isInside = contains(obj,thePolygon)
            isInside=false;
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if thePolygon == obj.arrayOfPolygonsInTheBlob{iCounter}
                    isInside=true;
                end
            end
        end
        
        function isEqual=eq(obj,theBlob)
            isEqual=true;
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if ~theBlob.contains(obj.arrayOfPolygonsInTheBlob{iCounter})
                   isEqual=false; 
                end
            end
        end
        
        % Grow in a direction
        function growBlobRight(obj,theProject,YNumberOfPatches) %#ok<*INUSD>
            arrayOfPolygonsAdded={};
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType==1
                    
                    % Get the polygon's index
                    aIndexForPolygon=theProject.findPolygonIndex(obj.arrayOfPolygonsInTheBlob{iCounter});
                    
                    % Make the polygon on the right be thin
                    if (aIndexForPolygon+YNumberOfPatches) < length(theProject.GeometryBlock.ArrayOfPolygons)
                        theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon+YNumberOfPatches}.MetalType=1;
                        arrayOfPolygonsAdded{length(arrayOfPolygonsAdded)+1}=theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon+YNumberOfPatches}; %#ok<*AGROW>
                    end
                end
            end
                        
            % Add the new polygons to the blob
            for iCounter=1:length(arrayOfPolygonsAdded)
                obj.arrayOfPolygonsInTheBlob{length(obj.arrayOfPolygonsInTheBlob)+1}=arrayOfPolygonsAdded{iCounter};
            end
        end
        
        function growBlobLeft(obj,theProject,YNumberOfPatches)
            arrayOfPolygonsAdded={};
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType==1
                    
                    % Get the polygon's index
                    aIndexForPolygon=theProject.findPolygonIndex(obj.arrayOfPolygonsInTheBlob{iCounter});
                    
                    % Make the polygon on the left be thin
                    if (aIndexForPolygon-YNumberOfPatches) > 0
                        theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon-YNumberOfPatches}.MetalType=1;
                        arrayOfPolygonsAdded{length(arrayOfPolygonsAdded)+1}=theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon-YNumberOfPatches};
                    end
                end
            end
                        
            % Add the new polygons to the blob
            for iCounter=1:length(arrayOfPolygonsAdded)
                obj.arrayOfPolygonsInTheBlob{length(obj.arrayOfPolygonsInTheBlob)+1}=arrayOfPolygonsAdded{iCounter};
            end
        end
        
        function growBlobTop(obj,theProject,YNumberOfPatches)
            arrayOfPolygonsAdded={};
            
            % Find the Y centroid for patches on the top row
            TopRowValue=theProject.GeometryBlock.ArrayOfPolygons{1}.CentroidYCoordinate;
            
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType==1 && obj.arrayOfPolygonsInTheBlob{iCounter}.CentroidYCoordinate ~= TopRowValue
                    
                    % Get the polygon's index
                    aIndexForPolygon=theProject.findPolygonIndex(obj.arrayOfPolygonsInTheBlob{iCounter});
                    
                    % Make the polygon on the top be thin
                    if (aIndexForPolygon-1) < length(theProject.GeometryBlock.ArrayOfPolygons)
                        theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon-1}.MetalType=1;
                        arrayOfPolygonsAdded{length(arrayOfPolygonsAdded)+1}=theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon-1};
                    end
                end
            end
                        
            % Add the new polygons to the blob
            for iCounter=1:length(arrayOfPolygonsAdded)
                obj.arrayOfPolygonsInTheBlob{length(obj.arrayOfPolygonsInTheBlob)+1}=arrayOfPolygonsAdded{iCounter};
            end
        end
        
        function growBlobBottom(obj,theProject,YNumberOfPatches)
            arrayOfPolygonsAdded={};
            
            % Find the Y centroid for patches on the bottom row
            BottomRowValue=theProject.GeometryBlock.ArrayOfPolygons{YNumberOfPatches}.CentroidYCoordinate;
            
            for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
                if obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType==1 && obj.arrayOfPolygonsInTheBlob{iCounter}.CentroidYCoordinate ~= BottomRowValue
                    
                    % Get the polygon's index
                    aIndexForPolygon=theProject.findPolygonIndex(obj.arrayOfPolygonsInTheBlob{iCounter});
                    
                    % Make the polygon on the bottom be thin
                    if (aIndexForPolygon+1) < length(theProject.GeometryBlock.ArrayOfPolygons)
                        theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon+1}.MetalType=1;
                        arrayOfPolygonsAdded{length(arrayOfPolygonsAdded)+1}=theProject.GeometryBlock.ArrayOfPolygons{aIndexForPolygon+1}; 
                    end
                end
            end
            
            % Add the new polygons to the blob
            for iCounter=1:length(arrayOfPolygonsAdded)
                obj.arrayOfPolygonsInTheBlob{length(obj.arrayOfPolygonsInTheBlob)+1}=arrayOfPolygonsAdded{iCounter};
            end
        end
        
        function convertBlobToThickMetal(obj)
            % Make all the polygons thick
           for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
               obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType=0;
           end
        end
        
        function convertBlobToThinMetal(obj)
            % Make all the polygons thin
           for iCounter=1:length(obj.arrayOfPolygonsInTheBlob)
               obj.arrayOfPolygonsInTheBlob{iCounter}.MetalType=1;
           end
        end
        
    end
end

