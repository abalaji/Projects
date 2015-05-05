-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: fib.vhd
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib is
  generic (width :     positive := 32);
  port( clk      : in  std_logic;
        rst      : in  std_logic;
        go       : in  std_logic;
        n        : in  std_logic_vector(width-1 downto 0);
        result   : out std_logic_vector(width-1 downto 0);
        done     : out std_logic );
end fib;

architecture FSMD_1P of fib is

  type STATE_TYPE is (START, WAIT_1, INIT, LOOP_COND,
                      LOOP_BODY, OUTPUT_RESULT);
  signal state : STATE_TYPE;

  signal n_reg   : unsigned(width-1 downto 0);
  signal i, x, y : unsigned(width-1 downto 0);
  
begin

  -- state register
  process (clk, rst)
  begin
    if (rst = '1') then
      state  <= START;
      done   <= '0';
      result <= (others => '0');
      n_reg  <= to_unsigned(0, width);
      i      <= to_unsigned(0, width);
      x      <= to_unsigned(0, width);
      y      <= to_unsigned(0, width);
     
    elsif (clk = '1' and clk'event) then

      case state is
        when START =>

          done <= '0';

          if (go = '0') then
            state <= WAIT_1;
          end if;

        when WAIT_1 =>

          if (go = '1') then
            done <= '0';
            state <= INIT;
          end if;

        when INIT =>

          n_reg <= unsigned(n);
          i     <= to_unsigned(3, width);
          x     <= to_unsigned(1, width);
          y     <= to_unsigned(1, width);

          state <= LOOP_COND;

        when LOOP_COND =>

          if (i   <= n_reg) then
            state <= LOOP_BODY;
          else
            state <= OUTPUT_RESULT;
          end if;

        when LOOP_BODY =>

          x <= y;
          y <= x+y;
          i <= i+1;

          state <= LOOP_COND;

        when OUTPUT_RESULT =>

          result <= std_logic_vector(y);
          done   <= '1';

          if (go = '0') then
            state <= WAIT_1;
          end if;

        when others => null;
      end case;

    end if;
  end process;
end FSMD_1P;


architecture FSMD_2P of fib is
  type STATE_TYPE is (START, WAIT_1, INIT, LOOP_COND,
                      LOOP_BODY, OUTPUT_RESULT);
  signal state, next_state : STATE_TYPE;

  signal n_s, next_n_s           : unsigned(width-1 downto 0);
  signal i, next_i               : unsigned(width-1 downto 0);
  signal x, next_x               : unsigned(width-1 downto 0);
  signal y, next_y               : unsigned(width-1 downto 0);
  signal result_s, next_result_s : std_logic_vector(width-1 downto 0);
  signal done_s, next_done_s     : std_logic;

begin

  process (clk, rst)
  begin
    if (rst = '1') then
      state    <= START;
      n_s      <= to_unsigned(0, width);
      i        <= to_unsigned(0, width);
      x        <= to_unsigned(0, width);
      y        <= to_unsigned(0, width);
      done_s   <= '0';
      result_s <= (others => '0');
    elsif (clk = '1' and clk'event) then
      state    <= next_state;
      n_s      <= next_n_s;
      i        <= next_i;
      x        <= next_x;
      y        <= next_y;
      done_s   <= next_done_s;
      result_s <= next_result_s;
    end if;
  end process;

  process(go, n, state, n_s, i, x, y, done_s, result_s)
  begin

    next_state    <= state;
    next_n_s      <= n_s;
    next_i        <= i;
    next_x        <= x;
    next_y        <= y;
    next_done_s   <= done_s;
    next_result_s <= result_s;

    case state is
      when START =>

        next_done_s <= '0';

        if (go = '0') then
          next_state <= WAIT_1;
        end if;

      when WAIT_1 =>

        if (go = '1') then
          next_done_s <= '0';
          next_state <= INIT;
        end if;

      when INIT =>

        next_n_s <= unsigned(n);
        next_i   <= to_unsigned(3, width);
        next_x   <= to_unsigned(1, width);
        next_y   <= to_unsigned(1, width);

        next_state <= LOOP_COND;

      when LOOP_COND =>

        if (i        <= n_s) then
          next_state <= LOOP_BODY;
        else
          next_state <= OUTPUT_RESULT;
        end if;

      when LOOP_BODY =>

        next_x <= y;
        next_y <= x+y;
        next_i <= i+1;

        next_state <= LOOP_COND;

      when OUTPUT_RESULT =>

        next_result_s <= std_logic_vector(y);
        next_done_s   <= '1';

        if (go = '0') then
          next_state <= WAIT_1;
        end if;

      when others => null;
    end case;
  end process;

  done   <= done_s;
  result <= result_s;

end FSMD_2P;


architecture FSM_D of fib is

  signal i_sel, x_sel, y_sel               : std_logic;
  signal i_ld, x_ld, y_ld, n_ld, result_ld : std_logic;
  signal i_le_n                            : std_logic;
begin

  CTR1 : entity work.ctrl
    port map (clk, rst, go, done,
              i_sel, x_sel, y_sel,
              i_ld, x_ld, y_ld, n_ld, result_ld,
              i_le_n);

  DP1 : entity work.datapath
    generic map (width)
    port map (clk, rst, n, result,
              i_sel, x_sel, y_sel,
              i_ld, x_ld, y_ld, n_ld, result_ld,
              i_le_n);

end FSM_D;
