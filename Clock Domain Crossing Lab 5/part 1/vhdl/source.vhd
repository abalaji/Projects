-- Greg Stitt
-- University of Florida

-- This entity generates "iterations" number of pulses on "output". It is
-- basically a clock divider that produces a clock with a period
-- clk_in_freq/clk_out_freq times slower than the provided clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity source is
  generic(clk_in_freq      :     natural;
          clk_out_freq     :     natural;
          iterations_width :     natural);
  port (
    clk                    : in  std_logic;
    rst                    : in  std_logic;
    iterations             : in  std_logic_vector(iterations_width-1 downto 0);
    go                     : in  std_logic;
    done                   : out std_logic;
    output                 : out std_logic);
end source;

architecture BHV of source is

  type STATE_TYPE is (S_INIT, S_CHECK_DONE, S_SET, S_CLEAR, S_DONE);
  signal state : STATE_TYPE;
  
  constant RATIO : integer := integer(ceil(real(clk_in_freq/clk_out_freq)));

  signal count          : integer range 0 to RATIO;
  signal iteration      : unsigned(iterations_width-1 downto 0);
  signal iterations_reg : unsigned(iterations_width-1 downto 0);
  signal output_s       : std_logic;

begin  -- BHV

  process (clk, rst)
  begin
    if (rst = '1') then

      count          <= 0;
      iteration      <= (others => '0');
      iterations_reg <= (others => '0');
      output_s       <= '0';
      done           <= '0';

    elsif (clk'event and clk = '1') then

      output_s <= '0';

      case state is
        when S_INIT =>

          iteration <= to_unsigned(0, iterations_width);

          if (go = '1') then
            iterations_reg <= unsigned(iterations);
            done           <= '0';
            state          <= S_CHECK_DONE;
          end if;

        when S_CHECK_DONE =>

          count <= 0;

          if (iteration = iterations_reg) then
            state <= S_DONE;
          else
            state <= S_SET;
          end if;       
          
        when S_SET =>

          output_s <= '1';
          count    <= count + 1;

          if (count = RATIO-1) then
            count <= 0;
            state <= S_CLEAR;
          end if;

        when S_CLEAR =>

          output_s <= '0';
          count    <= count + 1;

          if (count = RATIO-1) then
            iteration <= iteration + 1;
            state     <= S_CHECK_DONE;
          end if;

        when S_DONE =>

          done  <= '1';
          state <= S_INIT;

        when others => null;
      end case;
    end if;
  end process;

  output <= output_s;

end BHV;

