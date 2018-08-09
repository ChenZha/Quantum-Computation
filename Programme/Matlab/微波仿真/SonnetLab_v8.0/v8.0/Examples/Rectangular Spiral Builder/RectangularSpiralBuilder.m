% This function will build a Sonnet project with an 
% n turn spiral inductor. 
%
% SprialBuilder(n,w,s,d) builds an n turn spiral with
% the width of each turn being w, seperation between 
% turns being s and diameter of the innermost turn
% being d.
%
% SprialBuilder() builds an a spiral with a default
% set of values.
%
% This function is being released with permission
% from the original author. This script is publically 
% available on the Matlab file exchange website:
%   http://www.mathworks.com/matlabcentral/fileexchange/28975-spiral-inductor-builder

function RectangularSpiralBuilder(n,w,s,d)

if nargin == 0
    n=10;
    w=5;
    s=5;
    d=50;
end

if n < 1
    error('must be at least two turns');
end

p=SonnetProject();

p.deleteLayer(1);
p.deleteLayer(1);
p.addDielectricLayer('Air',250,1,1,0,0,0);
p.addDielectricLayer('Air',1,1,1,0,0,0);
p.addDielectricLayer('Alumina',25,9.8,1,.001,0,0);

% the size of the spiral is (2*n-1)*s + (2*n)*w + d;
% make the size of the box be double
size=(2*n-1)*s + (2*n)*w + d;
p.changeBoxSizeXY(2*size, 2*size);
p.changeCellSizeUsingNumberOfCells(5,5);

% start making the spiral at roughly the middle of the box
x=floor(size-.5*d);
y=floor(size-.5*d);

p.defineNewNormalMetalType('Gold',4.09e7,0.5,0.1);

p.addViaPolygonEasy(1,0,[x x+w x+w x],[y y y+w y+w],'Gold');
p.addViaPolygonEasy(1,0,[x-(n+1)*s-n*w x-(n+1)*s-n*w x-(n+1)*s-(n+1)*w x-(n+1)*s-(n+1)*w],[y y+w y+w y],'Gold');
p.addMetalPolygonEasy(0,[x+w x-(n+1)*s-(n+1)*w x-(n+1)*s-(n+1)*w x+w],[y y y+w y+w],'Gold');
p.addMetalPolygonEasy(1,[0 x-(n+1)*s-n*w x-(n+1)*s-n*w 0],[y y y+w y+w],'Gold');
p.addPortAtLocation(0,y);

p.addReferencePlane('LEFT','FIX',x-(n+1)*s-(n+1)*w);

for i=1:n
    p.addMetalPolygonEasy(1,[x x+d x+d x],[y y y+w y+w],'Gold');
    p.addMetalPolygonEasy(1,[x+d x+d+w x+d+w x+d],[y y y+d+w y+d+w],'Gold');
    p.addMetalPolygonEasy(1,[x+d+w x+d+w x-s-w x-s-w],[y+d+w y+d+2*w y+d+2*w y+d+w],'Gold');
    p.addMetalPolygonEasy(1,[x-s-w x-s x-s x-s-w],[y+d+w y+d+w y-s y-s],'Gold');
    
    x=x-s-w;
    y=y-s-w;
    d=d+2*w+2*s;
end

p.addMetalPolygonEasy(1,[x x+w x+w x],[y+w y+w 0 0],'Gold');
p.addPortAtLocation(x+w/2,0);
p.addReferencePlane('TOP','FIX',y+w+s);

p.saveAs('spiral.son');
p.openInSonnet(false);

end