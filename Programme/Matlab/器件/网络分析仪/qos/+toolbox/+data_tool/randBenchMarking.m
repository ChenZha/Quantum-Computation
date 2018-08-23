function [fidelity,h] = randBenchMarking(numGates, Pref, Pgate, numQs, gateName,ax)

    numGates = double(numGates); % numGates could be int16

    if nargin < 5
        gateName = '';
    end
    if nargin < 6
        ax = [];
    end

    function y_ = fitFcn(p,x_)
        y_ = p(1)*p(2).^x_+p(3);
    end

    indR = 1+0:size(Pref,2)-0;
    Pref_a = mean(Pref(:,indR),1);
    numGates_r = numGates(indR);

    p0(1) = range(Pref_a);
    p0(2) = 1-0.02*2^numQs/(2^numQs-1);
    p0(3) = Pref_a(end);
    lb = [0.8*p0(1),1-0.7*2^numQs/(2^numQs-1),0];
    ub = [5*p0(1),1,1.1*p0(3)];
    warning('off');
    [Cref,~,res_ref,~,~,~,J_ref] = lsqcurvefit(@fitFcn,p0,numGates_r,Pref_a,lb,ub);
    warning('on');
    ci_ref = nlparci(Cref,res_ref,'jacobian',J_ref,'alpha',0.05); % 95% confidence interval
 
    indG = 1+0:size(Pgate,2)-0;
    Pgate_a = mean(Pgate(:,indG),1);
    numGates_g = numGates(indG).';
    
    p0(1) = range(Pgate_a);
    p0(2) = 1-0.02*2^numQs/(2^numQs-1);
    p0(3) = Pgate_a(end);
    lb = [0.8*p0(1),1-0.7*2^numQs/(2^numQs-1),0];
    ub = [5*p0(1),1,1.1*p0(3)];
    [Cgate,~,res_ref,~,~,~,J_ref] = lsqcurvefit(@fitFcn,p0,numGates_g,Pgate_a(:),lb,ub);
    ci_gate = nlparci(Cgate,res_ref,'jacobian',J_ref,'alpha',0.05); % 95% confidence interval
    
    rref = (1-Cref(2))*(2^numQs-1)/(2^numQs);
    rgate = (1-Cgate(2))*(2^numQs-1)/(2^numQs);
    fidelity = 1-(1-Cgate(2)/Cref(2))*(2^numQs-1)/(2^numQs);
    
    df = ((2^numQs-1)/(2^numQs))*(Cgate(2)/Cref(2))*...
        sqrt((diff(ci_ref(2,:))/2/Cref(2))^2 + (diff(ci_gate(2,:))/2/Cgate(2))^2);
    
    if isempty(ax) || ~isgraphics(ax)
        h = qes.ui.qosFigure(sprintf('Randomized Benchmarking | %s', gateName),false);
        ax = axes('parent',h,'FontSize',16);
    else
        axes(ax);
        h = gcf;
        hold(ax,'on');
    end
    
    plot(ax,numGates_r,Pref(:,indR),'.b','MarkerSize',5);
    hold on;
    plot(ax,numGates_g,Pgate(:,indG),'.r','MarkerSize',5);
    xlabel(ax,'number of Clifford gates','FontSize',12);
    ylabel(ax,'sequence fidelity','FontSize',16);
    legend(ax,{'reference',[gateName, ' interleaved']},'FontSize',12);
    
%     if numGates == 1
%         title(ax,[gateName,' fidelity: ',num2str(fidelity,'%0.4f'),...
%             ', r_{SQ,ref}: ',num2str(rref/1.875,'%0.4f'),', r_{SQ,gate}: ',num2str(rgate/1.875,'%0.4f')],...
%             'FontSize',12,'FontWeight','normal','interpreter','tex');
%     else
%     end
    
    if numQs == 1
        title(ax,[gateName,' fidelity: ',num2str(100*fidelity,'%0.2f'),'\pm',num2str(100*df,'%0.2f'),'%(95% confidence)',...
        10,'r_{ref}: ',num2str(rref,'%0.4f'),', r_{interleaved}: ',num2str(rgate,'%0.4f')],...
        'FontSize',12,'FontWeight','normal','interpreter','tex');
    else
        title(ax,[gateName,' fidelity: ',num2str(100*fidelity,'%0.1f'),'\pm',num2str(100*df,'%0.1f'),'%(95% confidence)',...
        10,'r_{ref}: ',num2str(rref,'%0.3f'),', r_{interleaved}: ',num2str(rgate,'%0.3f')],...
        'FontSize',12,'FontWeight','normal','interpreter','tex');
    end
    
    xf = 0.5:0.1:1*numGates(end)+0.5;
    plot(ax,xf,fitFcn(Cref,xf),'-b','LineWidth',2);
    plot(ax,xf,fitFcn(Cgate,xf),'-r','LineWidth',2);
    yl = get(ax,'YLim');
    set(ax,'YLim',[yl(1),1]);
    grid on;
end