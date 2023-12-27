library ieee;
use ieee.std_logic_1164.all;


entity test_bin2bcd is
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    SW_OK  : in  std_logic;
    SW     : in  std_logic_vector(11 downto 0);
    AND_70 : out std_logic_vector(7 downto 0);
    DP     : out std_logic;
    SEG_AG : out std_logic_vector(6 downto 0));
end test_bin2bcd;

architecture RTL of test_bin2bcd is
  signal Q      : std_logic;
  signal VM_OK  : std_logic;
  signal BCD    : std_logic_vector( 15 downto 0);
  signal BCD_OK : std_logic;
begin  -- RTL

  process (CLK, RST)
  begin
    if RST = '1' then
      Q     <= '0';
      VM_OK <= '0';
    elsif CLK'event and CLK = '1' then
      Q     <= SW_OK;
      VM_OK <= (not Q) and SW_OK;
    end if;
  end process;


  U_bin2bcd : entity work.bin2bcd
    port map (
      clk    => clk,
      rst    => rst,
      VM_OK  => VM_OK,
      V_MED  => SW,
      BCD_OK => BCD_OK,
      BCD    => BCD);

  U_cnt_display : entity work.cnt_display
    port map (
      CLK    => CLK,
      RST    => RST,
      BCD    => BCD,
      BCD_OK => BCD_OK,
      AND_70 => AND_70,
      DP     => DP,
      SEG_AG => SEG_AG);
end RTL;
