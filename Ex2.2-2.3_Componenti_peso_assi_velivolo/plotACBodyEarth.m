function [vEulerAngles, vXYZe] = plotACBodyEarth(angles)
%% Setup the figure
h_fig1 = figure(1);
light('Position', [1, 0, -2], 'Style', 'local')
set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
grid on; hold on

%% Load A/C shape
shapeScaleFactor = 1;
shape = loadAircraftMAT('aircraft_pa24-250.mat', shapeScaleFactor);

%% Set the A/C in place
vXYZe = [2, 2, -2];
vEulerAngles = convang(angles, 'deg', 'rad');
theView = [105, 15];
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
end