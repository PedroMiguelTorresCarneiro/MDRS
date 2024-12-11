%% Task2

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
bestNoCycles = 0;
bestTime = 0;
bestSol = 0;
% Add the time limit for hill climbing (30 seconds)
timeLimit = 30;
k= 6;

anycastNodes = [3, 10];
roundTripDelays = zeros(1, nFlows);
besSolTimes = zeros(1, nFlows);
bestSolCycles = zeros(1, nFlows);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % Unicast services
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
        [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
        
        % Optimization Results Logging
        fprintf('\n--- Hill Climbing Optimization Results ---\n');
        fprintf('Best Objective (max link load): %.2f Gbps\n', bestObjective);
        fprintf('Number of Optimization Cycles: %d\n', noCycles);
        fprintf('Average Objective: %.2f Gbps\n', avObjective);
        fprintf('Optimization Time: %.2f seconds\n', bestTime);
        
        besSolTimes(f) = bestTime;
        bestSolCycles(f) = noCycles;

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

    elseif T(f,1) == 3 % Anycast service
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n',T(f,1), f);
        if ismember(T(f,2), anycastNodes)
            fprintf('\n\tSource node %d is already an anycast node\n', T(f,2));
            sP{f} = {T(f,2)};
            nSP(f) = 1;
        else
            minWorstLinkLoad = inf;
            bestAnycastPath = [];
            bestAnycastNode = [];
            bestChosenPathIndex = [];

            fprintf('\n[ANYCAST SERVICE] Finding Best Anycast Node for Flow %d\n', f);
            fprintf('Source Node: %d\n', T(f,2));
            fprintf('Candidate Anycast Nodes: ');
            disp(anycastNodes);

            for acNode = anycastNodes
                fprintf('\n--- Evaluating Anycast Node %d ---\n', acNode);

                % Find k-shortest paths from source to this anycast node
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);

                % Prepare flow-specific parameters
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);

                % HILL CLIMB OPTIMIZATION
                [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
                
                % Debug prints for paths and optimization
                fprintf('Number of paths found: %d\n', length(totalCost));
                fprintf('Path Costs (ms):\n');
                disp(totalCost * 1000);
        
                % Select the best path for this anycast node
                chosenPathIndex = bestSol(f);
                currentCost = totalCost(chosenPathIndex);
              
                fprintf('Chosen Path Index: %d\n', chosenPathIndex);
                fprintf('Chosen Path: ');
                disp(shortestPath{chosenPathIndex});
                fprintf('One-way Propagation Delay: %.2f ms\n', currentCost * 1000);
                fprintf('Round-trip Propagation Delay: %.2f ms\n', currentCost * 2000);
                fprintf('Worst Link Load: %.2f Gbps\n', bestObjective);

                chosenPathIndex = bestSol(f); % Index of the chosen path from Hill Climbing
                roundTripDelays(f) = 2 * totalCost(chosenPathIndex) * 1000; % Propagation delay (round trip in ms)

                % Update the best path based on worst link load
                if bestObjective < minWorstLinkLoad
                    fprintf('\n\t**** New Best Path Found! ****\n');
                    fprintf('\tImproved Worst Link Load: %.2f Gbps (Previous: %.2f Gbps)\n', bestObjective, minWorstLinkLoad);
                    
                    minWorstLinkLoad = bestObjective;
                    bestAnycastPath = shortestPath{chosenPathIndex};
                    bestAnycastNode = acNode;
                    bestChosenPathIndex = chosenPathIndex;
                    
                    besSolTimes(f) = bestTime;
                    bestSolCycles(f) = noCycles;

                    % Additional logging for optimization improvement
                    fprintf('\tChosen Path Details:\n');
                    fprintf('\tAnycast Node: %d\n', bestAnycastNode);
                    fprintf('\tPath: ');
                    disp(bestAnycastPath);
                    fprintf('\tWorst Link Load: %.2f Gbps\n', minWorstLinkLoad);
                end
            end
            % Calculate and store round-trip delay
            roundTripDelays(f) = 2 * totalCost(bestChosenPathIndex) * 1000; % Round trip

            % Final summary
            fprintf('\n\n[FINAL ANYCAST SELECTION for Flow %d]\n', f);
            fprintf('Best Anycast Node: %d\n', bestAnycastNode);
            fprintf('Best Path: ');
            disp(bestAnycastPath);
            fprintf('Worst Link Load: %.2f Gbps\n', minWorstLinkLoad);
            fprintf('Round-trip Propagation Delay: %.2f ms\n\n', roundTripDelays(f));
            fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n',T(f,1), f);
        end
    end
end

% Calculate total cycles and best solution metrics
totalCycles = sum(bestSolCycles);
bestSolutionTime = min(besSolTimes);
bestSolutionCycles = bestSolCycles(find(besSolTimes == bestSolutionTime, 1));

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
    fprintf("Flow %d:\n", f);
    fprintf("Running time for best solution \t\t= %.2f s\n", besSolTimes(f));
    fprintf("Number of cycles for best solution \t= %d\n", bestSolCycles(f));
end

fprintf('----------------------------------------------------[a. END]\n\n');

%% b)

clear all
close all
clc
fprintf('\nAlinea b)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
Taux = zeros(1,4);

% Initialize variables to track the best solution
bestNoCycles = 0;
bestTime = 0;
bestSol = 0;
% Add the time limit for hill climbing (30 seconds)
timeLimit = 30;
k= 6;

anycastNodes = [1, 6];
roundTripDelays = zeros(1, nFlows);
besSolTimes = zeros(1, nFlows);
bestSolCycles = zeros(1, nFlows);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % Unicast services
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
        [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
        
        % Optimization Results Logging
        fprintf('\n--- Hill Climbing Optimization Results ---\n');
        fprintf('Best Objective (max link load): %.2f Gbps\n', bestObjective);
        fprintf('Number of Optimization Cycles: %d\n', noCycles);
        fprintf('Average Objective: %.2f Gbps\n', avObjective);
        fprintf('Optimization Time: %.2f seconds\n', bestTime);
        
        besSolTimes(f) = bestTime;
        bestSolCycles(f) = noCycles;

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

    elseif T(f,1) == 3 % Anycast service
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n',T(f,1), f);
        if ismember(T(f,2), anycastNodes)
            fprintf('\n\tSource node %d is already an anycast node\n', T(f,2));
            sP{f} = {T(f,2)};
            nSP(f) = 1;
        else
            minWorstLinkLoad = inf;
            bestAnycastPath = [];
            bestAnycastNode = [];
            bestChosenPathIndex = [];

            fprintf('\n[ANYCAST SERVICE] Finding Best Anycast Node for Flow %d\n', f);
            fprintf('Source Node: %d\n', T(f,2));
            fprintf('Candidate Anycast Nodes: ');
            disp(anycastNodes);

            for acNode = anycastNodes
                fprintf('\n--- Evaluating Anycast Node %d ---\n', acNode);

                % Find k-shortest paths from source to this anycast node
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);

                % Prepare flow-specific parameters
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);

                % HILL CLIMB OPTIMIZATION
                [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
                
                % Debug prints for paths and optimization
                fprintf('Number of paths found: %d\n', length(totalCost));
                fprintf('Path Costs (ms):\n');
                disp(totalCost * 1000);
        
                % Select the best path for this anycast node
                chosenPathIndex = bestSol(f);
                currentCost = totalCost(chosenPathIndex);
              
                fprintf('Chosen Path Index: %d\n', chosenPathIndex);
                fprintf('Chosen Path: ');
                disp(shortestPath{chosenPathIndex});
                fprintf('One-way Propagation Delay: %.2f ms\n', currentCost * 1000);
                fprintf('Round-trip Propagation Delay: %.2f ms\n', currentCost * 2000);
                fprintf('Worst Link Load: %.2f Gbps\n', bestObjective);

                chosenPathIndex = bestSol(f); % Index of the chosen path from Hill Climbing
                roundTripDelays(f) = 2 * totalCost(chosenPathIndex) * 1000; % Propagation delay (round trip in ms)

                % Update the best path based on worst link load
                if bestObjective < minWorstLinkLoad
                    fprintf('\n\t**** New Best Path Found! ****\n');
                    fprintf('\tImproved Worst Link Load: %.2f Gbps (Previous: %.2f Gbps)\n', bestObjective, minWorstLinkLoad);
                    
                    minWorstLinkLoad = bestObjective;
                    bestAnycastPath = shortestPath{chosenPathIndex};
                    bestAnycastNode = acNode;
                    bestChosenPathIndex = chosenPathIndex;
                    
                    besSolTimes(f) = bestTime;
                    bestSolCycles(f) = noCycles;

                    % Additional logging for optimization improvement
                    fprintf('\tChosen Path Details:\n');
                    fprintf('\tAnycast Node: %d\n', bestAnycastNode);
                    fprintf('\tPath: ');
                    disp(bestAnycastPath);
                    fprintf('\tWorst Link Load: %.2f Gbps\n', minWorstLinkLoad);
                end
            end
            % Calculate and store round-trip delay
            roundTripDelays(f) = 2 * totalCost(bestChosenPathIndex) * 1000; % Round trip

            % Final summary
            fprintf('\n\n[FINAL ANYCAST SELECTION for Flow %d]\n', f);
            fprintf('Best Anycast Node: %d\n', bestAnycastNode);
            fprintf('Best Path: ');
            disp(bestAnycastPath);
            fprintf('Worst Link Load: %.2f Gbps\n', minWorstLinkLoad);
            fprintf('Round-trip Propagation Delay: %.2f ms\n\n', roundTripDelays(f));
            fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n',T(f,1), f);
        end
    end
end

% Calculate total cycles and best solution metrics
totalCycles = sum(bestSolCycles);
bestSolutionTime = min(besSolTimes);
bestSolutionCycles = bestSolCycles(find(besSolTimes == bestSolutionTime, 1));

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
    fprintf("Flow %d:\n", f);
    fprintf("Running time for best solution \t\t= %.2f s\n", besSolTimes(f));
    fprintf("Number of cycles for best solution \t= %d\n", bestSolCycles(f));
end

fprintf('----------------------------------------------------[b. END]\n\n');


%% c)

clear all
close all
clc
fprintf('\nAlinea c)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
Taux = zeros(1,4);

% Initialize variables to track the best solution
bestNoCycles = 0;
bestTime = 0;
bestSol = 0;
% Add the time limit for hill climbing (30 seconds)
timeLimit = 30;
k= 6;

anycastNodes = [4, 12];
roundTripDelays = zeros(1, nFlows);
besSolTimes = zeros(1, nFlows);
bestSolCycles = zeros(1, nFlows);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % Unicast services
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
        [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
        
        % Optimization Results Logging
        fprintf('\n--- Hill Climbing Optimization Results ---\n');
        fprintf('Best Objective (max link load): %.2f Gbps\n', bestObjective);
        fprintf('Number of Optimization Cycles: %d\n', noCycles);
        fprintf('Average Objective: %.2f Gbps\n', avObjective);
        fprintf('Optimization Time: %.2f seconds\n', bestTime);
        
        besSolTimes(f) = bestTime;
        bestSolCycles(f) = noCycles;

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

    elseif T(f,1) == 3 % Anycast service
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n',T(f,1), f);
        if ismember(T(f,2), anycastNodes)
            fprintf('\n\tSource node %d is already an anycast node\n', T(f,2));
            sP{f} = {T(f,2)};
            nSP(f) = 1;
        else
            minWorstLinkLoad = inf;
            bestAnycastPath = [];
            bestAnycastNode = [];
            bestChosenPathIndex = [];

            fprintf('\n[ANYCAST SERVICE] Finding Best Anycast Node for Flow %d\n', f);
            fprintf('Source Node: %d\n', T(f,2));
            fprintf('Candidate Anycast Nodes: ');
            disp(anycastNodes);

            for acNode = anycastNodes
                fprintf('\n--- Evaluating Anycast Node %d ---\n', acNode);

                % Find k-shortest paths from source to this anycast node
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);

                % Prepare flow-specific parameters
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);

                % HILL CLIMB OPTIMIZATION
                [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
                
                % Debug prints for paths and optimization
                fprintf('Number of paths found: %d\n', length(totalCost));
                fprintf('Path Costs (ms):\n');
                disp(totalCost * 1000);
        
                % Select the best path for this anycast node
                chosenPathIndex = bestSol(f);
                currentCost = totalCost(chosenPathIndex);
              
                fprintf('Chosen Path Index: %d\n', chosenPathIndex);
                fprintf('Chosen Path: ');
                disp(shortestPath{chosenPathIndex});
                fprintf('One-way Propagation Delay: %.2f ms\n', currentCost * 1000);
                fprintf('Round-trip Propagation Delay: %.2f ms\n', currentCost * 2000);
                fprintf('Worst Link Load: %.2f Gbps\n', bestObjective);

                chosenPathIndex = bestSol(f); % Index of the chosen path from Hill Climbing
                roundTripDelays(f) = 2 * totalCost(chosenPathIndex) * 1000; % Propagation delay (round trip in ms)

                % Update the best path based on worst link load
                if bestObjective < minWorstLinkLoad
                    fprintf('\n\t**** New Best Path Found! ****\n');
                    fprintf('\tImproved Worst Link Load: %.2f Gbps (Previous: %.2f Gbps)\n', bestObjective, minWorstLinkLoad);
                    
                    minWorstLinkLoad = bestObjective;
                    bestAnycastPath = shortestPath{chosenPathIndex};
                    bestAnycastNode = acNode;
                    bestChosenPathIndex = chosenPathIndex;
                    
                    besSolTimes(f) = bestTime;
                    bestSolCycles(f) = noCycles;

                    % Additional logging for optimization improvement
                    fprintf('\tChosen Path Details:\n');
                    fprintf('\tAnycast Node: %d\n', bestAnycastNode);
                    fprintf('\tPath: ');
                    disp(bestAnycastPath);
                    fprintf('\tWorst Link Load: %.2f Gbps\n', minWorstLinkLoad);
                end
            end
            % Calculate and store round-trip delay
            roundTripDelays(f) = 2 * totalCost(bestChosenPathIndex) * 1000; % Round trip

            % Final summary
            fprintf('\n\n[FINAL ANYCAST SELECTION for Flow %d]\n', f);
            fprintf('Best Anycast Node: %d\n', bestAnycastNode);
            fprintf('Best Path: ');
            disp(bestAnycastPath);
            fprintf('Worst Link Load: %.2f Gbps\n', minWorstLinkLoad);
            fprintf('Round-trip Propagation Delay: %.2f ms\n\n', roundTripDelays(f));
            fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n',T(f,1), f);
        end
    end
end

% Calculate total cycles and best solution metrics
totalCycles = sum(bestSolCycles);
bestSolutionTime = min(besSolTimes);
bestSolutionCycles = bestSolCycles(find(besSolTimes == bestSolutionTime, 1));

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
    fprintf("Flow %d:\n", f);
    fprintf("Running time for best solution \t\t= %.2f s\n", besSolTimes(f));
    fprintf("Number of cycles for best solution \t= %d\n", bestSolCycles(f));
end

fprintf('----------------------------------------------------[c. END]\n\n');


%% d)

clear all
close all
clc
fprintf('\nAlinea d)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nLinks= size(Links,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
Taux = zeros(1,4);

% Initialize variables to track the best solution
bestNoCycles = 0;
bestTime = 0;
bestSol = 0;
% Add the time limit for hill climbing (30 seconds)
timeLimit = 30;
k= 6;

anycastNodes = [5, 14];
roundTripDelays = zeros(1, nFlows);
besSolTimes = zeros(1, nFlows);
bestSolCycles = zeros(1, nFlows);

for f = 1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % Unicast services
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
        [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
        
        % Optimization Results Logging
        fprintf('\n--- Hill Climbing Optimization Results ---\n');
        fprintf('Best Objective (max link load): %.2f Gbps\n', bestObjective);
        fprintf('Number of Optimization Cycles: %d\n', noCycles);
        fprintf('Average Objective: %.2f Gbps\n', avObjective);
        fprintf('Optimization Time: %.2f seconds\n', bestTime);
        
        besSolTimes(f) = bestTime;
        bestSolCycles(f) = noCycles;

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

    elseif T(f,1) == 3 % Anycast service
        fprintf('\n[SERVICE %d]---------- Path Discovery Flow %d ----------[ BEGIN ] \n',T(f,1), f);
        if ismember(T(f,2), anycastNodes)
            fprintf('\n\tSource node %d is already an anycast node\n', T(f,2));
            sP{f} = {T(f,2)};
            nSP(f) = 1;
        else
            minWorstLinkLoad = inf;
            bestAnycastPath = [];
            bestAnycastNode = [];
            bestChosenPathIndex = [];

            fprintf('\n[ANYCAST SERVICE] Finding Best Anycast Node for Flow %d\n', f);
            fprintf('Source Node: %d\n', T(f,2));
            fprintf('Candidate Anycast Nodes: ');
            disp(anycastNodes);

            for acNode = anycastNodes
                fprintf('\n--- Evaluating Anycast Node %d ---\n', acNode);

                % Find k-shortest paths from source to this anycast node
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);

                % Prepare flow-specific parameters
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);

                % HILL CLIMB OPTIMIZATION
                [bestSol, bestObjective, noCycles, avObjective, bestTime] = HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);
                
                % Debug prints for paths and optimization
                fprintf('Number of paths found: %d\n', length(totalCost));
                fprintf('Path Costs (ms):\n');
                disp(totalCost * 1000);
        
                % Select the best path for this anycast node
                chosenPathIndex = bestSol(f);
                currentCost = totalCost(chosenPathIndex);
              
                fprintf('Chosen Path Index: %d\n', chosenPathIndex);
                fprintf('Chosen Path: ');
                disp(shortestPath{chosenPathIndex});
                fprintf('One-way Propagation Delay: %.2f ms\n', currentCost * 1000);
                fprintf('Round-trip Propagation Delay: %.2f ms\n', currentCost * 2000);
                fprintf('Worst Link Load: %.2f Gbps\n', bestObjective);

                chosenPathIndex = bestSol(f); % Index of the chosen path from Hill Climbing
                roundTripDelays(f) = 2 * totalCost(chosenPathIndex) * 1000; % Propagation delay (round trip in ms)

                % Update the best path based on worst link load
                if bestObjective < minWorstLinkLoad
                    fprintf('\n\t**** New Best Path Found! ****\n');
                    fprintf('\tImproved Worst Link Load: %.2f Gbps (Previous: %.2f Gbps)\n', bestObjective, minWorstLinkLoad);
                    
                    minWorstLinkLoad = bestObjective;
                    bestAnycastPath = shortestPath{chosenPathIndex};
                    bestAnycastNode = acNode;
                    bestChosenPathIndex = chosenPathIndex;
                    
                    besSolTimes(f) = bestTime;
                    bestSolCycles(f) = noCycles;

                    % Additional logging for optimization improvement
                    fprintf('\tChosen Path Details:\n');
                    fprintf('\tAnycast Node: %d\n', bestAnycastNode);
                    fprintf('\tPath: ');
                    disp(bestAnycastPath);
                    fprintf('\tWorst Link Load: %.2f Gbps\n', minWorstLinkLoad);
                end
            end
            % Calculate and store round-trip delay
            roundTripDelays(f) = 2 * totalCost(bestChosenPathIndex) * 1000; % Round trip

            % Final summary
            fprintf('\n\n[FINAL ANYCAST SELECTION for Flow %d]\n', f);
            fprintf('Best Anycast Node: %d\n', bestAnycastNode);
            fprintf('Best Path: ');
            disp(bestAnycastPath);
            fprintf('Worst Link Load: %.2f Gbps\n', minWorstLinkLoad);
            fprintf('Round-trip Propagation Delay: %.2f ms\n\n', roundTripDelays(f));
            fprintf('\n[SERVICE %d]---------- Flow %d ----------[ END ] \n',T(f,1), f);
        end
    end
end

% Calculate total cycles and best solution metrics
totalCycles = sum(bestSolCycles);
bestSolutionTime = min(besSolTimes);
bestSolutionCycles = bestSolCycles(find(besSolTimes == bestSolutionTime, 1));

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
    fprintf("Flow %d:\n", f);
    fprintf("Running time for best solution \t\t= %.2f s\n", besSolTimes(f));
    fprintf("Number of cycles for best solution \t= %d\n", bestSolCycles(f));
end

fprintf('----------------------------------------------------[d. END]\n\n');

