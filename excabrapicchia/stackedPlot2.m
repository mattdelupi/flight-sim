function stackedPlot2(x, y1, y2, labels, titles, lgnd, filename)
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    if isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.54, 0.9, 0.39; ...
                     0.05, 0.1, 0.9, 0.39];
    elseif isempty(lgnd) && ~isempty(titles)
        positions = [0.05, 0.55, 0.9, 0.375; ...
                     0.05, 0.1, 0.9, 0.375];
    elseif ~isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.54, 0.7, 0.39; ...
                     0.05, 0.1, 0.7, 0.39];
    else
        positions = [0.05, 0.55, 0.7, 0.375; ...
                     0.05, 0.1, 0.7, 0.375];
    end

    subplot('Position', positions(1, :))
        [~, n] = size(y1);
        hold on
        for j = 1 : n
            plot(x, y1(:, j), 'LineWidth', 2)
        end
        hold off
        ylabel(labels{2}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{1}, 'Interpreter', 'latex', 'FontSize', 12)
        end
    subplot('Position', positions(2, :))
        [~, n] = size(y2);
        hold on
        for j = 1 : n
            plot(x, y2(:, j), 'LineWidth', 2)
        end
        hold off
        xlabel(labels{1}, 'Interpreter', 'latex', 'FontSize', 18)
        ylabel(labels{3}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{2}, 'Interpreter', 'latex', 'FontSize', 12)
        end

    if ~isempty(lgnd)
        lgnd = legend(lgnd, 'Interpreter', 'latex', 'FontSize', 18);
        lgnd.Position(1) = 0.775;
        lgnd.Position(2) = positions(1, 2) + positions(1, 4) - lgnd.Position(4);
    end

    exportgraphics(h, filename, 'Resolution', 300)
end