function p = lbredblue(m)
% Light-Bertlein colormap.
%
%       'lbblue'       Single-hue progression to purlish-blue (default)
%       'lbbluegray'   Diverging progression from blue to gray
%       'lbbrownblue'  Orange-white-purple diverging scheme
%       'lbredblue'    Modified spectral scheme

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat=[175  53  71;
           216  82  88;
           239 133 122;
           245 177 139;
           249 216 168;
           242 238 197;
           216 236 241;
           154 217 238;
            68 199 239;
             0 170 226;
             0 116 188]/255;

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');