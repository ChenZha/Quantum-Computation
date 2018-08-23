% load('D:\data\20171226\GHZ_Tomo_180127T224125_42_.mat')
% Pm = zeros(size(tomoData{1}));
% numReps = numel(tomoData);
% for ii = 1:numReps
%   Pm = Pm+tomoData{ii};
% end
% Pm = Pm/numReps;
% toolbox.data_tool.fitting.fitGHZ(Pm);
function phaseCorrection = fitGHZ(Pm)
    numQs = log(size(Pm,1))/log(3);
    assert(abs(round(numQs) - numQs) < 1e-6);
    numQs = round(numQs);
    Dim = 2^numQs;
    rho_ideal = zeros(Dim);
    rho_ideal(1,1) = 0.5;
    rho_ideal(1,Dim) = 0.5;
    rho_ideal(Dim,1) = 0.5;
    rho_ideal(Dim,Dim) = 0.5;
    function y = fitFunc(phaseCorrection_)
        rho = sqc.qfcns.stateTomoData2Rho(Pm,phaseCorrection_);
        y = sum(sum(abs(rho - rho_ideal)));
    end
    options = optimset('Display','iter','MaxFunEvals',500);
    
    phaseCorrection = fminsearch(@fitFunc,zeros(1,numQs),options);
    
    rho_opt = sqc.qfcns.stateTomoData2Rho(Pm,phaseCorrection);
    ax = qes.util.plotfcn.Rho(rho_opt,[],1,false);
    ax = qes.util.plotfcn.Rho(rho_ideal,ax,0,false);
    f = sqc.qfcns.fidelity(rho_ideal,rho_opt);
    title(ax(1),['Fidelity: ',num2str(f,'%0.3f')]);

end