library ieee;
use ieee.std_logic_1164.all;

entity fifo32 is
  port (
    clk_src     : in  std_logic;
    clk_dest    : in  std_logic;
    rst         : in  std_logic;
    empty       : out std_logic;
    full        : out std_logic;
    almost_full : out std_logic;
    rd          : in  std_logic;
    wr          : in  std_logic;
    data_in     : in  std_logic_vector(31 downto 0);
    data_out    : out std_logic_vector(31 downto 0));
end fifo32;

architecture STR of fifo32 is


-- The following code must appear in the VHDL architecture header:
 
component fifo_32
    port (
    din: IN std_logic_VECTOR(31 downto 0);
    rd_clk: IN std_logic;
    rd_en: IN std_logic;
    rst: IN std_logic;
    wr_clk: IN std_logic;
    wr_en: IN std_logic;
    almost_full: OUT std_logic;
    dout: OUT std_logic_VECTOR(31 downto 0);
    empty: OUT std_logic;
    full: OUT std_logic);
end component;


  begin
-------------------------------------------------------------
 
-- The following code must appear in the VHDL architecture body.
-- Substitute your own instance name and net names.
 
U_F32 : fifo_32
        port map (
            din => data_in,
            rd_clk => clk_dest,
            rd_en => rd,
            rst => rst,
            wr_clk => clk_src,
            wr_en => wr,
            almost_full => almost_full,
            dout => data_out,
            empty => empty,
            full => full);
 
		
end STR;
