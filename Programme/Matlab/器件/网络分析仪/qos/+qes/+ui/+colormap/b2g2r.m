function p = b2g2r(m)
%BLUE2RED  colormap showing a gradient from blue to green to red.
%
% Author: David Legland
% e-mail: david.legland@jouy.inra.fr
% Created: 2006-05-24
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).
if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

r = zeros(256,1);
r(128:192) = linspace(0, 1, 65);
r(192:256)=1;

g = zeros(256,1);
g(1:64) = linspace(0,1,64);
g(64:192)=1;
g(192:256) = linspace(1, 0, 65);

b = zeros(256,1);
b(1:64)=1;
b(64:128) = linspace(1,0,65);

cmap_mat = [r g b];

xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');

