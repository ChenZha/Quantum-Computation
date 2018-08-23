function multiplexedReadout()

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    qubits = {'q7','q8','q9'};
    legends = {'multiplexed','single 100','single 110','single 101'};
    numSamples = 40;
    
    numQs = numel(qubits);
    for ii = 1:numQs
        if ischar(qubits{ii})
            qubits{ii} = sqc.util.qName2Obj(qubits{ii});
        end
    end

    numQs = numel(qubits);
    XYGates = cell(1,numQs);
    for ii = 1:numQs
        XYGates{ii} = gate.Y2p(qubits{ii});
    end
    
    Rs = measure.resonatorReadout(qubits{1});
    Rs.delay = XYGates{1}.length+50;
    
    % Rm = measure.resonatorReadout(fliplr(qubits));
    Rm = measure.resonatorReadout(qubits);
    Rm.delay = XYGates{1}.length+50;
    
    hf = qes.ui.qosFigure(sprintf('Multiplexed readout test' ),false);
    ax = axes('parent',hf);

    DataSQ = NaN(numSamples,numQs);
    DataMQ = NaN(numSamples,1);
    x = 1:numSamples;
    for ii = 1:numSamples
        XYGates{1}.Run();
        
        % XYGates{2}.Run();
        
        data_ = Rm();
        DataMQ(ii,:) = sum(data_(1:2^(numQs-1)));
        for jj = 1:numQs
            XYGates{1}.Run();
            XYGates{jj}.Run();
            data_ = Rs();
            DataSQ(ii,jj) = data_(1);
        end
        try
            plot(ax,x,DataMQ,'--');
            hold(ax,'on');
            for jj = 1:numQs
                plot(ax,x,DataSQ(:,jj));
            end
            hold(ax,'off');
            xlabel('Nth repeatition');
            ylabel('P|0>');
            legend(ax,legends);
            drawnow;
            pause(0.1);
        catch
            hf = qes.ui.qosFigure(sprintf('Multiplexed readout test' ),false);
            ax = axes('parent',hf);
        end
    end
end