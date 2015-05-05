----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:08:48 09/12/2013 
-- Design Name: 
-- Module Name:    com_le - Behavioral 
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

entity com_le is
    Port ( m : in  STD_LOGIC_VECTOR (7 downto 0);
           n : in  STD_LOGIC_VECTOR (7 downto 0);
           mLEn : out  STD_LOGIC);
end com_le;

architecture BHV of com_le is

begin

	mLEn <= '1' when unsigned(m) <= unsigned(n) else '0';
	
end BHV;

