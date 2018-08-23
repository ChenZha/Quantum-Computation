function sTomo1D(P,Title)
% Yulin Wu, 17/09/26

	sz = size(P);
	nq = log(sz(1))/log(3);
% 	if round(nq) ~= nq % not working
    if abs(round(nq) - nq) > 0.001
		error('illegal data format: P not a 3^nq row matrix, nq is the number of qubits');
	end
% 	if round(log(sz(2))/log2) ~= nq
    if abs(round(log(sz(2))/log(2)) - nq) > 0.001
		error('illegal data format: P not a 2^nq column matrix, nq is the number of qubits');
    end
    nq = round(nq);
	lprX0 = qes.util.looper({'X','Y','I'});
	lprX = lprX0;
	for ii = 2:nq
		lprX = lprX + lprX0;
	end
	xlbls = cell(1,3^nq);
	ii = 0;
	while 1
        ii = ii+1;
        e = lprX();
        if isempty(e)
			break;
        end
		xlbls{ii} = cellfun(@horzcat,e);
	end
	legendsLbls = cell(1,2^nq);
	for ii = 0:2^nq-1
		legendsLbls{ii+1} = ['|',dec2bin(ii,nq),'>'];
	end
	figure();
	plot(P,'-s');
	set(gca,'XLim',[1,3^nq],'YLim',[-0.035,1.05],'XTick',1:3^nq,'XTickLabel',xlbls,'YTick',[0,0.25,0.5,0.75,1]);
	grid on;
	legend(legendsLbls);
	title(['|q_{n},...q_{1}>, ',Title]);
    % xlabel('|q_{n},...q_{1}>');
end