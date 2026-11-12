function [d_state_dt] = ThrustFun_booster(t,state)

global g mdot_boost S_ref c m0 Cd

% Constants
mdot_boost = 1.57;
cf = 1.507;
c_star = 1532;
c = cf*c_star;
m0 = 16.695;    %From CAD
Cd = 0.37;

% Initial statements
V_axial= state(1);
V_normal = state(2);
x = state(3);
z = state(4);
theta = state(5);


% position or time functions
V = sqrt(V_axial^2 + V_normal^2);
[~,~,~,rho] = atmosisa(-z);          % gas thermodynamic state as a function of altitude

% derivatives
V_axial_dot = (mdot_boost*c)/(m0-mdot_boost*t) - 0.5*rho*S_ref*Cd*V_axial^2/(m0-mdot_boost*t) - g*sin(theta);
V_normal_dot = g*cos(theta);
x_dot = V_axial*cos(theta) + V_normal*sin(theta);
z_dot = V_axial*sin(theta) - V_normal*cos(theta);
theta_dot = 0;

d_state_dt = [V_axial_dot; V_normal_dot; x_dot; z_dot; theta_dot];
end
