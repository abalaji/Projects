library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity dual_port_ram is
  generic (
    data_width :     integer := 32;
    addr_width :     integer := 10
    );
  port (
    clk        : in  std_logic;
    -- write port
    wen        : in  std_logic;
    waddr      : in  std_logic_vector(addr_width-1 downto 0);
    wdata      : in  std_logic_vector(data_width-1 downto 0);
    -- read port
    raddr      : in  std_logic_vector(addr_width-1 downto 0);
    rdata      : out std_logic_vector(data_width-1 downto 0)
    );
end entity;

architecture SYNC_READ of dual_port_ram is

  type memory_type is array (natural range <>) of std_logic_vector(data_width-1 downto 0);
  signal memory : memory_type(2**addr_width-1 downto 0);
  signal raddr_reg : std_logic_vector(addr_width-1 downto 0);
  
begin

  process(clk)
  begin
    if clk'event and clk = '1' then
      if wen = '1' then
        memory(to_integer(unsigned(waddr))) <= wdata;
      end if;

      raddr_reg <= raddr;
    end if;
  end process;

  rdata <= memory(to_integer(unsigned(raddr_reg)));

end SYNC_READ;

