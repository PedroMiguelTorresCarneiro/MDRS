function Loads = calculateLinkLoadsPairs(nNodes, Links, T, sP, Solution)
    nFlows = size(T, 1); % Number of flows
    nLinks = size(Links, 1); % Number of links
    aux = zeros(nNodes); % Auxiliary matrix to store link loads

    for i = 1:nFlows
        if Solution(i) > 0
            % Process working path
            workingPath = sP{1, i}{Solution(i)};
            for j = 2:length(workingPath)
                aux(workingPath(j - 1), workingPath(j)) = aux(workingPath(j - 1), workingPath(j)) + T(i, 3); % Add load (forward direction)
                aux(workingPath(j), workingPath(j - 1)) = aux(workingPath(j), workingPath(j - 1)) + T(i, 4); % Add load (reverse direction)
            end
            
            % Process backup path if it exists
            if ~isempty(sP{2, i}) && ~isequal(sP{2, i}, 0)
                backupPath = sP{2, i}{Solution(i)};
                for j = 2:length(backupPath)
                    aux(backupPath(j - 1), backupPath(j)) = aux(backupPath(j - 1), backupPath(j)) + T(i, 3); % Add load (forward direction)
                    aux(backupPath(j), backupPath(j - 1)) = aux(backupPath(j), backupPath(j - 1)) + T(i, 4); % Add load (reverse direction)
                end
            end
        end
    end

    % Compile the loads into the output matrix
    Loads = [Links zeros(nLinks, 2)];
    for i = 1:nLinks
        Loads(i, 3) = aux(Loads(i, 1), Loads(i, 2)); % Load in forward direction
        Loads(i, 4) = aux(Loads(i, 2), Loads(i, 1)); % Load in reverse direction
    end
end
