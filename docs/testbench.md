# pulse_extender — VUnit testbench

## Layout

```
Grok_VHDL/
  run.py                         # VUnit entry point
  rtl/pulse_extender.vhd         # DUT
  tb/tb_pulse_extender.vhd       # testbench
  docs/                          # this specification
```

Simulator is selected in `run.py` (GHDL preferred, NVC acceptable). No vendor sim in v1.

## How the bench is built

One testbench entity `tb_pulse_extender` with the same generic as the DUT:

```
generic (
  runner_cfg       : string;
  G_EXTEND_CYCLES  : positive := 2
);
```

The DUT is instantiated once, generic map `G_EXTEND_CYCLES`. VUnit does **not** change a generic at runtime. The three lengths are three **configurations** added in `run.py`:

| Config name | `G_EXTEND_CYCLES` |
|-------------|-------------------|
| `extend_2`  | 2 |
| `extend_5`  | 5 |
| `extend_10` | 10 |

Each configuration is a separate VUnit test run (own elaboration, own waveform).

Clock: 10 ns period (100 MHz). Period is a TB convenience; the DUT is specified in cycles only.

Reset sequence, every test:

1. `i_pulse <= '0'`
2. `rst_n <= '0'` for 3 rising edges
3. `rst_n <= '1'`
4. 2 idle cycles
5. Assert `o_pulse_extended = '0'` before stimulus

Helpers in the TB (procedures):

| Procedure | Role |
|-----------|------|
| `wait_cycles(n)` | Wait `n` rising edges |
| `pulse_for(n)` | Drive `i_pulse = '1'` for `n` cycles, then `'0'` |
| `expect_high(n)` | Check `o_pulse_extended = '1'` for `n` consecutive cycles |
| `expect_low(n)` | Check `o_pulse_extended = '0'` for `n` consecutive cycles |

Checks use VUnit `check_equal` on `o_pulse_extended`, sampled after `rising_edge(clk)`.

Watchdog: VUnit default test timeout. No extra watchdog process.

## Test cases

All three cases use the same stimulus. Only `G_EXTEND_CYCLES` changes. Expected high time is `W + G_EXTEND_CYCLES` with `W = 1`.

Registered output: the first high output is the cycle *after* the first high input sample.

### TC1 — `extend_2`

- Config: `G_EXTEND_CYCLES = 2`
- Stimulus: single-cycle `i_pulse`
- Expect: `o_pulse_extended` high for **3** cycles, then low for at least 3 cycles
- Also: output low during reset and the 2 idle cycles before the pulse

### TC2 — `extend_5`

- Config: `G_EXTEND_CYCLES = 5`
- Stimulus: identical to TC1
- Expect: high for **6** cycles, then low for at least 3 cycles

### TC3 — `extend_10`

- Config: `G_EXTEND_CYCLES = 10`
- Stimulus: identical to TC1
- Expect: high for **11** cycles, then low for at least 3 cycles

## Pass / fail

A test fails if any `check_equal` fails (wrong level on a sampled cycle) or if the VUnit runner times out.

A test passes only if:

- output is low through reset + pre-pulse idle
- output is high for exactly `1 + G_EXTEND_CYCLES` consecutive cycles after the latency cycle
- output is low for 3 cycles after that

No coverage of multi-cycle `i_pulse`, back-to-back pulses, or reset-during-stretch in v1.

## run.py responsibilities

- Create a VUnit project
- Add `rtl/*.vhd` and `tb/*.vhd`
- Add the three configs on `tb_pulse_extender`
- Default action: run all three
