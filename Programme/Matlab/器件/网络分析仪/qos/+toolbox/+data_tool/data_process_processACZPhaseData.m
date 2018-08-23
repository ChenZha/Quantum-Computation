%% export data to workspace
sz = size(z);
for ii = 1:sz(1)
z(ii,:) = unwrap(z(ii,:));
end
for ii = 1:sz(2)
z(:,ii) = unwrap(z(:,ii));
end

figure();imagesc(x,y,z.'/pi);
xlabel('ACZ pulse length');
ylabel('ACZ pulse amplitude');
set(gca,'YDir','normal');
colorbar;
colormap jet;
title('z: phase(\pi)');
