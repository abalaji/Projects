library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity addr_gen_in is
  generic(width :     positive);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    size        : in  std_logic_vector(width downto 0);
    go          : in  std_logic;
    send        : out std_logic;
    received    : in  std_logic;
    addr        : out std_logic_vector(width-1 downto 0));
end addr_gen_in;

architecture BHV of addr_gen_in is

  type state_type is (S_INIT, S_CHECK_DONE, S_SEND, S_WAIT_FOR_ACK);
  signal state : state_type;

  signal size_reg  : unsigned(width downto 0);
  signal addr_s    : std_logic_vector(width downto 0);

begin  -- BHV

  process (clk, rst)
  begin
    if (rst = '1') then

      addr_s   <= (others => '0');
      size_reg <= (others => '0');
      send <= '0';
      state    <= S_INIT;

    elsif (clk'event and clk = '1') then

      case state is
        when S_INIT =>

          addr_s <= std_logic_vector(to_unsigned(0, width+1));

          if (go = '1') then
            size_reg <= unsigned(size);
            state    <= S_CHECK_DONE;
          end if;

        when S_CHECK_DONE =>

          if (unsigned(addr_s) = size_reg) then
            state <= S_INIT;
          else

            state <= S_SEND;
          end if;

        when S_SEND =>

          send  <= '1';
          state <= S_WAIT_FOR_ACK;

        when S_WAIT_FOR_ACK =>

          send <= '0';

          if (received = '1') then
            addr_s <= std_logic_vector(unsigned(addr_s)+1);
            state  <= S_CHECK_DONE;
          end if;

        when others => null;
      end case;
    end if;
  end process;

  addr <= addr_s(width-1 downto 0);

end BHV;

