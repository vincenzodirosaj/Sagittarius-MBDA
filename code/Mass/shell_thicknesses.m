clc; close all; clearvars;

% Introduce the variables

p_chamber = 50;                           % Chamber pressure
p_chamber = p_chamber*10^5;               % In Pascal
D_case = 0.12;                            % Case diameter
r_case = D_case/2;                        % Case radius
D_nozzle = 0.1;                           % Nozzle diameter
r_nozzle = D_nozzle/2;                    % Nozzle radius

%% Material: Steel
E_steel = 1.75 * 10^11;                   % Young's modulus of the material
alpha_thermal = 2.0 * 10^(-6);            % Steel thermal conductivity
sigma_yield = 350 * 10^6;                 % Yield stress

%% Thermal behaviour
delta_T = 500;                            % Thermal gradient the structure must withstand
sigma_thermal = E_steel*alpha_thermal*delta_T              % Thermal stress

%% Nozzle and Case thicknesses
t_case = (p_chamber*r_case)/(sigma_yield/1.2-sigma_thermal)     % Case thickness
t_nozzle = (p_chamber*r_nozzle)/(sigma_yield/1.2-sigma_thermal) % Nozzle thickness

sigma_radial = p_chamber*r_case/t_case                      % Radial pressure load
sigma_axial = (p_chamber*r_case)/(2*t_case)                % Axial pressure load

%% Sizing of the structure containing the battery and the warhead
%% Known parameters
R_outer = 0.1;                            % Outer radius
D_outer = 2*R_outer;                      % Outer diameter
E_alu = 72 * (10^9);                      % Young's modulus, alloy 7075
length = 1.0249;                          % Length
arm = length-0.6633;                      % Moment arm of the force
rho_alu = 2800;                           % Kg/m^3, density

%% Compression sizing
t_compression = 0.000001;                 % Thickness initialization
sigma_critical = 50 * 10^6;               % Critical stress initialization
for i = 1:1000000
    nu_poisson = 0.3;                              % Poisson's modulus
    t_compression = sigma_critical*(sqrt(3*(1-nu_poisson^2)))*R_outer/E_alu;  % Thickness from the direct formula
    r_inner = R_outer - t_compression;             % Radius
    d_inner = 2*r_inner;                           % Diameter
    area = 0.25*pi*(D_outer^2-(D_outer-2*t_compression)^2);         % Area of a hollow circular section
    I_polar = pi/32 *(D_outer^4-(D_outer-2*t_compression)^4);       % Polar moment of inertia
    I_section = 0.5*I_polar;                       % The polar moment of inertia is the diagonal
                                                   % of the inertia tensor and, given the double
                                                   % symmetry, the moments of inertia about the
                                                   % two axes are equal
    radius_gyration = sqrt(I_section/area);        % Radius of gyration


    P_euler = (pi^2*E_alu*I_section)/((2*length)^2*5);   % Euler buckling load
    sigma_critical = P_euler/area;                       % Critical stress

    slenderness = 2*length/radius_gyration;              % Beam slenderness

end
F_compression = 250;                      % Compressive force acting on the structure, kgf
F_compression = F_compression*9.80665;    % Newton;


%% Shear sizing
t_shear = t_compression;                  % Thickness initialization
for i = 1:1000000
    r_inner = R_outer - t_shear;                  % Radius
    d_inner = 2*r_inner;                          % Diameter
    area = 0.25*pi*(D_outer^2-(D_outer-2*t_shear)^2);         % Area
    I_polar = pi/32 *(D_outer^4-(D_outer-2*t_shear)^4);       % Polar moment of inertia
    I_section = 0.5*I_polar;                      % Section moment of inertia


    load_factor = 10;                             % Load factor
    weight = 30;                                  % Weight including ballast
    shear_force = load_factor * weight;           % Shear force, kgf
    shear_force = shear_force*9.80665;            % Shear force, Newton
    theta_angle = linspace(0,2*pi, 100);          % Section angle
    R_mean = (R_outer+r_inner)/2;                 % Mean radius
    S_static = -(R_outer^2*t_shear*sin(theta_angle));   % Static moment of the section
    tau = - ((shear_force*S_static)/(I_section*t_shear)); % Shear stress
    tau_max = max(tau);                           % Maximum stress
    tau_critical = 1/sqrt(3) *sigma_critical;     % Critical tau according to the V.M. criterion

    % Check
    if tau_max > tau_critical
       t_shear = t_shear+0.0000001;
    else
        t_shear = t_shear;
    end
end


%% Bending moment sizing
t_bending = t_shear;
for i = 1:10000
    r_inner = R_outer - t_bending;
    d_inner = 2*r_inner;
    area = 0.25*pi*(D_outer^2-(D_outer-2*t_bending)^2);
    I_polar = pi/32 *(D_outer^4-(D_outer-2*t_bending)^4);
    I_section = 0.5*I_polar;
    radius_gyration = sqrt(I_section/area);
    M_bending = shear_force * arm;
    W_bending = pi * (D_outer^4-d_inner^4)/(32*D_outer);   % Bending section modulus
    sigma_bending_max = M_bending/W_bending ; % because the maximum bending stress is
    % found at the outer edge of the circumference and
    % therefore at the radius


    if sigma_bending_max > sigma_critical
       t_bending = t_bending+0.0001;
    else
        t_bending = t_bending;
    end
end
thickness = [t_compression t_shear t_bending];   % Take the largest of these as the thickness
thickness = max(thickness);
if thickness<1
    thickness = 0.002;
end
thickness = thickness


%% Sizing
% Once the thickness is known, repeat all the structural calculations to
% evaluate the geometric properties of the cylinder

r_inner = R_outer - thickness;
d_inner = 2*r_inner;
area = 0.25*pi*(D_outer^2-(D_outer-2*thickness)^2);
I_polar = pi/32 *(D_outer^4-(D_outer-2*thickness)^4);
I_section = 0.5*I_polar;
radius_gyration = sqrt(I_section/area);
volume_shell = area * length;
W_shell = volume_shell * rho_alu

%% Fatigue behaviour
% Once the thickness geometry is known, it is appropriate to evaluate the
% fatigue behaviour; since the V.M. stress is < 80 MPa, this behaviour is
% verified
sigma_axial_stress = F_compression/area;
R_mean = (R_outer+r_inner)/2;
S_static = -(R_outer^2*thickness*sin(theta_angle));
tau = - ((shear_force*S_static)/(I_section*thickness));
tau_max = max(tau);
W_bending = pi * (D_outer^4-d_inner^4)/(32*D_outer);
sigma_bending_max = M_bending/W_bending ;
sigma_von_mises = sqrt(sigma_bending_max^2+sigma_axial_stress^2+3*tau_max^2);

%% SAVE DATA
save('thicknesses.mat',"thickness","t_nozzle","t_case");

%% Plot section
theta_angle = linspace(0,2*pi, 100);
x_outer = R_outer * cos(theta_angle);
y_outer = R_outer * sin(theta_angle);
x_int = r_inner * cos(theta_angle);
y_int = r_inner * sin(theta_angle);




[cyl_outer_x, cyl_outer_y, cyl_outer_z] = cylinder(R_outer, 50);
cyl_outer_z = cyl_outer_z * length;
[cyl_int_x, cyl_int_y, cyl_int_z] = cylinder(r_inner, 50);
cyl_int_z = cyl_int_z * length;
figure(2)
surf(cyl_outer_x, cyl_outer_y, cyl_outer_z, 'FaceAlpha', 0.5);
hold on;
surf(cyl_int_x, cyl_int_y, cyl_int_z, 'FaceAlpha', 0);
title('Cylinder')

figure(1)
hold on;
plot(x_outer, y_outer, 'b-');
plot(x_int, y_int, 'b-');
axis equal
title('Shell structure cross-section');
hold off
