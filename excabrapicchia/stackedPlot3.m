function stackedPlot3(x, y1, y2, y3, labels, titles, lgnd, filename)
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    if isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.72, 0.9, 0.27; ...
                     0.05, 0.40, 0.9, 0.27; ...
                     0.05, 0.08, 0.9, 0.27];
    elseif isempty(lgnd) && ~isempty(titles)
        positions = [0.05, 0.72, 0.9, 0.25; ...
                     0.05, 0.40, 0.9, 0.25; ...
                     0.05, 0.08, 0.9, 0.25];
    elseif ~isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.72, 0.7, 0.27; ...
                     0.05, 0.40, 0.7, 0.27; ...
                     0.05, 0.08, 0.7, 0.27];
    else
        positions = [0.05, 0.72, 0.7, 0.25; ...
                     0.05, 0.40, 0.7, 0.25; ...
                     0.05, 0.08, 0.7, 0.25];
    end

    subplot('Position', positions(1, :))
        [~, n] = size(y1);
        hold on
        for j = 1 : n
            plot(x, y1(:, j), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 16)
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
            plot(x, y2(:, j), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 16)
        end
        hold off
        ylabel(labels{3}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{2}, 'Interpreter', 'latex', 'FontSize', 12)
        end
    subplot('Position', positions(3, :))
        [~, n] = size(y3);
        hold on
        for j = 1 : n
            plot(x, y3(:, j), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 16)
        end
        hold off
        xlabel(labels{1}, 'Interpreter', 'latex', 'FontSize', 18)
        ylabel(labels{4}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{3}, 'Interpreter', 'latex', 'FontSize', 12)
        end

    if ~isempty(lgnd)
        lgnd = legend(lgnd, 'Interpreter', 'latex', 'FontSize', 18);
        lgnd.Position(1) = 0.775;
        lgnd.Position(2) = positions(1, 2) + positions(1, 4) - lgnd.Position(4);
    end

    exportgraphics(h, filename, 'Resolution', 300)
end