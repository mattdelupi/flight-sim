function trajectoryView(time, ...
                        x_EG, y_EG, z_EG, ...
                        phi, theta, psi, ...
                        shapeScaleFactor, samples, ...
                        filename)
    
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    grid on; hold on
    light('Position', [1, 0, -4], 'Style', 'local');
    set(gca, 'XDir', 'reverse'); set(gca, 'ZDir', 'reverse')
    daspect([1, 1, 1])
    
    shape = loadAircraftMAT('aircraft_mig29.mat', shapeScaleFactor);
    
    m_XYZ_EG = [x_EG, y_EG, z_EG];
    m_euler_angles = [psi, theta, phi];
    
    plot3d_options.samples = floor(linspace(1, length(time), samples));
    plot3d_options.theView = [165, 25];
    plot3d_options.bodyAxes.show = true;
    plot3d_options.bodyAxes.magX = 1.25 * shapeScaleFactor;
    plot3d_options.bodyAxes.magY = 0.75 * shapeScaleFactor;
    plot3d_options.bodyAxes.magZ = 0.75 * shapeScaleFactor;
    plot3d_options.bodyAxes.lineWidth = 1.75;
    plot3d_options.helperLines.show = true;
    plot3d_options.helperLines.lineColor = 'k';
    plot3d_options.helperLines.lineStyle = ':';
    plot3d_options.helperLines.lineWidth = 1.25;
    plot3d_options.trajectory.show = true;
    plot3d_options.trajectory.lineColor = 'k';
    plot3d_options.trajectory.lineStyle = '-';
    plot3d_options.trajectory.lineWidth = 2;
    
    plotTrajectoryAndBodyE(h, shape, m_XYZ_EG, m_euler_angles, plot3d_options);
    
    hold on
    x_max = max([max(abs(m_XYZ_EG(:, 1))), 100]);
    y_max = max([max(abs(m_XYZ_EG(:, 2))), 100]);
    z_max = 0.05 * x_max;
    v_XYZ_0 = [0, 0, 0];
    v_extent = [x_max, y_max, z_max];
    plotEarthAxes(h, v_XYZ_0, v_extent);
    hold off
    
    ylim([min([-100, y_EG.']), y_max]); zlim([1.05*min(z_EG), 0.95*max(z_EG)]);
    hxL = xlabel("$x_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex', 'FontSize', 18);
    hyL = ylabel("$y_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex', 'FontSize', 18); hyL.Position(2) = hyL.Position(2) - y_max;
    hzL = zlabel("$z_{_\mathrm{E}}$ (m)", 'Interpreter', 'latex', 'FontSize', 18);
    % title("\textbf{3D View of the trajectory}", 'Interpreter', 'latex')
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)

    exportgraphics(h, filename, 'Resolution', 450)

end