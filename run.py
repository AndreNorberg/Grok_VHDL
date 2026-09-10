#!/usr/bin/env python3
from pathlib import Path
from vunit import VUnit

ROOT = Path(__file__).resolve().parent

vu = VUnit.from_argv(compile_builtins=False)
vu.add_vhdl_builtins()

lib = vu.add_library("lib")
lib.add_source_files(str(ROOT / "rtl" / "*.vhd"), vhdl_standard="2008")
lib.add_source_files(str(ROOT / "tb" / "*.vhd"), vhdl_standard="2008")

tb = lib.test_bench("tb_pulse_extender")
for n in (2, 5, 10):
    tb.add_config(name=f"extend_{n}", generics={"G_EXTEND_CYCLES": n})

vu.main()
