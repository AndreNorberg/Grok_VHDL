# pulse_extender — VUnit testbench

## Layout

```
Grok_VHDL/
  run.py                         # VUnit entry; simulator = GHDL
  rtl/pulse_extender.vhd         # DUT
  tb/tb_pulse_extender.vhd       # testbench
  docs/                          # this specification
```

Simulator: **GHDL only** (`vu = VUnit.from_argv(); ...` with GHDL as the simulator). No NVC, no vendor sim.

## How the bench is built

One testbench entity `tb_pulse_extender`:

```
generic (
  runner_cfg       : string;
  G_EXTEND_CYCLES  : positive := 2
);
```

DUT instantiated once, generic mapped to `G_EXTEND_CYCLES`. Three VUnit configurations in `run.py`:

| Config name | `G_EXTEND_CYCLES` |
|-------------|-------------------|
| `extend_2`  | 2 |
| `extend_5`  | 5 |
| `extend_10` | 10 |

Each configuration elaborates the TB separately. Inside the TB, several named tests run for every configuration (`if run("test_...")`).

Clock: 10 ns period. DUT behaviour is specified in cycles only.

Reset sequence, every test:

1. `i_pulse <= '0'`, `i_enable <= '1'`
2. `rst_n <= '0'` (async). Check `o_pulse_extended = '0'` before the next clock edge
3. Hold reset ≥ 3 rising edges
4. `rst_n <= '1'`
5. 2 idle cycles
6. Check output still low

Helpers:

| Procedure | Role |
|-----------|------|
| `wait_cycles(n)` | Wait `n` rising edges |
| `pulse_for(n)` | Drive `i_pulse = '1'` for `n` cycles, then `'0'` |
| `expect_high(n)` | `check_equal` output `'1'` for `n` consecutive cycles |
| `expect_low(n)` | `check_equal` output `'0'` for `n` consecutive cycles |

Samples after `rising_edge(clk)`, except the async-reset check which is combinational on `rst_n`.

## Test matrix

Every test below runs under all three configurations. Expected high time: `W + G_EXTEND_CYCLES`. First high output is the cycle after the first enabled high input sample.

| Test name | `W` | Enable | Expect |
|-----------|-----|--------|--------|
| `test_pulse_width_1` | 1 | held `'1'` | high `1+N` cycles, then low ≥ 3 |
| `test_pulse_width_3` | 3 | held `'1'` | high `3+N` cycles, then low ≥ 3 |
| `test_pulse_width_4` | 4 | held `'1'` | high `4+N` cycles, then low ≥ 3 |
| `test_enable_low_masks_pulse` | 1 | `'0'` during the pulse | output stays low |
| `test_enable_clears_tail` | 1 | drop enable mid-tail | output low the cycle after enable is sampled `'0'`; stays low after enable returns `'1'` (no leftover count) |

`N` = `G_EXTEND_CYCLES`.

### `test_pulse_width_1`

Single-cycle `i_pulse`, `i_enable = '1'`.

| Config | High cycles |
|--------|-------------|
| `extend_2` | 3 |
| `extend_5` | 6 |
| `extend_10` | 11 |

### `test_pulse_width_3`

`i_pulse` high for 3 cycles.

| Config | High cycles |
|--------|-------------|
| `extend_2` | 5 |
| `extend_5` | 8 |
| `extend_10` | 13 |

### `test_pulse_width_4`

`i_pulse` high for 4 cycles.

| Config | High cycles |
|--------|-------------|
| `extend_2` | 6 |
| `extend_5` | 9 |
| `extend_10` | 14 |

### `test_enable_low_masks_pulse`

`i_enable = '0'`, then `pulse_for(1)`, wait `1+N+3` cycles. `o_pulse_extended` must stay `'0'`.

### `test_enable_clears_tail`

`i_enable = '1'`, `pulse_for(1)`, wait until output is high, then set `i_enable = '0'` for 2 cycles, then `i_enable = '1'` again with `i_pulse = '0'`. Output must go low after the disabled sample and must not return high.

## Pass / fail

Fail: any `check_equal` mismatch, or VUnit timeout.

Pass for width tests: low through async reset + idle; high for exactly `W+N` consecutive cycles; low for 3 cycles after.

Total runs: 3 configs × 5 tests = 15.

## run.py responsibilities

- VUnit project, GHDL
- Add `rtl/*.vhd` and `tb/*.vhd`
- Add configs `extend_2`, `extend_5`, `extend_10`
- Default action: run all 15
