# Grok_VHDL documentation

FPGA demo repository: synthesizable VHDL `pulse_extender` plus a VUnit + GHDL testbench.

| Document | Content |
|----------|---------|
| [pulse_extender_spec.md](pulse_extender_spec.md) | DUT function, generics, ports, timing, arithmetic libraries |
| [testbench.md](testbench.md) | VUnit layout, test matrix, pass/fail rules |

## Scope (v1)

- Entity `pulse_extender`: async `rst_n`, `i_enable`, pulse stretch by `W + G_EXTEND_CYCLES`
- Libraries: `std_logic_1164` + `numeric_std`. No `std_logic_arith`
- VUnit + GHDL
- Three generic configurations (2 / 5 / 10) and five tests each (15 runs)
