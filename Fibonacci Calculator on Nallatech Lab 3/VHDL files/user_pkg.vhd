library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package user_pkg is
  
  constant C_GO_ADDR : std_logic_vector(31 downto 0) := x"00000000";
  constant C_N_ADDR : std_logic_vector(31 downto 0) := x"00000001";
  constant C_RESULT_ADDR : std_logic_vector(31 downto 0) := x"00000002";
  constant C_DONE_ADDR : std_logic_vector(31 downto 0) := x"00000003";  
end user_pkg;
