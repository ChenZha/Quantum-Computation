classdef Wv_PlateauSeq < Wv_Piecewise
    % Plateau sequence
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        edgefunc = 1; % edge function: 1/2/3: linear/sqrcos/gaussian, default linear
    end
    properties (GetAccess = private, Constant = true)
        rsigma = 0.4;  % this defines the variance of the gaussian edge shape.
                       % 0.4 makes the edge fall to ~0.03 amplitude(-30dB)
                       % this property should not subject to user modification.
    end
    methods
        function obj = Wv_PlateauSeq()
            obj = obj@Wv_Piecewise();
        end
        function set.edgefunc(obj,val)
            if val ~=1 && val ~=2 && val ~=3
                error('Wv_Piecewise:InvalidInput','illegal edgefuc value, edgefunc only has two choices: 1 for linear, 2 for square cosine and 3 for gaussian.');
            end
            obj.edgefunc = val;
        end
        function val = TimeFcn(obj,t)
            % todo: implement in a more efficient way
            obj.CheckParameters(); % check parameters
            Wave = zeros(1,obj.length);
            NPcs = numel(obj.rise);
            startpnt = obj.startpnt;
            for ii = 1:NPcs
                if ii == 1
                    if obj.rise(ii) == 1 || obj.edgefunc == 1
                        Wave(startpnt:startpnt+obj.rise(ii)) =...
                            linspace(0,obj.amp(ii),obj.rise(ii)+1);
                    elseif obj.edgefunc == 2
                        x = -obj.rise(ii):0;
                        A = cos(x/obj.rise(ii)*pi/2).^2;
                        Wave(startpnt:startpnt+obj.rise(ii)) = obj.amp(ii)*A;
                    elseif obj.edgefunc == 3
                        x = -obj.rise(ii):0;
                        sigma = obj.rsigma*obj.rise(ii);
                        A = 1/(sigma*sqrt(2*pi))*exp(-x.^2/(2*sigma^2));
                        A = A - A(1);
                        A = obj.amp(ii)*A/max(A);
                        Wave(startpnt:startpnt+obj.rise(ii)) = A;
                    end
                else
                    if obj.rise(ii) == 1 || obj.edgefunc == 1
                        Wave(startpnt:startpnt+obj.rise(ii)) =...
                            linspace(obj.amp(ii-1),obj.amp(ii),obj.rise(ii)+1);
                    elseif obj.edgefunc == 2
                        if obj.amp(ii) >= obj.amp(ii-1)
                            x = -obj.rise(ii):0;
                            A = cos(x/obj.rise(ii)*pi/2).^2;
                            A = (obj.amp(ii)-obj.amp(ii-1))*A;
                            Wave(startpnt:startpnt+obj.rise(ii)) =A + obj.amp(ii-1);
                        else
                            x = 0:obj.rise(ii);
                            A = cos(x/obj.rise(ii)*pi/2).^2;
                            A = (obj.amp(ii-1)-obj.amp(ii))*A;
                            Wave(startpnt:startpnt+obj.rise(ii)) = A + obj.amp(ii);
                        end
                    elseif obj.edgefunc == 3
                        if obj.amp(ii) >= obj.amp(ii-1)
                            x = -obj.rise(ii):0;
                            sigma = obj.rsigma*obj.rise(ii);
                            A = 1/(sigma*sqrt(2*pi))*exp(-x.^2/(2*sigma^2));
                            A = A - A(1);
                            A = (obj.amp(ii)-obj.amp(ii-1))*A/max(A);
                            Wave(startpnt:startpnt+obj.rise(ii)) =A + obj.amp(ii-1);
                        else
                            x = 0:obj.rise(ii);
                            sigma = obj.rsigma*obj.rise(ii);
                            A = 1/(sigma*sqrt(2*pi))*exp(-x.^2/(2*sigma^2));
                            A = A - A(end);
                            A = (obj.amp(ii-1)-obj.amp(ii))*A/max(A);
                            Wave(startpnt:startpnt+obj.rise(ii)) = A + obj.amp(ii);
                        end
                    end
                end
                Wave(startpnt+obj.rise(ii)+1:...
                     startpnt+obj.rise(ii)+obj.duration(ii)-1) =...
                    obj.amp(ii);
                startpnt = startpnt+obj.rise(ii)+obj.duration(ii);
            end
            val = Wave(t+1);
        end
        function v = FreqFcn(obj,f)
            v = Waveform.FFT(obj,f);
        end
    end
end