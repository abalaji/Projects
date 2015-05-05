----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:43 10/18/2013 
-- Design Name: 
-- Module Name:    addr_gen_in - BHV 
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
use work.user_pkg.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity addr_gen_in is
Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           go : in  STD_LOGIC;
           size : in  STD_LOGIC_VECTOR (C_ADDR_WIDTH downto 0);
           raddr : inout  STD_LOGIC_VECTOR (C_ADDR_WIDTH-1 downto 0);
			  en: out std_logic;
           valid_in : out  STD_LOGIC);
end addr_gen_in;

architecture BHV of addr_gen_in is
constant C_ONE : unsigned(C_ADDR_WIDTH-1 downto 0) := "000000000000001";
begin

process(clk,rst)
--variable temp : unsigned(C_ADDR_WIDTH-1 downto 0);
begin

if(rst ='1') then
--		temp := (others => '0');
		raddr <= (others => '0');
		valid_in <= '0';

	elsif(clk'event and clk = '1') then
	
	if (go = '1') then
		if( unsigned(raddr) < unsigned(size)-1 ) then
			raddr <= std_logic_vector((unsigned(raddr))+C_ONE);
			valid_in <= '1';
			en<='1';
		end if;
		
	end if;
	end if;
	end process;

end BHV;

