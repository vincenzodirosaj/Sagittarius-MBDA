close all; clear all; clc;

global g mdot_variable S c m0 Cd mdot_mean

%% Initialization
g = 9.8;                              % Gravity acceleration [m/s^2]
R = 287;                              % Universal gas constant [J/(kg*K)]
gamma = 1.15;
[~,~,P_ambient,rho] = atmosisa(-0000);       % External pressure and density [Pa], [kg/m3]

P0 = 7*10^5;                         % [pa]
Pexit = 1*P_ambient;

% calculation of c
phi = 0.98;
g_cm_s2 = 981;
cal_val = 984;   %[cal/g]      pg 23, see readme
J = 4.18*10^7;   %[ergs/cal]  conversion factor
c = (phi/g_cm_s2)*sqrt(2*J*cal_val*(1-(Pexit/P0)^((gamma-1)/gamma)))*g;


%% Initial values
m0 = 11.912;

x0 = 0;                              % Initial position [m]
z0 = 215.05;
V0_axial = 250.25;                        % Initial velocity along the axis [m/s]
V0_normal = 0;                       % Initial velocity along the normal to the axis [m/s]
theta0 = 50;                         % Initial angle of climb = angle of launch [deg]
theta0_rad = convang(theta0, 'deg', 'rad');
x_target=8000;      %Maximum intercept range [m]

x_target=8000;      % Maximum intercept range [m]
z_target=5000;      % Maximum intercept altitude [m]


% Propellant: HTPB
T0=3440;          % Chamber temperature [K] %Sutton
a = 4.655*(10^-5); % Propellant coefficient
n = 0.4;          % Pressure exponent           %Sutton
rho_prop = 1854.55;   % Propellant density [kg/m^3]
burn_rate = a*(P0^n);     % Burning rate [m/sec]


% Geometry constraints
de = 0.025;             % Exit diameter [m]
dtot=0.1105;            %Total diameter [m]
Ae = pi*(de/2)^2;       % Exit area [m^2]
S = ((dtot^2)/4)*pi;    % Section surface [m^2]


Cd = 0.285;


% Exit conditions calculations
M_exit = sqrt(((P0/(Pexit))^((gamma-1)/gamma)-1)/((gamma-1)/2));
A_throat = (Ae*M_exit)*((2/(gamma+1))*(1+((gamma-1)/2)*(M_exit^2)))^(-(gamma+1)/(2*(gamma-1)));
% A_throat = (Ae/M_exit)*((1+(gamma-1)/2)/(1+(gamma-1)*M_exit*M_exit/2))^(-(gamma+1)/(2*(gamma-1)))
d_throat = sqrt(4*A_throat/pi);

t_fin_sustain = (sqrt((x_target-x0)^2+(z_target-z0)^2))/V0_axial;
N_points = 100;
t_vec = linspace(0,t_fin_sustain,N_points);

mdot_profile = (0.5*rho*(V0_axial^2)*S*Cd+m0*g*sin(theta0_rad))./(c+t_vec.*g*sin(theta0_rad));
mdot_mean = sum(mdot_profile)/N_points       % mdot is taken as the mean of the previously computed vector

mdot_variable = @(t) interp1(t_vec,mdot_profile,t,"linear");

%% Test with integration of the equations of motion
% Constant m dot = mean
state0_sustain = [V0_axial, V0_normal, x0, z0, theta0_rad];
[vTime_m,mState_m] = ode45(@ThrustFun,[0 t_fin_sustain],state0_sustain);        % m stands for "(mdot) mean"

acc_axial_mdot_mean = gradient(mState_m(:,1), vTime_m);
F_axial_m = (m0-mdot_mean.*(vTime_m)).*acc_axial_mdot_mean;


% Variable m_dot
state0_sustain = [V0_axial, V0_normal, x0, z0, theta0_rad];
[vTime_v,mState_v] = ode45(@ThrustFun_variable_mdot,[0 t_fin_sustain],state0_sustain);

acc_axial_mdot_variable = gradient(mState_v(:,1), vTime_v);
F_axial_v = (m0-mdot_variable(vTime_v).*(vTime_v)).*acc_axial_mdot_variable;

%% Savings
Thrust = mdot_mean*c;

save ('engine_datas', 'Thrust', 't_fin_sustain')

%% Sizing
volume_rate = mdot_mean/rho_prop;
A_grain = volume_rate/burn_rate;
d_grain = 2*sqrt(A_grain/pi)
l_grain = burn_rate*t_fin_sustain

volume_grain = l_grain * A_grain;
m_prop = rho_prop * volume_grain

cf=Thrust/(P0*A_throat)
c_star=P0*A_throat/mdot_mean
%% Plots
figure(1)
plot(vTime_v,mState_v(:,1),'k',vTime_m,mState_m(:,1),'b');
ylabel("Axial Velocity"); xlabel("time");
legend('mdot_variable','mdot_mean')

figure(2)
plot(mState_v(:,3),mState_v(:,4),'k',mState_m(:,3),mState_m(:,4),'b')
ylabel("z"); xlabel("x");
legend('mdot_variable','mdot_mean')
axis equal

% figure(3)
% plot(vTime,convang(mState(:,5),'rad', 'deg'))
% ylabel("theta"); xlabel("time");
%


figure(4)
plot(vTime_v,F_axial_v,'k', vTime_m, F_axial_m, 'b');
ylabel("Axial total force"); xlabel("time");
legend('mdot_variable','mdot_mean')

figure(5)
plot(t_vec,mdot_profile,'k',t_vec, mdot_mean,'-ob');
ylabel("mdot(t)"); xlabel("time");
legend('mdot_variable','mdot_mean')
