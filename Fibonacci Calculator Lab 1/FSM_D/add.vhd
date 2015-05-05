----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:03:45 09/12/2013 
-- Design Name: 
-- Module Name:    add - BHV 
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

entity add is
    Port ( p : in  STD_LOGIC_VECTOR (7 downto 0);
           q : in  STD_LOGIC_VECTOR (7 downto 0);
           r : out  STD_LOGIC_VECTOR (7 downto 0));
end add;

architecture BHV of add is

begin

process(p,q)
begin
	
	r <= std_logic_vector(unsigned(p)+unsigned(q));

end process;


end BHV;

