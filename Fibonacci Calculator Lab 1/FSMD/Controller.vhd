----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:21 09/12/2013 
-- Design Name: 
-- Module Name:    Fibonacci - FSMD
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

entity Fibonacci is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           go : in  STD_LOGIC;
			  done : out STD_LOGIC;
			  n : in STD_LOGIC_VECTOR (7 downto 0);
           result : out  STD_LOGIC_VECTOR (7 downto 0));
end Fibonacci;

architecture FSMD of Fibonacci is

type STATE_TYPE is (S_WAIT_GO_0, S_WAIT_GO_1,S_STORE_INPUT, S_LOOP_COND, S_ADD_X_Y, S_DONE_STATE);

signal state : STATE_TYPE;

signal x,y: STD_LOGIC_VECTOR( 7 downto 0);
signal i,c,input : unsigned(7 downto 0);



begin

input <= unsigned(n);


	process(clk,rst)
	variable temp : unsigned( 7 downto 0);
	begin
		
		if(rst='1') then
		
			result <= (others => '0');
			done <= '0';
			i <= (others => '0');
			x <= (others => '0');
			y <= (others => '0');
			c <= "00000001";
			temp := (others => '0');
			state <= S_WAIT_GO_1;
			
		elsif(clk'event and clk='1') then
			
			case state is
			
			when S_WAIT_GO_1 =>
				if(go='1') then
				state <= S_STORE_INPUT;
				else
				state <= S_WAIT_GO_1;
				end if;
				
			when S_STORE_INPUT =>
				done <= '0';
				i <= "00000011";
				x <= "00000001";
				y <= "00000001";
				state <= S_LOOP_COND;
				
			when S_LOOP_COND =>
				if(i <= input) then
				state <= S_ADD_X_Y;
				else
				state <= S_DONE_STATE;
				end if;
				
			when S_ADD_X_Y =>
				temp := unsigned(x) + unsigned(y);
				x <= y;
				y <= std_logic_vector(temp);
				i <= i + c;
				state <= S_LOOP_COND;
				
			when S_DONE_STATE =>
				result <= y;
				done <= '1';
				state <= S_WAIT_GO_0;
				
			when S_WAIT_GO_0 =>
				if(go='0') then
				state <= S_WAIT_GO_1;
				else
				state <= S_WAIT_GO_0;
				end if;
			
			when others => null;
	end case;
end if;
end process;
end FSMD;

