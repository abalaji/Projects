----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:24:22 10/18/2013 
-- Design Name: 
-- Module Name:    delay - Behavioral 
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

entity delay is
generic(cycles :     positive := 3;
          width  :     positive := 1);
    port( clk    : in  std_logic;
          rst    : in  std_logic;
          en     : in  std_logic;
          input  : in  std_logic_vector(width-1 downto 0);
          output : out std_logic_vector(width-1 downto 0));

end delay;

architecture BHV of delay is
type reg_array is array (0 to cycles-1) of std_logic_vector(width-1 downto 0);
signal regs : reg_array;
  
begin
process(clk, rst)
  begin  
    if (rst = '1') then
      
      for i in 0 to cycles-1 loop
        regs(i) <= (others => '0');
      end loop;
    elsif (clk'event and clk = '1') then
    
      if (en = '1') then
        regs(0) <= input;
      end if;
  
      for i in 0 to cycles-2 loop
        if (en = '1') then
          regs(i+1) <= regs(i);
        end if;
      end loop;      
      
    end if;
  end process;
  
  output <= regs(cycles-1);


end BHV;

