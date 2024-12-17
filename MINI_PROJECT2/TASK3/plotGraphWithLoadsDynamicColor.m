function plotGraphWithLoadsDynamicColor(Nodes, Links, Loads, n)
    % Plot the graph with dynamic coloring for loads and links
    figure(n);
    co = Nodes(:,1) + 1j * Nodes(:,2); % Complex coordinates
    plot(co, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 18);
    hold on;
    
    % Find the highest load value and its index
    [maxLoad, maxIndex] = max(max(Loads(:,3:4), [], 2));
    
    % Plot links and annotate with load values
    for i = 1:size(Links,1)
        % Determine line color based on the link's load
        if i == maxIndex
            lineColor = 'r'; % Red for the worst link
        else
            lineColor = 'b'; % Light blue for normal links
        end
        
        % Plot the link with the determined color
        plot([Nodes(Links(i,1),1) Nodes(Links(i,2),1)], [Nodes(Links(i,1),2) Nodes(Links(i,2),2)], 'Color', lineColor, 'LineWidth', 1);
         
        % Calculate the midpoint of the link
        midX = (Nodes(Links(i,1),1) + Nodes(Links(i,2),1)) / 2;
        midY = (Nodes(Links(i,1),2) + Nodes(Links(i,2),2)) / 2;
        
        % Determine text color for the loads
        if Loads(i,3) == maxLoad || Loads(i,4) == maxLoad
            textColor = 'r'; % Red for the highest value
        else
            textColor = '#3CB371'; % Dark green for normal values
        end
        
        % Display the link loads at the midpoint with white background
        text(midX, midY + 10, ...
             sprintf('→ %.2f\n← %.2f', Loads(i,3), Loads(i,4)), ...
             'HorizontalAlignment', 'center', ...
             'Color', textColor, ...
             'FontWeight', 'normal', ...
             'FontSize', 11, ...
             'BackgroundColor', 'w', ... % White background for better visibility
             'Margin', 2); % Add some padding
    end
    
    % Re-plot nodes for visibility
    plot(co, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'MarkerSize', 18);
    
    % Label the nodes
    for i = 1:length(co)
        text(Nodes(i,1), Nodes(i,2), sprintf('%d', i), 'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 14);
    end
    
    grid on;
    hold off;
end
