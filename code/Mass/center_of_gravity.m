clearvars; close all; clc;
%% Material properties

Density.steel=7850;                 % Steel
Density.propellant=1854.55;         % Propellant

%% FIRST PIECE: Nose

nose.length = 0.4;                       % Nose length
nose.diameter = 0.1056;                       % Nose diameter
nose.thickness = 1.4e-3;             % Nose section thickness

% Volume estimation
nose.external_volume = pi*nose.diameter^2*nose.length/12; % Outer nose volume (cone shaped)
nose.internal_volume =pi*(nose.diameter-2*nose.thickness)^2*(nose.length-nose.thickness)/12 ; % Hollow section volume
nose.volume=nose.external_volume-nose.internal_volume;   % Effective nose volume

mass_nose = nose.volume * Density.steel;
% Nose center of gravity
x_cg_nose = ((nose.external_volume * Density.steel*nose.length*3/4)-(nose.internal_volume * Density.steel*(nose.length-2*nose.thickness)*3/4))/(nose.volume * Density.steel); % x coordinate measured from the cone tip
y_cg_nose= 0;
z_cg_nose= 0;


%% SECOND PIECE: the piece containing the Warhead

warhead.length = 0.125;           % Warhead length
warhead.diameter = 0.08;            % Warhead diameter

%warhead.volume= (pi*(warhead.diameter/2)^2)*warhead.length;    % Warhead volume

warhead.mass=1.9388;
thickness_data = open("thicknesses.mat");
thickness = thickness_data.thickness;
warhead.thickness=thickness;  % Thickness of the cylinder walls that contain the warhead

warhead_case.diameter=nose.diameter; % outer diameter of the cylinder containing the warhead
warhead_case.length=warhead.length+2*warhead.thickness;


warhead_case.thickness=warhead.thickness;

% Warhead Case Volume
warhead_case.external_volume=pi*((warhead_case.diameter/2)^2)*warhead_case.length;
warhead_case.internal_volume=pi*(((warhead_case.diameter-2*warhead_case.thickness)/2)^2)*(warhead_case.length-2*warhead_case.thickness);
warhead_case.volume=warhead_case.external_volume-warhead_case.internal_volume;

warhead_case.mass=warhead_case.volume*Density.steel;

% Warhead & Case center of gravity
mass_warhead_case = warhead_case.mass+warhead.mass;      % Warhead case mass
x_cg_warhead_case = nose.length+warhead_case.length/2;
y_cg_warhead_case = 0;
z_cg_warhead_case = 0;     % Warhead case barycenter position


%% THIRD PIECE: contains the battery
battery_case.length=0.1025; %10 percent of the total length
%Mass reported below
x_cg_battery_case=nose.length+warhead_case.length+battery_case.length/2;
%% FOURTH PIECE: Sustain Case + grain + nozzle
%this third piece will have two centers of gravity: the center of gravity of
%the sustain structure (which is fixed) and the one of the grain, which
%instead moves

%Sustain grain

sustain_case.length= 0.3974;
sustain_case.diameter=0.1056;
sustain_case.thickness=thickness_data.t_case;

sustain_case.external_volume=(pi*((sustain_case.diameter/2)^2)*sustain_case.length);
sustain_case.internal_volume=(pi*(((sustain_case.diameter-2*sustain_case.thickness)/2)^2)*(sustain_case.length-sustain_case.thickness));
sustain_case.volume=sustain_case.external_volume-sustain_case.internal_volume;

sustain_case.mass=sustain_case.volume*Density.steel;

%Center of gravity calculation parameters
x_cg_wall_vertical=sustain_case.thickness/2;                                       % Center of gravity, vertical wall
x_cg_wall_top=((sustain_case.length-sustain_case.thickness)/2)+sustain_case.thickness;% Center of gravity, upper horizontal wall
x_cg_wall_bottom=x_cg_wall_top;                                                           % Center of gravity, lower horizontal wall

volume_wall_vertical=(pi*(sustain_case.diameter/2)^2)*sustain_case.thickness; % Vertical wall volume
volume_wall_top=(sustain_case.volume-volume_wall_vertical)/2;                          % Upper horizontal wall volume
volume_wall_bottom=volume_wall_top;                                            % Lower horizontal wall volume

mass_sustain_case = sustain_case.mass;                 % Sustain case mass
x_cg_sustain_case = nose.length+warhead_case.length+battery_case.length+((x_cg_wall_vertical*volume_wall_vertical+x_cg_wall_top*volume_wall_top+x_cg_wall_bottom*volume_wall_bottom)/sustain_case.volume);
y_cg_sustain_case = 0;
z_cg_sustain_case = 0;           % Sustain case barycenter

% the commented block below was another way to compute the center of gravity
% of the sustain case
%x_check=(sustain_case.external_volume*Density.steel*sustain_case.length/2-sustain_case.internal_volume*Density.steel*(sustain_case.thickness+(sustain_case.length-sustain_case.thickness)/2))/mass_sustain_case;
%x_check=x_check+nose.length+warhead_case.length;


%Nozzle

nozzle.conv_length=0.0333;
nozzle.div_length=0.1288;

nozzle.inlet_diameter=0.0976;
nozzle.throat_diameter=0.031;
nozzle.exit_diameter=0.1;

nozzle.thickness=thickness_data.t_nozzle;

nozzle.conv_half_angle=pi/4;   %45 deg
nozzle.div_half_angle=pi/12;  %15 deg

nozzle.ext_conv_volume=(1/3)*pi*nozzle.conv_length*(((nozzle.inlet_diameter+2*nozzle.thickness)/2)^2+((nozzle.throat_diameter+2*nozzle.thickness)/2)^2+...
    ((nozzle.inlet_diameter+2*nozzle.thickness)/2)*((nozzle.throat_diameter+2*nozzle.thickness)/2));
nozzle.ext_div_volume=(1/3)*pi*nozzle.div_length*(((nozzle.throat_diameter+2*nozzle.thickness)/2)^2+((nozzle.exit_diameter+2*nozzle.thickness)/2)^2+...
    ((nozzle.throat_diameter+2*nozzle.thickness)/2)*((nozzle.exit_diameter+2*nozzle.thickness)/2));

nozzle.int_conv_volume=(1/3)*pi*nozzle.conv_length*((nozzle.inlet_diameter/2)^2+(nozzle.throat_diameter/2)^2+(nozzle.inlet_diameter/2)*(nozzle.throat_diameter/2));
nozzle.int_div_volume=(1/3)*pi*nozzle.div_length*((nozzle.throat_diameter/2)^2+(nozzle.exit_diameter/2)^2+(nozzle.throat_diameter/2)*(nozzle.exit_diameter/2));

nozzle.volume=nozzle.ext_conv_volume+nozzle.ext_div_volume-(nozzle.int_conv_volume+nozzle.int_div_volume);

nozzle.mass=nozzle.volume*Density.steel;

nozzle.conv_slant_length=nozzle.conv_length/cos(nozzle.conv_half_angle);
nozzle.x_cg_conv=nozzle.conv_length-(nozzle.conv_slant_length/2)*cos(nozzle.conv_half_angle);

nozzle.div_slant_length=nozzle.div_length/cos(nozzle.div_half_angle);
nozzle.x_cg_div=nozzle.conv_length+(nozzle.div_slant_length/2)*cos(nozzle.div_half_angle);


mass_nozzle_shell=nozzle.mass;
% x_cg_nozzle = nose.length+warhead_case.length+sustain_case.length+((nozzle.x_cg_conv*(nozzle.ext_conv_volume-nozzle.int_conv_volume)+...
%          (nozzle.x_cg_div*(nozzle.ext_div_volume-nozzle.int_div_volume)))/nozzle.volume);
y_cg_nozzle = 0;
z_cg_nozzle= 0;           % Nozzle barycenter


%data required for the convergent section study
conv_length=nozzle.conv_length;
L_conv=(nozzle.inlet_diameter+2*nozzle.thickness)/(2*tan(nozzle.conv_half_angle));
L_conv_star=nozzle.inlet_diameter/(2*tan(nozzle.conv_half_angle));
mass_conv_outer=pi/3*((nozzle.inlet_diameter+2*nozzle.thickness)/2)^2*L_conv*Density.steel;  % mass of the fuller outer cone (convergent section)
mass_conv_outer_missing=pi/3*((nozzle.throat_diameter+2*nozzle.thickness)/2)^2*(L_conv-conv_length)*Density.steel;  % mass of the missing tip of the outer cone (since the convergent section is a truncated cone)
%now the barycenter of the solid outer truncated cone (in the convergent section) is found
A1_cg_outer=nose.length+warhead_case.length+battery_case.length+sustain_case.length-(nozzle.conv_length+nozzle.div_length)+(L_conv/4*mass_conv_outer-((L_conv-conv_length)/4+conv_length)*mass_conv_outer_missing)/(mass_conv_outer-mass_conv_outer_missing);
%A1_cg_outer=nose.length+warhead_case.length+sustain_case.length+(nozzle.conv_length+nozzle.div_length)+((nozzle.inlet_diameter+2*nozzle.thickness)/(4* (2*tan(nozzle.conv_half_angle))*mass_conv_outer)-(((nozzle.inlet_diameter+2*nozzle.thickness)/ (2*tan(nozzle.conv_half_angle))-nozzle.conv_length)/4+ nozzle.conv_length)*mass_conv_outer_missing)/(mass_conv_outer-mass_conv_outer_missing);


mass_conv_inner=pi/3*(nozzle.inlet_diameter/2)^2*L_conv_star*Density.steel; % mass of the fuller inner cone (convergent section)
mass_conv_inner_missing=pi/3*((nozzle.throat_diameter)/2)^2*(L_conv_star-conv_length)*Density.steel;  % mass of the missing tip of the outer cone (since the convergent section is a truncated cone)
%now the barycenter of the hollow inner truncated cone (in the convergent section) is found
A2_cg_inner=nose.length+warhead_case.length+sustain_case.length+battery_case.length-(nozzle.conv_length+nozzle.div_length)+(L_conv_star/4*mass_conv_inner-((L_conv_star-conv_length)/4+conv_length)*mass_conv_inner_missing)/(mass_conv_inner-mass_conv_inner_missing);

%barycenter of the convergent section
x_cg_convergent=(A1_cg_outer*(mass_conv_outer-mass_conv_outer_missing)-A2_cg_inner*(mass_conv_inner-mass_conv_inner_missing))/((mass_conv_outer-mass_conv_outer_missing)-(mass_conv_inner-mass_conv_inner_missing));
mass_convergent=(mass_conv_outer-mass_conv_outer_missing)-(mass_conv_inner-mass_conv_inner_missing);   % mass of the convergent section


%data required for the divergent section study
div_length=nozzle.div_length;
L_div=(nozzle.exit_diameter+2*nozzle.thickness)/(2*tan(nozzle.div_half_angle));
L_div_star=nozzle.exit_diameter/(2*tan(nozzle.div_half_angle));
mass_div_outer=pi/3*((nozzle.exit_diameter+2*nozzle.thickness)/2)^2*L_div*Density.steel; % mass of the fuller inner cone (divergent section)
mass_div_outer_missing=pi/3*((nozzle.throat_diameter+2*nozzle.thickness)/2)^2*(L_div-div_length)*Density.steel;  % mass of the missing tip of the outer cone (since the divergent section is a truncated cone)
%now the barycenter of the solid outer truncated cone (in the divergent section) is found
B1=(L_div/4*mass_div_outer-((L_div-div_length)/4+div_length)*mass_div_outer_missing)/(mass_div_outer-mass_div_outer_missing);


mass_div_inner=pi/3*(nozzle.exit_diameter/2)^2*L_div_star*Density.steel;% mass of the fuller inner cone (divergent section)
mass_div_inner_missing=pi/3*((nozzle.throat_diameter)/2)^2*(L_div_star-div_length)*Density.steel;  % mass of the missing tip of the inner cone (since the divergent section is a truncated cone)
%now the barycenter of the hollow inner truncated cone (in the divergent section) is found
B2=(L_div_star/4*mass_div_inner-((L_div_star-div_length)/4+div_length)*mass_div_inner_missing)/(mass_div_inner-mass_div_inner_missing);

%barycenter of the convergent section
x_cg_divergent=(B1*(mass_div_outer-mass_div_outer_missing)-B2*(mass_div_inner-mass_div_inner_missing))/((mass_div_outer-mass_div_outer_missing)-(mass_div_inner-mass_div_inner_missing));
x_cg_divergent=nose.length+warhead_case.length+battery_case.length+sustain_case.length-x_cg_divergent;
mass_divergent=(mass_div_outer-mass_div_outer_missing)-(mass_div_inner-mass_div_inner_missing);% mass of the divergent section





x_cg_nozzle=(x_cg_convergent*mass_convergent+x_cg_divergent*mass_divergent)/(mass_convergent+mass_divergent);
mass_nozzle_total=(mass_convergent+mass_divergent);

%Grain

grain.diameter=0.0976;
grain.initial_length=0.2361;
grain.initial_mass=3.2765;

grain.burn_rate=0.0076;
t_burn_end=grain.initial_length/grain.burn_rate;
%t_burn_end=31.066-3.5;
N_points=100;
time_vec=linspace(0,t_burn_end,N_points);

%% Battery mass
battery_case.mass=15*(mass_nose + mass_warhead_case + mass_sustain_case + mass_nozzle_total + grain.initial_mass)/(100*0.85); %15 percent of the total mass
mass_battery_case=battery_case.mass;
%% for loop
mass_full = 14.2431; % mass_full
mass_input = mass_full; mass_current = mass_full; grain_consumed = 0;
mass_over_time = zeros(N_points, 1);  %initialize the matrix in which the mass as a function of time is stored
for i=1:N_points
    time_vec(i)=t_burn_end*i/N_points;

    grain.length(i)=grain.initial_length-time_vec(i)*grain.burn_rate;
    mass_over_time(i,1) = mass_input - grain_consumed;

    grain.volume(i)=grain.length(i)*(pi*(grain.diameter/2)^2);
    grain_consumed = ((grain.initial_mass/Density.propellant-grain.volume(i))*Density.propellant);
    grain.mass(i)=grain.initial_mass-grain_consumed;

mass_grain(i) = grain.mass(i);                 % Grain mass
x_cg_grain(i) = nose.length+warhead_case.length+battery_case.length+sustain_case.thickness+grain.length(i)/2;
y_cg_grain(i) = 0;
z_cg_grain(i) = 0;

                              % Grain barycenter

%% Barycenter Calculation

x_cg_missile(i) = (x_cg_nose*mass_nose + x_cg_warhead_case*mass_warhead_case+x_cg_battery_case*battery_case.mass +...
             x_cg_sustain_case*mass_sustain_case + x_cg_nozzle*mass_nozzle_total + x_cg_grain(i)*mass_grain(i))/...
             (mass_nose + mass_warhead_case + mass_sustain_case + mass_nozzle_total +battery_case.mass+ mass_grain(i));
mass_current = (mass_nose + mass_warhead_case + mass_sustain_case + mass_nozzle_total +battery_case.mass+ mass_grain(i));
y_cg_missile(i) = (y_cg_nose*mass_nose +y_cg_warhead_case*mass_warhead_case +...
             y_cg_sustain_case*mass_sustain_case + y_cg_nozzle*mass_nozzle_total + y_cg_grain(i)*mass_grain(i))/...
             (mass_nose + mass_warhead_case +battery_case.mass+ mass_sustain_case + mass_nozzle_total + mass_grain(i));

z_cg_missile(i) = (z_cg_nose*mass_nose + z_cg_warhead_case*mass_warhead_case +...
             z_cg_sustain_case*mass_sustain_case + z_cg_nozzle*mass_nozzle_total + z_cg_grain(i)*mass_grain(i))/...
             (mass_nose + mass_warhead_case + battery_case.mass+mass_sustain_case + mass_nozzle_total + mass_grain(i));

CG_with_time(1,i) = time_vec(i);
CG_with_time(2,i) = x_cg_missile(i);
end
mass_current = (mass_nose + mass_warhead_case + mass_sustain_case + mass_nozzle_total +battery_case.mass+ grain.initial_mass);

total_length = nose.length + warhead.length + battery_case.length + sustain_case.length

% figure (1)
% plot (time_vec,x_cg_missile,'.-');
% xlabel("time (s)");
% ylabel("Missile Barycenter X (m)");
% axis ([0 32 0.5 0.6]);
% figure (2)
% plot (time_vec,y_cg_missile,'.-');
% xlabel("time (s)");
% ylabel("Missile Barycenter Y (m)");
% axis ([0 32 -0.5 0.5]);
% figure (3)
% plot (time_vec,z_cg_missile,'.-');
% xlabel("time (s)");
% ylabel("Missile Barycenter Z (m) ");
% axis ([0 32 -0.5 0.5]);

%% SAVE DATA
save('center_of_gravity.mat',"x_cg_nose","mass_nose","x_cg_warhead_case","mass_warhead_case","x_cg_battery_case","mass_battery_case",...
              "x_cg_sustain_case","mass_sustain_case","x_cg_nozzle","mass_nozzle_total","x_cg_grain","mass_grain","N_points","x_cg_missile")

save("mass_with_time.mat","mass_over_time","CG_with_time");
