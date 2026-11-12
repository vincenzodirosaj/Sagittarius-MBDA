close all; clear; clc;

%% Materials

rho_graphite=1150; %Graphite density [kg/m^3]
rho_copper=8900; %Copper density [kg/m^3]

k_graphite=1;      %Graphite thermal conductivity [W/m*K]
k_copper=360;    %Copper thermal conductivity [W/m*K]

c_graphite=710;    %Graphite specific heat [J/kg*K]
c_copper=430;    %Copper specific heat [J/kg*K]

h_conv=50000;  %Boundary-layer convective heat transfer coefficient [W/K*m^2]

L=0.004;   %Layer length [m]
d_cr=0.0109; %Throat section diameter [m]
%% Temperatures

T_aw=3440; %Adiabatic wall temperature [K]
T0=300; %Sink temperature at the initial instant [K]
T_melt_copper=1360; %Copper melting temperature [K]


%% First layer: porous graphite (insulating layer)

delta1=0.004;  %Layer thickness [m]

h_eff_1=k_graphite/delta1; %Convective heat transfer coefficient, 1st layer [W/K*m^2]

if h_eff_1/h_conv>150
    disp ('error')
end

alpha=k_graphite/(rho_graphite*c_graphite); %Layer thermal diffusivity [m^2/sec]

t_adapt=(delta1^2)/(4*alpha); %Layer adaptation time [sec]

%% Second layer: copper (heat sink)

delta2=0.01; %Layer thickness [m]

h_eff_2=k_copper/delta2; %Convective heat transfer coefficient, 2nd layer [W/K*m^2]

if h_eff_2/h_eff_1<100
    disp ('error')
end

tau=(rho_copper*c_copper*delta2*delta1)/k_graphite; %Characteristic time [sec]

t_fin= 30; %Firing time [sec]

T2=T_aw-(T_aw-T0)*exp(-t_fin/tau); %Sink temperature at the final instant [K]

if T2>T_melt_copper
    disp ('error')
end

disp (T2);
disp (delta1);
disp (delta2);

V_graphite=pi*L*((((d_cr/2+(delta1/2))^2)-(d_cr/2)^2));
V_copper=pi*L*((((d_cr/2+(delta1/2))^2+(delta2/2)^2))-((d_cr/2)^2+(delta1/2)^2));

m_graphite=V_graphite*rho_graphite;
m_copper=V_copper*rho_copper;
