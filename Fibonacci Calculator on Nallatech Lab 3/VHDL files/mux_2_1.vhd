-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: mux.vhd
--
-- Description: This file implements a 2 to 1 mux.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2_1 is
  generic (width      :     positive := 32);
  port(input1, input2 : in  std_logic_vector(width-1 downto 0);
       sel            : in  std_logic;
       output         : out std_logic_vector(width-1 downto 0));
end mux_2_1;

architecture bhv of mux_2_1 is
begin
  process(input1, input2, sel)
  begin
    case sel is
      when '1'    => output <= input1;
      when '0'    => output <= input2;
      when others => null;
    end case;
  end process;
end bhv;
