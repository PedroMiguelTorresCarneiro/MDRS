function delay = calculatePathDelay(path, netCostMatrix)
    % Function to calculate the total delay of a given path
    %
    % Inputs:
    %   path - Array of nodes representing the path (e.g., [1 2 4])
    %   netCostMatrix - NxN matrix of link costs/delays
    %
    % Output:
    %   delay - Total delay (sum of delays along the path)
    
    % Initialize delay
    delay = 0;
    
    % Loop through each link in the path
    for i = 1:length(path) - 1
        % Extract nodes for the current link
        node1 = path(i);
        node2 = path(i + 1);
        
        % Add the cost of this link to the total delay
        delay = delay + netCostMatrix(node1, node2);
    end
end
