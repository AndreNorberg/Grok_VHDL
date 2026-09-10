# Grok_VHDL documentation

FPGA demo repository: synthesizable VHDL `pulse_extender` plus a VUnit + GHDL testbench.

| Document | Content |
|----------|---------|
| [pulse_extender_spec.md](pulse_extender_spec.md) | DUT function, generics, ports, timing, arithmetic libraries |
| [testbench.md](testbench.md) | VUnit layout, test matrix, pass/fail rules |
| This file | GHDL, PATH, GTKWave |

## Scope (v1)

- Entity `pulse_extender`: async `rst_n`, `i_enable`, pulse stretch by `W + G_EXTEND_CYCLES`
- Libraries: `std_logic_1164` + `numeric_std`. No `std_logic_arith`
- VUnit + GHDL
- Three generic configurations (2 / 5 / 10) and five tests each (15 runs)

## Install GHDL

VUnit finds GHDL by running `ghdl` from `PATH`. After install, `ghdl --version` must work in the same terminal you use for `python3 run.py`.

Official packages: [GHDL Getting | Installing](https://ghdl.github.io/ghdl/getting.html). Releases: [github.com/ghdl/ghdl/releases](https://github.com/ghdl/ghdl/releases).

### Linux

Debian / Ubuntu:

```
sudo apt-get update
sudo apt-get install -y ghdl
ghdl --version
```

`apt` puts `ghdl` in `/usr/bin`. That directory is already on `PATH`. No extra PATH step.

Fedora:

```
sudo dnf install ghdl
ghdl --version
```

Arch:

```
sudo pacman -S ghdl-gcc
```

Tarball (any distro), if the package is too old:

1. Download an Ubuntu/Linux asset from [GHDL releases](https://github.com/ghdl/ghdl/releases).
2. Extract, e.g. to `$HOME/opt/ghdl`.
3. Add the `bin` directory to `PATH` (see below).

### Windows

Two usable setups. Pick one.

**A. Standalone zip (cmd / PowerShell)**

1. Download the Windows standalone `.zip` from [GHDL releases](https://github.com/ghdl/ghdl/releases) (not the MSYS2 `.pkg.tar.zst`).
2. Extract to a path without spaces if possible, e.g. `C:\ghdl`.
3. Add `C:\ghdl\bin` (the folder that contains `ghdl.exe`) to `PATH`.
4. Open a **new** terminal. Run `ghdl --version`.

**B. MSYS2 / MinGW64**

1. Install [MSYS2](https://www.msys2.org/).
2. In the MSYS2 MINGW64 shell:

```
pacman -S mingw-w64-x86_64-ghdl-mcode
ghdl --version
```

(`mingw-w64-x86_64-ghdl-llvm` is the LLVM backend; either works with this repo.)

`ghdl.exe` lands in `C:\msys64\mingw64\bin`. Use that shell, or add that folder to the Windows `PATH` if you want GHDL from PowerShell.

WinGet, if the package is published on the machine:

```
winget search ghdl
winget install <id from search>
```

Still add the install `bin` folder to `PATH` if `ghdl` is not found afterwards.

## Add GHDL to PATH

### Linux

Session only:

```
export PATH="$HOME/opt/ghdl/bin:$PATH"
hash -r
ghdl --version
```

Persistent (bash). Append to `~/.bashrc` (or `~/.profile`):

```
export PATH="$HOME/opt/ghdl/bin:$PATH"
```

Then `source ~/.bashrc` or open a new terminal.

Persistent (zsh): same line in `~/.zshrc`.

Replace `$HOME/opt/ghdl/bin` with the directory that actually contains the `ghdl` binary (`which ghdl` after a working session).

### Windows

**PowerShell, current user, persistent:**

```
[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\ghdl\bin",
  "User")
```

Close the terminal and open a new one. Check:

```
$env:Path -split ';' | Select-String ghdl
ghdl --version
```

**GUI:**

1. Start menu → “environment variables” → *Edit environment variables for your account*.
2. User variable `Path` → Edit → New.
3. Add the folder that contains `ghdl.exe` (e.g. `C:\ghdl\bin` or `C:\msys64\mingw64\bin`).
4. OK on all dialogs. New terminal required.

**Current cmd session only:**

```
set PATH=C:\ghdl\bin;%PATH%
ghdl --version
```

Do not add `ghdl.exe` itself to `PATH`. Add the directory.

## Waveforms (GTKWave)

Yes. GHDL writes a dump; **GTKWave** displays it. VUnit can start GTKWave after a test (`-g` / `--gui`).

Format for this repo: **GHW** (`--wave=`). It keeps VHDL types (`std_logic`, arrays). VCD works too (`--vcd=`) but drops some VHDL types.

### Dump one test and open GTKWave

`gtkwave` must be on `PATH`. Run **one** test, not the full suite:

```
python3 run.py -g --gtkwave-fmt=ghw lib.tb_pulse_extender.extend_2.test_pulse_width_1
```

VUnit 4.7 flags: `-g` / `--gui`, `--gtkwave-fmt={ghw,vcd}`. Later VUnit also accepts `--viewer gtkwave` and `--viewer-fmt ghw`.

If GTKWave does not start, dump only and open the file yourself:

```
python3 run.py --gtkwave-fmt=ghw lib.tb_pulse_extender.extend_2.test_pulse_width_1
```

Dump location:

```
vunit_out/test_output/lib.tb_pulse_extender.extend_2.test_pulse_width_1_<hash>/ghdl/wave.ghw
```

Exact path is printed in the test output. Then:

```
gtkwave path/to/wave.ghw
```

### Signals in GTKWave

1. SST / hierarchy on the left: `tb_pulse_extender` → `dut`
2. Select `clk`, `rst_n`, `i_enable`, `i_pulse`, `o_pulse_extended` (and `cnt` if you want the stretch counter)
3. Append / drag them into the wave pane
4. Time zoom: `+` / `-`, or View → Zoom Full
5. File → Write Save File (`.gtkw`) if you want the same signal layout next time:

```
gtkwave wave.ghw view.gtkw
```

### Install GTKWave

**Linux (Debian / Ubuntu):**

```
sudo apt-get install -y gtkwave
gtkwave --version
```

`apt` puts it on `PATH` already.

**Linux (Fedora):** `sudo dnf install gtkwave`

**Linux (Arch):** `sudo pacman -S gtkwave`

**Windows, standalone:** download a Windows build from [gtkwave/gtkwave](https://github.com/gtkwave/gtkwave) or the older SourceForge packages. Add the folder that contains `gtkwave.exe` to `PATH` (same method as GHDL).

**Windows, MSYS2 MINGW64:**

```
pacman -S mingw-w64-x86_64-gtkwave
gtkwave --version
```

Binary: `C:\msys64\mingw64\bin\gtkwave.exe`. Use the MINGW64 shell, or add that `bin` directory to the Windows `PATH`.

Check from the same terminal as `run.py`:

```
gtkwave --version
```
