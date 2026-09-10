library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

architecture rtl of pulse_extender is

  function width_for(n : positive) return positive is
    variable bits : natural := 0;
    variable rest : natural := n;
  begin
    while rest > 0 loop
      bits := bits + 1;
      rest := rest / 2;
    end loop;
    if bits = 0 then
      return 1;
    end if;
    return bits;
  end function;

  constant C_CNT_WIDTH : positive := width_for(G_EXTEND_CYCLES);
  signal   cnt         : unsigned(C_CNT_WIDTH - 1 downto 0);

begin

  p_stretch : process(clk, rst_n)
  begin
    if rst_n = '0' then
      cnt              <= (others => '0');
      o_pulse_extended <= '0';
    elsif rising_edge(clk) then
      if i_enable = '0' then
        cnt              <= (others => '0');
        o_pulse_extended <= '0';
      elsif i_pulse = '1' then
        cnt              <= to_unsigned(G_EXTEND_CYCLES, C_CNT_WIDTH);
        o_pulse_extended <= '1';
      elsif cnt > 0 then
        cnt              <= cnt - 1;
        o_pulse_extended <= '1';
      else
        o_pulse_extended <= '0';
      end if;
    end if;
  end process;

end architecture;
