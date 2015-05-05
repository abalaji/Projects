-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: tb.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity tb is
end tb;

architecture behavior of tb is

  constant TEST_WIDTH       : positive := 32;
  constant TEST_VAL         : positive := 13;
--  constant MAX_INPUT        : positive := 2**C_ADDR_WIDTH;
  constant MAX_INPUT        : positive := 256;
  constant MAX_CYCLES       : integer  := MAX_INPUT*20;
  constant CLK1_HALF_PERIOD : time     := 5 ns;
  constant CLK2_HALF_PERIOD : time     := CLK1_HALF_PERIOD*1.5;

  signal clk1 : std_logic                               := '0';
  signal clk2 : std_logic                               := '0';
  signal rst  : std_logic                               := '1';
  signal addr : std_logic_vector(TEST_WIDTH-1 downto 0) := (others => '0');
  signal en   : std_logic                               := '0';
  signal wen  : std_logic                               := '0';
  signal din  : std_logic_vector(TEST_WIDTH-1 downto 0) := (others => '0');
  signal dout : std_logic_vector(TEST_WIDTH-1 downto 0);

  signal sim_done : std_logic := '0';

begin

  UUT : entity work.fifo_h101
    port map (
      clk1 => clk1,
      clk2 => clk2,
      rst  => rst,
      addr => addr,
      en   => en,
      wen  => wen,
      din  => din,
      dout => dout);

  -- toggle clock
  clk1 <= not clk1 after CLK1_HALF_PERIOD when sim_done = '0' else clk1;
  clk2 <= not clk2 after CLK2_HALF_PERIOD when sim_done = '0' else clk2;

  process

    function checkOutput (
      i : integer)
      return integer is

    begin

      return ((i*4) mod 256)*((i*4+1) mod 256) + ((i*4+2) mod 256)*((i*4+3) mod 256);
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
    wait until clk1'event and clk1 = '1';
    wait until clk1'event and clk1 = '1';

    -- initialize MEM_IN with consecutive numbers
    for i in 0 to MAX_INPUT-1 loop
      addr <= std_logic_vector(unsigned(C_MEM_IN_START_ADDR)+i);
      en   <= '1';
      wen  <= '1';
      din  <= std_logic_vector(to_unsigned((i*4) mod 256, 8) &
                               to_unsigned((i*4+1) mod 256, 8) &
                               to_unsigned((i*4+2) mod 256, 8) &
                               to_unsigned((i*4+3) mod 256, 8));
      wait until clk1'event and clk1 = '1';
    end loop;  -- i

    -- send size = i over memory map
    addr <= C_SIZE_ADDR;
    en   <= '1';
    wen  <= '1';
    din  <= std_logic_vector(to_unsigned(MAX_INPUT, TEST_WIDTH));
    wait until clk1'event and clk1 = '1';

    -- send go = 1 over memory map
    addr <= C_GO_ADDR;
    en   <= '1';
    wen  <= '1';
    din  <= std_logic_vector(to_unsigned(1, TEST_WIDTH));
    wait until clk1'event and clk1 = '1';

    done  := '0';
    count := 0;

    while done = '0' and count < MAX_CYCLES loop

      -- read done signal using memory map
      addr <= C_DONE_ADDR;
      en   <= '1';
      wen  <= '0';
      wait until clk1'event and clk1 = '1';
      -- give entity one cycle to respond
      wait until clk1'event and clk1 = '1';
      done  := dout(0);
      count := count + 1;
    end loop;

    if (done /= '1') then
      errors := errors + 1;
      report "Done signal not asserted before timeout.";
    end if;

    -- read mem_out
    for i in 0 to MAX_INPUT-1 loop
      addr <= std_logic_vector(unsigned(C_MEM_OUT_START_ADDR)+i);
      en   <= '1';
      wen  <= '0';
      wait until clk1'event and clk1 = '1';
      -- give entity one cycle to respond
      wait until clk1'event and clk1 = '1';
      result := dout;

      if (unsigned(result) /= checkOutput(i)) then
        errors := errors + 1;
        report "Result for " & integer'image(i) &
          " is incorrect. The output is " &
          integer'image(to_integer(unsigned(result))) &
          " but should be " & integer'image(checkOutput(i));
      end if;
    end loop;  -- i

    report "SIMULATION FINISHED!!!";

    grade   := total_points-(real(errors)*total_points*0.03);
    if grade < min_grade then
      grade := min_grade;
    end if;

    report "TOTAL ERRORS : " & integer'image(errors);
-- report "GRADE = " & integer'image(integer(grade)) & " out of " &
-- integer'image(integer(total_points));
    sim_done <= '1';
    wait;
  end process;

end;
