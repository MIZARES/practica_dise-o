-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-------------------------------------------------------------------------------

entity cnt_display_tb is

end cnt_display_tb;

-------------------------------------------------------------------------------

architecture sim of cnt_display_tb is


  signal   CLK_i     : std_logic                     := '0';
  signal   RST_i     : std_logic;
  signal   BCD_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal   BCD_OK_i  : std_logic                     := '0';
  signal   AND_70_i  : std_logic_vector(7 downto 0);
  signal   DP_i      : std_logic;
  signal   SEG_AG_i  : std_logic_vector(6 downto 0);
  --constant T         : time                          :=5ms ;  -- Completar
  constant T         : time                          :=5us ;  -- Completar
  signal   D_BCD     : std_logic_vector(3 downto 0);
  signal   D_DISPLAY : std_logic_vector(15 downto 0);

begin  -- sim

  DUT : entity work.cnt_display
    port map (
      CLK    => CLK_i,
      RST    => RST_i,
      BCD    => BCD_i,
      BCD_OK => BCD_OK_i,
      AND_70 => AND_70_i,
      DP     => DP_i,
      SEG_AG => SEG_AG_i);

  RST_i <= '1', '0'  after 233 ns;
  CLK_i <= not CLK_i after 5 ns;
  
-- Generación del dato BCD
  process
    procedure gen_dato(dato_bcd : std_logic_vector ) is
    begin
      wait until CLK_i = '0';
      BCD_i    <= dato_bcd;
      BCD_OK_i <= '1';
      wait until CLK_i = '0';
      BCD_OK_i <= '0';
      wait for T;
    end gen_dato;
  begin  -- process
    wait for 333 ns;
    gen_dato(x"2550");
    gen_dato(x"1234");
    gen_dato(x"0987");
    gen_dato(x"1092");
    gen_dato(x"8745");
    gen_dato(x"5678");
    gen_dato(x"56AA");
    gen_dato(x"CD12");
    report "fin de la simulacion" severity failure;

  end process;

-- Visualización del dato visualizado en los displays

  with SEG_AG_i select
    D_BCD <= x"0"when "1000000",  --0   --gfedcba
    x"1" when"1111001",                 --1
    x"2"when"0100100",                  --2
    x"3"when"0110000",                  --3
    x"4"when"0011001",                  --4
    x"5"when "0010010",                 --5
    x"6"when "0000010",                 --6
    x"7"when "1111000",                 --7
    x"8"when "0000000",                 --8
    x"9"when "0011000",                 --9
    "----"when "0111111",               --(-)
    x"F" when "0001110",                --(F)
    x"A" when others;


  process (CLK_i, RST_i)
  begin  -- process
    if RST_i = '1' then
      D_DISPLAY<= (others => '0');
    elsif CLK_i'event and CLK_i = '1' then
      case AND_70_i is
        when "11111110"=> D_DISPLAY(3 downto 0)   <= D_BCD;
        when "11111101"=> D_DISPLAY(7 downto 4)   <= D_BCD;
        when "11111011"=> D_DISPLAY(11 downto 8)  <= D_BCD;
        when "11110111"=> D_DISPLAY(15 downto 12) <= D_BCD;
        when others=> null;
      end case;
    end if;
  end process;


end sim;

-------------------------------------------------------------------------------
