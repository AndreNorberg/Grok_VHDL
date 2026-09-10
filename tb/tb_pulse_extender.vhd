library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_pulse_extender is
  generic (
    runner_cfg      : string;
    G_EXTEND_CYCLES : positive := 2
  );
end entity;

architecture tb of tb_pulse_extender is

  constant C_CLK_PERIOD : time := 10 ns;

  signal clk              : std_logic := '0';
  signal rst_n            : std_logic := '0';
  signal i_enable         : std_logic := '0';
  signal i_pulse          : std_logic := '0';
  signal o_pulse_extended : std_logic;

begin

  clk <= not clk after C_CLK_PERIOD / 2;

  dut : entity work.pulse_extender
    generic map (
      G_EXTEND_CYCLES => G_EXTEND_CYCLES
    )
    port map (
      clk              => clk,
      rst_n            => rst_n,
      i_enable         => i_enable,
      i_pulse          => i_pulse,
      o_pulse_extended => o_pulse_extended
    );

  test_runner : process
    procedure wait_cycles(n : natural) is
    begin
      for i in 1 to n loop
        wait until rising_edge(clk);
      end loop;
    end procedure;

    procedure pulse_for(n : positive) is
    begin
      i_pulse <= '1';
      wait_cycles(n);
      i_pulse <= '0';
    end procedure;

    procedure expect_high(n : positive) is
    begin
      for i in 1 to n loop
        wait until rising_edge(clk);
        check_equal(o_pulse_extended, '1', "expected high, beat " & integer'image(i));
      end loop;
    end procedure;

    procedure expect_low(n : positive) is
    begin
      for i in 1 to n loop
        wait until rising_edge(clk);
        check_equal(o_pulse_extended, '0', "expected low, beat " & integer'image(i));
      end loop;
    end procedure;

    -- First rising edge samples the pulse (output still 0).
    -- Output is then high for W+N cycles: W-1 while pulse stays high,
    -- then N+1 after pulse returns low.
    procedure apply_pulse_and_check_width(w : positive) is
    begin
      i_pulse <= '1';
      wait until rising_edge(clk);
      if w > 1 then
        for i in 2 to w loop
          wait until rising_edge(clk);
          check_equal(o_pulse_extended, '1', "high during input pulse, beat " & integer'image(i));
        end loop;
      end if;
      i_pulse <= '0';
      expect_high(G_EXTEND_CYCLES + 1);
      expect_low(3);
    end procedure;

    procedure apply_reset is
    begin
      i_pulse  <= '0';
      i_enable <= '1';
      rst_n    <= '0';
      wait for 1 ns;
      check_equal(o_pulse_extended, '0', "async reset must force output low");
      wait_cycles(3);
      rst_n <= '1';
      wait_cycles(2);
      check_equal(o_pulse_extended, '0', "output low after reset idle");
    end procedure;

  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("test_pulse_width_1") then
        apply_reset;
        apply_pulse_and_check_width(1);

      elsif run("test_pulse_width_3") then
        apply_reset;
        apply_pulse_and_check_width(3);

      elsif run("test_pulse_width_4") then
        apply_reset;
        apply_pulse_and_check_width(4);

      elsif run("test_enable_low_masks_pulse") then
        apply_reset;
        i_enable <= '0';
        wait_cycles(1);
        pulse_for(1);
        expect_low(1 + G_EXTEND_CYCLES + 3);

      elsif run("test_enable_clears_tail") then
        apply_reset;
        pulse_for(1);
        wait until rising_edge(clk);
        check_equal(o_pulse_extended, '1', "tail must start after the pulse sample");
        i_enable <= '0';
        wait_cycles(2);
        check_equal(o_pulse_extended, '0', "enable low must clear output");
        i_enable <= '1';
        expect_low(G_EXTEND_CYCLES + 2);
      end if;
    end loop;

    test_runner_cleanup(runner);
  end process;

  test_runner_watchdog(runner, 100 us);

end architecture;
