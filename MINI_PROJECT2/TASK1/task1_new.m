%% Task1

%% a)

clear all
close all
clc
fprintf('\nAlinea a)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
anycastNodes = [3, 10];
roundTripDelays = zeros(1, nFlows);
Taux = zeros(1,4);

k = 1;
for f=1:nFlows
    if T(f,1) == 1 || T(f,1) == 2 % ---> UNICAST SERVICE
        [shortestPath, totalCost] = kShortestPath(D,T(f,2),T(f,3),k);
        sP{f}= shortestPath;
        nSP(f)= length(totalCost); 
        Taux(f,:) = T(f,2:5);
        roundTripDelays(f) = 2 * totalCost * 1000; % ---> Ida e Volta (*2) e converter para ms (*1000)
    elseif T(f,1) == 3 % ---> ANYCAST SERVICE
        if ismember(T(f,2), anycastNodes)
            sP{f} = {T(f,2)};
            nSP(f) = 1;
            Taux(f,:) = T(f,2:5);
            Taux(f,2) = T(f,2); % ---> Nó origm do percurso
        else
            Taux(f,:) = T(f,2:5);
            minCost = inf;
            for acNode = anycastNodes
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, k);
                if totalCost < minCost
                    minCost = totalCost;          % Update custo min
                    sP{f} = shortestPath;         % Guardar 
                    nSP(f) = 1;
                    Taux(f,2) = acNode; % ---> Nó origm do percurso é o anyCast node
                end
            end
            % Calculate round-trip delay (ms)
            roundTripDelays(f) = 2 * minCost * 1000; % ---> Ida e Volta (*2) e converter para ms (*1000)
        end
    end
end

udS1 = roundTripDelays(T(:,1) == 1);
udS2 = roundTripDelays(T(:,1) == 2);
adS3 = roundTripDelays(T(:,1) == 3);

fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS1));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS1));
fprintf("\n")
fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS2));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS2));
fprintf("\n")
fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(adS3));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(adS3));
fprintf("\n")

fprintf('----------------------------------------------------[a. END]\n\n');

%% b)
fprintf('\nAlinea b)\n\n');

% Compute the link loads using the first (shortest) path of each flow:
sol= ones(1,nFlows); % Initialize vector all ones 
Loads= calculateLinkLoads(nNodes,Links,Taux,sP,sol);
% Determine the worst link load:
maxLoad= max(max(Loads(:,3:4)));

fprintf('Worst link load = %.2f Gbps\n\n', maxLoad);
for i = 1 : length(Loads)
    fprintf('{%d - %d}:\t%.2f\t%.2f\n', Loads(i), Loads(i+length(Loads)), Loads(i+length(Loads)*2), Loads(i+length(Loads)*3))
end

plotGraphWithLoadsDynamicColor(Nodes,Links,Loads,2) % ---> Ploting the graph

fprintf('----------------------------------------------------[b. END]\n\n');


%% c)

clear all
close all
clc
fprintf('\nAlinea c)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph

v = 2e5;
D = L/v; % atraso de propagação de cada ligação!
roundTripDelays = zeros(1, nFlows);
Taux = zeros(1,4);

% Initialize variables to track the best solution
bestWll = inf;
bestAnycastNodes = [];

% Try all possible combinations of 2 nodes
for n1 = 1:nNodes-1
    for n2 = n1+1:nNodes
        % Reset variables for this combination
        anycastNodes = [n1, n2];
        Taux = zeros(nFlows, 4);
        roundTripDelays = zeros(1, nFlows);
        sP = cell(1, nFlows);
        nSP = zeros(1, nFlows);
        
        % Process each flow
        for f = 1:nFlows
            if T(f,1) == 1 || T(f,1) == 2 % ---> [UNICAST SERVICE]
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), 1);
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);
                roundTripDelays(f) = 2 * totalCost * 1000; % ---> Ida e Volta (*2) e converter para ms (*1000)
            elseif T(f,1) == 3 % ---> ANYCAST SERVICE
                if ismember(T(f,2), anycastNodes)
                    sP{f} = {T(f,2)};
                    nSP(f) = 1;
                    Taux(f,:) = T(f,2:5);
                    Taux(f,2) = T(f,2); % ---> Nó origm do percurso
                else
                    Taux(f,:) = T(f,2:5);
                    minCost = inf;
                    for acNode = anycastNodes
                        [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, 1);
                        if totalCost < minCost
                            minCost = totalCost;
                            sP{f} = shortestPath;
                            nSP(f) = 1;
                            Taux(f,2) = acNode; % ---> Nó origm do percurso é o anyCast node
                        end
                    end
                    % Calculate round-trip delay (ms)
                    roundTripDelays(f) = 2 * minCost * 1000; % ---> Ida e Volta (*2) e converter para ms (*1000)
                end
            end
        end
        
        % Compute link loads
        sol = ones(1, nFlows);
        Loads = calculateLinkLoads(nNodes, Links, Taux, sP, sol);
        
        % Find worst link load
        maxLoad= max(max(Loads(:,3:4)));
        
        % Update best solution if current solution is better
        if maxLoad < bestWll
            bestWll = maxLoad;
            bestAnycastNodes = anycastNodes;
            bestRoundTripDelays = roundTripDelays;
        end
    end
end

udS1 = bestRoundTripDelays(T(:,1) == 1);
udS2 = bestRoundTripDelays(T(:,1) == 2);
adS3 = bestRoundTripDelays(T(:,1) == 3);

fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS1));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS1));
fprintf("\n")
fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS2));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS2));
fprintf("\n")
fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf('> Worst link load  \t\t= %.2f Gbps\n', bestWll);
fprintf('Best anycast nodes  \t\t= %s\n', num2str(bestAnycastNodes));
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(adS3));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(adS3));
fprintf("\n")


fprintf('----------------------------------------------------[c. END]\n\n');


%% d)

clear all
close all
clc
fprintf('\nAlinea d)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph
v = 2e5;
D = L/v; % propagation delay of each link

% Initialize variables to track the best solution
bestWorstAnycastDelay = inf;
bestAnycastNodes = [];

% Try all possible combinations of 2 nodes
for n1 = 1:nNodes-1
    for n2 = n1+1:nNodes
        % Reset variables for this combination
        anycastNodes = [n1, n2];
        Taux = zeros(nFlows, 4);
        roundTripDelays = zeros(1, nFlows);
        sP = cell(1, nFlows);
        nSP = zeros(1, nFlows);
        
        % Process each flow
        for f = 1:nFlows
            if T(f,1) == 1 || T(f,1) == 2 % UNICAST SERVICE
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), 1);
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);
                roundTripDelays(f) = 2 * totalCost * 1000; % Round-trip and convert to ms
            elseif T(f,1) == 3 % ANYCAST SERVICE
                if ismember(T(f,2), anycastNodes)
                    sP{f} = {T(f,2)};
                    nSP(f) = 1;
                    Taux(f,:) = T(f,2:5);
                    Taux(f,2) = T(f,2);
                else
                    Taux(f,:) = T(f,2:5);
                    minCost = inf;
                    for acNode = anycastNodes
                        [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, 1);
                        if totalCost < minCost
                            minCost = totalCost;
                            sP{f} = shortestPath;
                            nSP(f) = 1;
                            Taux(f,2) = acNode;
                        end
                    end
                    % Calculate round-trip delay (ms)
                    roundTripDelays(f) = 2 * minCost * 1000;
                end
            end
        end
        
        % Compute link loads
        sol = ones(1, nFlows);
        Loads = calculateLinkLoads(nNodes, Links, Taux, sP, sol);
        
        % Find worst link load
        maxLoad= max(max(Loads(:,3:4)));
        
        % Find worst anycast service round-trip delay
        anycastDelays = roundTripDelays(T(:,1) == 3);
        worstAnycastDelay = max(anycastDelays);
        
        % Update best solution if current solution has lower worst anycast delay
        if worstAnycastDelay < bestWorstAnycastDelay
            bestWorstAnycastDelay = worstAnycastDelay;
            bestAnycastNodes = anycastNodes;
            bestRoundTripDelays = roundTripDelays;
            bestMaxLoad = maxLoad;
        end
    end
end


udS1 = bestRoundTripDelays(T(:,1) == 1);
udS2 = bestRoundTripDelays(T(:,1) == 2);
adS3 = bestRoundTripDelays(T(:,1) == 3);

fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS1));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS1));
fprintf("\n")
fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS2));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS2));
fprintf("\n")
fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf('Worst link load  \t\t= %.2f Gbps\n', bestMaxLoad);
fprintf('Best anycast nodes  \t\t= %s\n', num2str(bestAnycastNodes));
fprintf("> Worst round-trip delay  \t= %.2f ms \n", max(adS3));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(adS3));
fprintf("\n")



fprintf('----------------------------------------------------[d. END]\n\n');

%% e)

clear all
close all
clc
fprintf('\nAlinea e)\n\n');

load('InputDataProject2.mat')
nNodes= size(Nodes,1);
nFlows= size(T,1);

%plotGraph(Nodes,Links,1) % ---> Ploting the graph
v = 2e5;
D = L/v; % propagation delay of each link

% Initialize variables to track the best solution
bestAvgAnycastDelay = inf;
bestAnycastNodes = [];

% Try all possible combinations of 2 nodes
for n1 = 1:nNodes-1
    for n2 = n1+1:nNodes
        % Reset variables for this combination
        anycastNodes = [n1, n2];
        Taux = zeros(nFlows, 4);
        roundTripDelays = zeros(1, nFlows);
        sP = cell(1, nFlows);
        nSP = zeros(1, nFlows);
        
        % Process each flow
        for f = 1:nFlows
            if T(f,1) == 1 || T(f,1) == 2 % UNICAST SERVICE
                [shortestPath, totalCost] = kShortestPath(D, T(f,2), T(f,3), 1);
                sP{f} = shortestPath;
                nSP(f) = length(totalCost);
                Taux(f,:) = T(f,2:5);
                roundTripDelays(f) = 2 * totalCost * 1000; % Round-trip and convert to ms
            elseif T(f,1) == 3 % ANYCAST SERVICE
                if ismember(T(f,2), anycastNodes)
                    sP{f} = {T(f,2)};
                    nSP(f) = 1;
                    Taux(f,:) = T(f,2:5);
                    Taux(f,2) = T(f,2);
                else
                    Taux(f,:) = T(f,2:5);
                    minCost = inf;
                    for acNode = anycastNodes
                        [shortestPath, totalCost] = kShortestPath(D, T(f,2), acNode, 1);
                        if totalCost < minCost
                            minCost = totalCost;
                            sP{f} = shortestPath;
                            nSP(f) = 1;
                            Taux(f,2) = acNode;
                        end
                    end
                    % Calculate round-trip delay (ms)
                    roundTripDelays(f) = 2 * minCost * 1000;
                end
            end
        end
        
        % Compute link loads
        sol = ones(1, nFlows);
        Loads = calculateLinkLoads(nNodes, Links, Taux, sP, sol);
        
        % Find worst link load
        maxLoad= max(max(Loads(:,3:4)));
        
        % Find worst anycast service round-trip delay
        anycastDelays = roundTripDelays(T(:,1) == 3);
        avgAnycastDelay = mean(anycastDelays);
        
        % Update best solution if current solution has lower worst anycast delay
        if avgAnycastDelay < bestAvgAnycastDelay
            bestAvgAnycastDelay = avgAnycastDelay;
            bestAnycastNodes = anycastNodes;
            bestRoundTripDelays = roundTripDelays;
            bestMaxLoad = maxLoad;
        end
    end
end


udS1 = bestRoundTripDelays(T(:,1) == 1);
udS2 = bestRoundTripDelays(T(:,1) == 2);
adS3 = bestRoundTripDelays(T(:,1) == 3);

fprintf("\n-----------------------| Unicast Service S = 1\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS1));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS1));
fprintf("\n")
fprintf("\n-----------------------| Unicast Service S = 2\n")
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(udS2));
fprintf("Average round-trip delay  \t= %.2f ms \n", mean(udS2));
fprintf("\n")
fprintf("\n-----------------------| Anycast Service S = 3\n")
fprintf('Worst link load  \t\t= %.2f Gbps\n', bestMaxLoad);
fprintf('Best anycast nodes  \t\t= %s\n', num2str(bestAnycastNodes));
fprintf("Worst round-trip delay  \t= %.2f ms \n", max(adS3));
fprintf("> Average round-trip delay  \t= %.2f ms \n", mean(adS3));
fprintf("\n")


fprintf('----------------------------------------------------[e. END]\n\n');