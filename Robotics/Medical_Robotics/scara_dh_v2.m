% DEFINE SCARA ROBOT USING ROBOTICS SYSTEM TOOLBOX
clear; clc; close all;

% 1. Create the Robot Object
robot = rigidBodyTree('DataFormat', 'column');
robot.Gravity = [0 0 -9.81]; % Set gravity

% --- DH PARAMETERS TABLE ---
% Format: [a, alpha, d, theta]
% a:     Link length (distance along x)
% alpha: Link twist (angle around x)
% d:     Link offset (distance along z) - Variable for Prismatic
% theta: Joint angle (angle around z)   - Variable for Revolute

% Parameters (in meters and radians)
L1 = 0.4;  % Link 1 length
L2 = 0.3;  % Link 2 length
D1 = 0.2;  % Base height
D4 = 0.1;  % Tool length

dhParams = [
    % a     alpha   d    theta
      L1    0       D1   0;      % Joint 1 (Revolute)
      L2    pi      0    0;      % Joint 2 (Revolute) - Alpha=pi flips Z-axis down
      0     0       0    0;      % Joint 3 (Prismatic) - Moves along Z (now pointing down)
      0     0       D4   0       % Joint 4 (Revolute) - Tool rotation
];

% --- BUILD THE ROBOT ---

% BODY 1: SHOULDER (Revolute)
body1 = rigidBody('body1');
jnt1 = rigidBodyJoint('jnt1', 'revolute');
% setFixedTransform defines the static part of the DH parameters.
% For revolute, 'theta' (last param) is the offset (usually 0).
setFixedTransform(jnt1, dhParams(1,:), 'dh'); 
body1.Joint = jnt1;
addBody(robot, body1, 'base');

% BODY 2: ELBOW (Revolute)
body2 = rigidBody('body2');
jnt2 = rigidBodyJoint('jnt2', 'revolute');
setFixedTransform(jnt2, dhParams(2,:), 'dh');
body2.Joint = jnt2;
addBody(robot, body2, 'body1');

% BODY 3: QUILL (Prismatic)
body3 = rigidBody('body3');
jnt3 = rigidBodyJoint('jnt3', 'prismatic');
% For prismatic, 'd' (3rd param) in DH is the offset.
% We set HomePosition to 0, but you can limit range below.
setFixedTransform(jnt3, dhParams(3,:), 'dh'); 
% Optional: Set joint limits (e.g., 0 to 0.2m extension)
jnt3.PositionLimits = [0, 0.2]; 
body3.Joint = jnt3;
addBody(robot, body3, 'body2');

% BODY 4: FLANGE (Revolute)
body4 = rigidBody('body4');
jnt4 = rigidBodyJoint('jnt4', 'revolute');
setFixedTransform(jnt4, dhParams(4,:), 'dh');
body4.Joint = jnt4;
addBody(robot, body4, 'body3');

% --- VISUALIZATION ---
figure('Name', 'SCARA Robot Model', 'Color', 'w');

% Define a configuration (joint positions)
% [Joint1_Angle; Joint2_Angle; Prismatic_Ext; Joint4_Angle]
config = homeConfiguration(robot);
config(1) = pi/4;  % Rotate shoulder 45 deg
config(2) = -pi/2; % Rotate elbow -90 deg
config(3) = 0.1;   % Extend quill 10cm

% Show the robot
show(robot, config, 'Frames', 'on');
axis([-0.5 0.8 -0.5 0.8 0 0.6]);
view(45, 30);
title('SCARA Robot defined with DH Parameters');
