# Simulador de Desempenho de uma Ligação IP Ponto-a-Ponto com BER

Este simulador, **Sim2**, implementado em MATLAB, é uma versão aprimorada do **Sim1** para estimar o desempenho de uma ligação IP ponto-a-ponto entre o router de uma empresa e o seu ISP (Internet Service Provider). Além das características do simulador **Sim1**, o **Sim2** considera a introdução de **erros de transmissão** devido à **taxa de erro de bits** (**BER**), o que permite uma simulação mais realista de uma ligação através de redes sem fios, como 4G/5G, onde os pacotes podem ser descartados tanto por **overflow** da fila quanto por **erros de transmissão**.

## Características do Simulador

### Parâmetros de Entrada:
- **λ**: Taxa de chegada de pacotes, em _packets per second_ (pps).
- **C**: Capacidade do link, em _Mbps_.
- **f**: Tamanho da fila, em _Bytes_.
- **P**: Número total de pacotes transmitidos com sucesso (critério de paragem).
- **b**: **Bit Error Rate** (taxa de erro de bits).

### Características do Tráfego:
- O intervalo de tempo entre chegadas de pacotes segue uma distribuição exponencial com média \( 1/\lambda \).
- O tamanho dos pacotes varia entre 64 e 1518 bytes, com as seguintes probabilidades:
  - 19% para pacotes de 64 bytes.
  - 23% para pacotes de 110 bytes.
  - 17% para pacotes de 1518 bytes.
  - Para outros valores de tamanho (65–109 bytes e 111–1517 bytes), a probabilidade é igual.


### Parâmetros de Desempenho Estimados:
1. **PL (Packet Loss)**: Percentagem de pacotes perdidos devido a **overflow da fila** ou **erros de transmissão**.

   $$
   PL = 100 \times \frac{\text{LOSTPACKETS}}{\text{TOTALPACKETS}}
   $$

2. **APD (Average Packet Delay)**: Atraso médio dos pacotes transmitidos, em milissegundos.

   $$
   APD = 1000 \times \frac{\text{DELAYS}}{\text{TRANSPACKETS}}
   $$

3. **MPD (Maximum Packet Delay)**: Atraso máximo observado durante a simulação, em milissegundos.

   $$
   MPD = 1000 \times \text{MAXDELAY}
   $$

4. **TT (Transmitted Throughput)**: _Throughput_ transmitido durante a simulação, em _Mbps_.

   $$
   TT = 10^{-6} \times \frac{\text{TRANSBYTES} \times 8}{\text{total simulated time}}
   $$

### Eventos no Simulador:
- **ARRIVAL**: Chegada de um pacote.
- **DEPARTURE**: Fim da transmissão de um pacote.

### Variáveis de Estado:
- **STATE**: Variável binária que indica se o link está livre ou ocupado.
- **QUEUEOCCUPATION**: Ocupação da fila, em bytes.
- **QUEUE**: Matriz com duas colunas, onde cada linha contém o tamanho e o instante de chegada de um pacote à fila.

### Contadores Estatísticos:
- **TOTALPACKETS**: Número total de pacotes que chegaram ao sistema.
- **LOSTPACKETS**: Número de pacotes descartados devido a **overflow da fila** ou **erros de transmissão**.
- **TRANSPACKETS**: Número de pacotes transmitidos com sucesso, sem erros de transmissão.
- **TRANSBYTES**: Soma dos bytes dos pacotes transmitidos.
- **DELAYS**: Soma dos atrasos dos pacotes transmitidos.
- **MAXDELAY**: O maior atraso registado entre os pacotes transmitidos.

### Critério de Paragem:
A simulação termina quando o $P$-ésimo pacote **sem erros** é transmitido com sucesso. Os pacotes que permanecem na fila no final da simulação, ou que são transmitidos com erros, não são contabilizados nas estimativas de desempenho.

### Simulação de Erros de Transmissão (BER):
O simulador **Sim2** introduz a simulação de erros de transmissão com base na **taxa de erro de bits** (**BER**). Após cada transmissão de um pacote, o simulador calcula a probabilidade de o pacote conter um erro de transmissão. Se um erro for detectado, o pacote é descartado.

A fórmula utilizada para simular os erros de transmissão é:

$$
P(\text{erro}) = 1 - (1 - b)^{\text{numBits}}
$$

Onde:
- **`b`** é a **BER** (taxa de erro de bits).
- **`numBits`** é o número total de bits no pacote (tamanho do pacote em bytes multiplicado por 8).

Se um erro for detetado, o pacote é descartado e contabilizado em **LOSTPACKETS**.

```matlab
numBits = PacketSize * 8;  % ------------------------> Número de bits do pacote transmitido
if rand() < 1 - (1 - b)^numBits
   % -----------------------------------------------> Pacote CONTÉM ERRO --> DESCARTAR
   LOSTPACKETS = LOSTPACKETS + 1;  % ---------------> Pacote descartado devido a erro de transmissão
else
   % -----------------------------------------------> Pacote TRANSMITIDO COM SUCESSO --> CONTABILIZAR
   TRANSBYTES = TRANSBYTES + PacketSize;
   DELAYS = DELAYS + (Clock - ArrInstant);
   if Clock - ArrInstant > MAXDELAY
      MAXDELAY = Clock - ArrInstant;
   end
   TRANSPACKETS = TRANSPACKETS + 1;  % -------------> Contar como transmissão bem sucedida
end
```

## Função de Simulação em MATLAB

A função **Sim2** implementa este simulador e faz uso das variáveis de estado e dos contadores estatísticos para calcular os parâmetros de desempenho mencionados, além de considerar a introdução de erros de transmissão com base no parâmetro **BER**.

### Exemplo de Utilização
Podes ajustar os parâmetros de entrada, como a taxa de pacotes, capacidade do link, tamanho da fila, número de pacotes e **BER**, para simular diferentes cenários de tráfego e observar o impacto nos parâmetros de desempenho.
