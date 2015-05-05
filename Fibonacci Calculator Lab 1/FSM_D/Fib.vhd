----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:45:11 09/12/2013 
-- Design Name: 
-- Module Name:    Fib - STR 
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

entity Fib is
    Port ( clk : in STD_LOGIC;
			  rst : in STD_LOGIC;
			  go : in  STD_LOGIC;
           n : in  STD_LOGIC_VECTOR (7 downto 0);
           done : out  STD_LOGIC;
           result : out  STD_LOGIC_VECTOR (7 downto 0)
			  );
end Fib;

architecture STR of Fib is

signal i_sel : std_logic;
signal i_ld : std_logic;
signal x_sel : std_logic;
signal x_ld : std_logic;
signal y_sel : std_logic;
signal y_ld : std_logic;
signal n_ld : std_logic;
signal i_le_n : std_logic;
signal result_ld : std_logic;

begin

	U_CTRL : entity work.controller
	
	port map ( clk => clk,
					rst => rst,
					go => go,
					done => done,
					i_sel => i_sel,
					i_ld => i_ld,
					x_sel => x_sel,
					x_ld => x_ld,
					y_sel => y_sel,
					y_ld => y_ld,
					n_ld => n_ld,
					i_le_n => i_le_n,
					result_ld => result_ld);
					
	U_DATAPATH : entity work.datapath
	
	port map ( clk => clk,
					rst => rst,
					n => n,
					result => result,
					i_sel => i_sel,
					i_ld => i_ld,
					x_sel => x_sel,
					x_ld => x_ld,
					y_sel => y_sel,
					y_ld => y_ld,
					n_ld => n_ld,
					i_le_n => i_le_n,
					result_ld => result_ld);

end STR;

