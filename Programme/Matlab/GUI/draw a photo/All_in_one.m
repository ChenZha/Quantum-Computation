% close all
%%
% addpath('.')
% addpath('qos')
addpath('?E:\Data');
listing = dir('?E:\Data\Circulator');
%%
figure;axis;
aaa=gca;
n=0;
for fid = 1:size(listing,1)
    f=listing(fid);
    if strcmp(f.name(1),'.')
        continue
    end
    if strcmp(f.name(end-3:end),'.mat')
    end
    if strcmp(f.name(end-6:end),'abs.fig')
        if ~strcmp(f.name(1:1),'r')

            n=n+1;
            uiopen([f.folder '\' f.name],1)
            bbb=gcf;
            set(bbb.Children.Children,'parent',aaa)
            close(bbb)

        end
    end
end
% mainlayout.Heights=zeros(1,n)-1;
% mainlayout.Widths=zeros(1,n)-1;
% %%
% showonepic=@(name)showonepic_(name,listing,listing2);
% showfourpic=@(pan)showfourpic_(pan,showonepic);
% showfourpic('T');
% showfourpic('S');
% showfourpic('R');
% showfourpic('Q');
% showfourpic('P');
% showfourpic('O');
% function mf=showfourpic_(pan,showonepic)
% names={'47','52','53','55'};
% mf=figure;
% mainlayout=uix.Grid('parent',mf);
% n=0;
% for ii = 1:size(names,2)
%     name=[pan,names{ii}];
%     try
%         f1=showonepic(name);
%         set(f1.Children,'parent',uicontainer('parent',mainlayout))
%         close(f1)
%         n=n+1;
%     catch
%     end
% end
% %mainlayout.Heights=zeros(1,n)-1;
% mainlayout.Widths=zeros(1,n)-1;
% end
% 
% function f1=showonepic_(name,listing,listing2)
% f1=figure();
% for fid = 1:size(listing,1)
%     f=listing(fid);
%     if strcmp(f.name(1),'.')
%         continue
%     end
%     if strcmp(f.name(1:3),'.mat')
%     end
%     if strcmp(f.name(end-6:end),'abs.fig')
%         if strcmp(f.name(1:3),name)
%             uiopen([f.folder '\' f.name],1)
%             set(gca,'parent',f1)
%             close gcf
%             break
%         end
%     end
% end
% f2=figure();
% for fid = 1:size(listing2,1)
%     f=listing2(fid);
%     if strcmp(f.name(1),'.')
%         continue
%     end
%     if strcmp(f.name(1:3),'.mat')
%     end
%     if strcmp(f.name(end-6:end),'abs.fig')
%         if strcmp(f.name(1:3),name)
%             uiopen([f.folder '\' f.name],1)
%             set(gca,'parent',f2)
%             close gcf
%             break
%         end
%     end
% end
% set(f2.Children.Children,'parent',f1.Children)
% close(f2)
% set(f1.Children,'xlim',[4,8])
% end