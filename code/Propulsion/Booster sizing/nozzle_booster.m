clc; clear; close all;

%% Booster nozzle data

d_inlet=0.0742;       %Inlet diameter [m]
d_throat=0.032;            %Throat diameter [m]
d_exit=0.07;             %Exit diameter [m]

A_throat=pi*((d_throat^2)/4);             %Throat area   [m^2]
A_exit=pi*((d_exit^2)/4);          %Exit area [m^2]

theta_conv=pi/4;        %Convergent half-angle [rad]
theta_div=pi/18;        %Divergent half-angle [rad]

L_throat=0.004;         %Throat length [m]

%% Length calculations

L_conv=((d_inlet/2)-(d_throat/2))*tan(pi/2-theta_conv);  %Convergent length [m]
L_div=d_throat*(sqrt(A_exit/A_throat)-1)/(2*tan(theta_div));   %Divergent length [m]

L_nozzle=L_div+L_conv+L_throat  %Total length [m]

%% Axial thrust loss calculation

lambda=0.5*(1+cos(theta_div));  %Percentage of axial thrust
thrust_loss_percentage=1-lambda  %Thrust loss percentage
