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
% This demo was written by Bashir Souid

function p=CircularSpiralBuilder(n,w,s,d,filename)

if nargin == 0
    n=10;
    w=2;
    s=1;
    d=1;
    filename='spiral.son';
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
aCellSize=min([w,s,d])/5;
p.changeCellSizeUsingNumberOfCells(aCellSize,aCellSize);

% start making the spiral at roughly the middle of the box
x=size-.5*d;
y=size-.5*d;

innerpointsx=[];
outerpointsx=[];
innerpointsy=[];
outerpointsy=[];

delta=pi/10;
for theta=0:delta:n*2*pi
    
    r1=d+(s+w)/(2*pi)*theta;
    r2=d+w+(s+w)/(2*pi)*theta;
    
    x1=x+r1*cos(theta);
    y1=y+r1*sin(theta);
    
    x2=x+r2*cos(theta);
    y2=y+r2*sin(theta);

    innerpointsx=[innerpointsx x1]; %#ok<*AGROW>
    innerpointsy=[innerpointsy y1];
    
    outerpointsx=[outerpointsx x2];
    outerpointsy=[outerpointsy y2];
    
end

innerpointsx=fliplr(innerpointsx);
innerpointsy=fliplr(innerpointsy);
pointsx=[outerpointsx innerpointsx outerpointsx(1)];
pointsy=[outerpointsy innerpointsy outerpointsy(1)];

p.addMetalPolygonEasy(1,pointsx,pointsy);

lastX=outerpointsx(length(outerpointsx));
lastY=outerpointsy(length(outerpointsy));

% Add a feed line
x=[lastX-w 2*size 2*size lastX-w];
y=[lastY-w lastY-w lastY-2*w lastY-2*w];
p.addMetalPolygonEasy(1,x,y);
p.addPortAtLocation(2*size,lastY-1.5*w);

% Add a feed line
x=[lastX+2*w (size+.5*d) (size+.5*d) lastX+2*w];
y=[lastY+w lastY+w lastY lastY];
p.addMetalPolygonEasy(0,x,y);

x=[(size+.5*d) (size+.5*d)+w (size+.5*d)+w (size+.5*d)];
y=[lastY+w lastY+w lastY lastY];
p.addViaPolygonEasy(0,1,x,y);

x=[lastX+w 2*size 2*size lastX+w];
y=[lastY+w lastY+w lastY lastY];
p.addMetalPolygonEasy(1,x,y);

x=[lastX+w lastX+2*w lastX+2*w lastX+w];
y=[lastY+w lastY+w lastY lastY];
p.addViaPolygonEasy(0,1,x,y);
p.addPortAtLocation(2*size,lastY+.5*w);

p.saveAs(filename);

end