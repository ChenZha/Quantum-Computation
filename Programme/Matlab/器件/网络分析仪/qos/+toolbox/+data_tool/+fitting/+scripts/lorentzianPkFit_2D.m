% fit for 2D data
% y, z(ii,:) is the iith trace, z(ii,:) = Lorentzian([iithParams],y);

sz = size(z);
zf = NaN*ones(sz);
FWHM = NaN*ones(1,sz(1));
y0 = NaN*ones(1,sz(1));
for ii = 1:sz(1)
    [y0, A, w, y0_, temp] = LorentzianPkFit(y,z(ii,:));
    wci_FWHM(ii,:) = temp(3,:); %
    FWHM(ii) = w;
    wci_y0(ii,:) = temp(4,:); %
    y0(ii) = y0_;
    zf(ii,:) = Lorentzian([y0, A, w, y0_],y);
%     figure();
%     plot(y,z(ii,:),'ob');
%     hold on;
%     plot(y,zf(ii,:),'r-');
end
figure();
errorbar(x,FWHM,FWHM-wci_FWHM(:,1)',wci_FWHM(:,2)'-FWHM);
figure();
y0_mean = y0 - mean(y0);
peak_pos = y0 - y0_mean;
wci_y0(:,1) = wci_y0(:,1) - peak_pos';
wci_y0(:,2) = wci_y0(:,2) - peak_pos';
imagesc(x,y-y0_mean,zf');
hold on;
errorbar(x,peak_pos,peak_pos-wci_y0(:,1)',wci_y0(:,2)'-peak_pos);
set(gca,'YDir','normal');