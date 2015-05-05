----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:00:03 09/12/2013 
-- Design Name: 
-- Module Name:    reg - Behavioral 
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

entity reg is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    load   : in  std_logic;
    input  : in  std_logic_vector(7 downto 0);
    output : out std_logic_vector(7 downto 0));
end reg;


architecture BHV of reg is
begin
  process(clk, rst)
  begin
    
	 if (rst = '1') then
      output   <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (load = '1') then
        output <= input;
      end if;
		
    end if;
	 
  end process;
end BHV;



