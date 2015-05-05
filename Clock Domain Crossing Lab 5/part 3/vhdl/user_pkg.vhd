library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package user_pkg is

  constant C_GO_ADDR      : std_logic_vector(31 downto 0) := x"00000000";
  constant C_SIZE_ADDR    : std_logic_vector(31 downto 0) := x"00000001";
  constant C_DONE_ADDR    : std_logic_vector(31 downto 0) := x"00000002";

  constant C_ADDR_WIDTH : positive := 15;
  constant C_MEM_IN_WIDTH : positive := 32;
  constant C_MEM_OUT_WIDTH : positive := 17;
  
  constant C_MEM_IN_START_ADDR : std_logic_vector(31 downto 0) := x"00000010";
  constant C_MEM_IN_END_ADDR   : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(C_MEM_IN_START_ADDR)+(2**C_ADDR_WIDTH-1));

  constant C_MEM_OUT_START_ADDR : std_logic_vector(31 downto 0) := std_logic_vector(shift_left(unsigned(C_MEM_IN_START_ADDR), C_ADDR_WIDTH));
  constant C_MEM_OUT_END_ADDR   : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(C_MEM_OUT_START_ADDR)+(2**C_ADDR_WIDTH-1));

  constant C_1 : std_logic := '1';
  constant C_0 : std_logic := '0';
end user_pkg;
