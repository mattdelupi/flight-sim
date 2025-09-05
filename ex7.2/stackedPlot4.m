function stackedPlot4(x, y1, y2, y3, y4, labels, titles, lgnd, filename)
    h = figure;
    set(h, 'Position', get(0, 'MonitorPositions'))

    if isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.79, 0.9, 0.20; ...
                     0.05, 0.55, 0.9, 0.20; ...
                     0.05, 0.31, 0.9, 0.20; ...
                     0.05, 0.07, 0.9, 0.20];
    elseif isempty(lgnd) && ~isempty(titles)
        positions = [0.05, 0.79, 0.9, 0.18; ...
                     0.05, 0.55, 0.9, 0.18; ...
                     0.05, 0.31, 0.9, 0.18; ...
                     0.05, 0.07, 0.9, 0.18];
    elseif ~isempty(lgnd) && isempty(titles)
        positions = [0.05, 0.79, 0.7, 0.20; ...
                     0.05, 0.55, 0.7, 0.20; ...
                     0.05, 0.31, 0.7, 0.20; ...
                     0.05, 0.07, 0.7, 0.20];
    else
        positions = [0.05, 0.79, 0.7, 0.18; ...
                     0.05, 0.55, 0.7, 0.18; ...
                     0.05, 0.31, 0.7, 0.18; ...
                     0.05, 0.07, 0.7, 0.18];
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
            plot(x, y3(:, j), 'LineWidth', 2)
        end
        hold off
        ylabel(labels{4}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{3}, 'Interpreter', 'latex', 'FontSize', 12)
        end
    subplot('Position', positions(4, :))
        [~, n] = size(y4);
        hold on
        for j = 1 : n
            plot(x, y4(:, j), 'LineWidth', 2)
        end
        hold off
        xlabel(labels{1}, 'Interpreter', 'latex', 'FontSize', 18)
        ylabel(labels{5}, 'Interpreter', 'latex', 'FontSize', 18)
        set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12)
        axis tight
        grid on
        if ~isempty(titles)
            title(titles{4}, 'Interpreter', 'latex', 'FontSize', 12)
        end

    if ~isempty(lgnd)
        lgnd = legend(lgnd, 'Interpreter', 'latex', 'FontSize', 18);
        lgnd.Position(1) = 0.775;
        lgnd.Position(2) = positions(1, 2) + positions(1, 4) - lgnd.Position(4);
    end

    exportgraphics(h, filename, 'Resolution', 300)
end