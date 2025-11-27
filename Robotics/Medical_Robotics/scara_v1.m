% SIMPLE SCARA ROBOT SIMULATION
clear; clc; close all;

% --- 1. ROBOT PARAMETERS ---
L1 = 5;  % Length of first arm (link 1)
L2 = 4;  % Length of second arm (link 2)

% --- 2. SIMULATION SETUP ---
% We will move the robot in a circle for this demo
t = linspace(0, 2*pi, 100); 
target_x = 5 + 2*cos(t);    % Circle center at (5,0) radius 2
target_y = 2*sin(t); 
target_z = 2 + sin(2*t);    % Move up and down slightly

% Prepare the figure
figure('Color', 'w');
axis([-2 10 -5 5 0 6]); 
grid on; hold on;
view(45, 30); % Set 3D viewing angle
xlabel('X'); ylabel('Y'); zlabel('Z');
title('SCARA Robot Simulation');

% Create graphics objects for the robot links (initially empty)
link1_plot = plot3([0,0], [0,0], [0,0], 'b-', 'LineWidth', 5); % Blue Link 1
link2_plot = plot3([0,0], [0,0], [0,0], 'r-', 'LineWidth', 5); % Red Link 2
vertical_plot = plot3([0,0], [0,0], [0,0], 'k-', 'LineWidth', 2); % Black vertical shaft
trail_plot = plot3(target_x, target_y, target_z, 'g--', 'LineWidth', 1); % Green path

% --- 3. ANIMATION LOOP ---
for i = 1:length(t)
    % Current target
    x = target_x(i);
    y = target_y(i);
    z = target_z(i);
    
    % --- INVERSE KINEMATICS (The Math) ---
    % Calculate the elbow angle (theta2) using Law of Cosines
    % r is distance from base to target (ignoring Z)
    r_sq = x^2 + y^2;
    cos_theta2 = (r_sq - L1^2 - L2^2) / (2 * L1 * L2);
    
    % Safety check for workspace limits
    if abs(cos_theta2) > 1
        disp('Target out of reach!'); continue;
    end
    
    theta2 = acos(cos_theta2); % Elbow angle (one of two possible solutions)
    
    % Calculate shoulder angle (theta1)
    theta1 = atan2(y, x) - atan2(L2 * sin(theta2), L1 + L2 * cos(theta2));
    
    % --- FORWARD KINEMATICS (Visualizing) ---
    % Where are the joints actually located?
    % Joint 0: Base (0,0,0) -> (0,0,z) to raise it up visually
    base_pos = [0, 0, 4]; 
    
    % Joint 1: Elbow position
    elbow_x = L1 * cos(theta1);
    elbow_y = L1 * sin(theta1);
    elbow_z = base_pos(3); % SCARA arms stay level
    elbow_pos = [elbow_x, elbow_y, elbow_z];
    
    % Joint 2: End Effector (X,Y position)
    ee_x = elbow_x + L2 * cos(theta1 + theta2);
    ee_y = elbow_y + L2 * sin(theta1 + theta2);
    ee_z = elbow_z;
    ee_pos = [ee_x, ee_y, ee_z];
    
    % End Tip: The vertical Z-axis rod
    tip_pos = [ee_x, ee_y, z];
    
    % --- UPDATE GRAPHICS ---
    set(link1_plot, 'XData', [base_pos(1), elbow_pos(1)], ...
                    'YData', [base_pos(2), elbow_pos(2)], ...
                    'ZData', [base_pos(3), elbow_pos(3)]);
                    
    set(link2_plot, 'XData', [elbow_pos(1), ee_pos(1)], ...
                    'YData', [elbow_pos(2), ee_pos(2)], ...
                    'ZData', [elbow_pos(3), ee_pos(3)]);
    
    set(vertical_plot, 'XData', [ee_pos(1), tip_pos(1)], ...
                       'YData', [ee_pos(2), tip_pos(2)], ...
                       'ZData', [ee_pos(3), tip_pos(3)]);
    
    % Draw a dot at the tip
    plot3(tip_pos(1), tip_pos(2), tip_pos(3), 'm.', 'MarkerSize', 10);
    
    drawnow;      % Force MATLAB to update the screen
    pause(0.05);  % Control speed
end
