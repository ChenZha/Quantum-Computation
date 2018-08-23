function [center0, center1, F00,F11,hf,axs,width] =...
			iq2prob_centers(iq_raw_0,iq_raw_1,auto)
% iq2prob_centers: finds raw iq centers(where probability of distribution is maximum)
% F00: the probability of |0> correctly measured as |0>
% F11: the probability of |1> correctly measured as |0>
% F01: the probability of |0> erroneously measured as |1>
% F10: the probability of |1> erroneously measured as |0>
% define:
% F = [F00,F10; F01,F11],
% Pm = [Pm0; Pm1]; % the measured probability
% for a state
% S = a|0> + b|1>;
% P = [P0; P1] = [abs(a)^2; abs(b)^2]; %|0>, |1> state probabilities
% by definition:
% Pm = F*[P0; P1];
% we have:
% P = inv(F)*Pm;

% Yulin Wu, 2017

    [~, ang, ~, ~,hf,axs] =... 
		data_taking.public.dataproc.iq2prob_maxVisibilityProjectionLine(iq_raw_0,iq_raw_1,auto);
    iq_raw_0_ = iq_raw_0*exp(-1j*ang);
    iq_raw_1_ = iq_raw_1*exp(-1j*ang);
    
    num_samples = numel(iq_raw_0);
    if num_samples < 2e4
        nBins = 40;
        numSmoot = 5;
    else
        nBins = 75;
        numSmoot = 11;
    end
    %%
    e0r = real(iq_raw_0_);
	e0r_ = abs(e0r - mean(e0r));
    width_r = 2*std(e0r_);
    outlierInd_r = e0r_ > width_r;
    e0i = imag(iq_raw_0_);
    e0i_ = abs(e0i - mean(e0i));
    width_i = 2*std(e0i_);
    outlierInd_i = e0i_ > width_i;
    outlierInd = outlierInd_r | outlierInd_i;
    
    width = (width_r+width_i)/2;
	
    e0r(outlierInd) = []; % remove outerliers
    e0i(outlierInd) = []; % remove outerliers
    
	e1r = real(iq_raw_1_);
	e1r_ = abs(e1r - mean(e1r));
    outlierInd_r = e1r_ > 2*std(e1r_);
    e1i = imag(iq_raw_1_);
    e1i_ = abs(e1i - mean(e1i));
    outlierInd_i = e1i_ > 2*std(e1i_);
    outlierInd = outlierInd_r | outlierInd_i;

	e1r(outlierInd) = []; % remove outerliers
    e1i(outlierInd) = []; % remove outerliers
    
    
    %%
	x_0 = min(e0r);
    x_1 = max(e0r);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
% 	c0r = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e0r,binEdges)/num_samples,numSmoot); 
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c0r = xi(idx);
	
	x_0 = min(e1r);
    x_1 = max(e1r);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
    
    dis = smooth(histcounts(e1r,binEdges)/num_samples,5);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c1r = xi(idx);
    %%
	
	x_0 = min(e0i);
    x_1 = max(e0i);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
% 	c0i = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e0i,binEdges)/num_samples,numSmoot);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c0i = xi(idx);
	
	x_0 = min(e1i);
    x_1 = max(e1i);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e1,binEdges)/num_samples,3));
% 	c1i = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e1i,binEdges)/num_samples,5);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c1i = xi(idx);
    
    %
    center0 = (c0r+1j*c0i)*exp(1j*ang);
    center1 = (c1r+1j*c1i)*exp(1j*ang);
    %
	e0 = real(iq_raw_0_);
	e1 = real(iq_raw_1_);
	cc = (c0r+c1r)/2;
	if c1r > c0r
		F00 = sum(e0<=cc)/num_samples; % the probability of |0> correctly measured as |0>
		F11 = sum(e1>=cc)/num_samples; % the probability of |1> correctly measured as |0>
	else
		F00 = sum(e0>=cc)/num_samples;
		F11 = sum(e1<=cc)/num_samples;
	end
%	F01 = 1-F00; % the probability of |0> erroneously measured as |1>
%	F10 = 1-F11; % the probability of |1> erroneously measured as |0>
    try 
        hold(axs(1),'on');
        plot(axs(1),center0,'+','Color','w','MarkerSize',15,'LineWidth',1);
        plot(axs(1),center1,'+','Color','g','MarkerSize',15,'LineWidth',1);
        hold(axs(1),'off');
    catch
    end
end