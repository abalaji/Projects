----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:53:32 09/15/2013 
-- Design Name: 
-- Module Name:    add_pipe - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity add_pipe is
generic ( width : positive := 8);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           in1 : in  STD_LOGIC_VECTOR (width*2-1 downto 0);
           in2 : in  STD_LOGIC_VECTOR (width*2-1 downto 0);
           output : out  STD_LOGIC_VECTOR (width*2 downto 0));
end add_pipe;

architecture BHV of add_pipe is
--signal output_inter: std_logic_vector (width*2 downto 0);
begin
	
	process(clk,rst,en)
	variable temp : unsigned(width*2 downto 0);
	begin
	
	if (rst='1') then
	output <= (others => '0');
	
	elsif(clk'event and clk='1') then
		
		if(en='1') then
		temp := resize(unsigned(in1),width*2+1) + resize(unsigned(in2),width*2+1);
		output <= std_logic_vector(resize(unsigned(in1),width*2+1) + resize(unsigned(in2),width*2+1));
		--else
		--output <= std_logic_vector(temp);
		end if;
	end if;
	
end process;
end BHV;

