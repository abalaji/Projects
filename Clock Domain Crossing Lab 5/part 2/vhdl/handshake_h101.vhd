library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity handshake_h101 is
  port(
    clk1 : in  std_logic;
    clk2 : in  std_logic;
    rst  : in  std_logic;
    addr : in  std_logic_vector(31 downto 0);
    en   : in  std_logic;
    wen  : in  std_logic;
    din  : in  std_logic_vector(31 downto 0);
    dout : out std_logic_vector(31 downto 0)
    );

  attribute dtinfo         : string;
  attribute dtinfo of clk1 : signal is "clk1";
  attribute dtinfo of clk2 : signal is "clk2";
  attribute dtinfo of rst  : signal  is "reset";
  attribute dtinfo of addr : signal is "usergroup, memmap";
end handshake_h101;

architecture STR of handshake_h101 is

  signal go   : std_logic;
  signal done : std_logic;
  signal size : std_logic_vector(C_ADDR_WIDTH downto 0);

  signal mem_in_wdata : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
  signal mem_in_waddr : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_in_rdata : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
  signal mem_in_raddr : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_in_wen   : std_logic;
  signal mem_in_send  : std_logic;
  signal mem_in_ack   : std_logic;

  signal dp_received  : std_logic;
  signal dp_send      : std_logic;
  signal dp_ack       : std_logic;
  signal dp_delay_ack : std_logic;
  signal dp_data_out  : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal dp_valid_out : std_logic;


  signal mem_out_wdata    : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal mem_out_waddr    : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_out_rdata    : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal mem_out_raddr    : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_out_wen      : std_logic;
  signal mem_out_received : std_logic;

begin

  -----------------------------------------------------------------------------
  -- Clock domain 1

  U_GLUE_LOGIC : entity work.glue_logic
    port map (
      clk           => clk1,
      rst           => rst,
      addr          => addr,
      en            => en,
      wen           => wen,
      din           => din,
      dout          => dout,
      go            => go,
      size          => size,
      done          => done,
      mem_in_wdata  => mem_in_wdata,
      mem_in_waddr  => mem_in_waddr,
      mem_in_wen    => mem_in_wen,
      mem_out_rdata => mem_out_rdata,
      mem_out_raddr => mem_out_raddr
      );

  -- Input bram
  U_MEM_IN : entity work.dual_port_ram(SYNC_READ)
    generic map (
      data_width => C_MEM_IN_WIDTH,
      addr_width => C_ADDR_WIDTH)
    port map (
      clk        => clk1,
      wen        => mem_in_wen,
      waddr      => mem_in_waddr,
      wdata      => mem_in_wdata,
      raddr      => mem_in_raddr,
      rdata      => mem_in_rdata);

  -- Generates reads from mem_in bram every time that the acknowledge is
  -- received from the destination domain. 

  U_MEM_IN_ADDR_GEN : entity work.addr_gen_in
    generic map (
      width    => C_ADDR_WIDTH)
    port map (
      clk      => clk1,
      rst      => rst,
      size     => size,
      go       => go,
      send     => mem_in_send,
      received => mem_in_ack,
      addr     => mem_in_raddr);

  -- handshake synchronizer for domain 1 to domain 2

  U_DP_IN_SYNC : entity work.handshake
    port map (
      clk_src   => clk1,
      clk_dest  => clk2,
      rst       => rst,
      go        => mem_in_send,
		delay_ack => dp_delay_ack,
      rcv       => dp_received,
      ack       => mem_in_ack);

  -----------------------------------------------------------------------------
  -- Clock domain 2
  -- Simple datapath

  U_DATAPATH : entity work.datapath
    port map (
      clk       => clk2,
      rst       => rst,
      en        => C_1,
      valid_in  => dp_received,
      valid_out => dp_valid_out,
      data_in   => mem_in_rdata,
      data_out  => dp_data_out);

  -- this register will hold a valid datapath output until the next valid
  -- output, which allows the destination in domain 1 to read it after the
  -- handshake.

  U_DP_OUTPUT : entity work.reg
    generic map (
      width  => 17)
    port map (
      clk    => clk2,
      rst    => rst,
      en     => dp_valid_out,
      input  => dp_data_out,
      output => mem_out_wdata);

  -- creates the send signal for the second handshake. Note that this will
  -- create a pulse because dp_valid_out will never be valid for more than a
  -- cycle because the source will not send a second piece of data until the
  -- first one has been acknowledged.
  
  U_DP_SEND : entity work.reg
    generic map (
      width     => 1)
    port map (
      clk       => clk2,
      rst       => rst,
      en        => C_1,
      input(0)  => dp_valid_out,
      output(0) => dp_send);

  -- delay the acknowledge until the result has been transferred back to
  -- domain 1. Note that this basically will prevent the pipeline from ever
  -- having more than one valid set of data. This could be improved by adding
  -- a FIFO to buffer data. However, if you are going to use a FIFO, you can
  -- get rid of the handshake (see next part of lab).
  dp_delay_ack <= not dp_ack;

  -----------------------------------------------------------------------------
  -- Clock domain 1

  -- handshake synchronizer from domain 2 to domain 1
  U_DP_OUT_SYNC : entity work.handshake
    port map (
      clk_src   => clk2,
      clk_dest  => clk1,
      rst       => rst,
      go        => dp_send,
      delay_ack => C_0,
      rcv       => mem_out_received,
      ack       => dp_ack);
  
  -- Output memory
  U_MEM_OUT : entity work.dual_port_ram(SYNC_READ)
    generic map (
      data_width => C_MEM_OUT_WIDTH,
      addr_width => C_ADDR_WIDTH)
    port map (
      clk        => clk1,
      wen        => mem_out_wen,
      waddr      => mem_out_waddr,
      wdata      => mem_out_wdata,
      raddr      => mem_out_raddr,
      rdata      => mem_out_rdata);

  -- output address generator that writes to memory every time it receives a
  -- message from the output handshake synchronizer.
  U_MEM_OUT_ADDR_GEN : entity work.addr_gen_out
    generic map (
      width => C_ADDR_WIDTH)
    port map (
      clk   => clk1,
      rst   => rst,
      size  => size,
      go    => go,
      en    => mem_out_received,
      addr  => mem_out_waddr,
      wen   => mem_out_wen,
      done  => done);

end STR;
