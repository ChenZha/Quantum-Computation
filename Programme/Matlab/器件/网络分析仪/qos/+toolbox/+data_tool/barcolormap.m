function hf=barcolormap(x,y,yerr,ax)
 
if nargin<4
hf=figure;
ax = axes('parent',hf);
end
% colorrange=[min(y),max(y)];
colorrange=[0,1];
for ii=1:numel(x)
hb=bar(ax,x(ii),y(ii),'facecolor',getfacecolor(y(ii),colorrange),'edgecolor','none');
hold on;
end
colorbar;
caxis(colorrange);
xticks(x)
if nargin>2
errorbar(ax,x,y,yerr,'linestyle','none','LineWidth',0.5,'CapSize',6,'color','k');
end
axis tight
end
function cc=getfacecolor(y,colorrange)
cm=colormap('parula');
cmx=linspace(colorrange(1),colorrange(2),size(cm,1));
if y>=colorrange(1) && y<=colorrange(2)
    cc(1)=interp1(cmx,cm(:,1),y);
    cc(2)=interp1(cmx,cm(:,2),y);
    cc(3)=interp1(cmx,cm(:,3),y);
else
    cc(1)=interp1(cmx,cm(:,1),colorrange(2));
    cc(2)=interp1(cmx,cm(:,2),colorrange(2));
    cc(3)=interp1(cmx,cm(:,3),colorrange(2));
    warning('colorrange error')
end
end