close all; clear all; clc;

%% Initialization
g = 9.8;                              % Gravity acceleration [m/s^2]
R = 287;                              % Universal gas constant [J/(kg*K)]
gamma = 1.1;
Cp = 1005;                            % Specific heat at constant pressure
[~,~,P_ambient,rho] = atmosisa(0);           % External pressure and density [Pa], [kg/m3]

P0 = 7*10^5;                          % Chamber Pressure [Pa]
Pexit = P_ambient;                    % Exit Pressure [Pa]
Thrust = 75;                          % Thrust[N], from 3DoF
c = 1982.8;                           % From CEA [m/s]
t_fin_sustain=30;                     % Time[s] %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Propellant: Htpb/ap/al
a = 2.91*(10^-5); % Propellant coefficient
n = 0.4;          % Pressure exponent
rho_prop = 1854.55;   % Propellant density [kg/m^3]
burn_rate = a*(P0^n);  % Burning rate [m/sec]


% Geometry constraints
de = 0.015;             % Exit diameter [m] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ae = pi*(de/2)^2;       % Exit area [m^2]

expansion_ratio=1.9;              %Exit area/Critical area from CEA
A_throat=Ae/expansion_ratio;           %Critical Area [m^2]
d_throat = sqrt(4*A_throat/pi);  %Critical diameter [m]

%% mdot and Isp calculation
mdot = Thrust/c;
Isp=Thrust/(mdot*g) %Specific Impulse [sec]

%% Sizing
volume_rate = mdot/rho_prop;             %Grain volume variation  [m^3/sec]
A_grain = volume_rate/burn_rate;         %Grain section [m^2]
d_grain = 2*sqrt(A_grain/pi)   %Grain diameter [m]
l_grain = burn_rate*t_fin_sustain  %Grain length [m]

volume_grain = l_grain * A_grain;       %Grain volume [m^3]
m_prop = rho_prop * volume_grain                  %Propellant mass [kg]
save("propellant_mass","m_prop","mdot");

%% cf and cstar calculation
cf=Thrust/(P0*A_throat)
c_star=P0*A_throat/mdot
