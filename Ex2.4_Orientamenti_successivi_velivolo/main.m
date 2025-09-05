close all; clc; clear;

%% Setup the figure
h_fig1 = figure(1);
light('Position', [1, 0, -2], 'Style', 'local')
set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
grid on; hold on

%% Load the A/C shape
shapeScaleFactor = 200;
shape = loadAircraftMAT('aircraft_mig29.mat', shapeScaleFactor);

%% Define the time domain
timeSteps = 100;
duration = 10;
t = linspace(0, duration, timeSteps);

%% Define the samples and the options
numberOfStages = 6;
trajectoryOptions.samples = floor(linspace(1, timeSteps, numberOfStages));
trajectoryOptions.theView = [60, 30];
trajectoryOptions.bodyAxes.show = true;
trajectoryOptions.bodyAxes.magX = 300;
trajectoryOptions.bodyAxes.magY = 300;
trajectoryOptions.bodyAxes.magZ = 200;
trajectoryOptions.bodyAxes.lineWidth = 2.5;
trajectoryOptions.helperLines.show = true;
trajectoryOptions.helperLines.lineColor = 'k';
trajectoryOptions.helperLines.lineWidth = 1.5;
trajectoryOptions.helperLines.lineStyle = ':';
trajectoryOptions.trajectory.show = true;
trajectoryOptions.trajectory.lineColor = 'k';
trajectoryOptions.trajectory.lineWidth = 1.5;
trajectoryOptions.trajectory.lineStyle = ':';

%% Define the CoG positions
mXYZe = zeros(timeSteps, 3);
mXYZe(:, 1) = 2250 - 2250 * cos(pi / duration * t);
mXYZe(:, 2) = 2250 * sin(pi / duration * t);
mXYZe(:, 3) = -1000;


%% Define the Euler angles
mEulerAngles = zeros(timeSteps, 3);
mEulerAngles(:, 1) = pi/2 - pi / duration * t;
mEulerAngles(:, 2) = 0;
mEulerAngles(:, 3) = -pi/3;

%% Plot the trajectory and the body
plotTrajectoryAndBodyE(h_fig1, shape, mXYZe, mEulerAngles, ...
                                                trajectoryOptions);

set(gca, 'TickLabelInterpreter', 'latex')
xlabel("$x_\mathrm{E}$ (m)", 'Interpreter', 'latex')
ylabel("$y_\mathrm{E}$ (m)", 'Interpreter', 'latex')
zlabel("$z_\mathrm{E}$ (m)", 'Interpreter', 'latex')
exportgraphics(gca, 'ex24main.pdf', 'Resolution', 450)