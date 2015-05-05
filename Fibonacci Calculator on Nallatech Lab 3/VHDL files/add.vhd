-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: add.vhd
--
-- Description: This file implements an adder.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add is
  generic (width       :     positive := 32);
  port( input1, input2 : in  std_logic_vector(width-1 downto 0);
        output         : out std_logic_vector(width-1 downto 0) );
end add;

architecture bhv of add is
begin
  process(input1, input2)
  begin
    output <= std_logic_vector(unsigned(input1)+unsigned(input2));
  end process;
end bhv;
