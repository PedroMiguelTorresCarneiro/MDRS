# Simulador de Desempenho com Prioridade VoIP

O **Sim4**, implementado em MATLAB, estende o **Sim3** ao considerar que pacotes de **VoIP** têm **prioridade** sobre pacotes de dados na fila de transmissão. O simulador é usado para estimar o desempenho de uma ligação IP ponto-a-ponto entre o router de uma empresa e o seu ISP, gerenciando **fluxos de pacotes de dados e VoIP** em uma fila compartilhada.

## Características do Simulador

### Parâmetros de Entrada:
- **λ**: Taxa de chegada de pacotes de dados, em _packets per second_ (pps).
- **C**: Capacidade do link, em _Mbps_.
- **f**: Tamanho da fila, em _Bytes_.
- **P**: Número total de pacotes de dados transmitidos com sucesso (critério de paragem).
- **n**: Número de fluxos VoIP. Cada fluxo VoIP gera pacotes com tamanhos distribuídos entre 110 e 130 bytes e intervalos de chegada distribuídos entre 16 e 24 milissegundos.

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
1. **PLdata (Packet Loss de Dados)**: Percentagem de pacotes de dados perdidos devido a **overflow da fila**.

   $$
   PL_{data} = 100 \times \frac{\text{LOSTPACKETS}_{data}}{\text{TOTALPACKETS}_{data}}
   $$

2. **PLVoIP (Packet Loss de VoIP)**: Percentagem de pacotes VoIP perdidos devido a **overflow da fila**.

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

### Implementação da Prioridade VoIP:
A principal modificação do **Sim4** em relação ao **Sim3** é a **prioridade dos pacotes VoIP**. A fila de pacotes é ordenada para que pacotes VoIP sejam sempre processados antes de pacotes de dados. Isso é feito ao **ordenar a fila** de forma decrescente pelo tipo de pacote (dando prioridade ao **VoIP**), garantindo que pacotes VoIP sejam transmitidos primeiro.
```matlab 
QUEUE = sortrows(QUEUE, 3, "descend");
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
- **LOSTPACKETS_DATA**: Número de pacotes de dados descartados devido a overflow da fila.
- **TRANSPACKETS_DATA**: Número de pacotes de dados transmitidos com sucesso.
- **TRANSBYTES_DATA**: Soma dos bytes dos pacotes de dados transmitidos.
- **DELAYS_DATA**: Soma dos atrasos dos pacotes de dados transmitidos.
- **MAXDELAY_DATA**: O maior atraso registado entre os pacotes de dados transmitidos.

- **TOTALPACKETS_VOIP**: Número total de pacotes VoIP que chegaram ao sistema.
- **LOSTPACKETS_VOIP**: Número de pacotes VoIP descartados devido a overflow da fila.
- **TRANSPACKETS_VOIP**: Número de pacotes VoIP transmitidos com sucesso.
- **TRANSBYTES_VOIP**: Soma dos bytes dos pacotes VoIP transmitidos.
- **DELAYS_VOIP**: Soma dos atrasos dos pacotes VoIP transmitidos.
- **MAXDELAY_VOIP**: O maior atraso registado entre os pacotes VoIP transmitidos.

### Critério de Paragem:
A simulação termina quando o $P$-ésimo pacote de **dados** é transmitido com sucesso. Pacotes VoIP e dados compartilham a mesma fila, mas a contagem de pacotes de dados transmitidos é utilizada como critério de paragem.
```matlab
while TRANSPACKETS_DATA + TRANSPACKETS_VOIP < P 
```

## Função de Simulação em MATLAB

A função **Sim4** implementa o simulador, priorizando pacotes **VoIP** na fila de transmissão. Pacotes de dados são enfileirados e transmitidos apenas se não houver pacotes VoIP na fila.

### Exemplo de Utilização
Podes ajustar os parâmetros de entrada como a taxa de pacotes, capacidade do link, tamanho da fila, número de pacotes de dados e fluxos VoIP, para simular diferentes cenários de tráfego e observar o impacto nos parâmetros de desempenho.
