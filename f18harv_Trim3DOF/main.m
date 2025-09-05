close all; clc; clear

%% A/C DATA
filename = "F18HARV.mat";
Aircraft = load(filename);

m = Aircraft.Mass; % A/C mass (kg)
W = Aircraft.Weight; % A/C weight (N)
T_max = Aircraft.Thrust_MAX; % available max thrust (N)
S = Aircraft.RefSurface; % reference surface area (m^2)
b = Aircraft.Wingspan; % wingspan (m)
c = Aircraft.RefChord; % reference chord length (m)
I_B = Aircraft.InertiaTensor; % tensor of inertia written wrt Body FoR
CL = @(alpha_deg_, delta_e_deg_) Aircraft.LiftCoeff(alpha_deg_, 0, 0, 0, 0, delta_e_deg_, 0, 0);
CD = @(alpha_deg_) Aircraft.DragCoeff(alpha_deg_, 0, 0, 0, 0, 0, 0, 0);
CC = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_) Aircraft.CrossforceCoeff(alpha_deg_, beta_deg_, 0, 0, 0, 0, delta_a_deg_, delta_r_deg_);
CRoll = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_, p_, r_) Aircraft.RollCoeff(alpha_deg_, beta_deg_, p_, 0, r_, 0, delta_a_deg_, delta_r_deg_);
CPitch = @(alpha_deg_, delta_e_deg_, q_) Aircraft.PitchCoeff(alpha_deg_, 0, 0, q_, 0, delta_e_deg_, 0, 0);
CYaw = @(alpha_deg_, beta_deg_, delta_a_deg_, delta_r_deg_, r_) Aircraft.YawCoeff(alpha_deg_, beta_deg_, 0, 0, r_, 0, delta_a_deg_, delta_r_deg_);

%% Flight conditions
g = 9.81; % acceleration of gravity (m/s^2)
z_EG_0 = -8000; % z coordinate of the CoG wrt Earth FoR (m)
q_0 = 0; % pitch rate (rad/s)
gamma_0 = convang(0, 'deg', 'rad'); % fligth path angle (deg)
[temp_0, sound_0, press_0, density_0] = atmosisa(-z_EG_0);
Nv = 20;
v_Mach_0 = linspace(0.15, 0.80, Nv);
v_V_0 = v_Mach_0 * sound_0;

%% First guess for the design vector
csi_0 = [0; 0; 0.5]; % [alpha_deg; delta_e_deg; delta_T]

%% alpha_deg, delta_e_deg and delta_t functions
alpha_deg = @(csi) csi(1);
delta_e_deg = @(csi) csi(2);
delta_T = @(csi) csi(3);

%% Quaternion functions
quat_0 = @(csi) sum([1, 0, 0, 0] .* angle2quat(0, gamma_0 + convang(alpha_deg(csi), 'deg', 'rad'), 0));
quat_1 = @(csi) sum([0, 1, 0, 0] .* angle2quat(0, gamma_0 + convang(alpha_deg(csi), 'deg', 'rad'), 0));
quat_2 = @(csi) sum([0, 0, 1, 0] .* angle2quat(0, gamma_0 + convang(alpha_deg(csi), 'deg', 'rad'), 0));
quat_3 = @(csi) sum([0, 0, 0, 1] .* angle2quat(0, gamma_0 + convang(alpha_deg(csi), 'deg', 'rad'), 0));
quat = @(csi) [quat_0(csi), quat_1(csi), quat_2(csi), quat_3(csi)];

%% Matrices and operators
omega_B_tilde = @(csi) ...
    [  0,      0,   q_0; ... % operator matrix for the left vector product by omega_B
       0,      0,    0; ...
     -q_0,     0,    0];

T_BE = @(csi) quat2dcm(quat(csi)); % change of basis matrix from Body FoR to Earth FoR
T_EB = @(csi) T_BE(csi).'; % change of basis matrix from Earth FoR to Body FoR

Quat_evol = @(csi) 0.5 * [-quat_1(csi), -quat_2(csi), -quat_3(csi); ...
                           quat_0(csi), -quat_3(csi),  quat_2(csi); ...
                           quat_3(csi),  quat_0(csi), -quat_1(csi); ...
                          -quat_2(csi),  quat_1(csi),  quat_0(csi)];

%% Velocity components in the Body FoR u, v and w from the state (airspeed, AoA and sideslip angle)
u = @(csi) V_0 * cos(0) * cosd(alpha_deg(csi));
v = @(csi) V_0 * sin(0);
w = @(csi) V_0 * cos(0) * sind(alpha_deg(csi));

%% Thrust and aerodynamic forces
T = @(csi, V) delta_T(csi) * T_max; % thrust (N)

L = @(csi, V) CL(alpha_deg(csi), delta_e_deg(csi)) * 0.5 * density_0 * V^2 * S; % lift (N)

D = @(csi, V) CD(alpha_deg(csi)) * 0.5 * density_0 * V^2 * S; % drag (N)

C = @(csi, V) 0;

%% Euler angles from quaternion components
function theta = quat2theta(quat)
    [~, theta, ~] = quat2angle(quat);
end

%% Force components in Body FoR
X = @(csi, V) T(csi, V) - D(csi, V) * cosd(alpha_deg(csi)) + L(csi, V) * sind(alpha_deg(csi)) - W * sin(quat2theta(quat(csi)));

Y = @(csi, V) C(csi, V) + W * sin(0) * cos(quat2theta(quat(csi)));

Z = @(csi, V) -D(csi, V) * sind(alpha_deg(csi)) - L(csi, V) * cosd(alpha_deg(csi)) + W * cos(0) * cos(quat2theta(quat(csi)));

%% Aerodynamic torque components in Body FoR
Roll = @(csi, V) 0;

Pitch = @(csi, V) CPitch(alpha_deg(csi), delta_e_deg(csi), q_0) * 0.5 * density_0 * V^2 * S * c;

Yaw = @(csi, V) 0;

%% Derivatives of V, alpha and q
V_dot = @(csi, V) 1/m * (-D(csi, V)*cos(0) + C(csi, V)*sin(0) + T(csi, V)*cosd(alpha_deg(csi))*cos(0) - W * ...
    (cosd(alpha_deg(csi))*cos(0)*sin(quat2theta(quat(csi))) - ...
    sin(0)*sin(0)*cos(quat2theta(quat(csi))) - ...
    sind(alpha_deg(csi))*cos(0)*cos(0)*cos(quat2theta(quat(csi)))));

alpha_dot = @(csi, V) 1/(m*V*cos(0)) * (-L(csi, V) - T(csi, V)*sind(alpha_deg(csi)) + W * ...
    (cosd(alpha_deg(csi))*cos(0)*cos(quat2theta(quat(csi))) + ...
    sind(alpha_deg(csi))*sin(quat2theta(quat(csi))))) + ...
    q_0 - tan(0) * (0*cosd(alpha_deg(csi)) + 0*sind(alpha_deg(csi)));

q_dot = @(csi, V) [0, 1, 0] * (I_B \ ([Roll(csi, V); Pitch(csi, V); Yaw(csi, V)] - omega_B_tilde(csi) * I_B * [0; q_0; 0]));

%% Cost function
function J = cost(V_dot, alpha_dot, q_dot)
    J = V_dot^2 + alpha_dot^2 + q_dot^2;
end

%% Nonlinear constraints
function [c, ceq] = nonLinCon(~)
    c = [];
    ceq = [];
end

%% Trim options
lower_bounds = [-5; -24; 0];
upper_bounds = [40; 10; 1];
trim_options = optimset('tolfun', 1e-9, 'Algorithm', 'interior-point');

%% Trim
v_alpha0_deg = zeros(Nv, 1);
v_delta_e0_deg = zeros(Nv, 1);
v_delta_T0 = zeros(Nv, 1);

for iv = 1 : Nv
    [csi, fval] = fmincon(@(x) cost(V_dot(x, v_V_0(iv)), alpha_dot(x, v_V_0(iv)), q_dot(x, v_V_0(iv))), ...
                          csi_0, ...
                          [], ...
                          [], ...
                          [], ...
                          [], ...
                          lower_bounds, ...
                          upper_bounds, ...
                          nonLinCon, ...
                          trim_options);
    
    v_alpha0_deg(iv) = csi(1);
    v_delta_e0_deg(iv) = csi(2);
    v_delta_T0(iv) = csi(3);
end

%% Diagram
fig_number = 1;
h_figs{fig_number} = figure(fig_number);
h_figs{fig_number}.Position(3) = h_figs{fig_number}.Position(3) + 500;
h_figs{fig_number}.Position(4) = h_figs{fig_number}.Position(4) + 150;

subplot_pos = ...
    [0.1, 0.65, 0.9, 0.255; ...
     0.1, 0.35, 0.9, 0.255; ...
     0.1, 0.05, 0.9, 0.255];

subplot('Position', subplot_pos(1, :))
    hold on
    plot(v_V_0, v_alpha0_deg, 'LineWidth', 1.25, 'Marker', 'o')
    hold off
    grid on
    xlim([0.95*min(v_V_0), 1.05*max(v_V_0)])
    ylabel("$\alpha_0$ (deg)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')
subplot('Position', subplot_pos(2, :))
    hold on
    plot(v_V_0, v_delta_e0_deg, 'LineWidth', 1.25, 'Marker', 'o')
    hold off
    grid on
    xlim([0.95*min(v_V_0), 1.05*max(v_V_0)])
    ylabel("$\delta_{\mathrm{e},0}$ (deg)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')
subplot('Position', subplot_pos(3, :))
    hold on
    plot(v_V_0, v_delta_T0, 'LineWidth', 1.25, 'Marker', 'o')
    hold off
    grid on
    xlim([0.95*min(v_V_0), 1.05*max(v_V_0)])
    ylabel("$\delta_{\mathrm{T},0}$", 'Interpreter', 'latex', 'FontSize', 12)
    xlabel("$V_0$ (m/s)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')

sgtitle(strcat("\textbf{3DoF Trim.} $h = ", num2str(-z_EG_0), "$ m"), 'Interpreter', 'latex')

exportgraphics(h_figs{fig_number}, 'f18harv_3DOF_Trim.pdf', 'Resolution', 300)
% exportgraphics(h_figs{fig_number}, 'f18harv_3DOF_Trim.png', 'Resolution', 300)

%% Verifying the trim
t_end = 1200;
Nt = 800;
v_Time = linspace(0, t_end, Nt);

m_Airspeed = zeros(Nv, Nt);
m_AoA = zeros(Nv, Nt);
m_Sideslip = zeros(Nv, Nt);
m_p = zeros(Nv, Nt);
m_q = zeros(Nv, Nt);
m_r = zeros(Nv, Nt);
m_x_EG = zeros(Nv, Nt);
m_y_EG = zeros(Nv, Nt);
m_z_EG = zeros(Nv, Nt);
m_quat_0 = zeros(Nv, Nt);
m_quat_x = zeros(Nv, Nt);
m_quat_y = zeros(Nv, Nt);
m_quat_z = zeros(Nv, Nt);

startv = 8;
endv = 8;
for iv = startv : endv
    V0 = v_V_0(iv);
    alpha0_deg = v_alpha0_deg(iv);
    delta_e0_deg = v_delta_e0_deg(iv);
    delta_T0 = v_delta_T0(iv);
    
    f_delta_T = @(t) interp1([0, 1] * t_end, [1, 1] * delta_T0, t, 'linear');
    f_delta_e_deg = @(t) interp1([0, 1] * t_end, [1, 1] * delta_e0_deg, t, 'linear');
    f_delta_a_deg = @(t) 0;
    f_delta_r_deg = @(t) 0;
    
    v_state_0 = [V0, convang(alpha0_deg, 'deg', 'rad'), 0, 0, 0, 0, 0, 0, z_EG_0, angle2quat(0, convang(alpha0_deg, 'deg', 'rad'), 0)];
    
    [~, m_Airspeed(iv, :), m_AoA(iv, :), m_Sideslip(iv, :), m_p(iv, :), m_q(iv, :), m_r(iv, :), ...
                                m_x_EG(iv, :), m_y_EG(iv, :), m_z_EG(iv, :), m_quat_0(iv, :), m_quat_x(iv, :), m_quat_y(iv, :), m_quat_z(iv, :)] = ...
                                Sim6DOF(Aircraft, v_state_0, v_Time(2:end), f_delta_T, f_delta_e_deg, f_delta_a_deg, f_delta_r_deg);
    disp(strcat("Simulazione ", num2str(iv), "/", num2str(Nv), " completata."))
end

fig_number = fig_number + 1;
h_figs{fig_number} = figure(fig_number);
h_figs{fig_number}.Position(3) = h_figs{fig_number}.Position(3) + 500;
h_figs{fig_number}.Position(4) = h_figs{fig_number}.Position(4) + 150;

subplot_pos = ...
    [0.1, 0.65, 0.9, 0.255; ...
     0.1, 0.35, 0.9, 0.255; ...
     0.1, 0.05, 0.9, 0.255];

subplot('Position', subplot_pos(1, :))
    hold on
    for iv=startv:endv; plot(v_Time, m_Airspeed(iv, :), 'LineWidth', 1.25); end
    hold off
    grid on
    ylim(V0 + [-1, 1])
    ylabel("Airspeed (m/s)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')
subplot('Position', subplot_pos(2, :))
    hold on
    for iv=startv:endv; plot(v_Time, convang(m_AoA(iv, :), 'rad', 'deg'), 'LineWidth', 1.25); end
    hold off
    grid on
    ylim(alpha0_deg + [-0.5, 0.5])
    ylabel("$\alpha$ (deg)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')
subplot('Position', subplot_pos(3, :))
    hold on
    for iv=startv:endv; plot(v_Time, m_q(iv, :), 'LineWidth', 1.25); end
    hold off
    grid on
    ylim([-0.25, 0.25])
    ylabel("$q$ (rad/s)", 'Interpreter', 'latex', 'FontSize', 12)
    xlabel("Simulation time (s)", 'Interpreter', 'latex', 'FontSize', 12)
    set(gca, 'TickLabelInterpreter', 'latex')

sgtitle("\textbf{3DoF Trim verification}", 'Interpreter', 'latex')

exportgraphics(h_figs{fig_number}, 'f18harv_3DOF_Trim_verification.pdf', 'Resolution', 300)
% exportgraphics(h_figs{fig_number}, 'f18harv_3DOF_Trim_verification.png', 'Resolution', 300)