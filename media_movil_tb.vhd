-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use ieee.math_real.all;
-------------------------------------------------------------------------------
entity media_movil_tb is

end media_movil_tb;

-------------------------------------------------------------------------------
architecture sim of media_movil_tb is

  signal clk_i     : std_logic                      := '0';
  signal rst_i     : std_logic                      := '1';
  signal DATA_OK_i : std_logic                      := '0';
  signal DATA_i    : std_logic_vector( 11 downto 0) := (others => '0');

  signal VM_OK_i      : std_logic;
  signal V_MED_i      : std_logic_vector( 11 downto 0);
  signal valor, ruido : integer := 3;   -- señales para visualizar la tensión medida en mV

begin  -- sim

  DUT : entity work.media_movil
    port map (
      clk     => clk_i,
      rst     => rst_i,
      DATA_OK => DATA_OK_i,
      DATA    => DATA_i,
      VM_OK   => VM_OK_i,
      V_MED   => V_MED_i);


  rst_i <= '0'       after 266 ns;
  clk_i <= not clk_i after 5 ns;

  process
    procedure gen_dato(dato_intg, N_data : integer) is
-- dato_intg: tensión medida en mV
--N_data: Nº veces repite la medida.
      variable seed1, seed2              : positive;
      variable rand                      : real;
      variable int_rand                  : integer;
    begin
      valor       <= dato_intg;
      for j in 1 to N_data loop
        wait until CLK_i = '0';
        uniform(seed1, seed2, rand);
        int_rand := integer(trunc(rand*20.0))-10;
        ruido     <= int_rand;
        DATA_i    <= std_logic_vector(to_unsigned((dato_intg+int_rand), DATA_i'length));
        DATA_OK_i <= '1';
        wait until CLK_i = '0';
        DATA_OK_i <= '0';
        wait for 77 ns;
      end loop;  -- j
      wait for 200 ns;
    end gen_dato;

  begin  -- process
    wait for 333 ns;
    gen_dato(255, 80);
    gen_dato(12, 80);
    gen_dato(1999, 90);
    gen_dato(2095, 100);

    report "fin de la simulacion" severity failure;
  end process;

end sim;


-------------------------------------------------------------------------------
