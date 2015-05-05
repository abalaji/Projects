library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity addr_gen_out is
  generic(width :     positive);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    size        : in  std_logic_vector(width downto 0);
    go          : in  std_logic;
    en          : in  std_logic;
    addr        : out std_logic_vector(width-1 downto 0);
    wen         : out std_logic;
    done        : out std_logic);
end addr_gen_out;

architecture BHV of addr_gen_out is

  type state_type is (S_INIT, S_CHECK_DONE, S_WAIT_FOR_ONE, S_WAIT_FOR_ZERO,
                      S_DONE, S_RESTART);
  signal state, next_state    : state_type;
  signal size_reg, next_size_reg : unsigned(width downto 0);
  signal addr_s, next_addr_s   : std_logic_vector(width downto 0);

begin  -- BHV

  process (clk, rst)
  begin
    if (rst = '1') then

      addr_s   <= (others => '0');
      size_reg <= (others => '0');
      state    <= S_INIT;

    elsif (clk'event and clk = '1') then

      addr_s   <= next_addr_s;
      size_reg <= next_size_reg;
      state    <= next_state;
    end if;
  end process;

  process(state, addr_s, size_reg, go, en, size)
  begin

    next_size_reg <= size_reg;
    next_addr_s   <= addr_s;
    next_state    <= state;
    done          <= '0';
    wen           <= '0';

    case state is
      when S_INIT =>

        next_addr_s <= std_logic_vector(to_unsigned(0, width+1));

        if (go = '1') then
          next_size_reg <= unsigned(size);
          next_state    <= S_CHECK_DONE;
        end if;

      when S_RESTART =>

        next_addr_s <= std_logic_vector(to_unsigned(0, width+1));
        done        <= '1';

        if (go = '1') then
          done          <= '0';
          next_size_reg <= unsigned(size);
          next_state    <= S_CHECK_DONE;
        end if;

      when S_CHECK_DONE =>

        if (unsigned(addr_s) = size_reg) then
          next_state <= S_DONE;
        else
          next_state <= S_WAIT_FOR_ONE;
        end if;

      when S_WAIT_FOR_ONE =>

        if (en = '1') then
          next_addr_s     <= std_logic_vector(unsigned(addr_s)+1);
          wen        <= '1';            -- no register on purpose
          next_state <= S_WAIT_FOR_ZERO;
        end if;

      when S_WAIT_FOR_ZERO =>

        if (en = '0') then
          next_state <= S_CHECK_DONE;
        end if;

      when S_DONE =>

        done       <= '1';
        next_state <= S_RESTART;

      when others => null;
    end case;
  end process;

  addr <= addr_s(width-1 downto 0);

end BHV;

