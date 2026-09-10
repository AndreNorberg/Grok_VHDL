# Grok_VHDL

VHDL `pulse_extender` + VUnit/GHDL testbench.

## Spec

- [docs/pulse_extender_spec.md](docs/pulse_extender_spec.md)
- [docs/testbench.md](docs/testbench.md)

Arithmetic rule: `std_logic` / `std_logic_vector` + `ieee.numeric_std`. No `std_logic_arith`.

## Run

Install GHDL and put it on `PATH` first: [docs/README.md](docs/README.md) (Linux and Windows).

```
pip install -r requirements.txt
ghdl --version
python3 run.py
```

15 tests: configs `extend_2`, `extend_5`, `extend_10` × five cases each.

Waveform (one test, GTKWave):

```
python3 run.py -g --gtkwave-fmt=ghw lib.tb_pulse_extender.extend_2.test_pulse_width_1
```

Install GTKWave: [docs/README.md](docs/README.md#waveforms-gtkwave).
