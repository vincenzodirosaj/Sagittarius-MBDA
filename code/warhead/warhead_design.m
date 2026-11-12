clc;clear all;close all;
%% velocity calculation
c_m_ratio=0.5; %c/m ratio (explosive mass over fragment mass)
k_gurney=8800; %this is sqrt(2E) expressed in ft/s (the Composition B value was used)
v0_ft_s=k_gurney*sqrt(c_m_ratio/(1+0.5*c_m_ratio)); %maximum fragment velocity in ft/s after the initial acceleration (Gurney, solid cylinder)
v_frag_max=v0_ft_s/3.281; %v0 in m/s
v_missile=250; %missile velocity in m/s
v_initial=sqrt(v_missile^2+v_frag_max^2); %initial fragment velocity in m/s
cd_frag=0.456; %fragment drag coefficient
rho_air=1; %air density in kg/m^3
R_initial=1; %initial radial distance between the missile and the target, in metres
theta_angle=atan(v_missile/v_frag_max);
alpha_frag=1-theta_angle; %angle between the fragment velocity and the longitudinal axis
r_fragment=0.005; %radius of the spherical fragment in m
A_fragment=pi*r_fragment^2; %fragment area in contact with the air
rho_fragment=7800; %fragment density in kg/m^3
m_fragment=4/3*pi*r_fragment^3*rho_fragment; %single fragment mass in kg
dist=R_initial/sin(alpha_frag);
dist=sqrt(5);
v_impact=v_initial*exp(-cd_frag*rho_air*dist*A_fragment/m_fragment);
deceleration_pct=100-v_impact/v_initial*100; %percentage deceleration caused by aerodynamics
t_flight=flight_time(v_initial,cd_frag,rho_air,A_fragment,m_fragment,alpha_frag,R_initial); %minimum impact velocity computed conservatively, in m/s

%% THOR formula
c11=7.074;
c12=1.029;
c13=-1.072;
c14=1.251;
c15=-0.139;
c31=-6.663;
c32=0.227;
c33=0.694;
c34=-0.316;
c35=1.901;
t_target=0.01; %target thickness in mm
V_residual=v_initial-0.3048*10^c11*(61023.75*t_target*A_fragment)^c12*(15432.1*m_fragment)^c13*(1/cos(alpha_frag))^c14*(3.28084*v_initial)^c15;
M_residual=m_fragment-6.48*10^(c31-5)*(61023.75*t_target*A_fragment)^c32*(15432.1*m_fragment)^(c33)*(1/cos(alpha_frag))^c34*(3.28084*v_initial)^c35;
%now the residual kinetic energy needed to also penetrate the other side and exit is found
V_residual_2=-1;
delta_v=900;
while V_residual_2<0
V_residual_2=(V_residual+delta_v)-0.3048*10^c11*(61023.75*t_target*A_fragment)^c12*(15432.1*M_residual)^c13*(1/cos(alpha_frag))^c14*(3.28084*(V_residual+delta_v))^c15;
M_residual_2=M_residual-6.48*10^(c31-5)*(61023.75*t_target*A_fragment)^c32*(15432.1*M_residual)^(c33)*(1/cos(alpha_frag))^c34*(3.28084*(V_residual+delta_v))^c35;
delta_v=delta_v+1;
end
E_kin_residual=1/2*M_residual*V_residual^2;
E_kin_required=1/2*M_residual*(V_residual+delta_v)^2; %residual kinetic energy required to exit from the other side
%% dimension calculation
d_warhead=0.077; %warhead diameter in m
L_warhead=0.15; %warhead length in m (the v0 formula is more accurate when L/D approaches 2.5)


%v0 is thought to be between 6000 ft/s and 8000 ft/s
%the single fragment mass is thought to be chosen between 1.5 and 3 ounces
%% mass calculation
n_per_circumference=floor((2*pi*d_warhead/2)/(pi*r_fragment)); %number of spherical fragments per circumference
n_rings=floor(L_warhead/(2*r_fragment));
n_fragments_total=n_per_circumference*n_rings; %total number of fragments
m_fragments=n_fragments_total*m_fragment; %fragment mass
m_explosive=c_m_ratio*m_fragments; %explosive mass
m_warhead=(m_explosive+m_fragments)/0.70; %consequence of the fact that the useful mass (fragments+explosive) is about 70 % of the warhead mass
m_dead=0.30*m_warhead; %dead mass of the warhead in kg

%% diameter calculation
r_explosive_max=d_warhead/2-2*r_fragment; %limit that the explosive radius must respect, in metres
rho_explosive=1650; %explosive density in kg/m^3
r_explosive=sqrt(m_explosive/(pi*rho_explosive*L_warhead)); %explosive radius in metres
%% SAVE DATA
save('warhead.mat',"L_warhead","d_warhead","alpha_frag","R_initial","r_fragment","n_rings","v_frag_max","v_missile")
