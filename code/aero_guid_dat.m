% SAGITTARIUS PROGRAM 3DOF SIMULATION
clear all; close all;
global x_ini h_ini v_aim x_ini_tgt h_ini_tgt v_tgt theta_tgt g S_ref

%%%%%%%%%%%%%% Run this again now that the calculations have been redone
load("Propulsion/Sustain/propellant_mass.mat");     %%%%%%%%%%%%%% Remember to update this (x ANTO; at the weekend Dav, Car and Gab will use a new program)
load("warhead/results_lethality_tests.mat")
load("warhead/results_lethality_tests_small.mat")

% Useful Constants & Atmospheric Constants
%==================================================================
d2r     = pi/180;                 % Conversion Deg to Rad
g       = 9.81;                   % Gravity [m/s/s]
m2ft    = 3.28084;                % metre to feet
Kg2slug = 0.0685218;              % Kg to slug

T0      = 288.16;                 % Temp. at Sea Level [K]
rho0    = 1.225;                  % Density [Kg/m^3]
L       = 0.0065;                 % Lapse Rate [K/m]
R       = 287.26;                 % Gas Constant J/Kg/K
gam     = 1.403;                  % Ratio of Specific Heats
P0      = 101325.0;               % Pressure at Sea Level [N/m^2]
h_trop  = 11000.0;                % Height of Troposphere [m]

%==================================================================
% Missile Configuration
%==================================================================
S_ref   = 0.0050;                       % Reference area [m^2]
d_ref   = 0.08;                        % Reference length [m]
mass_full = 11.224;                     % Mass with full propellant[Kg]
mp = 2.524;                                 % Propellant mass[kg]
mass_empty   = mass_full - mp;          % Mass without propellant [Kg]
Iyy_full = 1.034;                       %[kg*m2]
Iyy_empty = 0.904;                        %[kg*m2]

%=================================================================
% Solid engine
%=================================================================
Thrust  = 150;
t_fin_burn = 30;

%==================================================================
% CG_with_time
%==================================================================
CG_with_time(1,:) = [0, t_fin_burn];
CG_with_time(2,:) = [0.47645, 0.41875];

mass_with_time(1,:) = [0, t_fin_burn];
mass_with_time(2,:) = [mass_full, mass_empty];

%==================================================================
% Missile Aerodynamics
%==================================================================
X_cp = 0.6873;                 % X coordinate of the center of pressure


% Body coeffcients
Cx_with_M(1,:) = [0.27, 0.29, 0.75, 0.83,  0.7];     % Axial Force Coefficien
Cx_with_M(2,:) = [0,    0.85,     1,  1.5,    2];

Cn_alpha = 7.609;             % Normal Force Coefficient

% Fin coeffcients
Cx_fin = 0;                  % Fin Axial Force Coefficient
Cz_fin = 5.61;               % Normal Force Coefficient
% Moment Coefficients
Cm_q     = -0.65;           % From previous matlab calculations

%==================================================================
% Missile Actuators
%==================================================================
wn_fin      = 150.0;            % Actuator Bandwidth [rad/sec]
z_fin 	    = 0.707;              % Actuator Damping
fin_act_0   = 0.0;              % Initial Fin Angle [rad]
fin_max     =  35.0*d2r;        % Max Fin Deflection [rad]  %%%%%%%%%%% To be set once the correct aerodynamics is included
fin_min	    = -35.0*d2r;        % Min Fin Deflection [rad]
fin_maxrate = 500*d2r;          % Max Fin Rate [rad/sec]

%==================================================================
% Sensors (positioned in the third section of sustain)
%==================================================================
l_acc       = 0.07465;             % Position of accelerometer ahead of c.g [m]
max_load_factor = 6;
max_acc = max_load_factor*g;               % Maximum demanded acceleration
load aero_guid_autop	        % Gain Scheduled autopilot gains

%==================================================================
% Define Simulations
%==================================================================

% Maximum area to protect
x_prot = 8000;
z_prot = 5000;

n_x = 1;
n_h = 1;
v_x_ini_tgt = linspace(1000,x_prot,n_x);
v_h_ini_tgt = linspace(1000,z_prot,n_h);
Miss_table = zeros(n_x*n_h,7);

run_index = 0;
for i = 1:n_x
    for j = 1:n_h
        run_index = run_index+1;
        %==================================================================
        % Define Target
        x_ini_tgt = v_x_ini_tgt(i);
        h_ini_tgt = v_h_ini_tgt(j);
        pos_tgt   = [x_ini_tgt,-h_ini_tgt]; % Initial Target position [m]
        % minus is for the graphics
        v_tgt     = 60;		        % Target Velocity [m/s]
        theta_tgt = 180*d2r;		% Target Direction [rad]

        %==================================================================
        % Aiming
        v_aim = 200;
        [sol_theta_ini,t_crash_preview]  = fsolve(@AimingFun, [0, 30]);		% Initial Body Attitude [rad]
        theta_ini = min(sol_theta_ini);   % First solution
        theta_ini = 1.3*theta_ini + 0.008*(1/theta_ini);
        theta_ini_deg = theta_ini/d2r;
        look_angle_ini = atan((h_ini_tgt-h_ini)/(x_ini_tgt-x_ini));


        %==================================================================
        % Define Initial Conditions
        %==================================================================
        % Initial values (Booster)
        x0 = 0;                              % Initial position [m]
        z0 = 0;
        V0_axial = 0;                        % Initial velocity along the axis [m/s]
        V0_normal = 0;                       % Initial velocity along the normal to the axis [m/s]

        t_fin_boost = 0.62;                                     % time of booster separation
        state0 = [V0_axial, V0_normal, x0, z0, theta_ini];      % Sustain initial theta = Booster initial theta
        [vTime,mState] = ode45(@ThrustFun_booster,[0 t_fin_boost],state0);

        % Initial values (Sustain = end of the boosting phase)
        x_ini      = mState(end,3);		                    % Initial downrange position [m]
        h_ini      = mState(end,4);                         % Initial altitude [m]
        v_ini      = sqrt(mState(end,1)^2+mState(end,2)^2);	% Initial velocity [m/s]
        alpha_ini  = 0.00001*d2r;		                    % Initial incidence [rad]
        q_ini      = 0.00001*d2r;		                    % Initial pitch rate [rad/sec]


        sim("Flight3Dof_V.slx");

        final_position = ans.relative_position(end,:);   % x and y relative coordinates
        final_look_angle = ans.look_angle.signals.values(end);

        trajectory_x(:,1) = ans.relative_position(:,1);
        trajectory_x(:,2) = -ans.relative_position(:,2);
        %%% trajectory_theta(:,1) = ans.look_angle(:);
        trajectory_theta = ans.theta.signals.values;
        % Fill in the miss table
        Miss_table(run_index,1) = x_ini_tgt;                                % First column: initial target x
        Miss_table(run_index,2) = h_ini_tgt;                                % Second column: initial target z
        Miss_table(run_index,3) = sqrt( (x_ini_tgt)^2 + (h_ini_tgt)^2 );    % Third column: initial target distance to go
        Miss_table(run_index,4) = sqrt( (final_position(1)^2) + final_position(2)^2 ); % Fourth column: miss distance
        Miss_table(run_index,5) = final_look_angle;                         % Fifth column: look angle
        Miss_table(run_index,6) = max(ans.airspeed.signals.values);         % Maximum speed reached
        Miss_table(run_index,7) = ans.airspeed.time(end);                   % Simulation time


        % General settings for the output folder
        folder_name = sprintf('Scenario plots/TGT initial position X = %d , Z = %d', x_ini_tgt, h_ini_tgt);
        mkdir(folder_name);
        image_folder = sprintf('Scenario plots/TGT initial position X = %d , Z = %d', x_ini_tgt, h_ini_tgt);

% Plot settings to improve figure quality
set(0, 'defaultAxesFontSize', 14, 'defaultLineLineWidth', 1.5); % Thicker fonts and lines
set(0, 'defaultFigureColor', 'w'); % White background for the figure

% 1) Airspeed
F1 = figure;
plot(ans.airspeed.time, ans.airspeed.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Airspeed (m/s)", 'FontSize', 14);
title("Airspeed over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F1, fullfile(image_folder, sprintf('Airspeed at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F1, fullfile(image_folder, sprintf('Airspeed at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 2) Distance to go (Range)
F2 = figure;
plot(ans.distance_to_go.time, ans.distance_to_go.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Distance to go (m)", 'FontSize', 14);
title("Distance to Go over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F2, fullfile(image_folder, sprintf('Distance to go at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F2, fullfile(image_folder, sprintf('Distance to go at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 3) Mass
F3 = figure;
plot(ans.mass.time, ans.mass.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Mass (kg)", 'FontSize', 14);
title("Mass over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F3, fullfile(image_folder, sprintf('Mass at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F3, fullfile(image_folder, sprintf('Mass at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 4) PK (last 4 seconds)
F4 = figure;
plot(ans.Pk_final_values.time, ans.Pk_final_values.signals.values, 'Color', 'r', 'LineWidth', 1.5);
xlim([ans.Pk_final_values.time(round((9985/10000) * length(ans.Pk_final_values.time))) ans.Pk_final_values.time(end)]);
xlabel("Time (s)", 'FontSize', 14); ylabel("PK", 'FontSize', 14);
title("PK over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F4, fullfile(image_folder, sprintf('PK at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F4, fullfile(image_folder, sprintf('PK at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 5) Demanded acceleration
F5 = figure;
plot(ans.Demanded_acc.time, ans.Demanded_acc.signals.values, 'Color', 'r', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Acc (m/s^2)", 'FontSize', 14);
title("Demanded Acceleration over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F5, fullfile(image_folder, sprintf('Demanded acceleration at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F5, fullfile(image_folder, sprintf('Demanded acceleration at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 6) Actuated acceleration
F6 = figure;
plot(ans.Actuated_acc.time, ans.Actuated_acc.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Acc (m/s^2)", 'FontSize', 14);
title("Actuated Acceleration over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F6, fullfile(image_folder, sprintf('Actuated acceleration at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F6, fullfile(image_folder, sprintf('Actuated acceleration at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 7) Theta
F7 = figure;
plot(ans.theta.time, ans.theta.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Theta (rad)", 'FontSize', 14);
title("Theta over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F7, fullfile(image_folder, sprintf('Theta at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F7, fullfile(image_folder, sprintf('Theta at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 8) Look angle
F8 = figure;
plot(ans.look_angle.time, ans.look_angle.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Look Angle (rad)", 'FontSize', 14);
title("Look Angle over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F8, fullfile(image_folder, sprintf('Look Angle at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F8, fullfile(image_folder, sprintf('Look Angle at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 9) Angle of Attack (Alpha)
F9 = figure;
plot(ans.alpha.time, ans.alpha.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlabel("Time (s)", 'FontSize', 14); ylabel("Alpha (rad)", 'FontSize', 14);
title("Alpha over Time", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F9, fullfile(image_folder, sprintf('Alpha at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F9, fullfile(image_folder, sprintf('Alpha at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 10) Cut Look Angle (zoomed)
F10 = figure;
plot(ans.look_angle.time, ans.look_angle.signals.values, 'Color', 'b', 'LineWidth', 1.5);
xlim([ans.look_angle.time(1), ans.look_angle.time(round((9985/10000) * length(ans.look_angle.time)))]);
xlabel("Time (s)", 'FontSize', 14); ylabel("Look Angle (rad)", 'FontSize', 14);
title("Look Angle over Time (Zoomed)", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F10, fullfile(image_folder, sprintf('Zoom Look Angle at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F10, fullfile(image_folder, sprintf('Zoom Look Angle at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

% 11) Demanded acceleration (cut final divergence)
F11 = figure;
plot(ans.Demanded_acc.time, ans.Demanded_acc.signals.values, 'Color', 'r', 'LineWidth', 1.5);
xlim([ans.Demanded_acc.time(1), ans.Demanded_acc.time(round((99/100) * length(ans.Demanded_acc.time)))]);
xlabel("Time (s)", 'FontSize', 14); ylabel("Acc (m/s^2)", 'FontSize', 14);
title("Demanded Acceleration over Time (Cut)", 'FontSize', 16, 'FontWeight', 'bold');
subtitle(sprintf('at X = %d , Z = %d', x_ini_tgt, h_ini_tgt), 'FontSize', 12, 'FontWeight', 'bold');
grid on;
exportgraphics(F11, fullfile(image_folder, sprintf('Zoom Demanded acceleration at X = %d , Z = %d.png', x_ini_tgt, h_ini_tgt)), 'Resolution', 300);
savefig(F11, fullfile(image_folder, sprintf('Zoom Demanded acceleration at X = %d , Z = %d.fig', x_ini_tgt, h_ini_tgt)));

    end
end

Final_table = array2table(Miss_table, "VariableNames", ["x_ini_tgt", "z_ini_tgt", "Distance to go ini", ...
    "Miss Distance", "Final look angle", "V_max", "T-simulation"]);

function createPlot(x_data, y_data, x_label, y_label, title_text, subtitle_text, filename, color, image_folder)
    fig = figure;
    plot(x_data, y_data, 'Color', color, 'LineWidth', 1.5);
    xlabel(x_label, 'FontSize', 14); ylabel(y_label, 'FontSize', 14);
    title(title_text, 'FontSize', 16, 'FontWeight', 'bold');
    subtitle(subtitle_text, 'FontSize', 12, 'FontWeight', 'bold');
    grid on; % Grid to improve readability
    filename = fullfile(image_folder, filename);
%   savePlot(fig, filename); % Save in high resolution
    savefig(fig, [filename '.fig']); % Save in MATLAB format
end
