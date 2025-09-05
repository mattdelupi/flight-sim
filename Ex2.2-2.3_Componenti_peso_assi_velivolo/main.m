close all; clc; clear;

%% Mass data
mass = 1200; % kg
g = 9.81; % m / s^2

%% Euler angles
[vEulerAngles, vXYZe] = plotACBodyEarth([20, 10, 0]);
psi = vEulerAngles(1); theta = vEulerAngles(2); phi = vEulerAngles(3);

%% DCM
TBE = angle2dcm(psi, theta, phi, 'ZYX')

%% Weight
hold on
vWeight_E = [0; 0; mass*g]
vWeight_B = TBE * vWeight_E
quiver3(vXYZe(1), vXYZe(2), vXYZe(3), ...
    vWeight_E(1), vWeight_E(2), vWeight_E(3), ...
    1.5/mass/g, 'color', 'k', 'linewidth', 2)

set(gca, 'TickLabelInterpreter', 'latex')
xlabel("$x_\mathrm{E}$ (m)", 'Interpreter', 'latex')
ylabel("$y_\mathrm{E}$ (m)", 'Interpreter', 'latex')
zlabel("$z_\mathrm{E}$ (m)", 'Interpreter', 'latex')
exportgraphics(gca, 'ex23main.pdf', 'Resolution', 450)