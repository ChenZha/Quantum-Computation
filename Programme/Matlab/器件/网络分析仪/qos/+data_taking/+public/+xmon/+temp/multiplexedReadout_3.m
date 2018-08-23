function multiplexedReadout_3()

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    qubits = {'q7','q8','q9'};
    legends = {'q7|0>','q8|0>','q9|0>',...
        '|000>','|001>','|010>','|011>','|100>','|101>','|110>','|111>'};
    numSamples = 20;
    
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
    
    Rm = measure.resonatorReadout(qubits);
%     Rm = measure.resonatorReadout(fliplr(qubits));
    Rm.delay = XYGates{1}.length+50;
    
    hf = qes.ui.qosFigure(sprintf('Multiplexed readout test' ),false);
    ax = axes('parent',hf);

    DataMQ = NaN(numSamples,numQs);
    DataMQ_1 = NaN(numSamples,2^numQs);
    x = 1:numSamples;
    for ii = 1:numSamples
        for jj = 1:numQs
            XYGates{jj}.Run();
        end
        data_ = Rm();
        DataMQ(ii,:) = [sum(data_([1,3,5,7])), sum(data_([1,2,5,6])), sum(data_([1,2,3,4]))];
        DataMQ_1(ii,:) = data_;
        try
            plot(ax,x,DataMQ,'-');
            hold(ax,'on');
            plot(ax,x,DataMQ_1,'--');
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