classdef screenShot < handle
    % screenShot takes screen shots
    % s = screenShot;
    % img = s.Shot; % get a screen shot of the whole screen
    % figure();imshow(img); % show the screen shot
    % img = s.Shot([100,50,300,500]); % get a screen shot of the region
    %                                 % x from 100 to 100+300-1 pixels,
    %                                 % y from 500 to 50+500-1 pixels.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        robot
        screensize
        imsz
    end
    methods
        function obj = screenShot()
            obj.robot = java.awt.Robot;
            scrsz = get(0,'ScreenSize');
            obj.screensize = scrsz(3:4);
            obj.imsz = java.awt.Rectangle;
        end
        function img = Shot(obj,pos)
            if nargin == 1
                obj.imsz.x = 0;
                obj.imsz.y = 0;
                obj.imsz.width = obj.screensize(1);
                obj.imsz.height = obj.screensize(2);
            else
                obj.imsz.x = pos(1);
                obj.imsz.y = pos(2);
                obj.imsz.width = pos(3);
                obj.imsz.height = pos(4);
            end
            jvi = obj.robot.createScreenCapture(obj.imsz);
            img = jvi.getData.getPixels(0,0,obj.imsz.width,obj.imsz.height,[]);
            img = permute(reshape(img,3,obj.imsz.width,obj.imsz.height),[3 2 1])/255;
        end
    end
end