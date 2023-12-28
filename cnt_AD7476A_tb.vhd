-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
-------------------------------------------------------------------------------

entity cnt_AD7476A_tb is
end cnt_AD7476A_tb;

-------------------------------------------------------------------------------

architecture sim of cnt_AD7476A_tb is

  signal   VIN_i     : real range 0.0 to 3.5 := 1.1;
  signal   CLK_i     : std_logic             := '0';
  signal   RST_i     : std_logic             := '1';
  signal   SDATA_i   : std_logic;
  signal   CS_i      : std_logic;
  signal   SCLK_i    : std_logic;
  signal   DATA_i    : std_logic_vector(11 downto 0);
  signal   DATA_OK_i : std_logic;
  constant T_signal  : time      ;  -- completar


begin  -- sim

  U0 : entity work.AD7476A
    port map (
      VIN   => VIN_i,
      CS    => CS_i,
      SCLK  => SCLK_i,
      SDATA => SDATA_i);

  DUT : entity work.cnt_AD7476A
    port map (
      CLK     => CLK_i,
      RST     => RST_i,
      SDATA   => SDATA_i,
      CS      => CS_i,
      SCLK    => SCLK_i,
      DATA    => DATA_i,
      DATA_OK => DATA_OK_i);

  CLK_i <= not CLK_i after 5 ns;

  RST_i <= '0' after 133 ns;

  process
    procedure gen_vin(V_in : real) is
    begin
      VIN_i <= V_in;
      wait for T_signal;
    end gen_vin;
  begin
    wait until RST_i = '0';
    gen_vin(3.0);
    gen_vin(3.2);
    gen_vin(1.5);
    gen_vin(0.8);
    gen_vin(1.0);
    report "FIN CONTROLADO DE LA SIMULACION" severity failure;
  end process;
  
end sim;

-------------------------------------------------------------------------------
