# pulse_extender — functional specification

Synchronous pulse stretcher. While `i_pulse` is high the output is high. After `i_pulse` falls, the output stays high for `G_EXTEND_CYCLES` extra clock cycles, then returns low.

## Entity

```
entity pulse_extender is
  generic (
    G_EXTEND_CYCLES : positive := 2
  );
  port (
    clk              : in  std_logic;
    rst_n            : in  std_logic;
    i_pulse          : in  std_logic;
    o_pulse_extended : out std_logic
  );
end entity;
```

Port name is `o_pulse_extended` (spelling corrected from the request).

## Generics

| Generic | Type | Range (v1) | Meaning |
|---------|------|------------|---------|
| `G_EXTEND_CYCLES` | `positive` | ≥ 1 | Number of extra cycles the output stays high after `i_pulse` goes low |

Default `2` matches the shortest planned test.

## Ports

| Port | Dir | Active | Clock | Description |
|------|-----|--------|-------|-------------|
| `clk` | in | rising edge | — | System clock. All sampling and updates on rising edge. |
| `rst_n` | in | low | sync | Synchronous reset. While `rst_n = '0'` the counter is cleared and `o_pulse_extended = '0'`. |
| `i_pulse` | in | high | sync | Input pulse, already synchronous to `clk`. No async pulse-catch FF in v1. |
| `o_pulse_extended` | out | high | registered | Stretched pulse. Registered; 1 cycle input-to-output latency. |

## Timing rules

Let `W` be the number of consecutive cycles `i_pulse = '1'`.

1. Reset: `rst_n = '0'` on a rising edge → `o_pulse_extended = '0'` next, and the stretch counter is 0.
2. After reset release, output is low until a high `i_pulse` is sampled.
3. While `i_pulse = '1'` is sampled, output is high and the stretch counter is loaded with `G_EXTEND_CYCLES`.
4. When `i_pulse = '0'` is sampled and the counter is > 0, output stays high and the counter decrements by 1 each cycle.
5. When `i_pulse = '0'` and the counter reaches 0, output goes low.
6. Result for an isolated pulse: output high for `W + G_EXTEND_CYCLES` cycles, starting the cycle after the first high sample (registered output).
7. Retrigger: a new high sample during the tail reloads the counter to `G_EXTEND_CYCLES`. Output stays high. The tail is measured from the *last* falling edge of `i_pulse`.
8. `G_EXTEND_CYCLES` is constant after elaboration. It is not a run-time input.

### Example (`G_EXTEND_CYCLES = 2`, single-cycle input)

```
cycle          0  1  2  3  4  5  6
clk            r  r  r  r  r  r  r
i_pulse        0  1  0  0  0  0  0
o_pulse_ext    0  0  1  1  1  0  0
               |  |  |-- W+N=3 --|
```

Cycle 1 samples the pulse. Cycles 2..4 output is high (1 cycle of pulse + 2 extend). Cycle 5 output is low.

## Implementation notes (constraints for later RTL)

- VHDL-2008
- `ieee.std_logic_1164` only (no `numeric_std` required unless the counter is `unsigned`)
- One clock domain
- No vendor primitives
- Counter width: `ceil(log2(G_EXTEND_CYCLES+1))` or an integer range `0 to G_EXTEND_CYCLES`

## Out of scope (v1)

- Asynchronous `i_pulse`
- Asynchronous reset assertion
- Enable / clock-gate port
- Saturating vs wrapping behaviour for illegal generic 0 (type `positive` forbids 0)
- Synthesis constraints, UCF/XDC, or board bring-up
