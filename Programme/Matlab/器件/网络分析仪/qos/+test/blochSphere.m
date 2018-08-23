%% the most simple demo
s = sqc.qs.state([1,1]);
bs = sqc.util.blochSphere();
bs.addState(s);
bs.draw();
%% animation
hf = qes.ui.qosFigure('Bloch Sphere Test',false);
set(hf,'ToolBar','none','MenuBar','none');
ax = axes('Parent',hf,'Position',[-0.25,-0.25,1.5,1.5]);
numStates = 3; % the number of qubit states to plot
bs = sqc.util.blochSphere(ax,numStates);
bs.color = [1,0,0;0,1,0;0,0,1]; % numStates by 3
bs.drawHistory = true; % draw history or not
numSteps = 150;
k = linspace(0,1,numSteps);
for ii = 1:numSteps
    s1 = sqc.qs.state([k(ii),1-k(ii)]);
    s2 = sqc.qs.state([1-k(ii),k(ii)*1j]);
    s3 = sqc.qs.state([(1-k(ii)^2)*1j,-1j*k(ii)^2]);
    bs.addState(s1,1);
    bs.addState(s2,2);
    if ii < numSteps/2 || ii > 2*numSteps/3
        bs.addState(s3,3);
    else
        bs.addState([],3);
    end
    bs.draw();
    pause(0.1);
end
%%