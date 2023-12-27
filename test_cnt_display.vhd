library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity test_cnt_display is
  port ( CLK    : in  std_logic;
         RST    : in  std_logic;
         SW_OK  : in  std_logic;
         SW     : in  std_logic_vector (15 downto 0);
         SEG_AG : out std_logic_vector (6 downto 0);
         AND_70 : out std_logic_vector (7 downto 0);
         DP     : out std_logic);
end test_cnt_display;

architecture Behavioral of test_cnt_display is
  signal SW_OK_REG, LOAD : std_logic;

begin
  process (CLK, RST)
  begin
    if RST = '1' then
      LOAD      <= '0';
      SW_OK_REG <= '0';
    elsif CLK'event and CLK = '1' then
      SW_OK_REG <= SW_OK;
      LOAD      <= (not SW_OK_REG) and SW_OK;
    end if;
  end process;


  U_DISPLAY : entity work.cnt_display
    port map (
      CLK    => CLK,
      RST    => RST,
      BCD    => SW,
      BCD_OK => LOAD,
      AND_70 => AND_70,
      DP     => DP,
      SEG_AG => SEG_AG);
end Behavioral;
