%{
    TASK 2:
    Consider the event driven simulator Sim3 developed in Task 7 of the Practical Guide. Start by
    developing a new version of Sim3, named Sim3A, to estimate the same performance parameters
    as Sim3 and to consider that the link introduces a bit error rate given by b (which should be a
    new input parameter of Sim3A).
%}

%% 2.a)
%{
    Present the developed MATLAB function of Sim3A
    highlighting and justifying the introduced changes. Using Sim3A, estimate all
    performance parameters when lambda = 1500 pps, C = 10 Mbps, f = 1.000.000 Bytes, b = 10-5
    and n = 10, 20, 30 and 40 VoIP flows, based on 20 runs of the simulator (with a stopping
    criterion of P = 100.000 on each run) and with 90% confidence intervals.
%}
fprintf('\nAlinea 2a)\n Estimate the average [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]\n\n');


% Parameters
C       = 10; % ------------> Mbps
f       = 1000000; %--------> Bytes
P       = 100000; % --------> Stopping criterion
b       = 10^-5; % ---------> Bit error rate
alfa    = 0.1; % -----------> Confidence level
lambda  = 1500; %-----------> Arrival Rate
N       = 20; % ------------> Number of runs

% Number of VoIP flows
n_voip       = [10, 20, 30, 40];

% Allocate space
PLdata      = zeros(N, length(n_voip)); % ---> vector PL to store all the packet loss values
APDdata     = zeros(N, length(n_voip)); % ---> vector APD to store all the average packet delay values
MPDdata     = zeros(N, length(n_voip)); % ---> vector MDP to store all the packet loss values

PLVoIP      = zeros(N, length(n_voip)); % ---> vector PL to store all the packet loss values
APDVoIP     = zeros(N, length(n_voip)); % ---> vector APD to store all the average packet delay values
MPDVoIP     = zeros(N, length(n_voip)); % ---> vector MDP to store all the packet loss values

TT      = zeros(N, length(n_voip)); % ---> vector TT to store all the average packet delay values

% Iterate over the number of VoIP flows
for j = 1:length(n_voip)
    % Simulation loop
    % [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]
    for i= 1:N % ---> Number of runs
        [PLdata(i,j), PLVoIP(i,j), APDdata(i,j), APDVoIP(i,j), MPDdata(i,j), MPDVoIP(i,j),TT(i,j)] = Sim3A(lambda, C, f, P, n_voip(j), b);
    end
end

%---------------------------------| DATA
% Average packet loss (DATA)
media_PL_data = mean(PLdata); % ----> Average of the average packet loss
term_PL_data = norminv(1-alfa/2)*sqrt(var(PLdata)/N); % ----> Confidence interval
errlow_PL_data = max(0, media_PL_data - term_PL_data); % ----> Lower error bar (ensure non-negative)
errhigh_PL_data = media_PL_data + term_PL_data; % ----> Higher error bar

% Average packet delay (DATA)
media_APD_data = mean(APDdata); % ----> Average of the average packet delay
term_APD_data = norminv(1-alfa/2)*sqrt(var(APDdata)/N); % ----> Confidence interval
errLow_APD_data = max(0, media_APD_data - term_APD_data); % ----> Lower error bar
errHigh_APD_data = media_APD_data + term_APD_data; % ----> Higher error bar

% Average Maximum Packet Delay (DATA)
media_MPD_data = mean(MPDdata); % ----> Average of the maximum packet delay
term_MPD_data = norminv(1-alfa/2)*sqrt(var(MPDdata)/N); % ----> Confidence interval
errlow_MPD_data = max(0, media_MPD_data - term_MPD_data); % ----> Lower error bar
errhigh_MPD_data = media_MPD_data + term_MPD_data; % ----> Higher error bar

%---------------------------------| VoIP
% Average packet loss (VoIP)
media_PL_VoIP = mean(PLVoIP); % ----> Average of the average packet loss
term_PL_VoIP = norminv(1-alfa/2)*sqrt(var(PLVoIP)/N); % ----> Confidence interval
errlow_PL_VoIP = max(0, media_PL_VoIP - term_PL_VoIP); % ----> Lower error bar
errhigh_PL_VoIP = media_PL_VoIP + term_PL_VoIP; % ----> Higher error bar

% Average packet delay (VoIP)
media_APD_VoIP = mean(APDVoIP); % ----> Average of the average packet delay
term_APD_VoIP = norminv(1-alfa/2)*sqrt(var(APDVoIP)/N); % ----> Confidence interval
errLow_APD_VoIP = max(0, media_APD_VoIP - term_APD_VoIP); % ----> Lower error bar
errHigh_APD_VoIP = media_APD_VoIP + term_APD_VoIP; % ----> Higher error bar

% Average Maximum Packet Delay (VoIP)
media_MPD_VoIP = mean(MPDVoIP); % ----> Average of the maximum packet delay
term_MPD_VoIP = norminv(1-alfa/2)*sqrt(var(MPDVoIP)/N); % ----> Confidence interval
errlow_MPD_VoIP = max(0, media_MPD_VoIP - term_MPD_VoIP); % ----> Lower error bar
errhigh_MPD_VoIP = media_MPD_VoIP + term_MPD_VoIP; % ----> Higher error bar

%---------------------------------| THROUGHPUT
% Average Throughput (Total Throughput)
media_TT = mean(TT); % ----> Average of the average throughput
term_TT = norminv(1-alfa/2)*sqrt(var(TT)/N); % ----> Confidence interval
errLow_TT = max(0, media_TT - term_TT); % ----> Lower error bar
errHigh_TT = media_TT + term_TT; % ----> Higher error bar


% Display results
for j = 1:length(n_voip)
    fprintf('----------------------------| For n = %d VoIP flows:\n', n_voip(j));
    fprintf('[DATA] Average packet loss: %.2f +- %.2f\n', media_PL_data(j), term_PL_data(j));
    fprintf('[VoIP] Average packet loss: %.2f +- %.2f\n', media_PL_VoIP(j), term_PL_VoIP(j));
    fprintf('[DATA] Average packet delay: %.2f +- %.2f\n', media_APD_data(j), term_APD_data(j));
    fprintf('[VoIP] Average packet delay: %.2f +- %.2f\n', media_APD_VoIP(j), term_APD_VoIP(j));
    fprintf('[DATA] Average Maximum Packet Delay: %.2f +- %.2f\n', media_MPD_data(j), term_MPD_data(j));
    fprintf('[VoIP] Average Maximum Packet Delay: %.2f +- %.2f\n\n', media_MPD_VoIP(j), term_MPD_VoIP(j));
    fprintf('-------------> THROUGHPUT\n');
    fprintf('Average Average Throughput: %.2f +- %.2f\n\n', media_TT(j), term_TT(j));
end


fprintf('----------------------------------------------------[2a. END]\n\n');


%% 2.b)
%{
    Present the simulation results of 2.a concerning the packet loss
    of each service (data and VoIP) in bar charts with the confidence intervals in error bars.
    Justify the results and draw all relevant conclusions.
%}
fprintf('\nAlinea 2b)\n Ploting the bar char of PACKET LOSS (data and VoIP) \n\n');

% Define colors for Data and VoIP
data_color = [0 0.4470 0.7410];  % Blue for Data
voip_color = [0.8500 0.3250 0.0980];  % Orange for VoIP

% Create a figure and divide it into two subplots
figure;

% Plot Data Packet Loss
subplot(1,2,1);  % 1 row, 2 columns, first plot
bar(n_voip, media_PL_data, 'FaceColor', data_color);  % Data in blue
hold on;
errorbar(n_voip, media_PL_data, media_PL_data - errlow_PL_data, errhigh_PL_data - media_PL_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);
title('Average Packet Loss - Data');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;

% Plot VoIP Packet Loss
subplot(1,2,2);  % 1 row, 2 columns, second plot
bar(n_voip, media_PL_VoIP, 'FaceColor', voip_color);  % VoIP in orange
hold on;
errorbar(n_voip, media_PL_VoIP, media_PL_VoIP - errlow_PL_VoIP, errhigh_PL_VoIP - media_PL_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);
title('Average Packet Loss - VoIP');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;

% Adjust layout for side-by-side display
sgtitle('Comparison of Packet Loss (Data vs VoIP)');  % Title for both subplots

fprintf('----------------------------------------------------[2b. END]\n\n');

%% 2.c)
%{
    Present the simulation results of 2.a concerning the average
    packet delay of each service in bar charts with the confidence intervals in error bars.
    Justify the results and draw all relevant conclusions.
%}
fprintf('\nAlinea 2c)\n Ploting the bar char of AVG PACKET DELAY (data and VoIP) \n\n');

% Plot combined Average Packet Delay for Data and VoIP
figure;
hBar = bar(n_voip, [media_APD_data' media_APD_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Packet Delay (center them on the bars)
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_APD_data, media_APD_data - errLow_APD_data, errHigh_APD_data - media_APD_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Packet Delay (center them on the bars)
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_APD_VoIP, media_APD_VoIP - errLow_APD_VoIP, errHigh_APD_VoIP - media_APD_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Average Packet Delay (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Packet delay (ms)');
grid on;
legend('Data', 'VoIP', 'Location', 'northwest');
hold off;


fprintf('----------------------------------------------------[2c. END]\n\n');

%% 2.d)
%{
    Present the simulation results of 2.a concerning the maximum
    packet delay of each service in bar charts with the confidence intervals in error bars.
    Justify the results and draw all relevant conclusions.
%}
fprintf('\nAlinea 2d)\n Ploting the bar char of MAX PACKET DELAY (data and VoIP) \n\n');

% Plot Maximum Packet Delay for Data and VoIP
figure;
hBar = bar(n_voip, [media_MPD_data' media_MPD_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Maximum Packet Delay
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_MPD_data, media_MPD_data - errlow_MPD_data, errhigh_MPD_data - media_MPD_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Maximum Packet Delay
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_MPD_VoIP, media_MPD_VoIP - errlow_MPD_VoIP, errhigh_MPD_VoIP - media_MPD_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Maximum Packet Delay (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Maximum Packet Delay (ms)');
grid on;
legend('Data', 'VoIP', 'Location', 'northwest');
hold off;


fprintf('----------------------------------------------------[2d. END]\n\n');

%% 2.e)
%{
    Present the simulation results of 2.a concerning the total
    throughput in bar charts with the confidence intervals in error bars. Justify the results and
    draw all relevant conclusions.
%}
fprintf('\nAlinea 2e)\n Ploting the bar char of THROUGHPUT \n\n');

% Plot Total Throughput
figure;
hBar = bar(n_voip, media_TT, 'grouped');  % Single set of bars for total throughput
hold on;

% Error bars for Total Throughput
xTT = hBar.XEndPoints;  % Get the X positions of the bars
errorbar(xTT, media_TT, media_TT - errLow_TT, errHigh_TT - media_TT, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Total Throughput');
xlabel('Number of VoIP flows');
ylabel('Total Throughput (Mbps)');
grid on;
hold off;


fprintf('----------------------------------------------------[2e. END]\n\n');

%% 2.f)
%{
    Determine the theoretical value of the total throughput for all
    cases simulated in experiment 2.a. Present and explain the MATLAB code developed for
    these calculations. Compare these values with the results obtained in 2.e. What do you
    conclude?
%}
fprintf('\nAlinea 2f)\n Calculating Theoretical Total Throughput for Different VoIP Flow Counts\n\n');

% Parameters
prob_left = (1 - (0.19 + 0.23 + 0.17)) / ((109 - 65 + 1) + (1517 - 111 + 1)); % Probability for intermediate sizes
avgSIZE_data = 0.19*64 + 0.23*110 + 0.17*1518 + sum((65:109)*(prob_left)) + sum((111:1517)*(prob_left)); % Average size of Data packets
rate_data = 1500; % Data packet arrival rate (packets per second)
data_TT = rate_data * avgSIZE_data * 8 / 10^6; % Data Throughput in Mbps

% VoIP parameters
avgSIZE_voip = ( 110 + 130 ) / 2; % Average size of VoIP packets (in bytes)
int_time_voip = (16 + 24) / 2 / 10^3; % Average inter-arrival time for a single VoIP flow (converted to seconds)
rate_single_voip = 1 / int_time_voip; % Rate of a single VoIP flow (in packets per second)

% Define the number of VoIP flows to analyze
num_voip_flows = [10, 20, 30, 40];

% Loop through each VoIP flow scenario
for i = 1:length(num_voip_flows)
    n_voip = num_voip_flows(i); % Current number of VoIP flows
    total_voip_rate = n_voip * rate_single_voip; % Total rate for all VoIP flows
    voip_TT = total_voip_rate * avgSIZE_voip * 8 / 10^6; % VoIP Throughput in Mbps for this number of flows
    final_TT = data_TT + voip_TT; % Total throughput (Data + VoIP)

    % Display results for each VoIP flow scenario
    fprintf('For %d VoIP flows:\n', n_voip);
    fprintf('  Theoretical Total Throughput: %.2f Mbps\n\n', final_TT);
end

fprintf('----------------------------------------------------[2f. END]\n\n');