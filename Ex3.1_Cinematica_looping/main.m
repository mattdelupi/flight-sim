clc; close all; clear

%% Time and pitch constraints
t_end = 8.375; % final time (s)
q_max = 1; % max pitch angular rate (rad/s)

%% p, q and r laws
p = @(t) 0;
q = @(t) interp1([0, 0.05, 0.2, 0.8, 0.95, 1] * t_end, ...
                 [0,  0,   1,   1,   0,  0] * q_max, ...
                  t, 'pchip');
r = @(t) 0;

%% Initial conditions
quat_0 = [1; 0; 0; 0];

%% ODE RHS
dquat_dt = @(t, quat) 0.5 * [ 0,   -p(t), -q(t), -r(t); ...
                             p(t),   0,    r(t), -q(t); ...
                             q(t), -r(t),   0,    p(t); ...
                             r(t),  q(t), -p(t),   0  ] * quat;

%% ODE solution
ODE_options = odeset('AbsTol', 1e-9, 'RelTol', 1e-9);
[v_time, m_quat] = ode45(dquat_dt, [0, t_end], quat_0, ODE_options);

%% Euler angles
[v_psi, v_theta, v_phi] = quat2angle(m_quat);
v_psi_deg = convang(v_psi, 'rad', 'deg');
v_theta_deg = convang(v_theta, 'rad', 'deg');
v_phi_deg = convang(v_phi, 'rad', 'deg');

%% Plots
h_fig1 = figure(1);
hold on
plot(v_time, v_psi_deg, 'LineWidth', 1, 'LineStyle', '-');
plot(v_time, v_theta_deg, 'LineWidth', 1, 'LineStyle', '-');
plot(v_time, v_phi_deg, 'LineWidth', 1, 'LineStyle', '-');
hold off
grid on
xlabel("Time (s)", 'Interpreter', 'latex'); ylabel("Angles (deg)", 'Interpreter', 'latex')
%title("\textbf{Euler angles during a Looping}", 'Interpreter', 'latex')
legend({"$\psi$", "$\theta$", "$\varphi$"}, 'Interpreter', 'latex', 'Location', 'northeastoutside')
set(gca, 'TickLabelInterpreter', 'latex')
yticks([-90, -45, 0, 45, 90, 135, 180]); axis tight
exportgraphics(gca, 'ex31main.pdf', 'Resolution', 300)