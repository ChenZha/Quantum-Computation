function multiplexedReadout_4()

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    qubits = {'q6','q7','q8','q9'};
    legends = {'|0000>','|0001>','|0010>','|0011>','|0100>','|0101>','|0110>','|0111>',...
        '|1000>','|1001>','|1010>','|1011>','|1100>','|1101>','|1110>','|1111>'};
    numSamples = 5;
    
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
        for ww = 1:5
            for jj = 1:numQs
                XYGates{jj}.Run();
            end
            if ww == 1
                data_ = Rm();
            else
                data_ = data_ + Rm();
            end
        end
        data_ = data_/5;
        
        DataMQ_1(ii,:) = data_;
        try
            plot(ax,x,DataMQ_1,'-');
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