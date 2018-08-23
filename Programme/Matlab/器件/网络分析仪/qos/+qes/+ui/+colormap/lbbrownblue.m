function p = lbbrownblue(m)
% Light-Bertlein colormap.
%
%       'lbblue'       Single-hue progression to purlish-blue (default)
%       'lbbluegray'   Diverging progression from blue to gray
%       'lbbrownblue'  Orange-white-purple diverging scheme
%       'lbredblue'    Modified spectral scheme

if nargin < 1
    m = size(get(gcf,'colormap'),1); 
end

cmap_mat=[144 100  44;
           187 120  54;
           225 146  65;
           248 184 139;
           244 218 200;
           241 244 245;
           207 226 240;
           160 190 225;
           109 153 206;
            70  99 174;
            24  79 162]/255;

%interpolate values
xin=linspace(0,1,m)';
xorg=linspace(0,1,size(cmap_mat,1));

p(:,1)=interp1(xorg,cmap_mat(:,1),xin,'linear');
p(:,2)=interp1(xorg,cmap_mat(:,2),xin,'linear');
p(:,3)=interp1(xorg,cmap_mat(:,3),xin,'linear');