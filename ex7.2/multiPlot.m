function multiPlot(time, xlab, ylab, lgnd, filename, varargin)

    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    hold on
    for i = 1 : length(varargin)
        plot(time, varargin{i}, 'LineWidth', 2)
    end
    hold off
    
    xlabel(xlab, 'Interpreter', 'latex', 'FontSize', 18)
    ylabel(ylab, 'Interpreter', 'latex', 'FontSize', 18)
    grid on
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)

    if length(varargin) > 1
        legend(lgnd, 'Interpreter', 'latex', ...
            'FontSize', 18, 'Location', 'northeastoutside');
    end

    exportgraphics(h, filename, 'Resolution', 300)

end