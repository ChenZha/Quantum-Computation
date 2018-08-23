function g = XYArb(qubit, phi, ang)
% arbitary rotation at an arbitary axis in the xy plane
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    import sqc.op.physical.gate.XYArb_
	if strcmp(qubit.g_XY_impl,'hPi') && abs(ang) > pi/2
		if ang > 0
            g = XYArb_(qubit, phi, pi/2)*XYArb_(qubit, phi, ang - pi/2);
        else
            g = XYArb_(qubit, phi, -pi/2)*XYArb_(qubit, phi, ang + pi/2);
        end
    else
        g = XYArb_(qubit, phi, ang);
    end
end