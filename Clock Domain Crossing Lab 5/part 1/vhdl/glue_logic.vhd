-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.user_pkg.all;

entity glue_logic is
  port(
    clk        : in  std_logic;
    rst        : in  std_logic;
    addr       : in  std_logic_vector(31 downto 0);
    en         : in  std_logic;
    wen        : in  std_logic;
    din        : in  std_logic_vector(31 downto 0);
    dout       : out std_logic_vector(31 downto 0);
    go         : out std_logic;
    iterations : out std_logic_vector(31 downto 0);
    count      : in  std_logic_vector(31 downto 0);
    done       : in  std_logic
    );
end glue_logic;

architecture bhv of glue_logic is

  signal reg_go         : std_logic;
  signal reg_iterations : std_logic_vector(31 downto 0);

begin

  process(clk, rst) is
  begin

    if (rst = '1') then
      reg_go <= '0';
      reg_iterations  <= std_logic_vector(to_unsigned(0, 32));
      dout   <= std_logic_vector(to_unsigned(0, 32));

    elsif (clk'event and clk = '1') then

      reg_go <= '0';
      
      -- if a write
      if (en = '1' and wen = '1') then

        case addr is
          when C_GO_ADDR =>
            reg_go <= din(0);
          when C_ITERATIONS_ADDR  =>
            reg_iterations  <= din;

            -- count and done are read only
          when others => null;
        end case;

        -- if a read
      elsif (en = '1' and wen = '0') then

        case addr is
          when C_GO_ADDR    =>
            dout <= std_logic_vector(to_unsigned(0, 31)) & reg_go;
          when C_ITERATIONS_ADDR     =>
            dout <= reg_iterations;
          when C_COUNT_ADDR =>
            dout <= count;
          when C_DONE_ADDR  =>
            dout <= std_logic_vector(to_unsigned(0, 31)) & done;

          when others => null;
        end case;
      end if;

    end if;
  end process;

  go <= reg_go;
  iterations <= reg_iterations;

end bhv;
