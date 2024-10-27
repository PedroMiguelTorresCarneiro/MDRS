%{
    TASK 1:
    In this task, use Sim2 developed in Task 6 of the Practical Guide. Consider always the capacity
    of the link C = 10 Mbps and the size of the queue f = 10.000 Bytes. When performance
    parameters are estimated by simulation, present the results based on 20 runs of the simulator
    (with a stopping criterion of P = 100.000 on each run) and with 90% confidence intervals.
%}

%% 1.a) VALUES
%{
    Estimate by simulation the average packet delay and the average packet loss parameters 
    when the bit error rate of the link is b = 10-6 and for the arrival rate values
    \lamdba = 1500, 1600, 1700, 1800 and 1900 pps. 
    Plot the results in bar charts with the confidence intervals in error bars1. 
    
    Justify the results and draw all relevant conclusions.

    1 - https://www.mathworks.com/help/matlab/creating_plots/bar-chart-with-error-bars.html
%}
fprintf('\nAlinea 1a)\n Estimate the average packet delay and the average packet loss\n\n');

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

%% 1.a) PLOTS 

% Define figure with two subplots for side-by-side display
figure;

% Plot Average Packet Loss on the left
subplot(1,2,1);  % 1 row, 2 columns, first subplot
bar(lambda, media_PL);  % Bar chart for packet loss
hold on;
er_PL = errorbar(lambda, media_PL, media_PL - errlow_PL, errhigh_PL - media_PL); % Error bars
er_PL.Color = [0 0 0];  % Black error bars
er_PL.LineStyle = 'none'; % No line connecting error bars
title('Average Packet Loss');
xlabel('Arrival rate (pps)');
ylabel('Packet loss (%)');
grid on;
hold off;

% Plot Average Packet Delay on the right
subplot(1,2,2);  % 1 row, 2 columns, second subplot
bar(lambda, media_APD);  % Bar chart for packet delay
hold on;
er_APD = errorbar(lambda, media_APD, media_APD - errLow_APD, errHigh_APD - media_APD); % Error bars
er_APD.Color = [0 0 0];  % Black error bars
er_APD.LineStyle = 'none'; % No line connecting error bars
title('Average Packet Delay');
xlabel('Arrival rate (pps)');
ylabel('Packet delay (ms)');
grid on;
hold off;


fprintf('----------------------------------------------------[1a. END]\n\n');

%% 1b) VALUES 
%{
    Repeat experiment 1.a considering now a bit error rate
    b = 10-4. Justify the differences between these results and the results of experiment 1.a
    and draw all relevant conclusions.
%}
fprintf('\nAlinea 1b)\n Repeat experiment 1.a with b = 10^-4\n\n');

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


%% 1b) PLOTS

% Define figure with two subplots for side-by-side display
figure;

% Plot Average Packet Loss on the left
subplot(1,2,1);  % 1 row, 2 columns, first subplot
bar(lambda, media_PL);  % Bar chart for packet loss
hold on;
er_PL = errorbar(lambda, media_PL, media_PL - errlow_PL, errhigh_PL - media_PL); % Error bars
er_PL.Color = [0 0 0];  % Black error bars
er_PL.LineStyle = 'none'; % No line connecting error bars
title('Average Packet Loss');
xlabel('Arrival rate (pps)');
ylabel('Packet loss (%)');
grid on;
hold off;

% Plot Average Packet Delay on the right
subplot(1,2,2);  % 1 row, 2 columns, second subplot
bar(lambda, media_APD);  % Bar chart for packet delay
hold on;
er_APD = errorbar(lambda, media_APD, media_APD - errLow_APD, errHigh_APD - media_APD); % Error bars
er_APD.Color = [0 0 0];  % Black error bars
er_APD.LineStyle = 'none'; % No line connecting error bars
title('Average Packet Delay');
xlabel('Arrival rate (pps)');
ylabel('Packet delay (ms)');
grid on;
hold off;

fprintf('----------------------------------------------------[1b. END]\n\n');

%% 1c)
%{
    Determine the theoretical average packet loss (in %) only due to 
    the bit error rate for b = 10-6 and b = 10-4. Present and explain 
    the MATLAB code developed for these calculations. 
    Compare these values with the results obtained in 1.aand 1.b. 
    What do you conclude?
%}
fprintf('\nAlinea 1c)\n Calculate the theoretical average packet loss due to the bit error rate [ONLY]\n');

% Parameters
b_values = [1e-6, 1e-4];                    % Bit error rates

prob_left = (1 - (0.19 + 0.23 + 0.17)) / ((109 - 65 + 1) + (1517 - 111 + 1));
avg_packet_size = 0.19*64 + 0.23*110 + 0.17*1518 + sum((65:109)*(prob_left)) + sum((111:1517)*(prob_left));


    % Display the average packet size
fprintf('\nAverage Packet Size: %.2f bytes\n\n', avg_packet_size);

% Initialize array to store packet loss for each bit error rate
packet_loss = zeros(size(b_values));

% Loop over each bit error rate
for i = 1:length(b_values)
    b = b_values(i);  % Current bit error rate
    % Calculate packet loss using the formula
    packet_loss(i) = 1 - (1 - b)^(8 * avg_packet_size);  % 8 bits per byte
    fprintf('Packet loss for b = %.1e: %.4f%%\n', b_values(i), packet_loss(i) * 100);
end

fprintf('----------------------------------------------------[1c. END]\n\n');

%% PRINT ALL VALUES TO DEBUG

fprintf('Average packet loss: %.2f +- %.2f\n', PL);
fprintf('\n-----------------------------\n\n')
fprintf('Average packet delay: %.2f +- %.2f\n', APD);

