----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:22:49 10/03/2013 
-- Design Name: 
-- Module Name:    fib_h101 - STR 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fib_h101 is
port(
    dt_clk : in  std_logic;
    reset  : in  std_logic;
    addr   : in  std_logic_vector(31 downto 0);
    en     : in  std_logic;
    wen    : in  std_logic;
    din    : in  std_logic_vector(31 downto 0);
    dout   : out std_logic_vector(31 downto 0)
    );
end fib_h101;

architecture STR of fib_h101 is
signal go     : std_logic;
  signal n      : std_logic_vector(31 downto 0);
  signal result : std_logic_vector(31 downto 0);
  signal done   : std_logic;
begin
GL1: entity work.glue_logic
			port map ( clk => dt_clk,
						  rst => reset,
						  addr => addr,
						  en => en,
						  wen => wen,
						  din => din,
						  dout => dout,
						  go => go,
						  n => n,
						  result => result,
						  done => done);
						  
	FIB1: entity work.fib
			port map ( clk => dt_clk,
						  rst => reset,
						  go => go,
						  n => n,
						  result => result,
						  done => done );


end STR;

