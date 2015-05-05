library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity fifo_h101 is
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
end fifo_h101;

architecture STR of fifo_h101 is

  signal go   : std_logic;
  signal done : std_logic;
  signal size : std_logic_vector(C_ADDR_WIDTH downto 0);

  signal mem_in_wdata      : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
  signal mem_in_waddr      : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_in_rdata      : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
  signal mem_in_raddr      : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_in_wen        : std_logic;
  signal mem_in_en         : std_logic;
  signal mem_in_addr_valid : std_logic;
  signal mem_in_data_valid : std_logic;

  signal dp_data_in   : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
  signal dp_data_out  : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal dp_valid_in  : std_logic;
  signal dp_valid_out : std_logic;
  signal dp_en        : std_logic;
  signal dp_stall     : std_logic;

  signal mem_out_wdata : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal mem_out_waddr : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_out_rdata : std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
  signal mem_out_raddr : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
  signal mem_out_wen   : std_logic;

  signal mem_in_fifo_empty       : std_logic;
  signal mem_in_fifo_full        : std_logic;
  signal mem_in_fifo_almost_full : std_logic;
  signal mem_in_fifo_wr          : std_logic;
  signal mem_in_fifo_data_in     : std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);

  signal mem_out_fifo_empty : std_logic;
  signal mem_out_fifo_full  : std_logic;

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

  -- address generator for input memory. Notice there is only one addr_gen
  -- entity now instead of a separate one for the input and output memories.
  -- This simplification is enabled by the simplicity of the control required
  -- by the FIFO. The input address generator produces an address anytime the
  -- input FIFO isn't almost full. Because there is one cycle of latency for a
  -- read, it must stop when the FIFO is almost full to guarantee that there is
  -- enough room in the FIFO to store outstanding requests. For memories with
  -- longer delays (e.g. external memories), you must use a FIFO with a
  -- programmable full flag that leaves enough room for all outstanding
  -- requests. 

  U_MEM_IN_ADDR_GEN : entity work.addr_gen
    generic map (
      width => C_ADDR_WIDTH)
    port map (
      clk   => clk1,
      rst   => rst,
      size  => size,
      go    => go,
      stall => mem_in_fifo_almost_full,
      addr  => mem_in_raddr,
      valid => mem_in_addr_valid,
      done  => open);

  -- signifies valid data that has been read from the input memory. Creates a
  -- one cycle delay of the mem_in_valid signal, which corresponds to the time
  -- when valid data is available from the input memory

  U_DELAY : entity work.delay
    generic map (
      cycles    => 1,
      width     => 1)
    port map (
      clk       => clk1,
      rst       => rst,
      en        => mem_in_en,
      input(0)  => mem_in_addr_valid,
      output(0) => mem_in_data_valid);

  -- enables the valid delay register when the fifo isn't full (i.e., stalls
  -- when the fifo is full)
  mem_in_en <= not mem_in_fifo_full;

  -- writes to the input FIFO anytime there is valid input data and the FIFO
  -- isn't full. Checking for the full FIFO should be optional, because a FIFO
  -- should protect against writing when full, but I do it here just to be safe
  mem_in_fifo_wr <= mem_in_data_valid and not mem_in_fifo_full;

  -- input FIFO. Note that the input FIFO requires an almost_full flag because
  -- there will be outstanding memory reads when the FIFO is actually full. The
  -- almost_full flag ensures enough room for an outstanding request when
  -- the read latency is 1 cycle.
  U_MEM_IN_FIFO : entity work.fifo32
    port map (
      clk_src     => clk1,
      clk_dest    => clk2,
      rst         => rst,
      empty       => mem_in_fifo_empty,
      full        => mem_in_fifo_full,
      almost_full => mem_in_fifo_almost_full,
      -- read anytime the dp is enabled (reading an empty FIFO won't hurt)
      rd          => dp_en,
      wr          => mem_in_fifo_wr,
      data_in     => mem_in_rdata,      -- data from input memory
      data_out    => dp_data_in         -- data to datapath
      );

  -----------------------------------------------------------------------------
  -- Clock domain 2
  -- Simple datapath from pipelining lab

  U_DATAPATH : entity work.datapath
    port map (
      clk       => clk2,
      rst       => rst,
      en        => dp_en,
      valid_in  => dp_valid_in,
      valid_out => dp_valid_out,
      data_in   => dp_data_in,
      data_out  => dp_data_out);

  -- datapath has valid data whenever the input fifo isn't empty. Note that
  -- this requires the input memory to be "first-word fall through", which
  -- means that the front of the queue is already on the output. If there is
  -- latency involved in reading from the FIFO, then this valid signal must be
  -- delayed.
  dp_valid_in <= not mem_in_fifo_empty;

  -- stall when the output fifo is full
  dp_stall    <= mem_out_fifo_full;
  dp_en       <= not dp_stall;

  -----------------------------------------------------------------------------
  -- Clock domain 1

  -- output FIFO. This FIFO does not require the almost_full flag because the
  -- datapath can immediately stall, which prevents data loss.
  U_MEM_OUT_FIFO : entity work.fifo17
    port map (
      clk_src  => clk2,
      clk_dest => clk1,
      rst      => rst,
      empty    => mem_out_fifo_empty,
      full     => mem_out_fifo_full,
      rd       => mem_out_wen,
      wr       => dp_valid_out,
      data_in  => dp_data_out,
      data_out => mem_out_wdata);

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

  -- write to the memory any time there is data in the output FIFO. This
  -- assumes there is a valid address from the address generator, but that is a
  -- valid assumption in this case because the address generator can produce an
  -- address every cycle
  mem_out_wen <= not mem_out_fifo_empty;

  -- output address generator. Note that this is the same entity used by the
  -- input address generator.
  U_MEM_OUT_ADDR_GEN : entity work.addr_gen
    generic map (
      width => C_ADDR_WIDTH)
    port map (
      clk   => clk1,
      rst   => rst,
      size  => size,
      go    => go,
      -- stall whenever the output fifo is empty (nothing to write to memory)
      stall => mem_out_fifo_empty,
      addr  => mem_out_waddr,
      -- could potentially use valid to ensure that data isn't written to an
      -- invald address, but this will never occur in this example.
      valid => open,
      -- the circuit is done once the output address generator has finished.
      -- Note that this isn't always safe. For example, if it takes 20 cycles
      -- to write to memory, this could assert done before the data is actually
      -- written. If this is a concern, simply delay the done signal.
      done  => done);

end STR;
