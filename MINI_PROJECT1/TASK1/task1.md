# TASK1

## 1.a) Conclusions

With the given results for average packet loss and average packet delay across different arrival rates ($\lambda$ values), we can draw the following conclusions:

#### 1. Impact of Increasing Arrival Rate ($\lambda$) on Packet Loss:
- As the arrival rate increases from 1500 pps to 1900 pps, we observe a steady increase in the **average packet loss**:
  - For $\lambda$ = 1500 pps: 0.62% packet loss.
  - For $\lambda$ = 1900 pps: 2.21% packet loss.
- This suggests that the system is experiencing increasing congestion as the arrival rate grows. Higher arrival rates cause more packets to be queued or dropped due to buffer overflow or transmission errors.
- **Conclusion:** The increase in traffic intensity (higher $\lambda$) leads to higher packet loss, indicating that the system is reaching its capacity limits and struggling to handle the load.

#### 2. Impact of Increasing Arrival Rate ($\lambda$) on Average Packet Delay:
- The **average packet delay** also increases with higher arrival rates:
  - For $\lambda$ = 1500 pps: 1.78 ms delay.
  - For $\lambda$ = 1900 pps: 3.49 ms delay.
- This increase in delay can be explained by higher queue occupation. As more packets arrive, they must wait longer in the queue before being transmitted. Thus, the transmission delay increases.
- **Conclusion:** Higher traffic leads to increased queuing delays, causing longer overall packet delays as $\lambda$ approaches the link capacity.

#### 3. Non-linear Growth in Packet Loss and Delay:
- Both packet loss and delay increase **non-linearly** as the arrival rate increases:
  - For $\lambda$ = 1500 to 1600 pps: Small increases in packet loss and delay.
  - For $\lambda$ = 1800 to 1900 pps: Steeper increases in both packet loss and delay.
- This shows that as the system approaches saturation ($\lambda$ = 1900 pps), the performance degrades more rapidly. This non-linearity is typical of systems nearing congestion, where small increases in load lead to disproportionately larger impacts on performance.
- **Conclusion:** The system exhibits non-linear degradation under higher loads, indicating that it is nearing or exceeding its capacity, especially as $\lambda$ approaches 1900 pps.

#### 4. Performance Trade-offs:
- There is a trade-off between arrival rate and system performance:
  - At lower $\lambda$ values (1500 pps), the system handles traffic efficiently with minimal packet loss and delay.
  - At higher $\lambda$ values (1900 pps), both packet loss and delay increase significantly, showing the system's inability to handle traffic beyond its optimal capacity.

#### Overall Conclusion:
The results indicate that the system operates efficiently at lower arrival rates (around 1500–1600 pps), with relatively low packet loss and delay. However, as the arrival rate increases beyond 1700 pps, the system starts to experience congestion, resulting in noticeable increases in both packet loss and delay. At 1900 pps, the system's performance severely degrades, showing signs of congestion and overload. Thus, for reliable performance, the arrival rate should ideally be kept below 1700 pps to avoid significant performance degradation.

These findings emphasize the importance of managing the arrival rate to maintain system performance and prevent congestion in the network.

---

## 1.b) Conclusions

In this experiment, the bit error rate (BER) was increased to $b = 10^{-4}$, and the simulation results were compared with those from 1.a, where the BER was $b = 10^{-6}$. The differences in the performance metrics of **average packet loss** and **average packet delay** across the various arrival rates $\lambda$ allow us to observe the impact of a higher bit error rate on system performance.

#### 1. Impact of Higher Bit Error Rate on Packet Loss:
- The most significant impact of the increased bit error rate is observed in the **average packet loss**:
  - For $\lambda = 1500$ pps, packet loss increases dramatically from 0.63% (at $ b = 10^{-6} $) to 32.83% (at $b = 10^{-4}$).
  - For $ \lambda = 1900 $ pps, packet loss rises from 2.20% to 33.48%.
- This drastic increase in packet loss is due to the higher likelihood of transmission errors. With a bit error rate of $ b = 10^{-4} $, significantly more packets are lost due to errors, regardless of whether the queue is full or not. Thus, packet loss is primarily dominated by transmission errors rather than buffer overflow in this case.
- **Conclusion:** The higher bit error rate has a substantial negative effect on packet loss, causing a sharp increase in dropped packets due to transmission errors.

#### 2. Impact of Higher Bit Error Rate on Average Packet Delay:
- The **average packet delay** also increases with the higher bit error rate:
  - For $ \lambda = 1500 $ pps, the average delay increases from 1.78 ms (at $ b = 10^{-6} $) to 1.60 ms (at $ b = 10^{-4} $).
  - For $ \lambda = 1900 $ pps, the delay increases from 3.48 ms to 3.33 ms.
- This increase is due to the fact that with more packet loss, fewer packets successfully make it through the queue to transmission. The packets that are transmitted may still face delays, but overall queue lengths and waiting times may be shorter due to frequent packet drops from errors.
- **Conclusion:** While the delay increases with the bit error rate, the impact is not as severe as with packet loss. The increased packet loss might reduce the overall queuing time, mitigating the delay somewhat.

#### 3. Comparison of Packet Loss and Delay Between $ b = 10^{-6} $ and $ b = 10^{-4} $:
- For **$ b = 10^{-6} $**:
  - Packet loss was primarily influenced by queue overflow at high traffic loads, with losses ranging from 0.63% to 2.20%.
  - Packet delay was relatively low and increased with traffic, indicating that the system could still handle packets despite minor losses.
- For **$ b = 10^{-4} $**:
  - Packet loss is now dominated by transmission errors, with values consistently above 32%, showing that even at lower traffic levels, a significant portion of packets are lost.
  - The average delay increases more gradually but remains lower than in the case of $ b = 10^{-6} $, reflecting that fewer packets are actually making it to transmission due to errors.

#### 4. Performance Trade-offs:
- With $ b = 10^{-4} $, the system becomes error-prone, and packet losses become the primary concern, far outweighing the effects of queue overflow.
- Delay is less of a concern with higher error rates, as fewer packets are being successfully transmitted through the system, potentially reducing queue sizes and wait times.

#### Overall Conclusion:
The primary conclusion from this comparison is that increasing the bit error rate has a dramatic impact on packet loss. A higher BER causes a sharp increase in packet loss due to transmission errors, even at lower arrival rates. The average packet delay, while increasing, is less severely affected by the higher BER. To maintain reliable performance, it is critical to manage both the arrival rate and the bit error rate, as a high BER can severely degrade system performance, particularly in terms of packet loss.

---

## 1c) Theoretical Average Packet Loss Due to Bit Error Rate

In this task, we are calculating the theoretical average packet loss for **$ b = 10^{-6} $** and **$ b = 10^{-4} $** using the following approach:

#### Step 1: Packet Size Distribution $< \text{based on Simulator} >$

The packet size distribution is given by the following probabilities:

- **19%** of packets are 64 bytes.
- **23%** of packets are 110 bytes.
- **17%** of packets are 1518 bytes.
- The remaining **41%** of packets are uniformly distributed between 65–109 bytes and 111–1517 bytes.

#### Step 2: Average Packet Size Calculation

To compute the theoretical packet loss due to bit errors, we first need to calculate the weighted average packet size based on this distribution:
- Intermediate step:
    - Calculate the **Average size** of the 2 uniform distributions:
        ```matlab
          prob_left = (1 - (0.19 + 0.23 + 0.17)) / ((109 - 65 + 1) + (1517 - 111 + 1));
          avg_bytes = 0.19*64 + 0.23*110 + 0.17*1518 + sum((65:109)*(prob_left)) + sum((111:1517)*(prob_left));
          avg_time = avg_bytes * 8 / capacity;
        ```
- then:
$$
\text{Average Size} = (0.19 \times 64) + (0.23 \times 110) + (0.17 \times 1518) + \left(0.41 \times \left(\frac{87+814}{2}\right) \right) \approx 479.95 \text{ bytes}
$$

This gives an approximation of the expected packet size across different packet sizes.

#### Step 3: Probability of Bit Error in a Packet

$$
P_\text{noError} = (1 - b)^{8 \times PacketSize}
$$

```plaintext
    b               , bit error rate
    8 x PacketSize  , represent the total nº of bits in the packet
```

The probability of at least one bit error in the packet, which causes packet loss, is therefore:

$$
P_\text{error} = 1 - P_\text{noError} = 1 -  (1 - b)^{8 \times PacketSize} 
$$

```plaintext
    P<noError>      , probability of packet contains NO ERROR
    b               , bit error rate
    8 x PacketSize  , represent the total nº of bits in the packet
```

#### Step 4: Average Packet Loss Due to Bit Errors

Now, to compute the theoretical average packet loss due to the bit error rate, we apply the above formula to the average packet size calculated earlier. The average packet loss due to bit errors for **$ b = 10^{-6} $** and **$ b = 10^{-4} $** is given by:

$$
P_{\text{loss}} = 1 - (1 - 10^{-6})^{8 \times \text{Average Size}} \approx  0.00383 \approx 0,38\% 
$$

$$
P_{\text{loss}} = 1 - (1 - 10^{-4})^{8 \times \text{Average Size}} \approx 0.31885 \approx 31,89\%
$$

#### Step 5: Results

#### Simulated Values:
- **$ b = 10^{-6} $**
  - For lambda = 1500 pps: Packet loss: **0.62 ± 0.01%**
  - For lambda = 1600 pps: Packet loss: **0.77 ± 0.01%**
  - For lambda = 1700 pps: Packet loss: **1.03 ± 0.02%**
  - For lambda = 1800 pps: Packet loss: **1.50 ± 0.03%**
  - For lambda = 1900 pps: Packet loss: **2.21 ± 0.04%**

- **$ b = 10^{-4} $**
  - For lambda = 1500 pps: Packet loss: **32.83 ± 0.04%**
  - For lambda = 1600 pps: Packet loss: **32.88 ± 0.04%**
  - For lambda = 1700 pps: Packet loss: **33.04 ± 0.06%**
  - For lambda = 1800 pps: Packet loss: **33.21 ± 0.05%**
  - For lambda = 1900 pps: Packet loss: **33.48 ± 0.06%**

#### Comparison and Conclusions:

1. **For $ b = 10^{-6} $**:
   - The theoretical packet loss due to bit errors is **2.29%**, which is higher than the simulated packet losses for all values of **λ** except **λ = 1900 pps** (simulated loss of **2.21 ± 0.04%**).
   - The reason for this is that in the simulation, packet loss is not solely due to bit errors; queue overflow plays a significant role, especially at higher traffic loads. As the arrival rate increases, the queue fills up more frequently, causing more packet drops due to overflow. Thus, at lower **λ**, bit errors have a minimal effect compared to queu∞e overflows.
   - As **λ** increases, the simulated packet loss approaches the theoretical value, indicating that both bit errors and queue overflow contribute significantly at higher traffic loads.

2. **For $ b = 10^{-4} $**:
   - The theoretical packet loss due to bit errors is **90.13%**, which is much higher than the simulated packet losses (around **33%** for all values of **λ**).
   - In this case, packet loss is almost entirely dominated by bit errors, as the higher bit error rate causes more packets to be dropped due to transmission errors. However, the simulated packet losses are significantly lower than the theoretical packet loss. This discrepancy can be explained by the fact that in the simulation, even though bit errors are frequent, many packets are dropped due to queue overflow before they are even transmitted and affected by bit errors. Thus, the actual packet loss percentage is lower than the theoretical calculation based on bit errors alone.
   - The fact that the simulated packet loss remains roughly constant across all values of **λ** suggests that, at this high bit error rate, the queue overflow plays a relatively minor role, and bit errors dominate the packet loss.

3. **General Conclusion**:
   - The theoretical packet loss due to bit errors provides an upper bound on the loss that can be attributed to transmission errors alone.
   - In practice, as seen in the simulation, packet loss is influenced by both bit errors and queue overflow. For lower **λ** values and low bit error rates (**$ b = 10^{-6} $**), queue overflow dominates packet loss. As **λ** increases, bit errors contribute more significantly.
   - For higher bit error rates (**$ b = 10^{-4} $**), bit errors dominate packet loss, even though the actual simulated loss is lower than the theoretical value due to queue management.