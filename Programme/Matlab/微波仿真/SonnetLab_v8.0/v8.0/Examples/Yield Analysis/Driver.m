%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This script demonstrates how SonnetLab can be used for tolerance analysis.
%     The proposed approach utilizes a combination of high accuracy em
%     simulations along with interpolated data from many Monte Carlo method 
%     (http://en.wikipedia.org/wiki/Monte_Carlo_method) derived samples over 
%     the variable tolerance ranges. This script examines the effect of two 
%     forms of fabrication error for a Wilkinson power divider: the error present 
%     in the width of the trace and the error present in the gap width between the 
%     two output feedlines. This yield analysis approach can easily be extended to 
%     support more variables and different types of RF circuits.
%
%   This script was used to generate results for a paper titled "Yield Analysis of a
%     Stripline Wilkinson Power Divider using Monte Carlo Samples of Interpolated Full
%     Wave Simulation Data using Sonnet" by Bashir Souid and Serhend Arvas. This paper
%     was presented at the 2011 General Assembly and Scientific Symposium of the
%     International Union of Radio Science conference in Istanbul, Turkey.
%
%   The conference paper has since been converted into whitepaper publically
%     available from the Sonnet Software website:
%       http://www.sonnetsoftware.com/support/downloads/techdocs/montecarlo_sonnet.zip
%
%   Approach:
%
%     > Phase 1: High Accuracy Analysis of Solution Space <
%        SonnetLab will be used to generate n number of circuit
%        designs equally  spaced over the variable tolerance ranges.
%        Each of these  designs will be simulated with Sonnet Software's
%        high accuracy solver. A cost value is assigned to each circuit
%        based on its response information. Generally, the value of n
%        may be fairly small.
%
%     > Phase 2: Monte Carlo Samples of Solution Space <
%        This script will perform a large number of Monte Carlo
%        samples of the space with the cost value being determined
%        by interpolating from the high accuracy em simulation results.
%
%     > Phase 3: Compare Interpolated Sample Costs to Threshold <
%        Each Monte Carlo sample is compared to a specified cost threshold
%        which differentiates between a satisfactory circuit and a defect.
%        This script will plot both the cost values generated from Phase 1
%        and Phase 2. These plots make it easy to visualize the results.
%
%   Licence Notes:
%
%       SonnetLab, all included documentation, all included examples
%       and all other files (unless otherwise specified) are copyrighted
%       by Sonnet Software in 2011 with all rights reserved.
%
%       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS". ANY AND
%       ALL EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. UNDER NO CIRCUMSTANCES AND UNDER
%       NO LEGAL THEORY, TORT, CONTRACT, OR OTHERWISE, SHALL THE COPYWRITE HOLDERS,  CONTRIBUTORS,
%       MATLAB, OR SONNET SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
%       CONSEQUENTIAL DAMAGES OF ANY CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF
%       GOODWILL, WORK STOPPAGE, COMPUTER FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL
%       DAMAGES OR LOSSES, OR FOR ANY DAMAGES EVEN IF THE COPYWRITE HOLDERS, CONTRIBUTORS, MATLAB,
%       OR SONNET SOFTWARE HAVE BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES, OR FOR ANY CLAIM
%       BY ANY OTHER PARTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%    Input Region    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This variable will control the number of EM computed values
% to use over the range of the optimization variable regions
aNumberOfEmGridSteps=7;

% This is the desired number of monte carlo samples
aNumberOfSamples=15000;

% This is the desired threshold for the cost function. Samples
% with cost values below this threshold are considered good;
% samples with cost values above this threshold are bad.
aCostThreshold=3.8;

% PDF that should be used to generate random locations for
% Monte Carlo samples. Supported values are either 'norm' 
% for normal distribution or 'tri' for triangle distribution.
aDistribution = 'tri';

% Set the variable bounds. This represents the min/max
% variable values to be used for the trace and the min/max
% variable values used for the gap width.
aWMin=35;
aWMax=39;
aSMin=16.5;
aSMax=19.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build a set of variable values to represent the amount
% of over/under etching present in the trace width
aWAmount = linspace(aWMin,aWMax,aNumberOfEmGridSteps);

% Build a set of variable values to represent the amount
% of over/under etching present in the feedline gap width
aSAmount = linspace(aSMin,aSMax,aNumberOfEmGridSteps);

% Build a vector of the grid values to simulate
[aSAmountND,aWAmountND]=meshgrid(aSAmount,aWAmount);

% Preallocate a matrix of the cost values
aCostND=zeros(size(aWAmountND));

fprintf(1,'------------------------------------------------------------------------\n');
fprintf(1,' > Phase 1: High Accuracy Analysis of Solution Space <\n');
fprintf(1,'    Simulating %d Circuits Using Sonnet em\n',length(aWAmountND(:)));
fprintf(1,'------------------------------------------------------------------------\n');

% Build a set of Sonnet projects with equally spaced 
% variable values that span the variable range space.
for n=1:length(aWAmountND(:))
    
    % Open the original Sonnet Project
    aProject=SonnetProject('Template.son');
    
    % Modify the design to represent the specified variable values
    BuildCircuit(aProject,aSAmountND(n),aWAmountND(n));
    
    % Snap all polygons in the project to the Sonnet grid
    aProject.snapPolygonsToGrid();
    
    % Save the new design as a new filename
    aProjectFilename=['IterationNumber' num2str(n) '.son'];
    aProject.saveAs(aProjectFilename);
    
    % Simulate the circuit
    [aStatus aMessage]=aProject.simulate();
    if aStatus
        error(['Simulation failed: ' aMessage]);
    end
    
    % Determine the cost values based on the error function
    aSnPFilename=['IterationNumber' num2str(n) '.s3p'];
    aCostND(n)=CalculateCost(aSnPFilename);
    
    fprintf(1,'   | Iteration %3d |      | Sep=%-7.5g | Width=%-7.5g | Cost=%-10.6g |\n',n,aSAmountND(n),aWAmountND(n),aCostND(n));
    
end

fprintf(1,'------------------------------------------------------------------------\n');
fprintf(1,' > Phase 2: Monte Carlo Samples of Solution Space <\n');
fprintf(1,'    Generating %d Monte Carlo based samples and interpolating cost\n',aNumberOfSamples);
fprintf(1,'------------------------------------------------------------------------\n');

% Select a random points to sample at according to the pdf
if strcmp(aDistribution,'norm')==1
    aValuesForS=randraw('norm', [aSMin aSMax], aNumberOfSamples)';
    aValuesForW=randraw('norm', [aWMin aWMax], aNumberOfSamples)';
else
    aValuesForS=randraw('tri', [16 18 20], aNumberOfSamples);
    aValuesForW=randraw('tri', [35 36 39], aNumberOfSamples);
end

% Resample values that are outside of the variable range
iCounter=1;
while iCounter < aNumberOfSamples
    if (sum(aValuesForS>aSMax)+ sum(aValuesForS<aSMin)) > 0
        if aValuesForS(iCounter)>aSMax || aValuesForS(iCounter)<aSMin
            if strcmp(aDistribution,'norm')==1
                aValuesForS(iCounter)=randraw('norm', [aSMin aSMax], 1);
            else
                aValuesForS=randraw('tri', [16 18 20], aNumberOfSamples);
                
            end
            continue
        end
    else
        break;
    end
    iCounter=iCounter+1;
end
iCounter=1;
while iCounter < aNumberOfSamples
    if (sum(aValuesForW>aWMax)+ sum(aValuesForW<aWMin)) > 0
        if aValuesForW(iCounter)>aWMax || aValuesForW(iCounter)<aWMin
            if strcmp(aDistribution,'norm')==1
                aValuesForW(iCounter)=randraw('norm', [aWMin aWMax], 1);
            else
                aValuesForW=randraw('tri', [35 36 39], aNumberOfSamples);
            end
            continue
        end
    else
        break;
    end
    iCounter=iCounter+1;
end

% Get the interpolated cost at the Monte Carlo sampled variable values
aCostsSampled=interp2(aSAmountND,aWAmountND,aCostND,aValuesForS,aValuesForW);

fprintf(1,'------------------------------------------------------------------------\n');
fprintf(1,' > Phase 3: Compare Interpolated Sample Costs to Threshold <\n');
fprintf(1,'    Calculating Yield of the Monte Carlo method samples\n');
fprintf(1,'------------------------------------------------------------------------\n');

aNumberOfGoodCircuits=sum(aCostsSampled(:) <= aCostThreshold);

fprintf(1,'--------------------------------------------------------------------------\n');
fprintf(1,'  Analysis Complete \n');
fprintf(1,'    %d/%d iterations exceed the threshold of %g \n',aNumberOfGoodCircuits,aNumberOfSamples,aCostThreshold);
fprintf(1,'    Yield is %g percent \n',aNumberOfGoodCircuits/aNumberOfSamples*100);
fprintf(1,'--------------------------------------------------------------------------\n');

% Plot the high accuracy cost values simulated with Sonnet's solver
figure
colormap bone
caxis([0 1e8])
bb=plot3(aSAmountND,aWAmountND,aCostND,'.k');
set(bb,'MarkerSize',3)
hold on
aa=mesh(aSAmountND,aWAmountND,aCostND,zeros(size(aCostND)));
set(aa,'FaceAlpha',0)
hold off
title('High Accuracy Costs from EM Simulations')
xlabel('Sep (mils)');
ylabel('Width (mils)');
zlabel('Cost');
grid on
axis vis3d

% Plot the interpolated cost values based on Monte Carlo samples
F1=figure;
set(F1,'Color',[0 0 0]);
S2=scatter3(aValuesForS,aValuesForW,aCostsSampled,3,aCostsSampled);
set(get(S2,'Parent'),'Color',[0 0 0]);
set(get(S2,'Parent'),'XColor',[1 1 1]);
set(get(S2,'Parent'),'YColor',[1 1 1]);
set(get(S2,'Parent'),'ZColor',[1 1 1]);
H=title('Interpolated Costs of Monte Carlo Samples')
set(H,'Color',[1 1 1])
xlabel('Sep (mils)');
ylabel('Width (mils) ');
zlabel('Cost');
grid on
axis vis3d