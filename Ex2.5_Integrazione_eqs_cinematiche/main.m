close all; clc; clear;

%% Problem data
tEnd = 100;
psi0 = 0;
theta0 = 0;
phi0 = 0;
z0 = -1000;

%% Maximum magnitudes for the angular velocities
pMax = convangvel(2, 'deg/s', 'rad/s');
qMax = convangvel(1, 'deg/s', 'rad/s');
rMax = convangvel(1.2, 'deg/s', 'rad/s');

%% p law
vBreakPointsP(1, :) = [0, .03, .08, .2, .25, .35, .6, .67, .75, 1] * tEnd;
vBreakPointsP(2, :) = [0, .025, .7, 1, 1, 0, -1, -1, 0, 0] * pMax;
p = @(t) interp1(vBreakPointsP(1, :), vBreakPointsP(2, :), t, 'pchip');

%% q law
vBreakPointsQ(1, :) = [0, .03, .1, .2, .48, .6, .7, 1] * tEnd;
vBreakPointsQ(2, :) = [0, .025, .75, 1, 1, -.4, 0, 0] * qMax;
q = @(t) interp1(vBreakPointsQ(1, :), vBreakPointsQ(2, :), t, 'pchip');

%% r law
vBreakPointsR(1, :) = [0, .03, .1, .2, .5, .6, 1] * tEnd;
vBreakPointsR(2, :) = [0, .025, .75, 1, 1, 0, 0] * qMax;
r = @(t) interp1(vBreakPointsR(1, :), vBreakPointsR(2, :), t, 'pchip');

%% Reference value for CoG velocity components
u0 = convvel(380, 'km/h', 'm/s');
v0 = convvel(0, 'km/h', 'm/s');
w0 = convvel(0, 'km/h', 'm/s');

%% u law
vBreakPointsU(1, :) = [0, 1/30, 1/10, 1/5, .8, 1] * tEnd;
vBreakPointsU(2, :) = [1, .8, .7, 1, 1.1, 1] * u0;
u = @(t) interp1(vBreakPointsU(1, :), vBreakPointsU(2, :), t, 'pchip');

%% v law
v = @(t) 0;

%% w law
w = @(t) 0;

%% RHS of Gimbal equations
dPhiThetaPsidt = @(t, x) [ ...
    1, sin(x(1)).*sin(x(2))./cos(x(2)), cos(x(1)).*sin(x(2))./cos(x(2)); ...
    0, cos(x(1)), -sin(x(1)); ...
    0, sin(x(1))./cos(x(2)), cos(x(1))./cos(x(2)) ...
    ] * [p(t); q(t); r(t)];

%% Solution of Gimbal equations
gimbalOptions = odeset('RelTol', 1e-9, 'AbsTol', 1e-9 * ones(1, 3));
vPhiThetaPsi0 = [phi0, theta0, psi0];
[vTime, vPhiThetaPsi] = ode45(dPhiThetaPsidt, [0, tEnd], ...
                                            vPhiThetaPsi0, gimbalOptions);

%% Arrays of velocity components
for i = 1 : numel(vTime)
    vU(i) = u(vTime(i));
    vV(i) = v(vTime(i));
    vW(i) = w(vTime(i));
end

%% Euler angles functions
fPhi = @(t) interp1(vTime, vPhiThetaPsi(:, 1), t);
fTheta = @(t) interp1(vTime, vPhiThetaPsi(:, 2), t);
fPsi = @(t) interp1(vTime, vPhiThetaPsi(:, 3), t);

%% RHS of Navigation equations
dPosEdt = @(t, pos) ...
    transpose(angle2dcm(fPsi(t), fTheta(t), fPhi(t), 'ZYX')) * ...
                                                        [u(t); v(t); w(t)];

%% Solution of Navigation equations
navigationOptions = odeset('RelTol', 1e-3, 'AbsTol', 1e-3 * ones(1, 3));
vPosE0 = [0; 0; 0];
[~, vPosE] = ode45(dPosEdt, vTime, vPosE0, navigationOptions);

%% Arrays of CoG positions
vXe = vPosE(:, 1);
vYe = vPosE(:, 2);
vZe = vPosE(:, 3);

%% Setup the figure
h_fig1 = figure(1);
grid on; hold on
light('Position', [1, 0, -4], 'Style', 'local');
set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
daspect([1, 1, 1])

%% Load the A/C shape
shapeScaleFactor = 350;
shape = loadAircraftMAT('aircraft_mig29.mat', shapeScaleFactor);

%% Sequence of positions and Euler angles
mXYZe = [vXe, vYe, vZe+z0];
mEulerAngles = ...
            [vPhiThetaPsi(:, 3), vPhiThetaPsi(:, 2), vPhiThetaPsi(:, 1)];

%% Settings
plotOptions.samples = 1:50:numel(vTime);
plotOptions.theView = [105, 15];
plotOptions.bodyAxes.show = true;
plotOptions.bodyAxes.magX = 1.5 * shapeScaleFactor;
plotOptions.bodyAxes.magY = 2 * shapeScaleFactor;
plotOptions.bodyAxes.magZ = 2 * shapeScaleFactor;
plotOptions.bodyAxes.lineWidth = 2.5;
plotOptions.helperLines.show = true;
plotOptions.helperLines.lineColor = 'k';
plotOptions.helperLines.lineStyle = ':';
plotOptions.helperLines.lineWidth = 1.5;
plotOptions.trajectory.show = true;
plotOptions.trajectory.lineColor = 'k';
plotOptions.trajectory.lineStyle = '-';
plotOptions.trajectory.lineWidth = 1.5;

%% Plot body and trajectory
plotTrajectoryAndBodyE(h_fig1, shape, mXYZe, mEulerAngles, plotOptions);

%% Plot Earth axes
hold on
xMax = max([max(abs(mXYZe(:, 1))), 5]);
yMax = max([max(abs(mXYZe(:, 2))), 5]);
zMax = .05 * xMax;
vXYZ0 = [0, 0, 0];
vExtent = [xMax, yMax, zMax];
plotEarthAxes(h_fig1, vXYZ0, vExtent);
xlabel('$x_\mathrm{E}$ (m)', 'interpreter', 'latex')
ylabel('$y_\mathrm{E}$ (m)', 'interpreter', 'latex')
zlabel('$z_\mathrm{E}$ (m)', 'interpreter', 'latex')
set(gca, 'TickLabelInterpreter', 'latex')
hold off
exportgraphics(gca, 'ex25main.pdf', 'Resolution', 450)