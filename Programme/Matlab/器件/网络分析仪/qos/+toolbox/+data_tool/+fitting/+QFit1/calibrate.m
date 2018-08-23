function [ calibrateds21 ] = calibrate( freq,s21 )
%CALIBRATE Summary of this function goes here
%   Detailed explanation goes here

[ms21,ns21] = size(s21);
calibrateds21 = ones(ms21,ns21);
for iim = 1:ms21
    %% phase
    phase = recalculatephase(angle(s21(iim,:)));
    calibrateds21(iim,:) = s21(iim,:)./exp(1i*((phase(ns21)-phase(1))/(freq(ns21)-freq(1)).*(freq(1:ns21)-freq(1))));
    calibrateds21(iim,:) = calibrateds21(iim,:)/exp(1i*angle(calibrateds21(iim,1)));
    %% amplitude
    a = sqrt(abs(calibrateds21(iim,1))*abs(calibrateds21(iim,end)));
    calibrateds21(iim,:) = calibrateds21(iim,:)/a;
end
end

function [rephase] = recalculatephase(phase)
n = length(phase);
dphase = diff(phase);
for ii = 1:n-1
    if dphase(ii)>pi
        dphase(ii) = dphase(ii)-pi*2;
    elseif dphase(ii)< -pi
        dphase(ii) = dphase(ii)+pi*2;
    end
end

rephase = zeros(1,n);
rephase(1) = phase(1);
for ii = 2:n
    rephase(ii) = rephase(ii-1) + dphase(ii-1);
end
end