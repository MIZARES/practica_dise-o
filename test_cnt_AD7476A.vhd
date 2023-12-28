library ieee;
use ieee.std_logic_1164.all;


entity test_cnt_AD7476A is
  port (
    CLK   : in  std_logic;
    RST   : in  std_logic;
    SDATA : in  std_logic;
    CS    : out std_logic;
    SCLK  : out std_logic;
    leds  : out std_logic_vector(11 downto 0));
end test_cnt_AD7476A;

architecture RTL of test_cnt_AD7476A is
  signal DATA_OK : std_logic;
   signal   DATA          : std_logic_vector(11 downto 0);
begin  -- RTL

  U1 : entity work.cnt_AD7476A
    port map (
      CLK     => CLK,
      RST     => RST,
      SDATA   => SDATA,
      CS      => CS,
      SCLK    => SCLK,
      DATA    => DATA,
      DATA_OK => DATA_OK);

  process (CLK, RST)
  begin
    if RST = '1' then
      leds   <= (others => '0');
    elsif CLK'event and CLK = '1' then
      if (DATA_OK = '1') then
        leds <= DATA;
      end if;
    end if;
  end process;

end RTL;
