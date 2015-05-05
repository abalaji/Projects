----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:25:58 09/12/2013 
-- Design Name: 
-- Module Name:    datapath - Behavioral 
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

entity datapath is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           n : in  STD_LOGIC_VECTOR (7 downto 0);
           result : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  i_sel : in STD_LOGIC;
			  x_sel : in STD_LOGIC;
			  y_sel : in STD_LOGIC;
			  i_ld : in STD_LOGIC;
			  x_ld : in STD_LOGIC;
			  y_ld : in STD_LOGIC;
			  n_ld : in STD_LOGIC;
			  i_le_n : out STD_LOGIC;
			  result_ld : in STD_LOGIC);
			  
end datapath;

architecture STR of datapath is

signal mux_i_out :std_logic_vector(7 downto 0);
signal mux_x_out :std_logic_vector(7 downto 0);
signal mux_y_out :std_logic_vector(7 downto 0);
signal add_1_out : std_logic_vector(7 downto 0);
signal add_2_out : std_logic_vector(7 downto 0);
signal reg_i_out : std_logic_vector(7 downto 0);
signal reg_x_out : std_logic_vector(7 downto 0);
signal reg_y_out : std_logic_vector(7 downto 0);
signal reg_n_out : std_logic_vector(7 downto 0);

constant C_3 : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(3, 8));
constant C_1 : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(1, 8));

begin

	U_MUX_I : entity work.mux2x1
	
	port map ( a => add_1_out,
					b => C_3,
					sel => i_sel,
					c => mux_i_out);
					
	U_MUX_X : entity work.mux2x1
	
	port map ( a => reg_y_out,
					b => C_1,
					sel => x_sel,
					c => mux_x_out);
	
	U_MUX_Y : entity work.mux2x1
	
	port map ( a => add_2_out,
					b => C_1,
					sel => y_sel,
					c => mux_y_out);
					
	U_REG_I : entity work.reg
	
	port map ( input => mux_i_out,
					load => i_ld,
					clk => clk,
					rst => rst,
					output => reg_i_out);
					
	U_REG_X : entity work.reg
	
	port map ( input => mux_x_out,
					load => x_ld,
					clk => clk,
					rst => rst,
					output => reg_x_out);
					
	U_REG_Y : entity work.reg
	
	port map ( input => mux_y_out,
					load => y_ld,
					clk => clk,
					rst => rst,
					output => reg_y_out);
					
	U_REG_N : entity work.reg
	
	port map ( input => n,
					load => n_ld,
					clk => clk,
					rst => rst,
					output => reg_n_out);
					
	U_COM_LE: entity work.com_le
	
	port map ( m => reg_i_out,
					n => reg_n_out,
					mLEn => i_le_n);
					
	U_ADD1: entity work.add
	
	port map ( p => C_1,
					q => reg_i_out,
					r => add_1_out);
					
	U_ADD2: entity work.add
	
	port map ( p => reg_x_out,
					q => reg_y_out,
					r => add_2_out);
					
	U_REG_RESULT : entity work.reg
	
	port map ( input => reg_y_out,
					load => result_ld,
					clk => clk,
					rst => rst,
					output => result);
	
					
end STR;