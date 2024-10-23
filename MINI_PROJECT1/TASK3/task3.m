%{
    TASK 3:
    Consider the event driven simulators Sim3 and Sim4 developed in Task 7 of the Practical Guide.
    In all experiments of this task, consider the cases of  = 1500 pps, C = 10 Mbps, f = 10.000
    Bytes and n = 10, 20, 30 and 40 VoIP flows. All simulation results should be based on 20 runs
    of the simulator with a stopping criterion of P = 100.000 on each run to compute the estimated
    values and the 90% confidence intervals.
%}
%% 3.a)
%{
    Use Sim3 to estimate the average packet delay and average
    packet loss of each service (data and VoIP). Recall that in Sim3, both services are
    statistically multiplexed in a single FIFO queue. Present each of the four performance
    parameters in a bar chart with the confidence intervals in error bars. Justify the differences
    in the performance values obtained for each service and draw all relevant conclusions.
%}
fprintf('\nAlinea 3a)\n Estimate the average [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]\n\n');

%Parameters
% Parameters
C       = 10; % ------------> Mbps
f       = 10000; %----------> Bytes
P       = 100000; % --------> Stopping criterion
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
        [PLdata(i,j), PLVoIP(i,j), APDdata(i,j), APDVoIP(i,j), MPDdata(i,j), MPDVoIP(i,j),TT(i,j)] = Sim3(lambda, C, f, P, n_voip(j));
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


% Display results
for j = 1:length(n_voip)
    fprintf('----------------------------| For n = %d VoIP flows:\n', n_voip(j));
    fprintf('-------------> DATA\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_data(j), term_PL_data(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_data(j), term_APD_data(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n', media_MPD_data(j), term_MPD_data(j));
    fprintf('-------------> VoIP\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_VoIP(j), term_PL_VoIP(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_VoIP(j), term_APD_VoIP(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n\n', media_MPD_VoIP(j), term_MPD_VoIP(j));
end

fprintf('\nPloting the bar char of PACKET LOSS (data and VoIP) \n\n');

% Define colors for Data and VoIP
data_color = [0 0.4470 0.7410];  % Blue for Data
voip_color = [0.8500 0.3250 0.0980];  % Orange for VoIP

% Plot combined Packet Loss for Data and VoIP
figure;
hBar = bar(n_voip, [media_PL_data' media_PL_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Packet Loss (center them on the bars)
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_PL_data, media_PL_data - errlow_PL_data, errhigh_PL_data - media_PL_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Packet Loss (center them on the bars)
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_PL_VoIP, media_PL_VoIP - errlow_PL_VoIP, errhigh_PL_VoIP - media_PL_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Average Packet Loss (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;
legend('Data', 'VoIP', 'Location', 'northeast');
hold off;

fprintf('\nPloting the bar char of AVG PACKET DELAY (data and VoIP) \n\n');

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


fprintf('----------------------------------------------------[3a. END]\n\n');

%% 3.b)
%{
    Use Sim4 to estimate the same performance parameters as in
    3.a. Recall that in Sim4, VoIP service has higher priority than data service. Present each
    of the four performance parameters in a bar chart with the confidence intervals in error
    bars. Justify the differences in the performance values obtained for each service, and the
    differences between these results and the results of experiment 3.a. Draw all relevant
    conclusions.
%}
fprintf('\nAlinea 3b)\n Estimate the average [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]\n\n');


% Iterate over the number of VoIP flows
for j = 1:length(n_voip)
    % Simulation loop
    % [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]
    for i= 1:N % ---> Number of runs
        [PLdata(i,j), PLVoIP(i,j), APDdata(i,j), APDVoIP(i,j), MPDdata(i,j), MPDVoIP(i,j),TT(i,j)] = Sim4(lambda, C, f, P, n_voip(j));
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


% Display results
for j = 1:length(n_voip)
    fprintf('----------------------------| For n = %d VoIP flows:\n', n_voip(j));
    fprintf('-------------> DATA\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_data(j), term_PL_data(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_data(j), term_APD_data(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n', media_MPD_data(j), term_MPD_data(j));
    fprintf('-------------> VoIP\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_VoIP(j), term_PL_VoIP(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_VoIP(j), term_APD_VoIP(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n\n', media_MPD_VoIP(j), term_MPD_VoIP(j));
end

fprintf('\nPloting the bar char of PACKET LOSS (data and VoIP) \n\n');

% Define colors for Data and VoIP
data_color = [0 0.4470 0.7410];  % Blue for Data
voip_color = [0.8500 0.3250 0.0980];  % Orange for VoIP

% Plot combined Packet Loss for Data and VoIP
figure;
hBar = bar(n_voip, [media_PL_data' media_PL_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Packet Loss (center them on the bars)
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_PL_data, media_PL_data - errlow_PL_data, errhigh_PL_data - media_PL_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Packet Loss (center them on the bars)
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_PL_VoIP, media_PL_VoIP - errlow_PL_VoIP, errhigh_PL_VoIP - media_PL_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Average Packet Loss (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;
legend('Data', 'VoIP', 'Location', 'northeast');
hold off;

fprintf('\nPloting the bar char of AVG PACKET DELAY (data and VoIP) \n\n');

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



fprintf('----------------------------------------------------[3b. END]\n\n');

%% 3.d)
%{
    Use simulator Sim4A to estimate the same performance
    parameters as in 3.a and 3.b for p = 90%. Justify the differences in the performance values
    obtained for each service, and the differences between these results and the results of
    experiment 3.b. Draw all relevant conclusions.
%}
fprintf('\nAlinea 3d)\n Estimate the average [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]\n\n');

p = 90;

% Iterate over the number of VoIP flows
for j = 1:length(n_voip)
    % Simulation loop
    % [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]
    for i= 1:N % ---> Number of runs
        [PLdata(i,j), PLVoIP(i,j), APDdata(i,j), APDVoIP(i,j), MPDdata(i,j), MPDVoIP(i,j),TT(i,j)] = Sim4A(lambda, C, f, P, n_voip(j),p);
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


% Display results
for j = 1:length(n_voip)
    fprintf('----------------------------| For n = %d VoIP flows:\n', n_voip(j));
    fprintf('-------------> DATA\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_data(j), term_PL_data(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_data(j), term_APD_data(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n', media_MPD_data(j), term_MPD_data(j));
    fprintf('-------------> VoIP\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_VoIP(j), term_PL_VoIP(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_VoIP(j), term_APD_VoIP(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n\n', media_MPD_VoIP(j), term_MPD_VoIP(j));
end

fprintf('\nPloting the bar char of PACKET LOSS (data and VoIP) \n\n');

% Define colors for Data and VoIP
data_color = [0 0.4470 0.7410];  % Blue for Data
voip_color = [0.8500 0.3250 0.0980];  % Orange for VoIP

% Plot combined Packet Loss for Data and VoIP
figure;
hBar = bar(n_voip, [media_PL_data' media_PL_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Packet Loss (center them on the bars)
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_PL_data, media_PL_data - errlow_PL_data, errhigh_PL_data - media_PL_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Packet Loss (center them on the bars)
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_PL_VoIP, media_PL_VoIP - errlow_PL_VoIP, errhigh_PL_VoIP - media_PL_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Average Packet Loss (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;
legend('Data', 'VoIP', 'Location', 'northeast');
hold off;

fprintf('\nPloting the bar char of AVG PACKET DELAY (data and VoIP) \n\n');

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



fprintf('----------------------------------------------------[3d. END]\n\n');

%% 3.e)
%{
    Repeat experiment 3.d considering now p = 60%. Justify the
    differences in the performance values obtained for each service, and the differences
    between these results and the results of experiments 3.b and 3.d. Draw all relevant
    conclusions.
%}
fprintf('\nAlinea 3e)\n Estimate the average [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]\n\n');

p = 60;

% Iterate over the number of VoIP flows
for j = 1:length(n_voip)
    % Simulation loop
    % [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT]
    for i= 1:N % ---> Number of runs
        [PLdata(i,j), PLVoIP(i,j), APDdata(i,j), APDVoIP(i,j), MPDdata(i,j), MPDVoIP(i,j),TT(i,j)] = Sim4A(lambda, C, f, P, n_voip(j),p);
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


% Display results
for j = 1:length(n_voip)
    fprintf('----------------------------| For n = %d VoIP flows:\n', n_voip(j));
    fprintf('-------------> DATA\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_data(j), term_PL_data(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_data(j), term_APD_data(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n', media_MPD_data(j), term_MPD_data(j));
    fprintf('-------------> VoIP\n');
    fprintf('Average packet loss: %.2f +- %.2f\n', media_PL_VoIP(j), term_PL_VoIP(j));
    fprintf('Average packet delay: %.2f +- %.2f\n', media_APD_VoIP(j), term_APD_VoIP(j));
    fprintf('Average Maximum Packet Delay: %.2f +- %.2f\n\n', media_MPD_VoIP(j), term_MPD_VoIP(j));
end

fprintf('\nPloting the bar char of PACKET LOSS (data and VoIP) \n\n');

% Define colors for Data and VoIP
data_color = [0 0.4470 0.7410];  % Blue for Data
voip_color = [0.8500 0.3250 0.0980];  % Orange for VoIP

% Plot combined Packet Loss for Data and VoIP
figure;
hBar = bar(n_voip, [media_PL_data' media_PL_VoIP'], 'grouped');  % 'grouped' option for side-by-side bars
hold on;

% Set bar colors
hBar(1).FaceColor = data_color;  % Data bars in blue
hBar(2).FaceColor = voip_color;  % VoIP bars in orange

% Error bars for Data Packet Loss (center them on the bars)
xData = hBar(1).XEndPoints;  % Get the X positions of the Data bars
errorbar(xData, media_PL_data, media_PL_data - errlow_PL_data, errhigh_PL_data - media_PL_data, 'k', 'linestyle', 'none', 'linewidth', 1.5);

% Error bars for VoIP Packet Loss (center them on the bars)
xVoIP = hBar(2).XEndPoints;  % Get the X positions of the VoIP bars
errorbar(xVoIP, media_PL_VoIP, media_PL_VoIP - errlow_PL_VoIP, errhigh_PL_VoIP - media_PL_VoIP, 'k', 'linestyle', 'none', 'linewidth', 1.5);

title('Average Packet Loss (Data and VoIP)');
xlabel('Number of VoIP flows');
ylabel('Packet loss (%)');
grid on;
legend('Data', 'VoIP', 'Location', 'northeast');
hold off;

fprintf('\nPloting the bar char of AVG PACKET DELAY (data and VoIP) \n\n');

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



fprintf('----------------------------------------------------[3e. END]\n\n');