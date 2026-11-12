close all; clear all; clc;

global g mdot S c m0 r_burn A_port rho_prop m_prop Cd

%% Initialization
g = 9.8;                              % Gravity acceleration [m/s^2]
R = 287;                              % Universal gas constant [J/(kg*K)]
gamma = 1.2;
Cp = 1005;                            % Specific heat at constant pressure
[~,~,p,~] = atmosisa(0);
P_ambient = p;            % External pressure [Pa]

P0 = 30*10^5;                         % [pa]
c = 2000;                             % To be derived with CEA next Friday
Pexit = P_ambient;


% Initial values
x0 = 0;                              % Initial position [m]
z0 = 0;
V0_axial = 0;                        % Initial velocity along the axis [m/s]
V0_normal = 0;                       % Initial velocity along the normal to the axis [m/s]
theta0 = 50;                         % Initial angle of climb = angle of launch [deg]
% 90 degrees, most critical condition
theta0_rad = convang(theta0, 'deg', 'rad');

% Propellant: Htpb/ap/al
T0=3440;          % Chamber temperature [K]
a = 2.1*(10^-5); % Propellant coefficient
n = 0.4;          % Pressure exponent
rho_prop = 1854.55;   % Propellant density [kg/m^3]
r_burn = a*(P0^n);     % Burning rate [m/sec]


% Geometry constraints
de = 0.07;          % Exit diameter [m]
Ae = pi*(de/2)^2;  % Exit area [m^2]
S = Ae;                   % Total surface [m^2]
Cd = 0.585;

% Physics parameters and functions
M_exit = sqrt(((P0/(Pexit))^((gamma-1)/gamma)-1)/((gamma-1)/2));                             % Nozzle assumption Pe = 0.3 Pa

A_throat = (Ae*M_exit)*((2/(gamma+1))*(1+((gamma-1)/2)*(M_exit^2)))^(-(gamma+1)/(2*(gamma-1)));
A_port = 3.72*A_throat;    % Grain section [m^2], this specific value is chosen to avoid erosive burning

d_throat = sqrt(4*A_throat/pi);

Gamma_fn = sqrt(gamma)*sqrt(1+(gamma-1)/2)*(1+(gamma-1)/2)^(gamma/(1-gamma));
mdot = (Gamma_fn*P0*A_throat)/(sqrt(R*T0));

% Pexit   = P0*(1+((gamma-1)/2)*(M_exit^2))^(-gamma/(gamma-1));
% Texit   = T0/(1+((gamma-1)/2)*(M_exit^2));
% Vexit   = sqrt(2*Cp*(T0-Texit));

%% Searching mdot by dynamic equations integration

% iteration parameters
m0 = 12.5;                             % Total mass of the rocket at instant zero [kg]
for m_prop = 0.1:0.001:10                 % Propellant of the booster [kg]

    % Propellant mass [kg]
    t_fin = m_prop/mdot;                      % time of booster separation

    state0 = [V0_axial, V0_normal, x0, z0, theta0_rad];

    [vTime,mState] = ode45(@ThrustFun,[0 t_fin],state0);
    if mState(end,1)>=200
        mState(end,1)
        m_prop
        break
    end
end

acc_axial = gradient(mState(:,1), vTime);

Thrust = mdot*c;
c_star = P0*A_throat/mdot;
cf = Thrust/(P0*A_throat);

%% Booster sizing
v0_guess=[0.00001,0.00001];
sizes=fsolve(@sizegrain,v0_guess);

d_case=sizes(1)   % case diameter [m]
l_case=sizes(2)   % case length [m]

%% Plots
figure(1)
plot(vTime,mState(:,1));
ylabel("Axial Velocity"); xlabel("time");

figure(2)
plot(mState(:,3),mState(:,4))
ylabel("z"); xlabel("x");
axis equal

% figure(3)
% plot(vTime,convang(mState(:,5),'rad', 'deg'))
% ylabel("theta"); xlabel("time");
%
figure(4)
plot(vTime,(m0-mdot.*(vTime)).*acc_axial);
ylabel("Axial total force"); xlabel("time");
