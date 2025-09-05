function liftCharacteristicsPlot(myAircraft, ModelsInputs, alpha_deg_limits, delta_e_deg_cases, filename)

    Ndelta = length(delta_e_deg_cases);
    
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    hold on
    for idelta = 1 : Ndelta
        ModelsInputs(3) = delta_e_deg_cases(idelta);
        fplot(@(alpha_deg) myAircraft.LiftCoeffModel([alpha_deg, ModelsInputs]), ...
              alpha_deg_limits, 'LineWidth', 2)
        delta_e_labels{idelta} = strcat("$\delta_\mathrm{e}$ = ", num2str(delta_e_deg_cases(idelta)), " deg");
    end
    hold off
    xlabel("$\alpha_\mathrm{B}$ (deg)", 'Interpreter', 'latex', 'FontSize', 18);
    ylabel("$C_L$", 'Interpreter', 'latex', 'FontSize', 18)
    grid on
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
    legend(delta_e_labels, 'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 18)

    exportgraphics(h, filename, 'Resolution', 300)

end