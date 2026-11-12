function [t] = flight_time(v_initial,cd,rho,A,m_fragment,alpha_frag,y_distance)
step=0.01; %every how many metres the velocity is recomputed
dl=step*sin(alpha_frag); %lateral distance travelled
v_impact=v_initial*exp(-cd*rho*step*A/m_fragment);
t=step/v_impact;
while dl<y_distance
    v_impact=v_impact*exp(-cd*rho*step*A/m_fragment);
    t=t+step/v_impact;
    dl=dl+step*sin(alpha_frag);
end
end
%at the end we obtain the total time the fragment takes to reach
%y=y_distance, where the target is
