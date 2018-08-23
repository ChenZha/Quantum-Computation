function Run(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if isempty(obj.P) || isempty(obj.Ib_est) || isempty(obj.MaxSteps)
        error('IbSearch:RunError','some properties are not set yet!');
    end
    Run@Measurement(obj); % check object and its handle properties are isvalid or not
    SearchPrecision = 1e5;
    obj.msg = '';
    obj.dataready = false;
    if obj.N<500
        MaxRepeatTimes =6;
    elseif obj.N<1000
        MaxRepeatTimes =4;
    else
        MaxRepeatTimes =3;
    end
    Delta = 0.2*obj.Ib_est;         % initial 'search-step'
     if obj.CloseSearch            % 'fast search', reduce initial 'search-step'
         Delta = 0.05*obj.Ib_est;
     end
	 Ib = 0;             % initial 'search-point' is zero current bias,
                         % there is no need to to measure the switching
                         % probability a this point of course: P(Ib = 0)
                         % need must be zero, otherwise something is wrong.
                         % So here the measurement is skipped and directly
                         % assign zero to 'P0': the previous 'search-point'
     P0 = 0;             % switching probability.
	 Turned = false;     % true: searching direction has turned at least once.
						 % false: no so.
	 COUNT = 0;          % times of searching been done
     if obj.ShowProcess
        SearchPath = [];    % searching history, Ib, For real time plotting display
        PswRecord = []; % searching history, P(Ib), For real time plotting display
        obj.GenPlotAxes() % Generate the axes for plot if it is not already generated
     end
     if obj.N > 1.5e4
         MaxRVariance = 0.03;% Maximum relative variance
     elseif obj.N > 8e3
         MaxRVariance = 0.04;
     elseif obj.N > 5e3
         MaxRVariance = 0.05;
     else
         MaxRVariance = 0.06;
     end  
	 Ps = zeros(1,MaxRepeatTimes);
	 while 1
         if COUNT == 0
             Ib = obj.Ib_est;
         else
            Ib = Ib + Delta;			% Ib increase
         end
         if Ib <= 0
             obj.InstrumentObject.Run();
             temp = obj.InstrumentObject.data;
             if isnan(temp)
                 obj.msg = 'Can not measure the switching probability, please check the GetP measrement object, make sure it can run properly!';
                 break;
             else
                 Ptest = temp;
             end
             if Ptest>2e-2
                 obj.msg = ['P>0 even at Ib = 0!',char(10),...
                     'Possible causes:',char(10),...
                     'a),Not a josephson junction/SQUID or very bad josephson junction/SQUID(check IV curve);',char(10),...
                     'b),Hold plateau too high;',char(10),...
                     'c),Improper voltage signal level;',char(10),...
                     'd),awg not working or cable disconnected.'];
                 break;
             else
                 Ib = 0;
             end
         else
             obj.ReadoutPulseObj.PulseAmp  = Ib;
             obj.ReadoutPulseObj.GenWave();
             obj.ReadoutPulseObj.UpdateWvVppOffset();  % Set Vpp and Offset Only, even thought in the current case the waveform shape also changes
             pause(0.25); % pause, awg might need some time before it is ready.
         end
         if ~isempty(obj.msg) % if error
            break;
         end
		 ii = 0;
         while ii < MaxRepeatTimes
                         % probability is measured by three successive
                         % measurements, the results is accepted only when
                         % these three values are close, other wise
                         % the measurement is repeated.
                         % maximum repeat time: MaxRepeatTimes 
             ii = ii+1;
             obj.InstrumentObject.Run();
             temp = obj.InstrumentObject.data;
             if ischar(temp)
                 obj.msg = 'Can not measure the switching probability, please check the GetP measrement object, make sure it can run properly!';
                 break;
             else
                 Ps(ii) = temp;
             end
             if ii>=3
                 MeanP = mean(Ps(ii-2:ii));
                 if MeanP < 0.05	% when switching probability is very small,
                                    % the ralative variation is intrinsically
                                    % big. Do not do the following analyse
                                    % in this case.
                     P = MeanP;
                     break;
                 else               % the following MeanP ranges and their
                                    % corresponding MRV are not randomly
                                    % set, do not change.
                     if MeanP < 0.164
                        MRV = 1.6*MaxRVariance;
                     elseif MeanP < 0.459
                         MRV = 1.4*MaxRVariance;
                     elseif MeanP < 0.698
                         MRV = MaxRVariance;
                     elseif MeanP < 0.897
                         MRV = 0.6*MaxRVariance;
                     else
                         MRV = 0.2*MaxRVariance;
                     end
                     rVARi = (abs(Ps(ii-2) - MeanP) + abs(Ps(ii-1)...
                         - MeanP) + abs(Ps(ii) - MeanP))/(3*MeanP);
                     if rVARi < MRV
                         P = MeanP;
                         break;
                     end
                 end
                 if ii == MaxRepeatTimes     
                        % MaxRepeatTimes reached: switching probablility
                        % unstable take the average value of all
                        % measurements as the switching probability.
                     P = mean(Ps);
                 end
             end
         end
         if ~isempty(obj.msg)
             break;
         end
         if P > 1.1
             obj.msg = 'P>1! Please check the GetP object!';
             break;
         end
         COUNT = COUNT + 1;
         if obj.ShowProcess  % Searching display
            SearchPath = [SearchPath,Ib(1)];
            PswRecord = [PswRecord,P];
            SearchTarget = obj.P*ones(1,COUNT);
            x = 1:COUNT;
            obj.GenPlotAxes() % Generate the axes for plot if it is not already generated
            [AX,H1,H2] = plotyy(obj.PlotAxes,x,SearchPath,x,PswRecord); 
            hold(AX(2),'on');
            plot(AX(2),x,SearchTarget,':k');
            set(H1,'LineStyle','-','LineWidth',2,'Marker','s','MarkerSize',12);
            set(H2,'LineStyle','-','LineWidth',2,'Marker','o','MarkerSize',12);
            set(get(AX(1),'Ylabel'),'String','Ib (V)');
            set(get(AX(2),'Ylabel'),'String','P');
            set(get(AX(1),'Xlabel'),'String','Nth Search Step');
            FigName = ['Searching Ib for P(Ib) = ',num2str(obj.P,'%0.2f'),...
                ' | Running(',num2str(COUNT,'%0.0f'),'/',num2str(obj.MaxSteps,'%0.0f'),')...'];
            set(get(obj.PlotAxes,'parent'),'Name',FigName);
            hold(AX(1),'off');
            hold(AX(2),'off');
            drawnow;
         end
         S = (P-obj.P)*(P0-obj.P);
         % You might think about setting a conditon like P-obj.P < P_Procesion
         % (0.005 for example) to stop the search. Logically this is quit a
         % obevious critiria, but in really it is not:
         % real data is never noise free, especially the switching
         % probability, which is intrincically noisy. If you set a
         % P-obj.P < P_Procesion condition, this conditon will almost always be
         % triggered by noise prematurely!
         if COUNT >= obj.MaxSteps	% maximun step reached
             break;
         elseif S < 0 % crossing the target
             RSCOUNT = 1;
             if abs(Delta) < obj.Ib_est/SearchPrecision  % maximun precision reached
                 break;
             end
             if COUNT >= 9      % reduce step length to make the search more roburt
                 Delta = - 2*Delta/3;
             elseif COUNT == 1
                 Delta = -Delta;
             else
                 Delta = - Delta/2;
             end
             if COUNT ~=1
                Turned = true;
             end
         elseif S>0 
             if Turned	% crossing the target at least once
                if abs(Delta) < obj.Ib_est/SearchPrecision
                    break;
                else
                    if RSCOUNT < 2  % target still not crossed after tow steps, don't reduce step length
                        RSCOUNT = RSCOUNT +1;
                        if COUNT >= 9	% reduce step length to make the search more roburt
                            Delta = 2*Delta/3;
                        else
                            Delta = Delta/2;
                        end
                    end
                end
             else % the searching direction has not been changed since the start of the searching,
                 % in this case: 
                 % A, if the searching direction in minus and the searching step size keeps the
                 % same, the searching may  step into minus Ib current in some cases,
                 % this should not happen, so here check whether Ib will be minus in
                 % the next step, if so, reduce the search step;
                 % B, if the searching direction is positive, this means
                 % the Ic estimation 'Ib_est' is too small, leads to too small initial
                 % searching step, searching step needs to be increased.              
                 if Delta < 0  % conditon A, decrease searching step length
                     while 1
                        if Ib + Delta <= obj.Ib_est/10000   % do not use: Ib + Delta <= 0
                            Delta = Delta/2;
                        else
                            break;
                        end
                     end
                 else     % conditon B, increase searching step length
                     if COUNT >= 3  % already 3 or more steps, target still not crossed, step length needs to be increased.
                         Delta = 2*Delta;
                     end
                 end
             end
         end
         P0=P;
         if obj.abort
             return;
         end
     end
    if ~isempty(obj.msg)
        obj.data = NaN;
        obj.extradata = NaN;
    else
        obj.data = Ib;
        obj.extradata = P;
    end
    obj.dataready = true;
    if obj.ShowProcess  % Searching display
        FigName = ['Search Ib for P(Ib) = ',num2str(obj.P,'%0.2f'),' | Done.'];
        set(get(obj.PlotAxes,'parent'),'Name',FigName);
    end
end
