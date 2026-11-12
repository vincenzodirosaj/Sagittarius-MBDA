function F = AimingFun(x)

global v_aim x_ini_tgt h_ini_tgt v_tgt theta_tgt g

% along the y axis
F(1) = v_tgt*sin(theta_tgt)*x(2) + (h_ini_tgt) - v_aim*sin(x(1))*x(2) + 0; % +0.5*g*x(2)^2;
F(2) = v_tgt*cos(theta_tgt)*x(2) + (x_ini_tgt) - v_aim*cos(x(1))*x(2) + 0;

end