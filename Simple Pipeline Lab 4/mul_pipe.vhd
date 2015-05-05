----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:06:32 09/15/2013 
-- Design Name: 
-- Module Name:    mul_pipe - Behavioral 
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

entity mult_pipe is
generic (
    width  :     positive := 8);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width*2-1 downto 0));
end mult_pipe;

architecture BHV of mult_pipe is

begin
	process(clk,rst,en)
	variable temp : unsigned(width*2-1 downto 0);
	begin
	
	if (rst='1') then
	output <= (others => '0');
	
	elsif(clk'event and clk='1') then
		
		if(en='1') then
		temp := (unsigned(in1) * unsigned(in2));
		output <= std_logic_vector(unsigned(in1) * unsigned(in2));
		--else
		--output <= std_logic_vector(temp);
		
		end if;
	end if;

end process;
end BHV;

