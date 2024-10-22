# Simulador de Desempenho de uma Ligação IP Ponto-a-Ponto com Fluxos de Dados e VoIP e BER

O **Sim3A**, implementado em MATLAB, estende o **Sim3** ao adicionar um parâmetro de **Taxa de Erro de Bits (BER)** para simular erros de transmissão. O simulador estima o desempenho de uma ligação IP ponto-a-ponto entre o router de uma empresa e o seu ISP, suportando tanto **fluxos de pacotes de dados** quanto **VoIP (Voice over IP)**. A fila é gerida com uma disciplina **FIFO (First-In, First-Out)**, e pacotes podem ser perdidos por **overflow da fila** ou por **erros de transmissão**.

## Características do Simulador

### Parâmetros de Entrada:
- **λ**: Taxa de chegada de pacotes de dados, em _packets per second_ (pps).
- **C**: Capacidade do link, em _Mbps_.
- **f**: Tamanho da fila, em _Bytes_.
- **P**: Número total de pacotes de dados transmitidos com sucesso (critério de paragem).
- **n**: Número de fluxos VoIP. Cada fluxo VoIP gera pacotes com tamanhos distribuídos entre 110 e 130 bytes e intervalos de chegada distribuídos entre 16 e 24 milissegundos.
- **b**: **Taxa de Erro de Bits (BER)**, que introduz a possibilidade de pacotes transmitidos conterem erros.

### Características do Tráfego:
- O intervalo de tempo entre chegadas de pacotes de dados segue uma distribuição exponencial com média \( 1/\lambda \).
- O tamanho dos pacotes de dados varia entre 64 e 1518 bytes, com as seguintes probabilidades:
  - 19% para pacotes de 64 bytes.
  - 23% para pacotes de 110 bytes.
  - 17% para pacotes de 1518 bytes.
  - Para outros valores de tamanho (65–109 bytes e 111–1517 bytes), a probabilidade é igual.
- Os fluxos **VoIP** geram pacotes com tamanhos uniformemente distribuídos entre 110 e 130 bytes, e os intervalos de chegada variam entre 16 e 24 ms.
```matlab
for i = 1:n
    % Intervalos de chegada uniformemente distribuídos [16 e 24]ms
    tmpVoIP = Clock + 0.016 + (0.024 - 0.016)*rand();  
    % Gerar pacotes VoIP com tamanhos [110 e 130]bytes
    EventList = [EventList; ARRIVAL_VOIP, tmpVoIP, GeneratePacketSizeVoIP(), tmpVoIP];  
end
```

### Parâmetros de Desempenho Estimados:
1. **PLdata (Packet Loss de Dados)**: Percentagem de pacotes de dados perdidos devido a **overflow da fila** ou **erros de transmissão**.

   $$
   PL_{data} = 100 \times \frac{\text{LOSTPACKETS}_{data}}{\text{TOTALPACKETS}_{data}}
   $$

2. **PLVoIP (Packet Loss de VoIP)**: Percentagem de pacotes VoIP perdidos devido a **overflow da fila** ou **erros de transmissão**.

   $$
   PL_{VoIP} = 100 \times \frac{\text{LOSTPACKETS}_{VoIP}}{\text{TOTALPACKETS}_{VoIP}}
   $$

3. **APDdata (Average Packet Delay de Dados)**: Atraso médio dos pacotes de dados transmitidos, em milissegundos.

   $$
   APD_{data} = 1000 \times \frac{\text{DELAYS}_{data}}{\text{TRANSPACKETS}_{data}}
   $$

4. **APDVoIP (Average Packet Delay de VoIP)**: Atraso médio dos pacotes VoIP transmitidos, em milissegundos.

   $$
   APD_{VoIP} = 1000 \times \frac{\text{DELAYS}_{VoIP}}{\text{TRANSPACKETS}_{VoIP}}
   $$

5. **MPDdata (Maximum Packet Delay de Dados)**: Atraso máximo observado nos pacotes de dados, em milissegundos.

   $$
   MPD_{data} = 1000 \times \text{MAXDELAY}_{data}
   $$

6. **MPDVoIP (Maximum Packet Delay de VoIP)**: Atraso máximo observado nos pacotes VoIP, em milissegundos.

   $$
   MPD_{VoIP} = 1000 \times \text{MAXDELAY}_{VoIP}
   $$

7. **TT (Transmitted Throughput)**: _Throughput_ transmitido durante a simulação, em _Mbps_, somando os pacotes de dados e VoIP.

   $$
   TT = 10^{-6} \times \frac{\text{TRANSBYTES}_{data} + \text{TRANSBYTES}_{VoIP} \times 8}{\text{total simulated time}}
   $$

### Simulação de Erros de Transmissão (BER):
O **Sim3A** simula a introdução de **erros de transmissão** com base na **Taxa de Erro de Bits (BER)**. Após cada transmissão de um pacote, é calculada a probabilidade de o pacote conter um erro. Se um erro for detectado, o pacote é descartado e contabilizado em **LOSTPACKETS**.

A fórmula utilizada para calcular a probabilidade de erro num pacote é:

$$
P(\text{erro}) = 1 - (1 - b)^{\text{numBits}}
$$

Onde:
- **`b`** é a **BER**.
- **`numBits`** é o número total de bits no pacote (tamanho do pacote em bytes multiplicado por 8).

Se for detectado um erro, o pacote é descartado.
```matlab
if rand() < 1 - (1 - b)^numBits % --------------------> Pacote transmitido com ERROS (BER) --> DESCARTAR
    if ArrInstant == ARRIVAL_DATA
        LOSTPACKETS_DATA = LOSTPACKETS_DATA + 1;  % Pacote descartado --|DATA|-- devido a erro de transmissão
    else
        LOSTPACKETS_VOIP = LOSTPACKETS_VOIP + 1;  % Pacote descartado --|VoIP|-- devido a erro de transmissão
    end
else % -----------------------------------------------> Pacote TRANSMITIDO COM SUCESSO --> CONTABILIZAR
   % continuation of code ...
end
```

### Eventos no Simulador:
- **ARRIVAL_DATA**: Chegada de um pacote de dados.
- **ARRIVAL_VOIP**: Chegada de um pacote VoIP.
- **DEPARTURE**: Fim da transmissão de um pacote.

### Variáveis de Estado:
- **STATE**: Variável binária que indica se o link está livre ou ocupado.
- **QUEUEOCCUPATION**: Ocupação da fila, em bytes.
- **QUEUE**: Matriz com três colunas, onde cada linha contém o tamanho, o instante de chegada e o tipo (dados ou VoIP) de um pacote na fila.

### Contadores Estatísticos:
- **TOTALPACKETS_DATA**: Número total de pacotes de dados que chegaram ao sistema.
- **LOSTPACKETS_DATA**: Número de pacotes de dados descartados devido a overflow da fila ou erros de transmissão.
- **TRANSPACKETS_DATA**: Número de pacotes de dados transmitidos com sucesso, sem erros de transmissão.
- **TRANSBYTES_DATA**: Soma dos bytes dos pacotes de dados transmitidos.
- **DELAYS_DATA**: Soma dos atrasos dos pacotes de dados transmitidos.
- **MAXDELAY_DATA**: O maior atraso registado entre os pacotes de dados transmitidos.

- **TOTALPACKETS_VOIP**: Número total de pacotes VoIP que chegaram ao sistema.
- **LOSTPACKETS_VOIP**: Número de pacotes VoIP descartados devido a overflow da fila ou erros de transmissão.
- **TRANSPACKETS_VOIP**: Número de pacotes VoIP transmitidos com sucesso, sem erros de transmissão.
- **TRANSBYTES_VOIP**: Soma dos bytes dos pacotes VoIP transmitidos.
- **DELAYS_VOIP**: Soma dos atrasos dos pacotes VoIP transmitidos.
- **MAXDELAY_VOIP**: O maior atraso registado entre os pacotes VoIP transmitidos.

### Critério de Paragem:
A simulação termina quando o $P$-ésimo pacote de **dados** é transmitido com sucesso. Pacotes VoIP e dados compartilham a mesma fila, mas a contagem de pacotes de dados transmitidos é utilizada como critério de paragem.
```matlab
while TRANSPACKETS_DATA + TRANSPACKETS_VOIP < P
```

## Função de Simulação em MATLAB

A função **Sim3A** implementa o simulador e inclui a modelagem de **erros de transmissão (BER)**, além das características do **Sim3**, para calcular os parâmetros de desempenho.

### Exemplo de Utilização
Podes ajustar os parâmetros de entrada como a taxa de pacotes, capacidade do link, tamanho da fila, número de pacotes de dados e fluxos VoIP, e a **BER** para simular diferentes cenários de tráfego e observar o impacto nos parâmetros de desempenho.
