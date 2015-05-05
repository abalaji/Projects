----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:58:45 10/18/2013 
-- Design Name: 
-- Module Name:    add_gen_out - BHV 
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

entity add_gen_out is
Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           --go : in  STD_LOGIC;
           size : in  STD_LOGIC_VECTOR (C_ADDR_WIDTH downto 0);
           waddr : inout  STD_LOGIC_VECTOR (C_ADDR_WIDTH-1 downto 0);
			  wen : out std_logic;
			  done : out std_logic;
           valid_out : in  STD_LOGIC);
end add_gen_out;

architecture BHV of add_gen_out is
constant C_ONE : unsigned(C_ADDR_WIDTH-1 downto 0) := "000000000000001";
begin

process(clk,rst)

begin

	if(rst ='1') then
		--temp := (others => '0');
		waddr <= (others => '0');
		wen <= '0';
		done <= '0';

	elsif(clk'event and clk = '1') then
		
	--if (go = '1') then
		if(valid_out = '1' ) then
			wen <='1';
			if (unsigned(waddr) < unsigned(size)-1) then
			waddr <= std_logic_vector(unsigned(waddr)+C_ONE);
			--temp := temp + C_ONE;
			
			end if;
		else
			done <='1';	
		end if;
		
	--end if;
	end if;
	end process;

end BHV;

