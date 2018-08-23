function [Frequency,Amp, varargout] = fftSpectrum(t,y,varargin)
% fftSpectrum calculates the spectral amplitude of a time domain signal:
% y = y(t)
% if t is not equally spaced, y will be resampled using interpolation by
% given an extra input argument(any type and value is ok).
% Frequency unit: 1/(t's unit)
% Amp: Amplitude, unit: the same as y
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $
L = length(y);
L1 = length(t);
if L ~= L1
    Frequency = 'Input arguments must be the same length!';
    Amp ='Input arguments must be the same length!';
else
    if nargin >2 && length(unique(diff(t))) > 1
        ti = linspace(t(1),t(end),L1); % resample in case original data is not equally sampled
        yi = interp1(t,y,ti,'spline');
    else
        ti = t;
        yi = y;
    end
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(yi,NFFT)/ L;
    SamplingFrequency = 1/(ti(2)-ti(1));
    Frequency = SamplingFrequency/2*linspace(0,1,NFFT/2+1);
    Y = Y(1:length(Frequency));
    Amp = 2*abs(Y);
    varargout{1} = Y;
end
