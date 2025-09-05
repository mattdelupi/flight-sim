clc; close all; clear

%% Time and kinematics constraints
t_end = 100; % final time (s)
p_max = convangvel(5, 'deg/s', 'rad/s'); % max roll angular rate (rad/s)
q_max = convangvel(5, 'deg/s', 'rad/s'); % max pitch angular rate (rad/s)
r_max = convangvel(18, 'deg/s', 'rad/s');
u_0 = convvel(280, 'km/h', 'm/s');

%% p, q and r laws
p = @(t) interp1([0, 0.1, 0.15, 0.18, 0.23, 1] * t_end, ...
                 [0,  0,   0,    0,   0,  0] * p_max, ...
                  t, 'pchip');
q = @(t) interp1([0, 0.05, 0.1, 0.25, 0.3, 0.325, 0.375, 0.425, 0.475, 0.8, 0.84, 0.88, 1] * t_end, ...
                 [0,   1,   0,    0,   0,    0,    1,     1,      0,   0,    1,   0,  0] * q_max, ...
                  t, 'pchip');
r = @(t) interp1([0, 0.1, 0.2, 0.3, 0.35, 0.538, 0.638, 0.738,  1] * t_end, ...
                 [0,   0,  1,   0,    0,    0,    -1,       0,  0] * r_max, ...
                 t, 'pchip');

figure
hold on
fplot(@(t) convangvel(p(t), 'rad/s', 'deg/s'), [0, t_end], 'LineWidth', 1)
fplot(@(t) convangvel(q(t), 'rad/s', 'deg/s'), [0, t_end], 'LineWidth', 1)
fplot(@(t) convangvel(r(t), 'rad/s', 'deg/s'), [0, t_end], 'LineWidth', 1)
hold off
grid on
xlabel("Time (s)", 'Interpreter', 'latex'); ylabel("Angular velocities (deg/s)", 'Interpreter', 'latex')
legend("$p$", "$q$", "$r$", 'Location', 'northeastoutside', 'Interpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
axis tight
exportgraphics(gca, 'ex34main1.pdf', 'Resolution', 300)

%% u, v and w laws
u = @(t) interp1([0, 0.05, 0.2, 0.8, 0.95, 1] * t_end, ...
                 [1,  1,  0.7, 0.7, 1, 1] * u_0  , ...
                  t, 'pchip');
v = @(t) 0;
w = @(t) 0;

%% Initial conditions
quat_0 = angle2quat(0, 0, 0);

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
figure
hold on
plot(v_time, v_psi_deg, 'LineWidth', 1, 'LineStyle', '-');
plot(v_time, v_theta_deg, 'LineWidth', 1, 'LineStyle', '-');
plot(v_time, v_phi_deg, 'LineWidth', 1, 'LineStyle', '-');
hold off
grid on
xlabel("Time (s)", 'Interpreter', 'latex'); ylabel("Angles (deg)", 'Interpreter', 'latex')
% title("\textbf{Euler angles during a Looping}", 'Interpreter', 'latex')
legend({"$\psi$", "$\theta$", "$\varphi$"}, 'Interpreter', 'latex', 'Location', 'northeastoutside')
set(gca, 'TickLabelInterpreter', 'latex')
yticks([-90, -45, 0, 45, 90, 135, 180])
axis tight
exportgraphics(gca, 'ex34main2.pdf', 'Resolution', 300)

%% Velocity components in Earth FoR
T_EB = @(quat) quat2dcm(quat).';

v_u_E = zeros(length(v_time), 1);
v_v_E = zeros(length(v_time), 1);
v_w_E = zeros(length(v_time), 1);
for it = 1 : length(v_time)
    V_E = T_EB(m_quat(it, :)) * [u(v_time(it)); v(v_time(it)); w(v_time(it))];
    v_u_E(it) = V_E(1);
    v_v_E(it) = V_E(2);
    v_w_E(it) = V_E(3);
end

u_E = @(t) interp1(v_time, v_u_E, t, 'pchip');
v_E = @(t) interp1(v_time, v_v_E, t, 'pchip');
w_E = @(t) interp1(v_time, v_w_E, t, 'pchip');

%% CoG coordinates in Earth FoR
CoG_0 = [0, 0, -1000];
dCoG_dt = @(t, CoG) [u_E(t); v_E(t); w_E(t)];
[~, m_CoG] = ode45(dCoG_dt, v_time, CoG_0, ODE_options);

v_x_EG = m_CoG(:, 1);
v_y_EG = m_CoG(:, 2);
v_z_EG = m_CoG(:, 3);

%% Trajectory
h = figure; set(h, 'Position', 0.9*get(0, 'Screensize'))
grid on; hold on
light('Position', [1, 0, -4], 'Style', 'local');
set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
daspect([1, 1, 1])

% Load the A/C shape
shape_scale_factor = 125;
shape = loadAircraftMAT('aircraft_mig29.mat', shape_scale_factor);

% Sequence of positions and Euler angles
m_XYZ_EG = [v_x_EG, v_y_EG, v_z_EG];
m_euler_angles = [v_psi, v_theta, v_phi];

% Settings
plot3d_options.samples = 31 : 60 : length(v_time);
plot3d_options.theView = [165, 25];
plot3d_options.bodyAxes.show = true;
plot3d_options.bodyAxes.magX = 1.25 * shape_scale_factor;
plot3d_options.bodyAxes.magY = 0.75 * shape_scale_factor;
plot3d_options.bodyAxes.magZ = 0.75 * shape_scale_factor;
plot3d_options.bodyAxes.lineWidth = 1.25;
plot3d_options.helperLines.show = true;
plot3d_options.helperLines.lineColor = 'k';
plot3d_options.helperLines.lineStyle = ':';
plot3d_options.helperLines.lineWidth = 1;
plot3d_options.trajectory.show = true;
plot3d_options.trajectory.lineColor = 'k';
plot3d_options.trajectory.lineStyle = '-';
plot3d_options.trajectory.lineWidth = 1.5;

% Plot body and trajectory
plotTrajectoryAndBodyE(gcf, shape, m_XYZ_EG, m_euler_angles, plot3d_options);

% Plot Earth axes
hold on
x_max = max([max(abs(m_XYZ_EG(:, 1))), 100]);
y_max = max([max(abs(m_XYZ_EG(:, 2))), 100]);
z_max = 0.05 * x_max;
v_XYZ_0 = [0, 0, 0];
v_extent = [x_max, y_max, z_max];
plotEarthAxes(gcf, v_XYZ_0, v_extent);
hold off

% Figure add-ons
% ylim([-80, 80])
hxL = xlabel("$x_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex'); hxL.Position = hxL.Position + [0, -200, 0];
hyL = ylabel("$y_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex'); hyL.Position = hyL.Position + [0, -600, 0];
zlabel("$z_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex')
% title("\textbf{3D View of the trajectory}", 'Interpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
exportgraphics(gca, 'ex34main3.pdf', 'Resolution', 450)