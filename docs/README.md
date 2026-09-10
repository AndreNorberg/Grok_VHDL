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
