function [PLdata, PLVoIP, APDdata, APDVoIP, MPDdata, MPDVoIP, TT] = Sim4A(lambda, C, f, P, n, p)
    % INPUT PARAMETERS:
    %  lambda - packet rate (packets/sec) for data packets
    %  C      - link bandwidth (Mbps)
    %  f      - queue size (Bytes)
    %  P      - number of data packets (stopping criterion for data packets)
    %  n      - number of VoIP flows                                        --> n = nº de fluxos VoIP adicionais.
    %  p      - maximum queue occupation  (%)                               --> p = max(size) da fila de espera para pacotes de dados
    % OUTPUT PARAMETERS:
    %  PLdata   - packet loss of data packets (%)
    %  PLVoIP   - packet loss of VoIP packets (%)
    %  APDdata  - average packet delay of data packets (milliseconds)
    %  APDVoIP  - average packet delay of VoIP packets (milliseconds)
    %  MPDdata  - maximum packet delay of data packets (milliseconds)
    %  MPDVoIP  - maximum packet delay of VoIP packets (milliseconds)
    %  TT       - transmitted throughput (data + VoIP) (Mbps)
    
    % Events:
    ARRIVAL_DATA = 0;       % Arrival of a data packet
    ARRIVAL_VOIP = 2;       % Arrival of a VoIP packet
    DEPARTURE_DATA = 1;          % Departure of a packet
    DEPARTURE_VOIP = 3;

    % State variables:
    STATE = 0;              % 0 - connection is free; 1 - connection is occupied
    QUEUEOCCUPATION = 0;    % Occupation of the queue (in Bytes)
    QUEUE = [];             % Size, arrival time, and type of each packet in the queue
    
    %Statistical Counters for Data:
    TOTALPACKETS_DATA = 0;  % No. of data packets arrived to the system
    LOSTPACKETS_DATA = 0;   % No. of data packets dropped due to buffer overflow
    TRANSPACKETS_DATA = 0;  % No. of transmitted data packets
    TRANSBYTES_DATA = 0;    % Sum of the Bytes of transmitted data packets
    DELAYS_DATA = 0;        % Sum of the delays of transmitted data packets
    MAXDELAY_DATA = 0;      % Maximum delay among all transmitted data packets
    
    %{
        Se adicionarmos um novo fluxo VoIP, precisamos de adicionar novas variáveis
    %}
    TOTALPACKETS_VOIP = 0;  % No. of VoIP packets arrived to the system
    LOSTPACKETS_VOIP = 0;   % No. of VoIP packets dropped due to buffer overflow
    TRANSPACKETS_VOIP = 0;  % No. of transmitted VoIP packets
    TRANSBYTES_VOIP = 0;    % Sum of the Bytes of transmitted VoIP packets
    DELAYS_VOIP = 0;        % Sum of the delays of transmitted VoIP packets
    MAXDELAY_VOIP = 0;      % Maximum delay among all transmitted VoIP packets
    
    % Initializing the simulation clock:
    Clock = 0;
    
    % Initializing the List of Events with the first ARRIVAL for both data and VoIP:
    tmp = Clock + exprnd(1/lambda);  % Time of first data packet arrival
    EventList = [ARRIVAL_DATA, tmp, GeneratePacketSizeData(), tmp];
    
    % --------------------------------------------------------------------------------------------> Gerar primeira chegada para cada fluxo VoIP
    for i = 1:n

        %{
            Forma alternativa : tmpVoIP = unifrnd(0.016, 0.024);
            utilizando a função unifrnd() para gerar intervalos de 
            chegada uniformemente distribuídos [16 e 24]ms
        %}
        tmpVoIP = Clock + 0.02*rand();  % -------------------------------------> Intervalos de chegada uniformemente distribuídos [16 e 24]ms
        
        %{  
            Criamos a função GeneratePacketSizeVoIP() :
            Que gera pacotes VoIP com tamanhos entre 110 e 130 Bytes
        %}
        EventList = [EventList; ARRIVAL_VOIP, tmpVoIP, GeneratePacketSizeVoIP(), tmpVoIP];  % ----> Gerar pacotes VoIP com tamanhos [110 e 130]bytes
    end
    
    % Simulation loop:
    while TRANSPACKETS_DATA + TRANSPACKETS_VOIP < P         % Stopping criterium
        %{  
            Critério de paragem = nº total de pacotes transmitidos (dados + VoIP)
        %}

        EventList = sortrows(EventList,2);    % Order EventList by time
        Event = EventList(1,1);               % Get first event 
        Clock = EventList(1,2);               %    and all
        PacketSize = EventList(1,3);          %    associated
        ArrInstant = EventList(1,4);          %    parameters.
        EventList(1,:) = [];                  % Eliminate first event
        
        switch Event
            case ARRIVAL_DATA         % ----------------------------------------------------------> [CASE: first event = PACOTE DE DADOS]
                TOTALPACKETS_DATA = TOTALPACKETS_DATA + 1;
                tmp = Clock + exprnd(1/lambda);
                EventList = [EventList; ARRIVAL_DATA, tmp, GeneratePacketSizeData(), tmp];

                if STATE == 0
                    STATE = 1;
                    EventList = [EventList; DEPARTURE_DATA, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock];
                else
                    %{ 
                        Se a ocupação da fila mais o tamanho do pacote for menor que 
                        a percentagem máxima da fila de espera para pacotes de dados
                        definida por p, então adicionamos o pacote à fila de espera
                        
                        Caso contrário, contabilizamos a perda do pacote
                    %}
                    if QUEUEOCCUPATION + PacketSize <= f * (p/100)
                        %{
                            PERGUNTAR AO PROF SE EXISTE A POSSIBILIDADE DE 
                            ACEITARMOS MAIS DO QUE 100% NO p 

                            CASO EXISTA, ENTÃO A CONDIÇÃO DEVERÁ SER COMPLEMENTADA
                            ADICIONANDO UMA SEGUNDA CONDIÇÃO PARA ACEITAR PACOTES
                            COM TAMANHO MENOR QUE o TAMANHO MÁXIMO DA FILA

                        %}
                        QUEUE = [QUEUE; PacketSize, Clock, ARRIVAL_DATA];  % Adicionar pacotes de dados à fila comum
                        QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETS_DATA = LOSTPACKETS_DATA + 1;  % Contabilizar perda de pacotes de dados
                    end
                end
                
            case ARRIVAL_VOIP         % -----------------------------------------------------------> [CASE: first event = PACOTE VoIP]
                TOTALPACKETS_VOIP = TOTALPACKETS_VOIP + 1;                  % Contabilizar pacotes VoIP
                tmpVoIP = Clock + 0.016 + (0.024 - 0.016)*rand();           % Gerar novos pacotes VoIP com intervalos entre 16ms e 24ms
                EventList = [EventList; ARRIVAL_VOIP, tmpVoIP, GeneratePacketSizeVoIP(), tmpVoIP]; 
                if STATE == 0                                               % Se o estado for 0, então a conexão está livre(temos um pacote VoIP para transmitir)
                    STATE = 1;                                              
                    EventList = [EventList; DEPARTURE_VOIP, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock];
                else
                    if QUEUEOCCUPATION + PacketSize <= f                    % Se a ocupação da fila mais o tamanho do pacote for menor que o tamanho da fila
                        QUEUE = [QUEUE; PacketSize, Clock, ARRIVAL_VOIP];   % Adicionar pacotes VoIP à fila comum
                        QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;     % Atualizar ocupação da fila
                    else
                        LOSTPACKETS_VOIP = LOSTPACKETS_VOIP + 1;            % Contabilizar perda de pacotes VoIP
                    end
                end
                
            case DEPARTURE_DATA     % --------------------------------------------------------------> [CASE: first event = DEPARTURE_VOIP]
                TRANSBYTES_DATA = TRANSBYTES_DATA + PacketSize;         % Somar Bytes dos pacotes de DATA transmitidos
                DELAYS_DATA = DELAYS_DATA + (Clock - ArrInstant);       % Tempo atual menos o instante em que chegou ao sistema
                if Clock - ArrInstant > MAXDELAY_DATA                   % Verificar se o atraso atual é maior que o atraso máximo
                    MAXDELAY_DATA = Clock - ArrInstant;                 % Atualizar atraso máximo
                end
                TRANSPACKETS_DATA = TRANSPACKETS_DATA + 1;              % Contabilizar pacotes de dados transmitidos
                
                if QUEUEOCCUPATION > 0 % -----------------------------------------------------------> Queue(1,1) = TAMANHO DO PRIMEIRO PACOTE DA FILA DE ESPERA
                    %{
                        Ordena a fila para dar prioridade aos pacotes VoIP,
                        de forma descendente para garantir que no topo da fila
                        ficam os pacote VoIP, para serem os primeiros a ser 
                        transmitidos
                    %}
                    QUEUE = sortrows(QUEUE, 3, "descend");
                    
                    if QUEUE(1,3) == ARRIVAL_DATA
                        EventList = [EventList; DEPARTURE_DATA, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                    else
                        EventList = [EventList; DEPARTURE_VOIP, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                    end
                    
                    QUEUEOCCUPATION = QUEUEOCCUPATION - QUEUE(1,1);
                    QUEUE(1,:) = []; % -------------------------------------------------------------> Remover pacote da fila
                else
                    STATE = 0; % -------------------------------------------------------------------> Quando n há pacotes para serem transmitidos passa para o estado 0
                end
           
            case DEPARTURE_VOIP     % --------------------------------------------------------------> [CASE: first event = DEPARTURE_VOIP]
                TRANSBYTES_VOIP = TRANSBYTES_VOIP + PacketSize;         % Somar Bytes dos pacotes VoIP transmitidos
                DELAYS_VOIP = DELAYS_VOIP + (Clock - ArrInstant);       % Tempo atual menos o instante em que chegou ao sistema
                if Clock - ArrInstant > MAXDELAY_VOIP                   % Verificar se o atraso atual é maior que o atraso máximo
                    MAXDELAY_VOIP = Clock - ArrInstant;                 % Atualizar atraso máximo
                end
                TRANSPACKETS_VOIP = TRANSPACKETS_VOIP + 1;              % Contabilizar pacotes VoIP transmitidos
                
                if QUEUEOCCUPATION > 0 % -----------------------------------------------------------> Queue(1,1) = TAMANHO DO PRIMEIRO PACOTE DA FILA DE ESPERA
                    %{
                        Ordena a fila para dar prioridade aos pacotes VoIP,
                        de forma descendente para garantir que no topo da fila
                        ficam os pacote VoIP, para serem os primeiros a ser 
                        transmitidos
                    %}
                    QUEUE = sortrows(QUEUE, 3, "descend");

                    if QUEUE(1,3) == ARRIVAL_VOIP
                        EventList = [EventList; DEPARTURE_VOIP, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                    else
                        EventList = [EventList; DEPARTURE_DATA, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                    end
                    
                    QUEUEOCCUPATION = QUEUEOCCUPATION - QUEUE(1,1);
                    QUEUE(1,:) = []; % -------------------------------------------------------------> Remover pacote da fila
                else
                    STATE = 0; % -------------------------------------------------------------------> Quando n há pacotes para serem transmitidos passa para o estado 0
                end
        end
    end
    
    % Cálculo dos parâmetros de desempenho:
    % -----------------| DATA |-----------------
    PLdata = 100*LOSTPACKETS_DATA/TOTALPACKETS_DATA;        % Percentagem de pacotes  perdidos
    APDdata = 1000*DELAYS_DATA/TRANSPACKETS_DATA;           % Atraso médio dos pacotes --> ms
    MPDdata = 1000*MAXDELAY_DATA;                           % Atraso máximo dos pacotes --> ms
    
    % -----------------| VoIP |-----------------
    PLVoIP = 100*LOSTPACKETS_VOIP/TOTALPACKETS_VOIP;        % Percentagem de pacotes  perdidos
    APDVoIP = 1000*DELAYS_VOIP/TRANSPACKETS_VOIP;           % Atraso médio dos pacotes --> ms
    MPDVoIP = 1000*MAXDELAY_VOIP;                           % Atraso máximo dos pacotes --> ms

    % -----------------| Total |-----------------
    TT = 1e-6*(TRANSBYTES_DATA + TRANSBYTES_VOIP)*8/Clock;  % Throughput total (dados + VoIP) --> Mbps
    
    end
    
    % Geração do tamanho dos pacotes de dados
    function out = GeneratePacketSizeData()
        aux = rand();
        aux2 = [65:109 111:1517];
        if aux <= 0.19
            out = 64;
        elseif aux <= 0.19 + 0.23
            out = 110;
        elseif aux <= 0.19 + 0.23 + 0.17
            out = 1518;
        else
            out = aux2(randi(length(aux2)));
        end
    end
    
    %{
        GeneratePacketSizeVoIP() :
        Que gera pacotes VoIP com tamanhos entre 110 e 130 Bytes
    %}
    function out = GeneratePacketSizeVoIP()
        out = 109 + randi(21); 
    end
    