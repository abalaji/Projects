-- Greg Stitt
-- University of Florida
-- EEL 5934/4930 Reconfigurable Computing
--
-- File: datapath.vhd
--
-- Description: This file implements the datapath for the Fibonacci
-- calculator.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  generic (width :     positive := 32);
  port(clk, rst  : in  std_logic;
       n         : in  std_logic_vector(width-1 downto 0);
       result    : out std_logic_vector(width-1 downto 0);

       -- control signals
       i_sel, x_sel, y_sel               : in  std_logic;
       i_ld, x_ld, y_ld, n_ld, result_ld : in  std_logic;
       i_le_n                            : out std_logic );
end datapath;

architecture str of datapath is

  component reg
    generic (width    :     positive := 32);
    port(clk, rst, en : in  std_logic;
         input        : in  std_logic_vector(width-1 downto 0);
         output       : out std_logic_vector(width-1 downto 0));
  end component;

  component mux_2_1
    generic (width       :     positive := 32);
    port( input1, input2 : in  std_logic_vector(width-1 downto 0);
          sel            : in  std_logic;
          output         : out std_logic_vector(width-1 downto 0));
  end component;

  component le
    generic (width       :     positive := 32);
    port( input1, input2 : in  std_logic_vector(width-1 downto 0);
          le             : out std_logic );
  end component;

  component add
    generic (width       :     positive := 32);
    port( input1, input2 : in  std_logic_vector(width-1 downto 0);
          output         : out std_logic_vector(width-1 downto 0) );
  end component;

  signal mux_i_out, mux_x_out, mux_y_out            : std_logic_vector(width-1 downto 0);
  signal reg_i_out, reg_x_out, reg_y_out, reg_n_out : std_logic_vector(width-1 downto 0);
  signal add1_out, add2_out                         : std_logic_vector(width-1 downto 0);

  constant C1 : std_logic_vector(width-1 downto 0) := std_logic_vector(to_unsigned(1, width));
  constant C3 : std_logic_vector(width-1 downto 0) := std_logic_vector(to_unsigned(3, width));

begin

  -- instantiate the muxes
  U_MUX_I : mux_2_1 generic map (width) port map (C3, add1_out, i_sel, mux_i_out);
  U_MUX_X : mux_2_1 generic map (width) port map (C1, reg_y_out, x_sel, mux_x_out);
  U_MUX_Y : mux_2_1 generic map (width) port map (C1, add2_out, y_sel, mux_y_out);

  --instantiate the registers
  U_REG_I : reg generic map (width) port map (clk, rst, i_ld, mux_i_out, reg_i_out);
  U_REG_X : reg generic map (width) port map (clk, rst, x_ld, mux_x_out, reg_x_out);
  U_REG_Y : reg generic map (width) port map (clk, rst, y_ld, mux_y_out, reg_y_out);
  U_REG_N : reg generic map (width) port map (clk, rst, n_ld, n, reg_n_out);
  U_REG_R : reg generic map (width) port map (clk, rst, result_ld, reg_y_out, result);

  -- instantiate the adders
  U_ADD1 : add generic map (width) port map (reg_i_out, C1, add1_out);
  U_ADD2 : add generic map (width) port map (reg_x_out, reg_y_out, add2_out);

  -- instantiate the less than/equal to comparator
  U_LE1 : le generic map (width) port map (reg_i_out, reg_n_out, i_le_n);

end str;
