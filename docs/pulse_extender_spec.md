# pulse_extender — functional specification

Pulse stretcher. While `i_pulse` is high and `i_enable` is high the output is high. After `i_pulse` falls, the output stays high for `G_EXTEND_CYCLES` extra clock cycles. High time for an isolated enabled pulse of width `W` is `W + G_EXTEND_CYCLES`.

## Entity

```
entity pulse_extender is
  generic (
    G_EXTEND_CYCLES : positive := 2
  );
  port (
    clk              : in  std_logic;
    rst_n            : in  std_logic;
    i_enable         : in  std_logic;
    i_pulse          : in  std_logic;
    o_pulse_extended : out std_logic
  );
end entity;
```

## Generics

| Generic | Type | Range | Meaning |
|---------|------|-------|---------|
| `G_EXTEND_CYCLES` | `positive` | ≥ 1 | Extra cycles the output stays high after `i_pulse` goes low |

Default `2` matches the shortest planned configuration.

## Ports

| Port | Dir | Active | Domain | Description |
|------|-----|--------|--------|-------------|
| `clk` | in | rising edge | — | System clock |
| `rst_n` | in | low | **async** | Clears counter to 0 and forces `o_pulse_extended = '0'` immediately, independent of `clk` |
| `i_enable` | in | high | sync | Function enable. Sampled on rising `clk`. When `'0'`, output is forced low and the counter is cleared |
| `i_pulse` | in | high | sync | Input pulse, synchronous to `clk`. No async pulse-catch FF |
| `o_pulse_extended` | out | high | registered | Stretched pulse. 1 cycle latency from sampled inputs (except async reset, which is immediate) |

## Timing rules

Let `W` be the number of consecutive rising edges where `i_enable = '1'` and `i_pulse = '1'`.

1. **Async reset:** `rst_n = '0'` → `o_pulse_extended = '0'` and counter = 0 in the same delta, no clock required. While reset is asserted, enable and pulse are ignored.
2. After reset release, output stays low until a rising edge samples `i_enable = '1'` and `i_pulse = '1'`.
3. Rising edge, `i_enable = '1'`, `i_pulse = '1'` → output high next, counter loaded with `G_EXTEND_CYCLES`.
4. Rising edge, `i_enable = '1'`, `i_pulse = '0'`, counter > 0 → output stays high, counter decrements by 1.
5. Rising edge, `i_enable = '1'`, `i_pulse = '0'`, counter = 0 → output low.
6. Isolated enabled pulse: output high for `W + G_EXTEND_CYCLES` cycles, starting the cycle after the first high sample.
7. **Retrigger:** a new high `i_pulse` sample during the tail reloads the counter to `G_EXTEND_CYCLES`. Tail is measured from the last falling sample of `i_pulse`.
8. **Enable low:** rising edge with `i_enable = '0'` → output low and counter = 0, regardless of `i_pulse` and regardless of a running tail. No delayed pulse when enable returns high; a new `i_pulse` is required.
9. `G_EXTEND_CYCLES` is an elaboration-time generic, not a port.

### Example (`G_EXTEND_CYCLES = 2`, `W = 1`, enable held high)

```
cycle          0  1  2  3  4  5  6
clk            r  r  r  r  r  r  r
i_enable       1  1  1  1  1  1  1
i_pulse        0  1  0  0  0  0  0
o_pulse_ext    0  0  1  1  1  0  0
                     |-- W+N=3 --|
```

### Example (`G_EXTEND_CYCLES = 2`, `W = 3`)

```
cycle          0  1  2  3  4  5  6  7  8
i_enable       1  1  1  1  1  1  1  1  1
i_pulse        0  1  1  1  0  0  0  0  0
o_pulse_ext    0  0  1  1  1  1  1  0  0
                     |-- W+N=5 ----|
```

### Example (enable drops during tail)

```
cycle          0  1  2  3  4  5  6
i_enable       1  1  1  1  0  1  1
i_pulse        0  1  0  0  0  0  0
o_pulse_ext    0  0  1  1  1  0  0
```

Cycle 4 samples `i_enable = '0'` → cycle 5 output is low and the remaining stretch is discarded.

## Implementation notes

- VHDL-2008
- Async reset in the clocked process: `if rst_n = '0' then ... elsif rising_edge(clk) then ...`
- Ports and vector signals: `std_logic` / `std_logic_vector`
- Arithmetic and counters: `ieee.numeric_std` only (`unsigned` / `signed`, `to_unsigned`, `resize`)
- Forbidden: `std_logic_arith`, `std_logic_unsigned`, `std_logic_signed`, `std_logic_misc` arithmetic
- One clock domain
- No vendor primitives
- Counter is `unsigned` with width enough to hold `G_EXTEND_CYCLES`

## Out of scope (v1)

- Asynchronous `i_pulse`
- Clock-enable that freezes the counter without clearing it (`i_enable` clears)
- Combinational output gate (output stays registered)
- Synthesis constraints, UCF/XDC, or board bring-up
