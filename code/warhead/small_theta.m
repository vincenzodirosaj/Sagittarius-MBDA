clc;clear all;close all;
%% DATA
load("warhead.mat")
d_missile=0.12; %missile's diameter [m]
d_cg_warhead=0.06875; %distance between the missile's center of gravity and the start of the warhead[m]
L_target=1;%target's length [m]
h_target=0.3; %target's height in [m]
w_target=1; %target's width [m]
v_target_max=60; %maximum target velocity [m/s]
v_target_min=0; %minimum target velocity [m/s]
l_nose=0.2; %nose length [m]
N_points=25;
theta_max=pi/4;
theta_vec_small=linspace(0,theta_max,N_points);
X_vec=linspace(-2,2,N_points);%these already refer to the centers of gravity
Y_vec=linspace(0.5,1,N_points);%these already refer to the centers of gravity
X_cg_fixed_small=X_vec;
Y_cg_fixed_small=Y_vec;
result_matrix = zeros(N_points^3, 5);
counter=1;
p_kill=0.07;
jj=0;
for i1=1:N_points
    theta=theta_vec_small(i1);
    for i2=1:N_points
    X=X_vec(i2);
        for i3=1:N_points
        jj=jj+1;
        Y=Y_vec(i3);
        v_y_fragment=v_frag_max*cos(theta)+v_missile*sin(theta);
        v_x_fragment=v_missile*cos(theta)-v_frag_max*sin(theta);
        n_hits_total=0;
              for j=1:n_rings
                  if j==1
                  y_front_init(j)=d_cg_warhead*sin(theta);
                  else
                   y_front_init(j)=d_cg_warhead*sin(theta)+y_front_final(j-1)-2*r_fragment*cos(theta);
                   end
              y_front_final(j)=y_front_init(j)+2*r_fragment;
                  if j==1
                  x_front_init(j)=d_cg_warhead*cos(theta);
                  else
                  x_front_init(j)=d_cg_warhead*cos(theta)+2*r_fragment*(j-1)-2*r_fragment*(j-1)*sin(theta);
                  end
              x_front_final(j)=x_front_init(j)+2*r_fragment;
              x_frag_center(j)=x_front_init(j)+r_fragment;
              y_frag_center(j)=y_front_init(j)+r_fragment;
              t=0;
                 while true
                 t=t+0.0000001;
                 x_frag_current=x_front_final(j)+v_x_fragment*t;
                 y_frag_current=y_frag_center(j)+v_y_fragment*t;
                 x_target_initial=X-L_target/2+t*v_target_max;
                 x_target_final=X+L_target/2+t*v_target_min;
                 y_target_initial=Y-h_target/2;
                 y_target_final=y_target_initial+h_target;
                   if x_frag_current >= x_target_initial && x_frag_current <= x_target_final && y_frag_current >= y_target_initial && y_frag_current <=y_target_final
                   hit_flag=1;
                   break;
                   end
                 distance=sqrt(x_frag_current^2+y_frag_current^2);
                   if distance >5
                   hit_flag=0;
                   break;
                   end
                 end
                 if hit_flag == 1
                 R_miss=-sin(theta)*(x_frag_current-x_frag_center(j))+cos(theta)*(y_frag_current-y_frag_center(j));
                 beta_max=atan(w_target/(R_miss+d_missile/2));
                 L_c=beta_max*d_warhead;
                 k_frag=floor((L_c-r_fragment*pi)/(2*r_fragment*pi));
                 n_frags=2*k_frag+1;
                 n_hits_total=n_hits_total+n_frags;
                 else
                 n_hits_total=n_hits_total+0;
                 end
            end
        P_k=1-(1-p_kill)^n_hits_total;
        result_matrix_small(counter, :)=[rad2deg(theta), X, Y, n_hits_total, P_k];
%         result_matrix(counter, :) = [rad2deg(theta), X, Y, n_hits_total, P_k];
%         X_cg(i2)=X+L_target/2+L_warhead*cos(theta)+d_cg_warhead*cos(theta);
%         Y_cg(i3)=Y+d_cg_warhead*sin(theta)+h_target/2;
%         result_matrix_guidance(counter, :) = [rad2deg(theta), X_cg(i2), Y_cg(i3), n_hits_total, P_k];
          Pk_matrix_small(i1,i2,i3) = P_k;
          counter=counter+1;
%         Pk_y_vec(i3) = P_k;
%         Y_value(i1,i3) = Y_cg(i3);
        end
%         X_value(i1,i2) = X_cg(i2);
%         Pk_x_mat(i2,:) =  interp1(Y_cg, Pk_y_vec, Y_cg_fixed);
    end
%     [X_cg_grid, Y_cg_fixed_grid] = meshgrid(X_cg, Y_cg_fixed); % Definition of the new vectors for the interpolation
%     x_new = linspace(-1.25, -0.25, N_points); y_new = linspace(0.6, 1.5, N_points);
%     % Creation of the grid of the new points
%     [X_cg_fixed_grid2, Y_cg_fixed_grid2] = meshgrid(X_cg_fixed, Y_cg_fixed);
%     % Interpolation of the values
%     Pk_final(i1,:,:) = interp2(X_cg_grid, Y_cg_fixed_grid, Pk_x_mat, X_cg_fixed_grid2, Y_cg_fixed_grid2, 'linear');
end
%%
%  Pk_final =Pk_matrix
 Pk_matrix_small = padarray(Pk_matrix_small, [1,1,1], 0);
% Creation of the vector with the column names
column_names = ["theta", "X", "Y", "n", "Pk"];
% Addition of the header row
result_matrix_with_headers = [column_names; result_matrix_small];
% Printing of the matrix with formatting
disp('==========================================================');
disp(result_matrix_with_headers);
disp('==========================================================');
%% PLOT OF THE RAMP FUNCTION LINKING THE RESIDUAL KINETIC ENERGY AND p
x_0=[-7000,0];
y_0=[0,0];
x_1=[0,763.965];
y_1=[0,0.07];
x_2=[8500,15500];
y_2=[1,1];
X=[x_0,x_1,x_2];
Y=[y_0,y_1,y_2];
figure
plot(X,Y)
hold on
plot(763.965, 0.07, 'ro', 'MarkerSize', 2);
title('p as a function of residual kinetic energy of penetration')
plot([763.965, 763.965], [-1, 0.07], '--k'); % Vertical dashed segment
plot([-8000, 763.965], [0.07, 0.07], '--k'); % Horizontal dashed segment
xlabel('Ekr')
ylabel('p')
xlim([-8000, 16500]);
ylim([-1, 2]);
legend('p(Ekr)','(763.965 ;  0.07)');
 %% Saving
% % Overwrite X_cg to make the notation consistent with Simulink
theta_vec_small = [theta_vec_small(1)-0.0001,theta_vec_small,theta_vec_small(end)+0.0001];
X_cg_fixed_small = [X_cg_fixed_small(1)-0.01,X_cg_fixed_small,X_cg_fixed_small(end)+ 0.01];
Y_cg_fixed_small = [Y_cg_fixed_small(1)-0.01,Y_cg_fixed_small,Y_cg_fixed_small(end)+ 0.01];
save("results_lethality_tests_small", "theta_vec_small", "X_cg_fixed_small", "Y_cg_fixed_small","Pk_matrix_small");
