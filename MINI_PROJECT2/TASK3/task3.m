%% Task3

%{
    UNICAST [S=2] 
        - protection 1:1 based on pair of link disjoint routing paths
            - to generate pairs : kShortestPathPairs
    UNICAST [S=1]
        - Single routing path

   ->USE HILL CLIMBING GREEDY RANDOMIZED
%}

%% a)

clear all
close all
clc
fprintf('\nAlinea a)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
Taux = zeros(1,4);

% Initialize variables to track the best solution
bestWll = inf;
bestNoCycles = 0;
bestTime = 0;
bestSol = 0;
% Add the time limit for hill climbing (30 seconds)
timeLimit = 60;
k= 12;

anycastNodes = [3, 10];
roundTripDelays = zeros(1, nFlows);
bestSolCycles = zeros(1, nFlows);
nCicles = zeros(1, nFlows);
bestSolTimes = zeros(1, nFlows);

for f = 1:nFlows
    if T(f,1) == 1 % ---> UNICAST SERVICE
        % Find k-shortest paths
        [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), k);
        
        % Prepare paths for Hill Climbing
        sP{f} = shortestPath;
        nSP(f) = length(totalCost);
        Taux(f,:) = T(f,2:5);
        
        % Detailed path information
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n',T(f,1), f);
        fprintf('Number of paths found: %d\n', nSP(f));
        fprintf('Path Costs (ms):\n');
        disp(totalCost * 1000);
        
        % Print path details
        %fprintf('Discovered Paths:\n');
        %for i = 1:nSP(f)
        %    fprintf('Path %d : ', i);
        %    disp(shortestPath{i});
        %end

        % HILL CLIMB OPTIMIZATION
        [bestSolCycle, bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
        
        % Optimization Results Logging
        fprintf('\n--- Hill Climbing Optimization Results ---\n');
        fprintf('Best Objective (max link load): %.2f Gbps\n', bestObjective);
        fprintf('Number of Optimization Cycles: %d\n', noCycles);
        fprintf('Average Objective: %.2f Gbps\n', avObjective);
        fprintf('Optimization Time: %.2f seconds\n', bestTime);
        
        bestSolTimes(f) = bestTime;
        nCicles(f) = noCycles;
        bestSolCycles(f) = bestSolCycle;
        
        
        % Path Selection
        chosenPathIndex = bestSol(f);
        chosenPath = shortestPath{chosenPathIndex};
        oneWayDelay = totalCost(chosenPathIndex);
        
        % Detailed Chosen Path Information
        fprintf('\n--- Chosen Path Details ---\n');
        fprintf('Chosen Path Index: %d\n', chosenPathIndex);
        fprintf('Chosen Path: %s \n', num2str(chosenPath));
        fprintf('One-way Propagation Delay: %.2f ms\n', oneWayDelay * 1000);
        fprintf('Round-trip Propagation Delay: %.2f ms\n', oneWayDelay * 2000);
        
        fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n',T(f,1), f);
        % Calculate and store round-trip delay
        roundTripDelays(f) = 2 * oneWayDelay * 1000;

    elseif T(f,1) == 2 % ---> UNICAST SERVICE WITH 1:1 PROTECTION
        % Generate Disjoint Path Pairs
        [firstPaths, secondPaths, totalPairCosts] = kShortestPathPairs(D, T(f,2), T(f,3), k);
        sP{1, f} = firstPaths;  % Working paths
        sP{2, f} = secondPaths; % Protection paths
        nSP(f) = length(totalPairCosts); % Number of valid path pairs
        Taux(f,:) = T(f,2:5);
        
        % Select the path pair with the maximum delay
        [~, selectedPathIndex] = max(totalPairCosts);
        selectedWorkingPath = sP{1, f}{selectedPathIndex};
        
         % Use kShortestPath to match the selected path
        [shortestPathTEST, totalCostTEST] = kShortestPath(D, T(f,2), T(f,3), k);
        matchedDelay = NaN; % Initialize delay value

        for i = 1:length(shortestPathTEST)
            if isequal(shortestPathTEST{i}, selectedWorkingPath)
                matchedDelay = totalCostTEST(i); % Get the corresponding delay
                break;
            end
        end

        if isnan(matchedDelay)
            error('Selected working path not found in kShortestPath results.');
        end
        

        roundTripDelays(f) = 2 * matchedDelay * 1000; % Propagation delay (round trip in ms)
    elseif T(f,1) == 3 % ---> ANYCAST SERVICE
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n', T(f,1), f);
        if ismember(T(f,2), anycastNodes)
            fprintf('\n\tSource node %d is already an anycast node\n', T(f,2));
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2); % ---> Source node is the anycast node
            roundTripDelays(f) = 0; % No delay since it's already the destination
        else
            
            fprintf('\n\tFinding paths to anycast nodes for Flow %d\n', f);
            fprintf('\tSource Node: %d\n', T(f,2));
            fprintf('\tCandidate Anycast Nodes: ');
            disp(anycastNodes);
            
            Taux(f,:) = T(f,2:5);
            minCost = inf;
            bestPath = []; % Variable to store the path with minimum cost
            for acNode = anycastNodes
                fprintf('\n\t--- Evaluating Anycast Node %d ---\n', acNode);

                % Compute k-shortest paths
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);
                
                fprintf('\tNumber of paths found: %d\n', length(totalCost));
                fprintf('\tPath Costs (ms):\n');
                disp(totalCost * 1000);

                % Find the minimum cost and corresponding path from the k options
                [minNodeCost, idx] = min(totalCost); % Get the minimum cost and its index
                fprintf('\tMinimum cost to Anycast Node %d: %.2f ms\n', acNode, minNodeCost * 1000);

                if minNodeCost < minCost
                    fprintf('\tUpdating best path with minimum cost to Anycast Node %d\n', acNode);
                    minCost = minNodeCost;          % Update minimum cost
                    bestPath = shortestPath{idx};  % Store the best path
                    Taux(f,2) = acNode;            % Update destination as the best anycast node
                end
            end
            
            % Update the shortest path and round-trip delay
            if isempty(bestPath)
                warning('No valid path found for Flow %d. Assigning Inf delay.', f);
                roundTripDelays(f) = inf; % Handle cases with no valid paths
                sP{f} = {}; % No valid path
                nSP(f) = 0;
                fprintf('\tNo valid path found. Round-trip Propagation Delay: Inf\n');
            else
                sP{f} = {bestPath}; % Store the best path
                nSP(f) = 1;
                roundTripDelays(f) = 2 * minCost * 1000; % Round-trip delay (in ms)
                fprintf('\n--- Chosen Path Details ---\n');
                fprintf('Chosen Path: %s \n', num2str(bestPath));
                fprintf('One-way Propagation Delay: %.2f ms\n', minCost * 1000);
                fprintf('Round-trip Propagation Delay: %.2f ms\n', roundTripDelays(f));
            end
        end
        fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n', T(f,1), f);
    end
end

% Calculate total cycles and best solution metrics
totalCycles = sum(bestSolCycles);
bestSolutionTime = min(besSolTimes);
%bestSolutionCycles = bestSolCycles(find(besSolTimes == bestSolutionTime, 1));

% Rest of the existing reporting code
udS1 = roundTripDelays(T(:,1) == 1);
udS2 = roundTripDelays(T(:,1) == 2);
adS3 = roundTripDelays(T(:,1) == 3);

fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("> Worst round-trip delay  \t= %.2f ms \n", max(udS1));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS1));

fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("> Worst round-trip delay  \t= %.2f ms \n", max(udS2));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS2));

fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(adS3));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(adS3));

fprintf("\n-----------------------| Hill Climbing Status\n")
fprintf('Anycast nodes  \t\t\t= %s\n', num2str(anycastNodes));
fprintf('Total number of cycles  \t= %d\n', totalCycles);
fprintf("\n-----------------------| Per-Flow Metrics\n")
fprintf("Flow x : best Time Solution | cycles for best time solution\n")

for f = 1:nFlows
    fprintf("Flow %.2d : %.2f s | %d \n", f, besSolTimes(f), bestSolCycles(f));
    %fprintf("Running time for best solution \t\t= %.2f s\n", besSolTimes(f));
    %fprintf("Number of cycles for best solution \t= %d\n", bestSolCycles(f));
end

fprintf('----------------------------------------------------[a. END]\n\n');