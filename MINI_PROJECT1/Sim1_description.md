# Simulador de Desempenho de uma Ligação IP Ponto-a-Ponto

Este simulador Sim1, implementado em MATLAB, é utilizado para estimar o desempenho de uma ligação IP ponto-a-ponto entre o router de uma empresa e o seu ISP (Internet Service Provider). A simulação é realizada apenas na direção **downstream** (ISP para a empresa), que é tipicamente a direção com maior carga de tráfego.

## Características do Simulador

### Parâmetros de Entrada:
- **λ**: Taxa de chegada de pacotes, em _packets per second_ (pps).
- **C**: Capacidade do link, em _Mbps_.
- **f**: Tamanho da fila, em _Bytes_.
- **P**: Número total de pacotes transmitidos durante a simulação.

### Características do Tráfego:
- O intervalo de tempo entre chegadas de pacotes segue uma distribuição exponencial com média \( 1/\lambda \).
- O tamanho dos pacotes varia entre 64 e 1518 bytes, com as seguintes probabilidades:
  - 19% para pacotes de 64 bytes.
  - 23% para pacotes de 110 bytes.
  - 17% para pacotes de 1518 bytes.
  - Para outros valores de tamanho (65–109 bytes e 111–1517 bytes), a probabilidade é igual.

### Parâmetros de Desempenho Estimados:
1. **PL (Packet Loss)**: Percentagem de pacotes perdidos devido a overflow na fila.

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
- **LOSTPACKETS**: Número de pacotes descartados devido a overflow da fila.
- **TRANSPACKETS**: Número de pacotes transmitidos com sucesso.
- **TRANSBYTES**: Soma dos bytes dos pacotes transmitidos.
- **DELAYS**: Soma dos atrasos dos pacotes transmitidos.
- **MAXDELAY**: O maior atraso registado entre os pacotes transmitidos.

### Critério de Paragem:
A simulação termina quando o \( P \)-ésimo pacote é transmitido. Os pacotes que permanecem na fila no final da simulação não são contabilizados nas estimativas de desempenho.

## Função de Simulação em MATLAB

A função Sim1 implementa este simulador e faz uso das variáveis de estado e dos contadores estatísticos para calcular os parâmetros de desempenho mencionados.

### Exemplo de Utilização
Podes ajustar os parâmetros de entrada, como a taxa de pacotes, capacidade do link, tamanho da fila e número de pacotes, para simular diferentes cenários de tráfego e observar o impacto nos parâmetros de desempenho.

