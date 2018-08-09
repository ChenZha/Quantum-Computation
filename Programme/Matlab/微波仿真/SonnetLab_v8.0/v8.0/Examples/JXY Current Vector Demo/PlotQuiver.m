function PlotQuiverCurrents(CurrentData,FigureNumber,phaseInDegrees,xArrowCount,yArrowCount,QuiverScale)

figure(FigureNumber);


aComplexMagX=CurrentData.XDirectedData;
aRealMagX=real(aComplexMagX*exp(1i*2*pi/180*phaseInDegrees));

aComplexMagY=CurrentData.YDirectedData;
aRealMagY=real(aComplexMagY*exp(1i*2*pi/180*phaseInDegrees));

aMatrixToPlot=sqrt(aRealMagX.^2+aRealMagY.^2);

i=find(aMatrixToPlot==0);
aMatrixToPlot(i)=NaN(size(i));

% Load the data
img=imagesc(aMatrixToPlot);
shading interp
set(img,'alphadata',~isnan(aMatrixToPlot));
set(gca,'color',[.7 .7 .7]);
axis image
colorbar
caxis([0 7e-3])  % Hard coded the current scale for the CurrentVectorDemo in SonnetLab - 4/2/14

[Xlen,Ylen]=size(aRealMagX);
x=round(linspace(1,Xlen,xArrowCount));
y=round(linspace(1,Ylen,yArrowCount));

[X,Y]=meshgrid(x,y);
DX=aRealMagX(x,y);
DY=aRealMagY(x,y);

hold on
quiver(X,Y,DX,DY,QuiverScale,'Color','k')
hold off

title(['Phase = ' num2str(phaseInDegrees) ' ^O'])