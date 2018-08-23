function p = lbbluegray(m)
% Light-Bertlein colormap.
%
%       'lbblue'       Single-hue progression to purlish-blue (default)
%       'lbbluegray'   Diverging progression from blue to gray
%       'lbbrownblue'  Orange-white-purple diverging scheme
%       'lbredblue'    Modified spectral scheme

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat=[  0 170 227;
            53 196 238;
           133 212 234;
           190 230 242;
           217 224 230;
           146 161 170;
           109 122 129;
            65  79  81]/255;

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');