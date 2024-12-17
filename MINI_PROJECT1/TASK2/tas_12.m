C       = 10; % ------------> Mbps
f       = 2000; %--------> Bytes
P       = 10000; % --------> Stopping criterion
b       = 10^-5; % ---------> Bit error rate
alfa    = 0.1; % -----------> Confidence level
lambda  = 1800; %-----------> Arrival Rate
N       = 100; % ------------> Number of runs

% Number of VoIP flows
n_voip       = [20];

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

%---------------------------------| THROUGHPUT
% Average Throughput (Total Throughput)
media_TT = mean(TT); % ----> Average of the average throughput
term_TT = norminv(1-alfa/2)*sqrt(var(TT)/N); % ----> Confidence interval
errLow_TT = max(0, media_TT - term_TT); % ----> Lower error bar
errHigh_TT = media_TT + term_TT; % ----> Higher error bar


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
    fprintf('-------------> THROUGHPUT\n');
    fprintf('Average Average Throughput: %.2f +- %.2f\n\n', media_TT(j), term_TT);
end