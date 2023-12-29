library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity voltimetro is
  port (  
    CLK    : in std_logic;
    RST    : in std_logic;
    SDATA  : in std_logic;
    CS     : out std_logic;
    SCLK   : out std_logic;
    AND_30 : out std_logic_vector(3 downto 0);
    DP     : out std_logic;
    SEG_AG : out std_logic_vector(6 downto 0)); 
end voltimetro;

architecture RTL of voltimetro is
  signal DATA    : std_logic_vector(11 downto 0);
  signal DATA_OK : std_logic;
  signal VM_OK   : std_logic;
  signal V_MED   : std_logic_vector( 11 downto 0);
  signal BCD     : std_logic_vector( 15 downto 0);
  signal BCD_OK  : std_logic;
begin  -- RTL

  U_cnt_AD7476A : entity work.cnt_AD7476A
    port map (
      CLK     => CLK,
      RST     => RST,
      SDATA   => SDATA,
      CS      => CS,
      SCLK    => SCLK,
      DATA    => DATA,
      DATA_OK => DATA_OK);
  U_media  : entity work.media_movil
    port map (
      clk     => clk,
      rst     => rst,
      DATA_OK => DATA_OK,
      DATA    => DATA,
      VM_OK   => VM_OK,
      V_MED   => V_MED);
  U_bin2bcd     : entity work.bin2bcd
    port map (
      clk     => clk,
      rst     => rst,
      VM_OK   => VM_OK,
      V_MED   => V_MED,
      BCD_OK  => BCD_OK,
    BCD       => BCD);

  U_cnt_display : entity work.cnt_display
    port map (
      CLK      => CLK,
      RST      => RST,
      BCD => BCD,
      BCD_OK   => BCD_OK,
      AND_30   => AND_30,
      DP       => DP,
      SEG_AG   => SEG_AG);
  
 
end RTL;