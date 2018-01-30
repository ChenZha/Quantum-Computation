function [ cs,fittingdatas,errs,step,finished ] = StepFitting(func,c0,xdata,ydata,errFunc,step0,minStep,maxNumofSteps,options)
%STEPFITTING can be use to fitting the experiments data
%   ZYR 2015-08-29
numofCoefficients = length(c0);
c = c0;
step = step0;
calculatedData = func(xdata,c);
err = errFunc(xdata,ydata,calculatedData);
cs = {c};
fittingdatas = {calculatedData};
errs = {err};
if options.display
    h = figure();
    plotDataandSave(h,xdata,ydata,calculatedData,...
        [options.pathname options.filename '_1.png']);
        save([options.pathname options.filename '_1.mat'],...
            'c','calculatedData','err','step');
end
while ~less(step,minStep) && length(cs)<maxNumofSteps
    for ii = 1:numofCoefficients*2+1
        if ii == numofCoefficients*2+1
            for jj = 1:numofCoefficients
                if step(jj)>=minStep(jj)
                    step(jj) = step(jj)/2;
                end
            end
        else
            adjacentC = c;
            indexofC = fix((ii+1)/2);
            if mod(ii,2) == 1
                adjacentC(indexofC) = c(indexofC)-step(indexofC);
            else
                adjacentC(indexofC) = c(indexofC)+step(indexofC);
            end
            if ~find(cs,adjacentC)
                if length(cs)<maxNumofSteps
                    adjacentcalculatedData = func(xdata,adjacentC);
                    adjacentErr = errFunc(xdata,ydata,adjacentcalculatedData);
                    cs = [cs {adjacentC}];
                    fittingdatas = [fittingdatas {adjacentcalculatedData}];
                    errs = [errs {adjacentErr}];
                    if adjacentErr<err
                        c = adjacentC;
                        calculatedData = adjacentcalculatedData; 
                        err = adjacentErr;
                        if options.display
                            plotDataandSave(h,xdata,ydata,calculatedData,...
                                [options.pathname options.filename '_' int2str(length(cs)) '.png']);
                            save([options.pathname options.filename '_' int2str(length(cs)) '.mat'],...
                                'c','calculatedData','err','step','xdata','ydata');
                        end
                        break;
                    end
                else
                    break;
                end
            end
        end
    end
end
finished = length(cs)<maxNumofSteps;
end

function l = less(s1,s2)
l = true;
n = length(s1);
for ii = 1:n
    l = l && s1(ii)<s2(ii);
end
end

function []=plotDataandSave(h,xdata,ydata,fittingdata,filename)
if ~isempty(get(h,'CurrentAxes'))
    delete(get(h,'CurrentAxes'));
end
figure(h);
ax = axes();
hold on
for ii = length(xdata);
    plot(ax,xdata{ii},ydata{ii},'o');
    plot(ax,fittingdata{ii}(1,:),fittingdata{ii}(2,:));
end
hold off
pause(1);
saveas(h,filename);
saveas(h,[filename(1:end-3) 'fig']);
end

function found = find(cs,c)
found = false;
for ii = 1:length(cs)
    samed = true;
    for jj = 1:length(cs{ii})
        samed = samed && (cs{ii}(jj) == c(jj));
    end
    if samed
        found = true;
        break;
    end
end
end
