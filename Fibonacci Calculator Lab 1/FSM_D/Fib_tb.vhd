
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:44:32 09/12/2013
-- Design Name:   Fib
-- Module Name:   C:/FSM_D_Lab1/Fib_tb.vhd
-- Project Name:  FSM_D_Lab1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Fib
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY Fib_tb_vhd IS
END Fib_tb_vhd;

ARCHITECTURE behavior OF Fib_tb_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT Fib
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		go : IN std_logic;
		n : IN std_logic_vector(7 downto 0);          
		done : OUT std_logic;
		result : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL clk :  std_logic := '0';
	SIGNAL rst :  std_logic := '0';
	SIGNAL go :  std_logic;
	SIGNAL n :  std_logic_vector(7 downto 0):= (others=>'0') ;

	--Outputs
	SIGNAL done :  std_logic;
	SIGNAL result :  std_logic_vector(7 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.Fib 
	
	PORT MAP(
		clk => clk,
		rst => rst,
		go => go,
		n => n,
		done => done,
		result => result
	);

	clk <= not clk after 10 ns;

	tb : PROCESS
	BEGIN

		rst <= '1';
		n <= std_logic_vector(to_unsigned(0,8));
		go <= '0';
		wait for 100ns;
		
		rst <= '0';
		for i in 0 to 4 loop
			wait until clk'event and clk = '1';
		end loop;
		
		n <= std_logic_vector(to_unsigned(3,8));
		go <= '1';
		wait until done = '1';
		assert (result = std_logic_vector(to_unsigned(2, 8)));
				
		go <= '0';
		for i in 0 to 4 loop
			wait until clk'event and clk='1';
		end loop;
		
		n <= std_logic_vector(to_unsigned(4,8));
		go <= '1';
		wait until done = '1';
		assert (result = std_logic_vector(to_unsigned(3, 8)));
				
		go <= '0';
		for i in 0 to 4 loop
			wait until clk'event and clk='1';
		end loop;
		
		n <= std_logic_vector(to_unsigned(5,8));
		go <= '1';
		wait until done = '1';
		assert (result = std_logic_vector(to_unsigned(5, 8)));
				
		go <= '0';
		for i in 0 to 4 loop
			wait until clk'event and clk='1';
		end loop;
		
		n <= std_logic_vector(to_unsigned(6,8));
		go <= '1';
		wait until done = '1';
		assert (result = std_logic_vector(to_unsigned(8, 8)));
				
		go <= '0';
		for i in 0 to 4 loop
			wait until clk'event and clk='1';
		end loop;
		
		wait;
	END PROCESS;

END;
