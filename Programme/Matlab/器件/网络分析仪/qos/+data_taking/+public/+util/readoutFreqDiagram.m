function readoutFreqDiagram(maxSidebandFreq,qubits)
% data_taking.public.util.readoutFreqDiagram(500e6);
%

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 1
        maxSidebandFreq = 500e6;
    end
    if nargin < 2
        qubits = {};
    end

    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_readoutFreqDiagram:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
	
    if isempty(qubits)
        qubits = sqc.util.loadQubits();
    else
        if ~iscell(qubits)
            qubits = {qubits};
        end
        for ii = 1:numel(qubits)
            if isa(qubits{ii},'sqc.qobj.qubit')
                continue;
            elseif ischar(qubits{ii})
                qubits{ii} = sqc.util.qName2Obj(qubits{ii});
            else
                throw(MException('QOS_readoutFreqDiagram:illegalArgument',...
                    'at least one of qubits is not a qubit name or a qubit object.'));
            end
        end
    end
    numQs = numel(qubits);
    fr = NaN*ones(1,numQs);
    fci = NaN*ones(1,numQs);
    qNames = cell(1,numQs);
    for ii = 1:numQs
        fr(ii) = qubits{ii}.r_fr;
        if ~isempty(qubits{ii}.r_fc)
            fci(ii) = qubits{ii}.r_fc;
        else
            fci(ii) = NaN;
        end
        qNames{ii} = qubits{ii}.name;
    end
    
    mfr = mean(fr)/1e9;
    flb = max(mfr)-maxSidebandFreq/1e9;
    fub = min(mfr)+maxSidebandFreq/1e9;
    
    h = qes.ui.qosFigure('Readout Resonator Freq. Diagram',false);
    pos = get(h,'Position');
    pos(2) = pos(2) - pos(4);
    pos(4) = 2*pos(4);
    set(h,'Position',pos);
    ax = axes('parent',h,'Box','on','XGrid','on','YGrid','on','GridLineStyle','--');
    pos = get(ax,'Position');
    pos(3) = 0.9*pos(3);
    set(ax,'Position',pos);
    hold(ax,'on');
    for ii = 1:numQs
        line([ii-0.5,ii+0.5],[fr(ii),fr(ii)]/1e9,...
            'Parent',ax,'LineStyle','-','Color',[0,0,0],...
            'LineWidth',2);
    end
    set(ax,'XTick',1:numQs,'XTickLabels',qNames);
    ylabel(ax,'frequency(GHz)');
    set(ax,'XLim',[0,numQs+1],'YLim',[flb,fub]);

    if numel(unique(fci)) == 1 && ~isnan(fci(1))
        fc = fci(1);
    else
        warning('qubits have different readout fc values.');
        fc = 1e9*mfr;
    end
    fcline = line([0,numQs+1],[fc,fc]/1e9,...
            'Parent',ax,'LineStyle','-','Color',[1,0,0],...
            'LineWidth',2);

    sbFreqs = fr - fc;
    n1_sbFreqs = (fc - sbFreqs)/1e9;
    n1_sbFreqsline = fcline;
    for ii = 1:numQs
        n1_sbFreqsline(ii) = line([0,numQs+1],[n1_sbFreqs(ii),n1_sbFreqs(ii)],...
            'Parent',ax,'LineStyle','--','Color',[1,0,0],...
            'LineWidth',1);
    end
    
    n2_sbFreqs = (fc - 2*sbFreqs)/1e9;
    n2_sbFreqsline = fcline;
    for ii = 1:numQs
        n2_sbFreqsline(ii) = line([0,numQs+1],[n2_sbFreqs(ii),n2_sbFreqs(ii)],...
            'Parent',ax,'LineStyle',':','Color',[0,1,0],...
            'LineWidth',1);
    end
    
    p2_sbFreqs = (fc + 2*sbFreqs)/1e9;
    p2_sbFreqsline = fcline;
    for ii = 1:numQs
        p2_sbFreqsline(ii) = line([0,numQs+1],[p2_sbFreqs(ii),p2_sbFreqs(ii)],...
            'Parent',ax,'LineStyle',':','Color',[0,0,1],...
            'LineWidth',1);
    end
        
    pos = [pos(1)+pos(3)+0.05 pos(2) 0.05 pos(4)];
    sld = uicontrol('Parent',h,'Style', 'slider',...
        'Min',flb,'Max',fub,'Value',mfr,...
        'Units','normalized','Position', pos,... 
        'SliderStep',[0.002,0.1],'Callback', @sldFunc); 
    
    function sldFunc(~,~)
        fc = 1e9*get(sld,'Value');
        set(fcline,'YData',[fc,fc]/1e9);
        sbFreqs = fr - fc;
        n1_sbFreqs = (fc - sbFreqs)/1e9;
        for ii = 1:numQs
            set(n1_sbFreqsline(ii),'YData',[n1_sbFreqs(ii),n1_sbFreqs(ii)]);
        end
        
        n2_sbFreqs = (fc - 2*sbFreqs)/1e9;
        for ii = 1:numQs
            set(n2_sbFreqsline(ii),'YData',[n2_sbFreqs(ii),n2_sbFreqs(ii)]);
        end
        
        p2_sbFreqs = (fc + 2*sbFreqs)/1e9;
        for ii = 1:numQs
            set(p2_sbFreqsline(ii),'YData',[p2_sbFreqs(ii),p2_sbFreqs(ii)]);
        end
    end

    pos = [pos(1)-0.1,pos(2)-0.1,0.2,0.05];
    saveBtn = uicontrol('Parent',h,'Style', 'pushbutton','FontSize',12,...
        'Units','normalized','Position', pos,'String','Save',... 
        'Callback', @Save);
    function Save(~,~)
        choice  = questdlg('Update settings?','Save options',...
                'Yes','No','No');
        if isempty(choice) || ~strcmp(choice, 'Yes')
            return;
        end
        for jj = 1:numQs
            QS.saveSSettings({qNames{jj},'r_fc'},fc);
        end
    end
end




