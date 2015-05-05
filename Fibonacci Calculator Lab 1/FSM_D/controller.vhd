----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:14:40 09/12/2013 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller is
	Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           go : in  STD_LOGIC;
			  done : out STD_LOGIC;
			  
			  i_sel : out STD_LOGIC;
			  x_sel : out STD_LOGIC;
			  y_sel : out STD_LOGIC;
			  i_ld : out STD_LOGIC;
			  x_ld : out STD_LOGIC;
			  y_ld : out STD_LOGIC;
			  n_ld : out STD_LOGIC;
			  i_le_n : in STD_LOGIC;
			  result_ld : out STD_LOGIC);
			  
end controller;

architecture BHV of controller is

type STATE_TYPE is (S_WAIT_GO_0, S_WAIT_GO_1,S_STORE_INPUT, S_LOOP_COND, S_ADD_X_Y, S_DONE_STATE);

signal state,next_state : STATE_TYPE;

begin

	process(clk,rst)
	begin
		
		if(rst='1') then
			state <= S_WAIT_GO_1;
		elsif(clk'event and clk='1') then
			state <= next_state;
		end if;
	end process;
	
	process(go,i_le_n,state)
	begin
	
				i_sel <= '0';
				i_ld <= '0';
				x_sel <= '0';
				x_ld <= '0';
				y_sel <= '0';
				y_ld <= '0';
				n_ld <= '1';
				result_ld <= '0';
				done <= '0';
			next_state <= state;
			
			case state is
			
			when S_WAIT_GO_1 =>
				if(go='1') then
				next_state <= S_STORE_INPUT;
				end if;
				
			when S_STORE_INPUT =>
				i_sel <= '1';
				i_ld <= '1';
				x_sel <= '1';
				x_ld <= '1';
				y_sel <= '1';
				y_ld <= '1';
				next_state <= S_LOOP_COND;
				
			when S_LOOP_COND =>
				if(i_le_n = '1') then
				next_state <= S_ADD_X_Y;
				else
				result_ld <= '1';
				next_state <= S_DONE_STATE;
				end if;
				
			when S_ADD_X_Y =>
				y_sel <= '0';
				y_ld <= '1';
				x_sel <= '0';
				x_ld <= '1';
				i_sel <= '0';
				i_ld <= '1';
				next_state <= S_LOOP_COND;
				
			when S_DONE_STATE =>
				done <= '1';
				next_state <= S_WAIT_GO_0;
				
			when S_WAIT_GO_0 =>
				if(go='0') then
				done <= '1';
				next_state <= S_WAIT_GO_1;
				end if;
			
			when others => null;
	end case;

end process;

end BHV;
