-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: le.vhd
--
-- Description: This file implements a less than or equal (LE) comparator.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity le is
  generic (width       :     positive := 32);
  port( input1, input2 : in  std_logic_vector(width-1 downto 0);
        le             : out std_logic );
end le;

architecture bhv of le is
begin
  process(input1, input2)
  begin
    if (unsigned(input1) <= unsigned(input2)) then
      le       <= '1';
    else
      le       <= '0';
    end if;
  end process;
end bhv;
