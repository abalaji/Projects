-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: tb.vhd
--
-- Description: This file implements a testbench for the Fibonacci
-- calculator. 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity tb is
end tb;

architecture behavior of tb is

  constant TEST_WIDTH : positive := 32;
  constant MAX_INPUT  : positive := 40;
-- constant TIMEOUT : time := MAX_INPUT*20ns;
  constant MAX_CYCLES : integer  := MAX_INPUT*4;

  signal clk  : std_logic                               := '0';
  signal rst  : std_logic                               := '1';
  signal addr : std_logic_vector(TEST_WIDTH-1 downto 0) := (others => '0');
  signal en   : std_logic                               := '0';
  signal wen  : std_logic                               := '0';
  signal din  : std_logic_vector(TEST_WIDTH-1 downto 0) := (others => '0');
  signal dout : std_logic_vector(TEST_WIDTH-1 downto 0);

  signal sim_done : std_logic := '0';

begin

  UUT : entity work.fib_h101
    port map (
      dt_clk => clk,
      reset  => rst,
      addr   => addr,
      en     => en,
      wen    => wen,
      din    => din,
      dout   => dout);

  -- toggle clock
  clk <= not clk after 5 ns when sim_done = '0' else clk;

  -- process to test different inputs
  process

    function checkOutput (
      in1 : integer)
      return unsigned is

      variable i, x, y, temp : integer;
    begin

      i := 3;
      x := 1;
      y := 1;

      while (to_unsigned(i, TEST_WIDTH) <= to_unsigned(in1, TEST_WIDTH)) loop

        temp := x+y;
        x    := y;
        y    := temp;
        i    := i + 1;
      end loop;

      return to_unsigned(y, TEST_WIDTH);
    end checkOutput;

    variable errors       : integer := 0;
    variable total_points : real    := 50.0;
    variable min_grade    : real    := total_points*0.25;
    variable grade        : real;

    variable result : std_logic_vector(TEST_WIDTH-1 downto 0);
    variable done   : std_logic;
    variable count  : integer;

  begin

    -- reset circuit  
    rst <= '1';
    wait for 200 ns;
    rst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    for i in 1 to MAX_INPUT-1 loop

      -- send n = i over memory map
      addr <= C_N_ADDR;
      en   <= '1';
      wen  <= '1';
      din  <= std_logic_vector(to_unsigned(i, TEST_WIDTH));
      wait until clk'event and clk = '1';

      -- send go = 1 over memory map
      addr <= C_GO_ADDR;
      en   <= '1';
      wen  <= '1';
      din  <= std_logic_vector(to_unsigned(1, TEST_WIDTH));
      wait until clk'event and clk = '1';

      -- send go = 0 over memory map
      addr <= C_GO_ADDR;
      en   <= '1';
      wen  <= '1';
      din  <= std_logic_vector(to_unsigned(0, TEST_WIDTH));
      wait until clk'event and clk = '1';

      done  := '0';
      count := 0;

      -- equivalent to wait until (done = '1') for TIMEOUT;      
      while done = '0' and count < MAX_CYCLES loop

        -- read done signal using memory map
        addr <= C_DONE_ADDR;
        en   <= '1';
        wen  <= '0';
        wait until clk'event and clk = '1';
        -- give entity one cycle to respond
        wait until clk'event and clk = '1';
        done  := dout(0);
        count := count + 1;
      end loop;

      if (done /= '1') then
        errors := errors + 1;
        report "Done signal not asserted before timeout.";
      end if;

      -- read done signal using memory map
      addr <= C_RESULT_ADDR;
      en   <= '1';
      wen  <= '0';
      wait until clk'event and clk = '1';
      -- give entity one cycle to respond
      wait until clk'event and clk = '1';
      result := dout;

      if (unsigned(result) /= checkOutput(i)) then
        errors := errors + 1;
        report "Result for " & integer'image(i) &
          " is incorrect. The output is " &
          integer'image(to_integer(unsigned(result))) &
          " but should be " & integer'image(to_integer(checkOutput(i)));
      end if;

      wait until clk'event and clk = '1';
      wait until clk'event and clk = '1';
    end loop;

    report "SIMULATION FINISHED!!!";

    grade   := total_points-(real(errors)*total_points*0.03);
    if grade < min_grade then
      grade := min_grade;
    end if;

    report "TOTAL ERRORS : " & integer'image(errors);
    report "GRADE = " & integer'image(integer(grade)) & " out of " &
      integer'image(integer(total_points));
    sim_done <= '1';
    wait;
  end process;

end;
