function [Gamma1,bias]=getAllGamma1()
% [Gamma1,bias]=toolbox.data_tool.fitting.getAllGamma1()

% if nargin<1
%     h=figure;
%     set(h,'Position',[373.8000  290.6000  923.2000  420.0000]);
%     box on;
%     ax=axes('Parent',h);
% end

path='E:\data\20180622_12bit\T10720';
files=dir(path);
Gamma1={};
bias={};
for ii=3:numel(files)
    if ~isempty(strfind(files(ii).name,'.mat'))
        aa=split(files(ii).name,'_');
        cc=split(aa{1},'q');
        bb=str2num((cc{2}));
        load([path '\' files(ii).name])  
        eval(['p=Config.session_settings.q' num2str(bb) '.zpls_amp2f01;'])   ;  
        [T1,bi]=toolbox.data_tool.fitting.reFitT1([path '\' files(ii).name],1,1,0,p);
        Gamma1{bb}=1./T1;
        bias{bb}=bi;
    end
end

% len=0;
% for ii=1:12
%     len=max(len,numel(Gamma1{ii}));
% end
% qq=(0.37:0.25:12.36)'*ones(1,len);
% bb=NaN(12*4,len);
% for ii=1:12
% bb(ii*4-1,1:numel(Gamma1{ii}))=bias{ii};
% bb(ii*4,1:numel(Gamma1{ii}))=bias{ii};
% end
% mm=NaN(12*4,len);
% for ii=1:12
% mm(ii*4-1,1:numel(Gamma1{ii}))=Gamma1{ii};
% mm(ii*4,1:numel(Gamma1{ii}))=Gamma1{ii};
% end
% surf(ax,qq,bb,-mm,'edgecolor','none')
% view(0,90);
% c=colorbar;
% caxis([-0.70000e-04 c.Limits(2) ])
% colorbar off;

end