%{
    In this task, use Sim2 developed in Task 6 of the Practical Guide. Consider always the capacity
    of the link C = 10 Mbps and the size of the queue f = 10.000 Bytes. When performance
    parameters are estimated by simulation, present the results based on 20 runs of the simulator
    (with a stopping criterion of P = 100.000 on each run) and with 90% confidence intervals.
%}

%% 1.a)
%{
    Estimate by simulation the average packet delay and the average packet loss parameters 
    when the bit error rate of the link is b = 10-6 and for the arrival rate values
    \lamdba = 1500, 1600, 1700, 1800 and 1900 pps. 
    Plot the results in bar charts with the confidence intervals in error bars1. 
    
    Justify the results and draw all relevant conclusions.

    1 - https://www.mathworks.com/help/matlab/creating_plots/bar-chart-with-error-bars.html
%}

% lambda,C,f,P,b

% Parameters
C       = 10; % ------------> Mbps
f       = 10000; % ---------> Bytes
P       = 100000; % --------> Stopping criterion
b       = 10^-6; % ---------> Bit error rate
N       = 20; % ------------> Number of runs
alfa    = 0.1; % -----------> Confidence level

% Arrival rate values
lambda  = [1500, 1600, 1700, 1800, 1900]; % pps

% Pre-allocation
PL      = zeros(N, length(lambda)); % ---> vector PL to store all the packet loss values
APD     = zeros(N, length(lambda)); % ---> vector APD to store all the average packet delay values

% Iterate over the arrival rate values (lambda)
for j = 1:length(lambda)
    % Simulation loop
    for i= 1:N % ---> Number of runs
        [PL(i,j), APD(i,j), ~, ~] = Sim2(lambda(j), C, f, P, b);
    end
end


% Average packet loss
media_PL = mean(PL); % ----> Average of the average packet loss
term_PL = norminv(1-alfa/2)*sqrt(var(PL)/N); % ----> Confidence interval
errlow_PL = media_PL - term_PL; % ----> Lower error bar
errhigh_PL = media_PL + term_PL; % ----> Higher error bar

% Average packet delay
media_APD = mean(APD); % ----> Average of the average packet delay
term_APD = norminv(1-alfa/2)*sqrt(var(APD)/N); % ----> Confidence interval
errLow_APD = media_APD - term_APD; % ----> Lower error bar
errHigh_APD = media_APD + term_APD; % ----> Higher error bar


% Display results
for j = 1:length(lambda)
    fprintf('For lambda = %d pps:\n', lambda(j));
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL(j), term_PL(j));
    fprintf('Average packet delay: %.2f +- %.2f\n\n', media_APD(j), term_APD(j));
end

% Plot PACKE LOSS
figure;
bar(lambda, media_PL);
hold on;

er_PL = errorbar(lambda, media_PL, media_PL - errlow_PL, errhigh_PL - media_PL); % ----> Error bars
er_PL.Color = [0 0 0];  % ----> Black
er_PL.LineStyle = 'none'; % ----> No line
title('Average Packet Loss');
xlabel('Arrival rate (pps)');
ylabel('Packet loss (%)');
grid on;
hold off;

% Plot AVERAGE PACKET DELAY
figure;
bar(lambda, media_APD);
hold on;

er_APD = errorbar(lambda, media_APD, media_APD - errLow_APD, errHigh_APD - media_APD); % ----> Error bars
er_APD.Color = [0 0 0];  % ----> Black
er_APD.LineStyle = 'none'; % ----> No line
title('Average Packet Delay');
xlabel('Arrival rate (pps)');
ylabel('Packet delay (ms)');
grid on;
hold off;


%% 1b)
%{
    Repeat experiment 1.a considering now a bit error rate
    b = 10-4. Justify the differences between these results and the results of experiment 1.a
    and draw all relevant conclusions.
%}

b       = 10^-4; % ---------> Bit error rate

% Iterate over the arrival rate values (lambda)
for j = 1:length(lambda)
    % Simulation loop
    for i= 1:N % ---> Number of runs
        [PL(i,j), APD(i,j), ~, ~] = Sim2(lambda(j), C, f, P, b);
    end
end


% Average packet loss
media_PL = mean(PL); % ----> Average of the average packet loss
term_PL = norminv(1-alfa/2)*sqrt(var(PL)/N); % ----> Confidence interval
errlow_PL = media_PL - term_PL; % ----> Lower error bar
errhigh_PL = media_PL + term_PL; % ----> Higher error bar

% Average packet delay
media_APD = mean(APD); % ----> Average of the average packet delay
term_APD = norminv(1-alfa/2)*sqrt(var(APD)/N); % ----> Confidence interval
errLow_APD = media_APD - term_APD; % ----> Lower error bar
errHigh_APD = media_APD + term_APD; % ----> Higher error bar


% Display results
for j = 1:length(lambda)
    fprintf('For lambda = %d pps:\n', lambda(j));
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL(j), term_PL(j));
    fprintf('Average packet delay: %.2f +- %.2f\n\n', media_APD(j), term_APD(j));
end

% Plot PACKE LOSS
figure;
bar(lambda, media_PL);
hold on;

er_PL = errorbar(lambda, media_PL, media_PL - errlow_PL, errhigh_PL - media_PL); % ----> Error bars
er_PL.Color = [0 0 0];  % ----> Black
er_PL.LineStyle = 'none'; % ----> No line
title('Average Packet Loss');
xlabel('Arrival rate (pps)');
ylabel('Packet loss (%)');
grid on;
hold off;

% Plot AVERAGE PACKET DELAY
figure;
bar(lambda, media_APD);
hold on;

er_APD = errorbar(lambda, media_APD, media_APD - errLow_APD, errHigh_APD - media_APD); % ----> Error bars
er_APD.Color = [0 0 0];  % ----> Black
er_APD.LineStyle = 'none'; % ----> No line
title('Average Packet Delay');
xlabel('Arrival rate (pps)');
ylabel('Packet delay (ms)');
grid on;
hold off;


%% 1c)

% Given probabilities for fixed sizes
p_64 = 0.19;
p_110 = 0.23;
p_1518 = 0.17;

% Uniform distribution for the remaining 41%
p_uniform = 0.41;

% Fixed packet sizes
size_64 = 64;
size_110 = 110;
size_1518 = 1518;

% Average of uniformly distributed packet sizes from 65 to 109 and from 111 to 1517
avg_uniform_65_109 = mean(65:109);    % Average of packet sizes from 65 to 109
avg_uniform_111_1517 = mean(111:1517); % Average of packet sizes from 111 to 1517

% Total number of packet sizes in each range
num_65_109 = 109 - 65 + 1;  % Number of packet sizes from 65 to 109
num_111_1517 = 1517 - 111 + 1;  % Number of packet sizes from 111 to 1517

% Weighted average of the two uniform ranges
uniform_average = (avg_uniform_65_109 * num_65_109 + avg_uniform_111_1517 * num_111_1517) / (num_65_109 + num_111_1517);

% Calculate the overall average packet size
averageSize = p_64 * size_64 + p_110 * size_110 + p_1518 * size_1518 + p_uniform * uniform_average;

%averageSize = 295.52028; % Average packet size in bytes

% Display the average size
fprintf('Theoretical Average Packet Size: %.2f bytes\n', averageSize);


% Parameters

b1 = 10^-6; % Bit error rate (BER) 10^-6
b2 = 10^-4; % Bit error rate (BER) 10^-4

% Calculate packet loss for b = 10^-6
PLoss_b1 = 1 - (1 - b1)^(8 * averageSize);

% Calculate packet loss for b = 10^-4
PLoss_b2 = 1 - (1 - b2)^(8 * averageSize);

% Display the results
fprintf('Theoretical Packet Loss for b = 10^-6: %.4f%%\n', PLoss_b1 * 100);
fprintf('Theoretical Packet Loss for b = 10^-4: %.4f%%\n', PLoss_b2 * 100);


%% PRINT ALL VALUES TO DEBUG

fprintf('Average packet loss: %.2f +- %.2f\n', PL);
fprintf('\n-----------------------------\n\n')
fprintf('Average packet delay: %.2f +- %.2f\n', APD);

