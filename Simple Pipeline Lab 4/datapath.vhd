----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:02:14 10/12/2013 
-- Design Name: 
-- Module Name:    datapath - STR 
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


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity datapath is
generic (
    width     :     positive := 8);

    Port ( clk : in  std_logic;
			  rst : in  std_logic;
			  --en  : in  std_logic;
			  rdata : in  STD_LOGIC_VECTOR (width*4-1 downto 0);
           output : out  STD_LOGIC_VECTOR (width*2 downto 0));
end datapath;

architecture STR of datapath is
signal in1, in2, in3, in4 : std_logic_vector(width-1 downto 0);
signal mul1_out : std_logic_vector(width*2-1 downto 0);
signal mul2_out : std_logic_vector(width*2-1 downto 0);
signal reg_in1 : std_logic_vector(width-1 downto 0);
signal reg_in2 : std_logic_vector(width-1 downto 0);
signal reg_in3 : std_logic_vector(width-1 downto 0);
signal reg_in4 : std_logic_vector(width-1 downto 0);
constant en: std_logic :='1';

begin

in4 <= rdata(7 downto 0);
in3 <= rdata(15 downto 8);
in2 <= rdata(23 downto 16);
in1 <= rdata(31 downto 24);

	U_REG1: entity work.reg
		generic map( width => 8)
		port map (clk => clk,
						rst => rst,
						en => en,
						input => in1,
						output => reg_in1 );
						
	U_REG2: entity work.reg
		generic map( width => 8)
		port map (clk => clk,
						rst => rst,
						en => en,
						input => in2,
						output => reg_in2 );
						
	U_REG3: entity work.reg
		generic map( width => 8)
		port map (clk => clk,
						rst => rst,
						en => en,
						input => in3,
						output => reg_in3 );
						
	U_REG4: entity work.reg
		generic map( width => 8)
		port map (clk => clk,
						rst => rst,
						en => en,
						input => in4,
						output => reg_in4 );


	U_MULR1: entity work.mult_pipe
		generic map( width => 8)
		port map ( in1 => reg_in1,
						in2 => reg_in2,
						clk => clk,
						rst => rst,
						en => en,
						output => mul1_out );
						
	U_MULR2: entity work.mult_pipe
		generic map( width => 8)
		port map ( in1 => reg_in3,
						in2 => reg_in4,
						clk => clk,
						rst => rst,
						en => en,
						output => mul2_out );
						
	U_ADDR1: entity work.add_pipe
		generic map( width => 8)
		port map ( in1 => mul1_out,
						in2 => mul2_out,
						clk => clk,
						rst => rst,
						en => en,
						output => output );


end STR;

