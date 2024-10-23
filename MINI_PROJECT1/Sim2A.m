function [PL , APD , MPD , TT] = Sim2(lambda,C,f,P,b)
    % INPUT PARAMETERS:
    %  lambda - packet rate (packets/sec)
    %  C      - link bandwidth (Mbps)
    %  f      - queue size (Bytes)
    %  P      - number of packets (stopping criterium for successful transmissions)
    %  b      - bit error rate (BER) % Adicionar o parâmetro BER ao input
    % OUTPUT PARAMETERS:
    %  PL   - packet loss (%)
    %  APD  - average packet delay (milliseconds)
    %  MPD  - maximum packet delay (milliseconds)
    %  TT   - transmitted throughput (Mbps)
    
    % Events:
    ARRIVAL= 0;       % Arrival of a packet            
    DEPARTURE= 1;     % Departure of a packet
    
    % State variables:
    STATE = 0;          % 0 - connection is free; 1 - connection is occupied
    QUEUEOCCUPATION= 0; % Occupation of the queue (in Bytes)
    QUEUE= [];          % Size and arriving time instant of each packet in the queue
    
    % Statistical Counters:
    TOTALPACKETS= 0;     % No. of packets arrived to the system
    LOSTPACKETS= 0;      % No. of packets dropped due to buffer overflow or transmission error
    TRANSPACKETS= 0;     % No. of transmitted packets without errors
    TRANSBYTES= 0;       % Sum of the Bytes of transmitted packets
    DELAYS= 0;           % Sum of the delays of transmitted packets
    MAXDELAY= 0;         % Maximum delay among all transmitted packets
    
    % Initializing the simulation clock:
    Clock= 0;
    
    % Initializing the List of Events with the first ARRIVAL:
    tmp= Clock + exprnd(1/lambda);
    EventList = [ARRIVAL, tmp, GeneratePacketSize(), tmp];
    
    % Simulation loop:
    while TRANSPACKETS < P              % Critério de paragem modificado: parar após transmitir P pacotes sem erros
        EventList = sortrows(EventList,2);  % Order EventList by time
        Event = EventList(1,1);            % Get first event 
        Clock = EventList(1,2);            %    and all
        PacketSize = EventList(1,3);       %    associated
        ArrInstant = EventList(1,4);       %    parameters.
        EventList(1,:) = [];               % Eliminate first event
        switch Event
            case ARRIVAL         % If first event is an ARRIVAL
                TOTALPACKETS = TOTALPACKETS + 1;
                tmp = Clock + exprnd(1/lambda);
                EventList = [EventList; ARRIVAL, tmp, GeneratePacketSize(), tmp];
                if STATE == 0
                    STATE = 1;
                    EventList = [EventList; DEPARTURE, Clock + 8*PacketSize/(C*10^6), PacketSize, Clock];
                else
                    if QUEUEOCCUPATION + PacketSize <= f
                        QUEUE = [QUEUE; PacketSize, Clock];
                        QUEUEOCCUPATION = QUEUEOCCUPATION + PacketSize;
                    else
                        LOSTPACKETS = LOSTPACKETS + 1;  % Pacote descartado devido a overflow da fila
                    end
                end
            case DEPARTURE          % If first event is a DEPARTURE
                % ---------------------------------------------------> Simular erro de transmissão com base no BER
                numBits = PacketSize * 8;  % ------------------------> Número de bits do pacote transmitido
                if rand() < (1 - b)^numBits
                    % -----------------------------------------------> Pacote TRANSMITIDO COM SUCESSO --> CONTABILIZAR
                    TRANSBYTES = TRANSBYTES + PacketSize;
                    DELAYS = DELAYS + (Clock - ArrInstant);
                    if Clock - ArrInstant > MAXDELAY
                        MAXDELAY = Clock - ArrInstant;
                    end
                    TRANSPACKETS = TRANSPACKETS + 1;  % -------------> Contar como transmissão bem sucedida
                else
                    % -----------------------------------------------> Pacote CONTÉM ERRO --> DESCARTAR
                    LOSTPACKETS = LOSTPACKETS + 1;  % ---------------> Pacote descartado devido a erro de transmissão
                end
                
                if QUEUEOCCUPATION > 0
                    EventList = [EventList; DEPARTURE, Clock + 8*QUEUE(1,1)/(C*10^6), QUEUE(1,1), QUEUE(1,2)];
                    QUEUEOCCUPATION = QUEUEOCCUPATION - QUEUE(1,1);
                    QUEUE(1,:) = [];
                else
                    STATE = 0;
                end
        end
    end
    
    % Performance parameters determination:
    PL = 100*LOSTPACKETS/TOTALPACKETS;  % Percentagem de pacotes perdidos, incluindo fila e erros de transmissão
    APD = 1000*DELAYS/TRANSPACKETS;     % Atraso médio dos pacotes transmitidos (em milissegundos)
    MPD = 1000*MAXDELAY;                % Atraso máximo dos pacotes transmitidos (em milissegundos)
    TT = 1e-6*TRANSBYTES*8/Clock;       % Throughput transmitido (em Mbps)
    
    end
    
    function out = GeneratePacketSize()
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
    