%% Task 2 %% a)
clear all 
close all 
clc  

% Load input data 
load('InputDataProject2.mat')  

% Debug print input data
fprintf('Loaded Input Data:\n');
fprintf('Number of Nodes: %d\n', size(Nodes, 1));
fprintf('Number of Links: %d\n', size(Links, 1));
fprintf('Number of Flows: %d\n', size(T, 1));

% Initialize network parameters 
nNodes = size(Nodes, 1); 
nLinks = size(Links, 1); 
nFlows = size(T, 1);  

% Propagation velocity 
v = 2e5; 
D = L/v; % Propagation delay for each link  

% Anycast nodes 
anycastNodes = [3, 10];  
fprintf('Anycast Nodes: %s\n', mat2str(anycastNodes));

% Initialize result storage variables 
bestWll = 0; 
bestAnycastNodes = anycastNodes; 
bestRoundTripDelays = zeros(1, nFlows); 
bestSolutions = cell(1, nFlows); 
roundTripDelays = zeros(1, nFlows);  

% Time limit for hill climbing algorithm 
timeLimit = 30; % 1 second 
k = 6; % Number of shortest paths to consider  

% Reset flow-specific variables     
sP = cell(1, nFlows);
nSP = zeros(1, nFlows);

% Process each flow 
for f = 1:nFlows     
    fprintf('\n--- Processing Flow %d ---\n', f);
    
    % Debug print flow details
    fprintf('SERVICE: %d\n', T(f, 1));
    fprintf('Source: %d, Destination: %d\n', T(f, 2), T(f, 3));
    
    % Handle different service types     
    if T(f, 1) == 1 || T(f, 1) == 2 % UNICAST SERVICE            
        % Find k shortest paths             
        [shortestPaths, totalCosts] = kShortestPath(D, T(f,2), T(f,3), k);
        %disp(shortestPaths);
        % Debug print unicast path details
        fprintf('Unicast - Number of Paths Found: %d\n', length(shortestPaths));
        for p = 1:length(shortestPaths)
            fprintf('Path %d Cost: %.2f\n', p, totalCosts(p)*1000);
        end
        
        % Store paths and number of paths             
        sP{f} = shortestPaths;
        nSP(f) = length(totalCosts);
        Taux(f,:) = T(f,2:5);

    elseif T(f, 1) == 3 % ANYCAST SERVICE             
        if ismember(T(f,2), anycastNodes)                
            % Source is already an anycast node                
            sP{f} = {T(f,2)};                
            nSP(f) = 1;                
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2); % ---> Nó origm do percurso
            
            fprintf('Source is already an anycast node: %d\n', T(f,2));
        else                
            % Find the nearest anycast node                
            Taux(f,:) = T(f,2:5);
            minCost = inf;      
            
            fprintf('Finding nearest anycast node for source %d\n', T(f,2));
            
            for acNode = anycastNodes                    
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, 1);
                fprintf('Anycast node %d - Path Cost: %.2f mas\n', acNode, totalCost*1000);
                %disp(shortestPath)
                if totalCost < minCost                        
                    minCost = totalCost;                        
                    sP{f} = shortestPath;                        
                    nSP(f) = 1;
                    Taux(f,2) = acNode;
                    bestAnycastNode = acNode;                    
                end                 
            end
            
            fprintf('\nBest Anycast Node: %d, Minimum Cost: %.2f ms\n\n', bestAnycastNode, minCost*1000);
        end
    end          
end

% Run Hill Climbing Optimization     
fprintf('Running Hill Climbing Optimization...\n');
[bestSolCycle, bestSol, bestObjective, noCycles, avObjective, bestTime] = ...
    HillClimbGreedyAlgorithm(nNodes, Links, Taux, sP, nSP, timeLimit);

% Debug print hill climbing results
fprintf('total nº of cycles: %d\n', noCycles);
fprintf('Time of the best Solution: %.2f ms\n', bestTime*1000);
fprintf('Cycle of the best Solution: %d\n', bestSolCycle);

fprintf('Best Objective (Loads): %.2f Gbps\n', bestObjective);
fprintf('Average Objective: %.2f Gbps\n', avObjective);

solutions = cell(1, nFlows);

for p = 1:nFlows
    bestPathIndex = bestSol(p);
    solutions{p} = sP{p}{bestPathIndex}; % Note the double {} since sP is a cell array of cell arrays
end

% Initialize oneWayDelays to store the delay for each solution path
oneWayDelays = zeros(1, length(solutions));

% Iterate through each path in the solutions array
for i = 1:length(solutions)
    % Check if the solution is not empty
    if ~isempty(solutions{i})
        % Calculate the delay for the current path
        oneWayDelays(i) = calculatePathDelay(solutions{i}, D);
    else
        % If the solution is empty, set the delay to Inf or 0
        oneWayDelays(i) = Inf; % or 0, depending on how you want to handle empty paths
    end
end

% Initialize arrays to store round-trip delays for each service
s1rtd = []; % For service type 1
s2rtd = []; % For service type 2
s3rtd = []; % For service type 3

% Loop through all flows
for p = 1:nFlows
    roundTripDelay = oneWayDelays(p) * 2000; % Calculate round-trip delay in ms
    
    if T(p, 1) == 1
        % For service type 1
        s1rtd = [s1rtd, roundTripDelay];
    elseif T(p, 1) == 2
        % For service type 2
        s2rtd = [s2rtd, roundTripDelay];
    elseif T(p, 1) == 3
        % For service type 3
        s3rtd = [s3rtd, roundTripDelay];
    end
end


fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(s1rtd));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(s1rtd));
fprintf("\n")
fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(s2rtd));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(s2rtd));
fprintf("\n")
fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(s3rtd));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(s3rtd));
fprintf("\n")

% Compute and plot the link loads using the optimized solution
%Loads = calculateLinkLoads(nNodes, Links, Taux, sP, bestSol);
%plotGraphWithLoadsDynamicColor(Nodes, Links, Loads, 2); % Plot graph with loads
%fprintf('Graph with dynamic loads plotted.\n');

for p = 1:nFlows
    fprintf('\nFlow %d --> %s \nOneWay Delay : %.2f | Roud-Trip Delay : %.2f\n\n', p, num2str(solutions{p}), oneWayDelays(p)*1000, oneWayDelays(p)*2000);
end



fprintf('----------------------------------------------------[a. END]\n\n');
