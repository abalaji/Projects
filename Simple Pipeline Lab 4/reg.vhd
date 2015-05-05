library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    width  :     positive:=1);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    input  : in  std_logic_vector(width-1 downto 0);
	 start :out std_logic;
    output : out std_logic_vector(width-1 downto 0));
end reg;

architecture BHV of reg is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
      output   <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (en = '1') then
        output <= input;
		  start<= '1';
      end if;
    end if;
  end process;
end BHV;
