-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity bin2bcd_tb is

end bin2bcd_tb;

-------------------------------------------------------------------------------

architecture sim of bin2bcd_tb is


  signal clk_i   : std_logic                      := '0';
  signal rst_i   : std_logic                      := '1';
  signal VM_OK_i : std_logic                      := '0';
  signal V_MED_i : std_logic_vector( 11 downto 0) := (others => '0');

  signal BCD_i    : std_logic_vector( 15 downto 0);
  signal BCD_OK_i : std_logic := '0';
begin  -- sim

  DUT : entity work.bin2bcd
    port map (
      clk    => clk_i,
      rst    => rst_i,
      VM_OK  => VM_OK_i,
      V_MED  => V_MED_i,
      BCD_OK => BCD_OK_i,
      BCD    => BCD_i);

  rst_i <= '0'       after 266 ns;
  clk_i <= not clk_i after 5 ns;

  process
    procedure gen_dato(dato_intg : integer) is
    begin

      wait until CLK_i = '0';
      V_MED_i <= std_logic_vector(to_unsigned(dato_intg, 12));
      VM_OK_i <= '1';
      wait until CLK_i = '0';
      VM_OK_i <= '0';
      wait until BCD_OK_i = '1';
      wait for 63 us;

    end gen_dato;

  begin  -- process

    wait for 333 ns;
    gen_dato(2550);
    gen_dato(1348);
    gen_dato(3678);
    gen_dato(2808);
    gen_dato(182);
    gen_dato(3300);
    gen_dato(1095);

    report "fin de la simulacion" severity failure;
  end process;


end sim;

-------------------------------------------------------------------------------
