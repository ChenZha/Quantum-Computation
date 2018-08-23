classdef XYArb_ < sqc.op.physical.gate.XY_base
    % arbitary rotation at an arbitary axis in the xy plane
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phi % defines the rotation axis
        ang
    end
    methods
        function obj = XYArb_(qubit, phi, ang)
            % phi: defines the rotation axis
            % ang: the rotation angle
            % XYArb(q, 0, pi) is the X gate
            % XYArb(q, 0, -pi/2) and XYArb(q, pi, pi/2) is the X2m gate
            % XYArb(q, pi/2, pi/2) and XYArb(q, -pi/2, -pi/2) is the Y2p gate
            % etc.,...
            obj = obj@sqc.op.physical.gate.XY_base(qubit);
            if ang >= pi
                ang = ang - 2*pi;
            elseif ang < -pi
                ang = ang + 2*pi;
            end
            switch qubit.g_XY_impl
                case {'', 'pi'}
                    obj.length = obj.qubits{1}.g_XY_ln;
                    obj.amp = obj.qubits{1}.g_XY_amp*abs(ang)/pi;
                    if ang >= 0
                        obj.phase = phi;
                    else
                        obj.phase = -phi;
                    end
                case 'hPi'
                    obj.length = obj.qubits{1}.g_XY2_ln;
                    if abs(ang) <= pi/2
                        obj.amp = 2*obj.qubits{1}.g_XY2_amp*abs(ang)/pi;
                        if ang >= 0
                            obj.phase = phi;
                        else
                            obj.phase = -phi;
                        end
                    else
                        error('illegal usage, do not XYArb_ directly, use XYArb or Rxy instead');
                    end
                otherwise
                    error('unrecognized XY gate implimentation: %s, available XY gate implementation options are: pi and hPi',...
                        qubit.g_XY_typ);
            end
            obj.setGateClass('XYArb');
        end
    end
end