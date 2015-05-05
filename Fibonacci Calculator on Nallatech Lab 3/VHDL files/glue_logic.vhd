----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:34:24 10/03/2013 
-- Design Name: 
-- Module Name:    glue_logic - bhv 
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
use ieee.numeric_std.all;
use work.user_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity glue_logic is
port(
    clk    : in  std_logic;
    rst    : in  std_logic;
    addr   : in  std_logic_vector(31 downto 0);
    en     : in  std_logic;
    wen    : in  std_logic;
    din    : in  std_logic_vector(31 downto 0);
    dout   : out std_logic_vector(31 downto 0);
    go     : out std_logic;
    n      : out std_logic_vector(31 downto 0);
    result : in  std_logic_vector(31 downto 0);
    done   : in  std_logic
    );
end glue_logic;

architecture bhv of glue_logic is

begin
process(clk, rst)
variable reg_go: std_logic;
variable reg_n:std_logic_vector(31 downto 0);
variable reg_r:std_logic_vector(31 downto 0);

begin

if (rst ='1') then	
	n <= (others => '0');
	reg_n := (others => '0');
	go <= '0';
	reg_go := '0';
	dout <= (others => '0');
elsif(clk'event and clk='1') then
 
	if(en = '1' and wen ='1') then
		if (addr = C_GO_ADDR )then
		reg_go := din(0);
		go <= reg_go;
		elsif (addr = C_N_ADDR) then
		reg_n := din;
		n <= reg_n;
		end if;
	elsif(en ='1' and wen = '0') then
		if (addr = C_GO_ADDR )then
		dout(0) <= reg_go;
		elsif (addr = C_N_ADDR) then
		dout <= reg_n;
		elsif (addr = C_RESULT_ADDR) then
		reg_r := result;
		dout <= reg_r;
		else
		dout <= (others => '0');
		dout(0) <= done;
		end if;
	end if;
end if;
end process;

end bhv;