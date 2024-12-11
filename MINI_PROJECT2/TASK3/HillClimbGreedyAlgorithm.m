 function [bestSolCycle, bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, T, sP, nSP, timeLimit)
    t = tic; % Start timer
    nFlows = size(T, 1); % Number of flows
    bestObjective = inf; % Initialize best load to infinity
    noCycles = 0; % Counter for the number of solutions generated
    aux = 0; % Cumulative load for averaging
    bestTime = 0; % Variable to store the time when the best load was found
    bestSolCycle = 0;

    while toc(t) < timeLimit
        % ------------------------- INITIAL SOLUTION SELECTION -------------------------
        % [RANDOM GREEDY ALGORITHM]
        %
        sol = zeros(1, nFlows); % Initialize the solution to zero
        randFlows = randperm(nFlows); % Randomize the order of flows
        for flow = randFlows
            path_index = 0; % Initialize the best path index
            best_load = inf; % Initialize the best load for this flow
            for path = 1:nSP(flow)
                sol(flow) = path; % Assign the current path
                Loads = calculateLinkLoads(nNodes, Links, T, sP, sol); % Calculate the link loads
                load = max(max(Loads(:, 3:4))); % Evaluate the maximum load
                
                % Update the best path if the load is better
                if load < best_load
                    path_index = path;
                    best_load = load;
                end
            end
            sol(flow) = path_index; % Assign the best path found for this flow
        end

        % Calculate the initial load after the greedy solution
        Loads = calculateLinkLoads(nNodes, Links, T, sP, sol);
        load = max(max(Loads(:, 3:4)));

        % ------------------------- HILL CLIMBING OPTIMIZATION -------------------------
        % [HILL CLIMBING ALGORITHM]
        %
        improved = true;
        while improved
            bestLocalLoad = load;
            bestLocalSol = sol;

            % exploring "neighboring" solutions
            % process continues until no further improvements can be found
            %
            for flow = 1:nFlows
                for path = 1:nSP(flow)
                    if path ~= sol(flow)  % ---> Neighbor Exploration
                        auxSol = sol;
                        auxSol(flow) = path;
                        % ---> Calculate the load for the new solution
                        Loads = calculateLinkLoads(nNodes, Links, T, sP, auxSol);
                        auxLoad = max(max(Loads(:, 3:4)));

                        % Check if the new load is better
                        if auxLoad < bestLocalLoad
                            bestLocalLoad = auxLoad;
                            bestLocalSol = auxSol;
                        end
                    end
                end
            end

            % Update solution if a better local solution is found
            if bestLocalLoad < load
                load = bestLocalLoad;
                sol = bestLocalSol;
            else
                improved = false; % ---> Stop if no improvement is found
            end
        end

        % ---> Track the Best Solution Found
        noCycles = noCycles + 1;
        aux = aux + load; 

        if load < bestObjective
            bestSol = sol;
            bestObjective = load;
            bestTime = toc(t); % ---> Track the time when the best load was found
            bestSolCycle = noCycles;
        end
    end

    avObjective = aux / noCycles; 
end