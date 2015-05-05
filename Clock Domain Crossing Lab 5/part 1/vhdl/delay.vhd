-- Greg Stitt
-- University of Florida
--
-- File: delay.vhd
-- Entity: DELAY
--
-- Description: This entity implements delay registers, which are specified by
-- generics, allowing for any delay amount "cycles", any width, and any
-- initialization value.
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-------------------------------------------------------------------------------
-- Generic
-- cycles: the number of cycles to delay
-- width: the width of the input/output
-- init: the intialization value of the delay registers (each bit of each
-- register is set to this value)

-- Port
-- clk: clock
-- rst (active hi): reset
-- en (active hi): enable signals, which if not asserted stalls the delay
-- input: the input to the delay registers
-- output: the output from the delay registers (the delayed signal)
-------------------------------------------------------------------------------

entity delay is
  generic(cycles :     natural;
          width  :     positive;
          init   :     std_logic := '0');
  port( clk      : in  std_logic;
        rst      : in  std_logic;
        en       : in  std_logic;
        input    : in  std_logic_vector(width-1 downto 0);
        output   : out std_logic_vector(width-1 downto 0));
end delay;

architecture str of delay is

  type SARRAY is array (0 to cycles) of std_logic_vector(width-1 downto 0);

  component reg
    generic (width :     positive  := 32;
             init  :     std_logic := '0');
    port(clk       : in  std_logic;
         rst       : in  std_logic;
         en        : in  std_logic;
         input     : in  std_logic_vector(width-1 downto 0);
         output    : out std_logic_vector(width-1 downto 0));
  end component;

  signal reg_val : SARRAY;

begin

  reg_val(0) <= input;

  U_DELAY : for i in 0 to cycles-1 generate

    U_DREG : reg generic map (width => width, init => init)
      port map (clk                 => clk,
                rst                 => rst,
                en                  => en,
                input               => reg_val(i),
                output              => reg_val(i+1));
  end generate U_DELAY;

  output <= reg_val(cycles);

end str;
