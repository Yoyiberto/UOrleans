% MATLAB script to define parameters for the Simulink model

% Clear workspace and command window
clear; clc;

% Define the proportional gain 'a'
% The stability of the system will depend on this value.
a = ;

% Define the frequency 'w' for the non-stationary component (in rad/s)
w = 5;

% --- Running the Simulation ---
% 1. Save your Simulink model (e.g., as 'motor_model.slx').
% 2. Run this script to load the variables 'a' and 'w' into the MATLAB workspace.
% 3. Open your Simulink model and press the "Run" button.
% 4. Double-click the Scope block to view the output y(t).

% Optional: You can also run the simulation directly from the script
% by uncommenting the line below (replace 'motor_model' with your file name)
% sim('motor_model');