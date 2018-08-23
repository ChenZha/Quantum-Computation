function p = lbblue(m)
% Light-Bertlein colormap.
%
%       'lbblue'       Single-hue progression to purlish-blue (default)
%       'lbbluegray'   Diverging progression from blue to gray
%       'lbbrownblue'  Orange-white-purple diverging scheme
%       'lbredblue'    Modified spectral scheme

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat=[243 246 248;
           224 232 240;
           171 209 236;
           115 180 224;
            35 157 213;
             0 142 205;
             0 122 192]/255;

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');