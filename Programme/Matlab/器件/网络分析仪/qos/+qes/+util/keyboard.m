classdef keyboard < handle
    % keyboard controls the keyboard
    % m = keyboard;
    % k.Punch('G'); % punch key 'G'.
    % k.Press('G'); % press and hold key 'G'.
    % k.Release('G'); % release key 'G'.
    % dose not support all the keys yet.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
    end
    properties (SetAccess = private, GetAccess = private)
        robot
    end
    methods
        function obj = keyboard()
            obj.robot = java.awt.Robot;
        end
        function Press(obj,key)
            [c,upkey,dwnkey] = qes.util.keyboard.KeyCode(key);
            if isempty(c)
                return;
            end
            if ~isempty(upkey)
                obj.robot.keyRelease(upkey);
            end
            if ~isempty(dwnkey)
                obj.robot.keyPress(dwnkey);
            end
            obj.robot.keyPress(c);
        end
        function Release(obj,key)
            [c,~,dwnkey] = qes.util.keyboard.KeyCode(key);
            if isempty(c)
                return;
            end
            obj.robot.keyRelease(c);
            if ~isempty(dwnkey)
                obj.robot.keyRelease(dwnkey);
            end
        end
        function Punch(obj,key)
            Press(obj,key);
            obj.robot.delay(5);
            Release(obj,key);
            obj.robot.delay(5);
        end
        function PEnter(obj)
            obj.robot.keyPress(13);
        end
        function REnter(obj)
            obj.robot.keyRelease(13);
        end
        function PBackSpace(obj)
            obj.robot.keyPress(8);
        end
        function RBackSpace(obj)
            obj.robot.keyRelease(8);
        end
        function PShift(obj)
            obj.robot.keyPress(16);
        end
        function RShift(obj)
            obj.robot.keyRelease(16);
        end
        function PCtrl(obj)
            obj.robot.keyPress(17);
        end
        function RCtrl(obj)
            obj.robot.keyRelease(17);
        end
        function PAlt(obj)
            obj.robot.keyPress(20);
        end
        function RAlt(obj)
            obj.robot.keyRelease(20);
        end
        function PDel(obj)
            obj.robot.keyPress(46);
        end
        function RDel(obj)
            obj.robot.keyRelease(46);
        end
    end
    methods (Access = private, Static = true)
        % not complete
        function [c,upkey,dwnkey] = KeyCode(key)
            if ~ischar(key)
                error('key is not a character!');
            end
            upkey = [];
            dwnkey = [];
            c = [];
            if isletter(key)
                upkey = 20; % cape lock
                if key < 97 % upper case
                    dwnkey = 16; % shift
                end
                c = uint8(upper(key));
                return;
            end
            switch key
                case '*'
                    c = 106;
                    return;
                case '+'
                    c = 107;
                    return;
                case '-'
                    c = 109;
                    return;
                case '.'
                    c = 110;
                    return;
                case '/'
                    c = 111;
                    return;
                case ';'
                    c = 186;
                    return;
            end
            if uint8(key) == 8 || uint8(key) == 9 || uint8(key) == 13 || uint8(key) == 32 || uint8(key) == 27
                c = uint8(key);
                return;
            end
            % to do...
        end
    end
end