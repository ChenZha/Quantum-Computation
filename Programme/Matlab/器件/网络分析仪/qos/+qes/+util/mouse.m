classdef mouse < handle
    % mouse controls the mouse
    % m = mouse;
    % m.MoveTo(20,20); % move the mouse to x = 20, y =20 (pixel)
    % m.LClick; % click left button
    % m.RClick; % click right button
    % m.LPress; % press and hold left button
    % m.LRelease; % release left button
    % m.Wheel(-50); % wheel back 50 pts

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        robot
        lbtn
        mbtn
        rbtn
    end
    methods
        function obj = mouse()
            obj.robot = java.awt.Robot;
            obj.lbtn = java.awt.event.InputEvent.BUTTON1_MASK;
            obj.mbtn = java.awt.event.InputEvent.BUTTON2_MASK;
            obj.rbtn = java.awt.event.InputEvent.BUTTON3_MASK;
        end
        function MoveTo(obj,xpos,ypos)
            obj.robot.mouseMove(xpos,ypos);
        end
        function LPress(obj)
            obj.robot.mousePress(obj.lbtn);
        end
        function LRelease(obj)
            obj.robot.mouseRelease(obj.lbtn);
        end
        function MPress(obj)
            obj.robot.mousePress(obj.mbtn);
        end
        function MRelease(obj)
            obj.robot.mouseRelease(obj.mbtn);
        end
        function RPress(obj)
            obj.robot.mousePress(obj.rbtn);
        end
        function RRelease(obj)
            obj.robot.mouseRelease(obj.rbtn);
        end
        function LClick(obj)
            obj.LPress();
            obj.robot.delay(10);
            obj.LRelease();
        end
        function MClick(obj)
            obj.MPress();
            obj.robot.delay(10);
            obj.MRelease();
        end
        function RClick(obj)
            obj.RPress();
            obj.robot.delay(10);
            obj.RRelease();
        end
        function Wheel(obj,amt)
            amt = round(amt);
            obj.robot.mouseWheel(amt);
        end
    end
end