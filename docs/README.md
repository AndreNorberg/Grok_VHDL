# Grok_VHDL documentation

FPGA demo repository: a small synthesizable VHDL design plus a VUnit testbench.

| Document | Content |
|----------|---------|
| [pulse_extender_spec.md](pulse_extender_spec.md) | DUT function, generics, ports, timing |
| [testbench.md](testbench.md) | VUnit layout, the three tests, pass/fail rules |

RTL and testbench source are not in the repo yet. They follow after this spec is reviewed.

## Scope (v1)

- One entity: `pulse_extender`
- One VUnit testbench with three configurations: extend by 2, 5 and 10 clock cycles
- Simulation only (GHDL or NVC via VUnit). No FPGA project files.
