function thrustCharacteristicsPlot(myAircraft, h_limits, Mach_limits, h_cases, Mach_cases, filename1, filename2, filename3)

    Nh = length(h_cases);
    
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    h_labels = cell(Nh, 1);
    hold on
    for ih = 1 : Nh
        fplot(@(Mach) 1e-3*myAircraft.ThrustModel(h_cases(ih), Mach), ...
                                            Mach_limits, 'LineWidth', 2)
        h_labels{ih} = strcat("$h = ", num2str(h_cases(ih)), "$ m");
    end
    hold off
    ylim([0, inf])
    xlabel("Mach number", 'Interpreter', 'latex', 'FontSize', 18)
    ylabel("$T_\mathrm{max}$ (kN)", 'Interpreter', 'latex', 'FontSize', 18)
    grid on
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
    legend(h_labels, 'Interpreter', 'latex', 'Location', 'northeastoutside', 'FontSize', 18)

    exportgraphics(h, filename1, 'Resolution', 300)

    NM = length(Mach_cases);

    g = figure;
    set(g, 'Position', get(0, 'MonitorPositions'))

    Mach_labels = cell(NM, 1);
    hold on
    for iM = 1 : NM
        fplot(@(altitude) 1e-3*myAircraft.ThrustModel(altitude, Mach_cases(iM)), ...
                                                h_limits, 'LineWidth', 2)
        Mach_labels{iM} = strcat("$M = ", num2str(Mach_cases(iM)), "$");
    end
    hold off
    ylim([0, inf])
    xlabel("Altitude (m)", Interpreter="latex", FontSize=18)
    ylabel("$T_\mathrm{max}$ (kN)", 'Interpreter', 'latex', 'FontSize', 18)
    grid on
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
    legend(Mach_labels, 'Interpreter', 'latex', 'Location', 'northeastoutside', 'FontSize', 18)

    exportgraphics(g, filename2, 'Resolution', 300)

    m = figure;
    set(m, 'Position', get(0, "MonitorPositions"))

    fmesh(@(altitude, mach) 1e-3*myAircraft.ThrustModel(altitude, mach), ...
        [h_limits, Mach_limits])
    zlim([0, inf])
    xlabel("Altitude (m)", Interpreter="latex", FontSize=18)
    ylabel("Mach number", 'Interpreter', 'latex', 'FontSize', 18)
    zlabel("$T_\mathrm{max}$ (kN)", 'Interpreter', 'latex', 'FontSize', 18)
    grid on
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)

    exportgraphics(m, filename3, 'Resolution', 450)

end