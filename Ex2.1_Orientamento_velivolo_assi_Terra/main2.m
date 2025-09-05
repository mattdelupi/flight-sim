close all; clc; clear;

%% Setup the figure
h_fig1 = figure(1);
light('Position', [1, 0, -2], 'Style', 'local')
set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
grid on; hold on

%% Load A/C shape
shapeScaleFactor = 1.75;
shape = loadAircraftMAT('aircraft_pa24-250.mat', shapeScaleFactor);

%% Set the A/C in place
vXYZe = [2, 2, -2];
vEulerAngles = convang([20, 10, 0], 'deg', 'rad');
theView = [200, 25];
bodyAxesOptions.show = true;
bodyAxesOptions.magX = 2 * shapeScaleFactor;
bodyAxesOptions.magY = 2 * shapeScaleFactor;
bodyAxesOptions.magZ = 1.5 * shapeScaleFactor;
bodyAxesOptions.lineWidth = 2.5;
plotBodyE(h_fig1, shape, vXYZe, vEulerAngles, bodyAxesOptions, theView)

%% Plot Earth axes
hold on
xMax = max([abs(vXYZe(1)), 5]);
yMax = max([abs(vXYZe(2)), 5]);
zMax = .3 * xMax;
vXYZ0 = [0, 0, 0];
vExtent = [xMax, yMax, zMax];
plotEarthAxes(h_fig1, vXYZ0, vExtent)

%% Draw CoG coordinate helper lines
hold on
plotPoint3DHelperLines(h_fig1, vXYZe)

set(gca, 'TickLabelInterpreter', 'latex')
xlabel("$x_\mathrm{E}$ (m)", 'Interpreter', 'latex')
ylabel("$y_\mathrm{E}$ (m)", 'Interpreter', 'latex')
zlabel("$z_\mathrm{E}$ (m)", 'Interpreter', 'latex')

exportgraphics(gca, 'ex2_1.pdf', 'Resolution', 450)