library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity datapath is
  port(clk       : in  std_logic;
       rst       : in  std_logic;
       en        : in  std_logic;
       valid_in  : in  std_logic;
       valid_out : out std_logic;
       data_in   : in  std_logic_vector(31 downto 0);
       data_out  : out std_logic_vector(16 downto 0)
       );
end datapath;

architecture str of datapath is

  type input_array is array (0 to 3) of std_logic_vector(7 downto 0);
  signal input, input_reg : input_array;

  type mult_array is array (0 to 1) of std_logic_vector(15 downto 0);
  signal mult_out : mult_array;

begin

  input(0) <= data_in(31 downto 24);
  input(1) <= data_in(23 downto 16);
  input(2) <= data_in(15 downto 8);
  input(3) <= data_in(7 downto 0);

  U_INPUT_REGS : for i in 0 to 3 generate
    U_REG      : entity work.reg
      generic map (
        width  => 8)
      port map (
        clk    => clk,
        rst    => rst,
        en     => en,
        input  => input(i),
        output => input_reg(i));
  end generate U_INPUT_REGS;

  U_MULTS  : for i in 0 to 1 generate
    U_MULT : entity work.mult_pipe
      generic map (
        width  => 8)
      port map (
        clk    => clk,
        rst    => rst,
        en     => en,
        input1 => input_reg(i*2),
        input2 => input_reg(i*2+1),
        output => mult_out(i));
  end generate U_MULTS;

  U_ADD : entity work.add_pipe
    generic map (
      width  => 16)
    port map (
      clk    => clk,
      rst    => rst,
      en     => en,
      input1 => mult_out(0),
      input2 => mult_out(1),
      output => data_out);
  
  U_DELAY : entity work.delay
    generic map (
      cycles    => 3,
      width     => 1)
    port map (
      clk       => clk,
      rst       => rst,
      en        => en,
      input(0)  => valid_in,
      output(0) => valid_out);

end str;
