----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:17:56 10/18/2013 
-- Design Name: 
-- Module Name:    controller - BHV 
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

entity controller is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           go : in  STD_LOGIC;
           size : in  STD_LOGIC_VECTOR (C_ADDR_WIDTH downto 0);
           done : out  STD_LOGIC;
           wr_en : in  STD_LOGIC;
           go_ag : inout  STD_LOGIC;
           size_ag : out  STD_LOGIC_VECTOR(C_ADDR_WIDTH downto 0));
end controller;

architecture BHV of controller is

--type STATE_TYPE is (START,WAIT_0, WAIT_1, INIT, OUT_AG, S_DONE);
--  signal state, next_state   : STATE_TYPE;
--
--begin
--
--
---- state register
--  process (clk, rst)
--  begin
--    if (rst = '1') then
--      state  <= START;
--      
--    elsif (clk = '1' and clk'event) then
--      state  <= next_state;
--      
--    end if;
--  end process;
--
---- next state logic
--  process( go, size, wr_en, state)
--  begin
--
--    go_ag <= '0';
--	 size_ag <= (others => '0');
--	 done <= '0';
--    next_state  <= state;
--	 
--	 case state is
--      when START =>
--			if (go = '0') then
--          next_state <= WAIT_1;
--        end if;
--		  
--		when WAIT_1 =>
--        if (go = '1') then
--			go_ag <= '1';
--			size_ag <= size;
--         next_state  <= OUT_AG;
--        end if;
--		  
--		 when OUT_AG =>
--		  if (wr_en ='1') then
--		  next_state <= S_DONE;
--		  end if;
--		 
--		 when S_DONE =>
--		  done <= '1';
--		  next_state <= WAIT_0;
--		  
--
--      when WAIT_0 =>
--        if (go = '0') then
--		  done <='1';
--          next_state <= WAIT_1;
--        end if;
--
--      when others => null;
--    end case;
--  end process;
  

begin

	
	process(clk,reset)
	begin
	
		if(reset ='1') then
			go_ag <= '0';
			done <= '0';
		elsif(clk'event and clk='1')then
			if(go='1')then
				go_ag <='1';
			end if;
			if(go_ag='1') then
			if (wr_en ='1')then
				done <='1';
			end if;
			end if;
		end if;
	end process;
	size_ag <= size;
	
end BHV;

