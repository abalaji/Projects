----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:20:47 10/18/2013 
-- Design Name: 
-- Module Name:    pipeline_h101 - STR 
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

entity pipeline_h101 is
    Port ( dt_clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (31 downto 0);
           en : in  STD_LOGIC;
           wen : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (31 downto 0);
           dout : out  STD_LOGIC_VECTOR (31 downto 0));
end pipeline_h101;

architecture STR of pipeline_h101 is
signal go_con, go_ag, done_con, done_ago, wen_bramb, delay_in, delay_out,reg_out,en_ff,en_delay : std_logic;
signal size_con, size_ag : std_logic_vector(C_ADDR_WIDTH downto 0);
signal mem_in_wen : std_logic;
signal mem_in_wdata : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
signal waddr: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
signal raddr: std_logic_vector(C_ADDR_WIDTH-1 downto 0);
signal mem_out_rdata : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
signal rdata_datapath : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
signal raddr_brama : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
signal waddr_bramb : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
signal wdata_bramb : std_logic_vector ( 16 downto 0);

begin

U_GLUE_LOGIC: entity work.glue_logic
			port map ( clk => dt_clk,
						  rst => reset,
						  addr => addr,
						  en => en,
						  wen => wen,
						  din => din,
						  dout => dout,
						  go => go_con,
						  size => size_con,
						  mem_in_wdata => mem_in_wdata,
						  mem_in_waddr => waddr,
						  mem_in_wen => mem_in_wen,
						  mem_out_raddr => raddr,
						  mem_out_rdata => mem_out_rdata,
						  done => done_con);

	U_CTRL: entity work.controller
			port map ( clk => dt_clk,
						reset => reset,
						go => go_con,
						size => size_con,
						go_ag => go_ag,
						size_ag => size_ag,
						wr_en => done_ago,
						done => done_con);
						
--	U_AG: entity work.add_gen
--			port map ( clk => dt_clk,
--						rst => reset,
--						go => go_ag,
--						size => size_ag_x,
--						valid_out => delay_out,
--						valid_in => delay_in,
-- 					wen => wen_bram2,
--						raddr => raddr_bram1,
--						waddr => waddr_bram2,
--						done => done_ago);

	U_AGIN : entity work.addr_gen_in
		port map ( clk => dt_clk,
						rst => reset,
						go => go_ag,
						size => size_ag,
						en=>en_ff,
						valid_in => delay_in,
						raddr => raddr_brama);
						
	U_AGOUT : entity work.add_gen_out
		port map ( clk => dt_clk,
						rst => reset,
						--go => go_ag,
						size => size_ag,
						valid_out => delay_out,
						waddr => waddr_bramb,
						wen => wen_bramb,
						done => done_ago);
						
	 
  U_MEM_IN : entity work.dual_port_ram(SYNC_READ)
    generic map (
      data_width => C_MEM_IN_WIDTH,
      addr_width => C_ADDR_WIDTH)
    port map (
      clk        => dt_clk,
      wen        => mem_in_wen,         -- connect to glue logic
      waddr      => waddr,       		-- connect to glue logic
      wdata      => mem_in_wdata,       -- connect to glue logic
      raddr      => raddr_brama,
      rdata      => rdata_datapath);
						
	U_DPTH: entity work.datapath
			port map ( clk => dt_clk,
						rst => reset,
						--en => en_ff,
						rdata => rdata_datapath,
						output => wdata_bramb);
	
--	U_FF : entity work.reg
--			port map ( clk => dt_clk,
--						rst => reset,
--						en => en_ff,
--						input(0) => delay_in,
--						output(0) => reg_out,
--						start=> en_delay);
						
	U_DELAY : entity work.delay
			port map ( clk => dt_clk,
						rst => reset,
						en => en_ff,
						input(0) => delay_in,
						output(0) => delay_out);
						
  -- Input RAM (make sure to declare signals for the following connections)
  
--  U_DEL : entity work.delay
--			port map ( clk => dt_clk,
--						rst => reset,
--						en => en,
--						input(0) => delay_in,
--						output(0) => delay_out);
-- 

  -- Output RAM (make sure to declare signals for the following connections)
  U_MEM_OUT : entity work.dual_port_ram(SYNC_READ)
    generic map (
      data_width => C_MEM_OUT_WIDTH,
      addr_width => C_ADDR_WIDTH)
    port map (
      clk        => dt_clk,
      wen        => wen_bramb,
      waddr      => waddr_bramb,
      wdata      => wdata_bramb,
      raddr      => raddr,      -- connect to glue logic
      rdata      => mem_out_rdata       -- connect to glue logic
      );

end STR;

