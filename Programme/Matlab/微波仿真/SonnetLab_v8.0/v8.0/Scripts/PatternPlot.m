% PatternPlot(theFilename) plots pattern information.
%
%  Examples:
%
%   PatternPlot('infpole.pat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SonnetLab, all included documentation, all included examples
% and all other files (unless otherwise specified) are copyrighted by Sonnet Software
% in 2011 with all rights reserved.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". ANY AND
% ALL EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. UNDER NO CIRCUMSTANCES AND UNDER
% NO LEGAL THEORY, TORT, CONTRACT, OR OTHERWISE, SHALL THE COPYWRITE HOLDERS,  CONTRIBUTORS,
% MATLAB, OR SONNET SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
% CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
% GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL
% DAMAGES OR LOSSES, OR FOR ANY DAMAGES EVEN IF THE COPYWRITE HOLDERS, CONTRIBUTORS, MATLAB,
% OR SONNET SOFTWARE HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM
% BY ANY OTHER PARTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PatternPlot(theFilename)

% Read the pattern file into an object which has the pattern information
aPattern=PatternRead(theFilename);

aNumOfFreqs=length(aPattern.getFrequencyValue());

aNumOfPorts=length(aPattern.Options.Ports);

aPhiVec=aPattern.getPhiList;
aPhiStep=aPhiVec(2)-aPhiVec(1);
aThetaVec=aPattern.getThetaList;
aThetaStep=aThetaVec(2)-aThetaVec(1);

[P,T]=meshgrid(aPhiVec,aThetaVec);

aDriveMatrix=[];
for aFreqCntr=1:aNumOfFreqs
    aEThetaMatCoeff=zeros(length(aThetaVec),length(aPhiVec),aNumOfPorts);
    aEPhiMatCoeff=zeros(length(aThetaVec),length(aPhiVec),aNumOfPorts);
    for aDriveCntr=1:aNumOfPorts
        aDriveMags=aPattern.ArrayOfPatterns(aFreqCntr).Drive{1};
        aDriveAngles=aPattern.ArrayOfPatterns(aFreqCntr).Drive{2};
        aDrive(aDriveCntr)=aDriveMags(aDriveCntr)*exp(1i*aDriveAngles(aDriveCntr));
    end
    aDriveArray{aFreqCntr}=aDrive;
    
    for aFieldPointCntr=1:length(aPattern.ArrayOfPatterns(aFreqCntr).ArrayOfElements)
        aLocalFieldPoint=aPattern.ArrayOfPatterns(aFreqCntr).ArrayOfElements(aFieldPointCntr);
        ThetaIndex=abs(round((aLocalFieldPoint.Theta)/aThetaStep))+1;
        PhiIndex=abs(round((aLocalFieldPoint.Phi)/aPhiStep))+1;
        for aPortCntr=1:length(aLocalFieldPoint.EThetaMag)
            aEThetaMatCoeff(ThetaIndex,PhiIndex,aPortCntr)=aLocalFieldPoint.EThetaMag(aPortCntr)*exp(1i*aLocalFieldPoint.EThetaAngle(aPortCntr));
            aEPhiMatCoeff(ThetaIndex,PhiIndex,aPortCntr)=aLocalFieldPoint.EPhiMag(aPortCntr)*exp(1i*aLocalFieldPoint.EPhiAngle(aPortCntr));
        end
    end
    aEThetaMatCoeffArray{aFreqCntr}=aEThetaMatCoeff;
    aEPhiMatCoeffArray{aFreqCntr}=aEPhiMatCoeff;
    %     aEThetaTotal{aFreqCntr}=aEThetaMatCoeff(:,:,)
end

for aFreqCntr=1:aNumOfFreqs
    aLocalEThetaCoeffArray=aEThetaMatCoeffArray{aFreqCntr};
    aLocalEPhiCoeffArray=aEPhiMatCoeffArray{aFreqCntr};
    aLocalDriveArray=aDriveArray{aFreqCntr};
    for aPortCntr=1:aNumOfPorts
        aLocalEThetaCoeffArray(:,:,aPortCntr)=aLocalEThetaCoeffArray(:,:,aPortCntr)*aLocalDriveArray(aPortCntr);       
        aLocalEPhiCoeffArray(:,:,aPortCntr)=aLocalEPhiCoeffArray(:,:,aPortCntr)*aLocalDriveArray(aPortCntr);       
    end
    aEThetaMatArray{aFreqCntr}=aLocalEThetaCoeffArray;
    aEPhiMatArray{aFreqCntr}=aLocalEPhiCoeffArray;
end

aEth=aEThetaMatArray{1};
aEphi=aEPhiMatArray{1};

aEthTotal=sum(aEth,3);
aEphiTotal=sum(aEphi,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Calculate Patterns and stuff...
ep0=8.854e-12;
mu0=pi*4e-7;
eta0=1/sqrt((ep0/mu0));

PowerPattern=(abs(aEthTotal).^2+abs(aEphiTotal).^2)/eta0;
GainPattern=(PowerPattern)/32*4*pi;
GainPatternDB=10*log10(GainPattern);

maxG=max(GainPatternDB(:));
minG=min(GainPatternDB(:));
GainPatternDB=GainPatternDB-minG;
GainPatternDB(find(GainPatternDB<0))=0;
[X,Y,Z]=sph2cartfixed(T*pi/180,P*pi/180,GainPatternDB);

C=PowerPattern;
C=GainPatternDB;
F1=figure;
set(F1,'Color',[1 1 1]);
H1=surf(X,Y,Z,C);
shading interp;
hold on
AxisLength=1.3;
line([0 -max(max(abs(X)))],[0 0],[0 0],'LineWidth',2,'Color','k')
text(-max(max(abs(X)))*1.1, 0, 0,'X','FontSize',18)
line([0 0],[0 max(max(abs(Y)))],[0 0],'LineWidth',2,'Color','k')
text(0, max(max(abs(Y)))*1.1, 0,'Y','FontSize',18)
line([0 0],[0 0],[0 max(max(abs(Z)))*1.3],'LineWidth',2,'Color','k')
text(0, 0, max(max(abs(Z)))*1.3 ,'Z','FontSize',18)
hold off
axis square equal 
A1=get(F1,'Children');
set(A1,'XTickLabel','')
set(A1,'YTickLabel','')
set(A1,'ZTickLabel','')
view(-141,24)
colorbar