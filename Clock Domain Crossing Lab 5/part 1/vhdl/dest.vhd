-- Greg Stitt
-- University of Florida

-- This entity counts the number of times "input" transitions from 0 to 1.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dest is
  generic(width :     natural);
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    input          : in  std_logic;
    output      : out std_logic_vector(width-1 downto 0));
end dest;

architecture BHV of dest is

  type state_type is (S_ZERO, S_ONE);
  signal state : state_type;  
  signal count : unsigned(width-1 downto 0);

begin  -- BHV

  process (clk, rst)
  begin
    if (rst = '1') then

      state <= S_ZERO;
      count <= to_unsigned(0, width);

    elsif (clk'event and clk = '1') then

      case state is
        when S_ZERO =>
          if (input = '1') then
            count <= count + 1;
            state <= S_ONE;
          end if;
          
        when S_ONE =>
          if (input = '0') then
            state <= S_ZERO;
          end if;
          
        when others => null;
      end case;


    end if;
  end process;

  output <= std_logic_vector(count);

end BHV;

