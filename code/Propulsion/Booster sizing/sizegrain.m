function F=sizegrain(x)

%Empirical Equations to find the Diameter and the Length for a Star Grain

global r_burn rho_prop A_port mdot m_prop

F1 = (pi/4)*((x(1))^2)*x(2) - A_port*x(2) - (m_prop/rho_prop);

F2 = 0.9*x(1)*x(2)*pi - ((mdot)/(rho_prop*r_burn));


end
