-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity glue_logic is
  port(
    clk           : in  std_logic;
    rst           : in  std_logic;
    addr          : in  std_logic_vector(31 downto 0);
    en            : in  std_logic;
    wen           : in  std_logic;
    din           : in  std_logic_vector(31 downto 0);
    dout          : out std_logic_vector(31 downto 0);
    go            : out std_logic;
    size          : out std_logic_vector(C_ADDR_WIDTH downto 0);
    done          : in  std_logic;
    mem_in_wdata  : out std_logic_vector(C_MEM_IN_WIDTH-1 downto 0);
    mem_in_waddr  : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    mem_in_wen    : out std_logic;
    mem_out_rdata : in  std_logic_vector(C_MEM_OUT_WIDTH-1 downto 0);
    mem_out_raddr : out std_logic_vector(C_ADDR_WIDTH-1 downto 0)
    );
end glue_logic;


architecture bhv of glue_logic is

  signal go_reg   : std_logic;
  signal size_reg : std_logic_vector(C_ADDR_WIDTH downto 0);

  signal dout_direct : std_logic_vector(31 downto 0);
  signal dout_sel    : std_logic;

  constant DOUT_SEL_MEM_OUT : std_logic := '1';
  constant DOUT_SEL_DIRECT  : std_logic := '0';

begin

  process(clk, rst)
    variable temp_addr : unsigned(31 downto 0);
  begin

    if (rst = '1') then
      go_reg      <= '0';
      size_reg    <= std_logic_vector(to_unsigned(0, size_reg'length));
      dout_direct <= std_logic_vector(to_unsigned(0, 32));

      mem_in_wen   <= '0';
      mem_in_waddr <= (others => '0');
      mem_in_wdata <= (others => '0');

    elsif (clk'event and clk = '1') then

      go_reg       <= '0';
      mem_in_wen   <= '0';
      mem_in_waddr <= (others => '0');
      mem_in_wdata <= (others => '0');

      -- if a write
      if (en = '1' and wen = '1') then

        -- write to input memory if address is in appropriate range
        if (unsigned(addr) >= unsigned(C_MEM_IN_START_ADDR) and
            unsigned(addr) <= unsigned(C_MEM_IN_END_ADDR)) then

          -- adjust the address to start at 0
          temp_addr := unsigned(addr) - unsigned(C_MEM_IN_START_ADDR);
          mem_in_waddr <= std_logic_vector(temp_addr(mem_in_waddr'range));
          mem_in_wdata <= din(mem_in_wdata'range);
          mem_in_wen   <= '1';
        end if;

        case addr is
          when C_GO_ADDR   =>
            go_reg   <= din(0);
          when C_SIZE_ADDR =>
            size_reg <= din(size_reg'range);
          when others      => null;
        end case;

      elsif (en = '1' and wen = '0') then

        -- read from output memory if address is in appropriate range
        -- actual read was performed in previous cycle. This statement just
        -- affects whether or not dout is defined by mem_out_rdata or dout_
        -- direct.
        if (unsigned(addr) >= unsigned(C_MEM_OUT_START_ADDR) and
            unsigned(addr) <= unsigned(C_MEM_OUT_END_ADDR)) then
          dout_sel         <= DOUT_SEL_MEM_OUT;
        else
          dout_sel         <= DOUT_SEL_DIRECT;
        end if;

        dout_direct <= (others => '0');

        case addr is
          when C_GO_ADDR   =>
            dout_direct                 <= std_logic_vector(to_unsigned(0, 31)) & go_reg;
          when C_SIZE_ADDR =>
            dout_direct(size_reg'range) <= size_reg;
          when C_DONE_ADDR =>
            dout_direct                 <= std_logic_vector(to_unsigned(0, 31)) & done;
          when others      => null;
        end case;
      end if;
    end if;
  end process;

  go   <= go_reg;
  size <= size_reg;

  -- sends address to output block ram to ensure that if this memory is read,
  -- the result will be available on the next cycle. 
  process(addr)
    variable temp_addr : unsigned(31 downto 0);
  begin
    -- adjust the address to start at 0
    temp_addr := unsigned(addr) - unsigned(C_MEM_OUT_START_ADDR);
    mem_out_raddr <= std_logic_vector(temp_addr(mem_out_raddr'range));
  end process;

  -- mux that defines dout based on where the read data come from
  process(dout_sel, dout_direct, mem_out_rdata)
  begin

    dout <= (others => '0');

    case dout_sel is
      when DOUT_SEL_MEM_OUT =>
        dout(mem_out_rdata'range) <= mem_out_rdata;
      when DOUT_SEL_DIRECT  =>
        dout                      <= dout_direct;
      when others           => null;
    end case;
  end process;
end bhv;
